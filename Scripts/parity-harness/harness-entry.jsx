// Browser-side harness: renders real @paper-design/shaders-react components and
// reads back raw RGBA pixels. Bundled by generate-goldens.mjs with esbuild and
// injected into a Playwright page.
import React from "react";
import { createRoot } from "react-dom/client";
import * as ShadersReact from "@paper-design/shaders-react";
import { getShaderColorFromString, ShaderFitOptions } from "@paper-design/shaders";

// Exposed so the Node driver resolves colors/enums with the actual library
// implementations instead of re-implementing them.
window.resolveColor = (value) => Array.from(getShaderColorFromString(value));
window.shaderFitValue = (fit) => ShaderFitOptions[fit];

window.glInfo = () => {
  const canvas = document.createElement("canvas");
  const gl = canvas.getContext("webgl2");
  const debug = gl.getExtension("WEBGL_debug_renderer_info");
  const renderer = debug ? gl.getParameter(debug.UNMASKED_RENDERER_WEBGL) : gl.getParameter(gl.RENDERER);
  gl.getExtension("WEBGL_lose_context")?.loseContext();
  return String(renderer);
};

function waitForMount(host, width, height, needsImage, timeoutMs = 15000) {
  return new Promise((resolve, reject) => {
    const started = performance.now();
    const poll = () => {
      const el = host.firstElementChild;
      const mount = el && el.paperShaderMount;
      const canvas = mount && mount.canvasElement;
      // The ResizeObserver sizes the canvas asynchronously after mount, so wait
      // for the exact target dimensions, not just a non-empty canvas.
      const sized = canvas && canvas.width === width && canvas.height === height;
      // The react wrapper awaits image loading before constructing the mount,
      // so mount existence implies the image uniform is an HTMLImageElement —
      // checked defensively via the mount's stored uniforms.
      const imageReady = !needsImage || mount?.providedUniforms?.u_image instanceof HTMLImageElement;
      if (mount && sized && imageReady) {
        resolve(mount);
      } else if (performance.now() - started > timeoutMs) {
        const size = canvas ? `${canvas.width}x${canvas.height}` : "no canvas";
        reject(new Error(`Timed out waiting for shader mount (canvas: ${size}, imageReady: ${imageReady})`));
      } else {
        requestAnimationFrame(poll);
      }
    };
    poll();
  });
}

function base64FromBytes(bytes) {
  let binary = "";
  const chunk = 0x8000;
  for (let i = 0; i < bytes.length; i += chunk) {
    binary += String.fromCharCode.apply(null, bytes.subarray(i, i + chunk));
  }
  return btoa(binary);
}

window.renderCase = async ({ component, params, frame, width, height, imageDataUrl }) => {
  const Component = ShadersReact[component];
  if (!Component) throw new Error(`Unknown component: ${component}`);

  const host = document.createElement("div");
  host.style.width = `${width}px`;
  host.style.height = `${height}px`;
  document.body.appendChild(host);
  const root = createRoot(host);

  try {
    const props = {
      ...params,
      speed: 0,
      frame,
      minPixelRatio: 1,
      webGlContextAttributes: { antialias: false, preserveDrawingBuffer: true },
      width,
      height,
    };
    if (imageDataUrl) props.image = imageDataUrl;

    root.render(React.createElement(Component, props));
    const mount = await waitForMount(host, width, height, Boolean(imageDataUrl));
    const canvas = mount.canvasElement;

    const gl = canvas.getContext("webgl2");
    // GL dithering (on by default) adds driver-dependent noise to the framebuffer.
    gl.disable(gl.DITHER);
    // Synchronous deterministic render (ShaderMount.setFrame renders immediately).
    mount.setFrame(frame);

    const raw = new Uint8Array(width * height * 4);
    gl.readPixels(0, 0, width, height, gl.RGBA, gl.UNSIGNED_BYTE, raw);

    // readPixels rows are bottom-up; Metal captures are top-down.
    const flipped = new Uint8Array(raw.length);
    const rowBytes = width * 4;
    for (let y = 0; y < height; y++) {
      flipped.set(raw.subarray(y * rowBytes, (y + 1) * rowBytes), (height - 1 - y) * rowBytes);
    }

    return { base64: base64FromBytes(flipped), width, height };
  } finally {
    root.unmount();
    host.remove();
  }
};

window.__harnessReady = true;
