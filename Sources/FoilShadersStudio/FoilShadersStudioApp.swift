import AppKit
@_spi(Studio) import FoilShaders
import ImageIO
import Metal
import SwiftUI
import UniformTypeIdentifiers

@main
struct FoilShadersStudioApp: App {
  var body: some Scene {
    WindowGroup("Foil Shader Studio") {
      StudioView()
    }
    .defaultSize(width: 1180, height: 760)
  }
}

private struct StudioView: View {
  @State private var selectedShader: StudioShader = .meshGradient
  @State private var presetIndexByShader: [StudioShader: Int] = [:]
  @State private var speed: Float = 0.25
  @State private var frame: Float = 0
  @State private var scale: Float = 1
  @State private var rotation: Float = 0
  @State private var offsetX: Float = 0
  @State private var offsetY: Float = 0
  @State private var selectedImage: ShaderImage?
  @State private var didCopyCode = false
  @State private var copyFeedbackID = UUID()

  var body: some View {
    NavigationSplitView {
      List(StudioShader.allCases, selection: $selectedShader) { shader in
        Text(shader.displayName)
          .tag(shader)
      }
      .navigationTitle("Shaders")
      .navigationSplitViewColumnWidth(min: 180, ideal: 240, max: 320)
    } detail: {
      HSplitView {
        previewPane
          .frame(minWidth: 300)
          .layoutPriority(1)

        inspectorPane
          .frame(minWidth: 280, idealWidth: 380, maxWidth: 520)
      }
      .navigationTitle(selectedShader.displayName)
    }
  }

  private var previewPane: some View {
    GeometryReader { proxy in
      let availableSize = CGSize(
        width: max(1, proxy.size.width - 32),
        height: max(1, proxy.size.height - 32)
      )
      let previewSize = fittedPreviewSize(in: availableSize)

      FoilShadersShaderView(configuration: previewConfiguration(size: previewSize))
        .frame(width: previewSize.width, height: previewSize.height)
        .background(.black.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contextMenu {
          Button("Copy Image", systemImage: "doc.on.clipboard") {
            copyPreviewImage(size: previewSize)
          }
          Button("Save Image...", systemImage: "square.and.arrow.down") {
            savePreviewImage(size: previewSize)
          }
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
    }
    .frame(minWidth: 300, minHeight: 240)
  }

  private var inspectorPane: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        Picker("Preset", selection: presetBinding) {
          ForEach(0..<selectedShader.presetCount, id: \.self) { index in
            Text(selectedShader.presetName(at: index)).tag(index)
          }
        }
        .pickerStyle(.menu)

        if selectedShader.usesImage {
          Button("Choose Image", systemImage: "photo") {
            chooseImage()
          }
        }

        GroupBox("Motion") {
          slider("Speed", value: $speed, range: -2...2)
          slider("Frame", value: $frame, range: 0...5000)
        }

        GroupBox("Sizing") {
          slider("Scale", value: $scale, range: 0.1...4)
          slider("Rotation", value: $rotation, range: 0...360)
          slider("Offset X", value: $offsetX, range: -1...1)
          slider("Offset Y", value: $offsetY, range: -1...1)
        }

        codeSnippetPane
      }
      .padding(18)
    }
    .background(.regularMaterial)
  }

  private var codeSnippetPane: some View {
    GroupBox("Code") {
      ZStack(alignment: .topTrailing) {
        GeometryReader { proxy in
          ScrollView([.horizontal, .vertical]) {
            Text(currentCode)
              .font(.system(.caption, design: .monospaced))
              .textSelection(.enabled)
              .padding(12)
              .padding(.top, 30)
              .frame(
                minWidth: proxy.size.width,
                minHeight: proxy.size.height,
                alignment: .topLeading
              )
          }
          .frame(width: proxy.size.width, height: proxy.size.height)
        }

        Button(
          didCopyCode ? "Copied" : "Copy",
          systemImage: didCopyCode ? "checkmark" : "doc.on.doc"
        ) {
          copyCurrentCode()
        }
        .controlSize(.small)
        .padding(8)
      }
      .frame(maxWidth: .infinity, minHeight: 220)
    }
  }

  private func slider(_ title: String, value: Binding<Float>, range: ClosedRange<Float>)
    -> some View
  {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(title)
        Spacer()
        Text(value.wrappedValue.formatted(.number.precision(.fractionLength(2))))
          .monospacedDigit()
          .foregroundStyle(.secondary)
      }
      Slider(value: value, in: range)
    }
    .padding(.vertical, 4)
  }

  private var presetBinding: Binding<Int> {
    Binding(
      get: { presetIndexByShader[selectedShader, default: 0] },
      set: { presetIndexByShader[selectedShader] = min($0, max(0, selectedShader.presetCount - 1)) }
    )
  }

  private var currentConfiguration: ShaderConfiguration {
    let index = presetIndexByShader[selectedShader, default: 0]
    var configuration = selectedShader.configuration(at: index)
    configuration.sizing.scale *= scale
    configuration.sizing.rotation = rotation
    configuration.sizing.offsetX = offsetX
    configuration.sizing.offsetY = offsetY
    configuration.motion.speed = speed
    configuration.motion.frame = frame
    configuration.renderOptions = ShaderRenderOptions(width: 1280, height: 720)
    if selectedShader.usesImage, let selectedImage {
      configuration.image = selectedImage
    }
    return configuration
  }

  private var currentCode: String {
    let index = presetIndexByShader[selectedShader, default: 0]
    return FoilShadersCodeGenerator.swiftUICode(
      componentName: selectedShader.componentName,
      presetReference: "\(selectedShader.presetArrayName)[\(index)]",
      sizing: currentConfiguration.sizing,
      motion: currentConfiguration.motion,
      renderOptions: currentConfiguration.renderOptions
    )
  }

  private func previewConfiguration(size: CGSize) -> ShaderConfiguration {
    var configuration = currentConfiguration
    configuration.renderOptions = ShaderRenderOptions(width: size.width, height: size.height)
    return configuration
  }

  private func fittedPreviewSize(in availableSize: CGSize) -> CGSize {
    let aspectRatio = CGFloat(16.0 / 9.0)
    let availableWidth = max(1, availableSize.width)
    let availableHeight = max(1, availableSize.height)
    let widthForHeight = availableHeight * aspectRatio

    if widthForHeight <= availableWidth {
      return CGSize(width: widthForHeight, height: availableHeight)
    }

    return CGSize(width: availableWidth, height: availableWidth / aspectRatio)
  }

  private func chooseImage() {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.image]
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    if panel.runModal() == .OK, let url = panel.url {
      selectedImage = .url(url)
    }
  }

  private func copyPreviewImage(size: CGSize) {
    do {
      let image = try capturePreviewImage(size: size)
      let nsImage = NSImage(
        cgImage: image,
        size: NSSize(width: image.width, height: image.height)
      )
      guard let pngData = pngData(for: image), let tiffData = nsImage.tiffRepresentation else {
        throw PreviewImageError.pngEncodingFailed
      }

      let pasteboard = NSPasteboard.general
      pasteboard.declareTypes([.png, .tiff], owner: nil)
      pasteboard.setData(pngData, forType: .png)
      pasteboard.setData(tiffData, forType: .tiff)
    } catch {
      presentPreviewImageError(error)
    }
  }

  private func savePreviewImage(size: CGSize) {
    do {
      let image = try capturePreviewImage(size: size)
      let panel = NSSavePanel()
      panel.allowedContentTypes = [.png]
      panel.canCreateDirectories = true
      panel.nameFieldStringValue = "foil-shader-preview.png"

      guard panel.runModal() == .OK, let url = panel.url else { return }
      try writePNG(image, to: url)
    } catch {
      presentPreviewImageError(error)
    }
  }

  private func capturePreviewImage(size: CGSize) throws -> CGImage {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw PreviewImageError.metalUnavailable
    }

    let configuration = previewConfiguration(size: size)
    let captureSize = previewCaptureSize(for: size, renderOptions: configuration.renderOptions)
    let renderer = try FoilShadersRenderer(device: device)
    try renderer.configure(configuration.kind)
    renderer.apply(configuration)
    renderer.setSpeed(0)
    renderer.setFrame(configuration.motion.frame)
    renderer.setRenderSize(
      width: captureSize.width,
      height: captureSize.height,
      pixelRatio: captureSize.pixelRatio
    )

    guard let image = renderer.captureCurrentImage() else {
      throw PreviewImageError.captureFailed
    }
    return image
  }

  private func previewCaptureSize(
    for pointSize: CGSize,
    renderOptions: ShaderRenderOptions
  ) -> (width: Int, height: Int, pixelRatio: Float) {
    let pointWidth = max(1.0, Double(pointSize.width))
    let pointHeight = max(1.0, Double(pointSize.height))
    let backingScale = Double(
      NSApp.keyWindow?.screen?.backingScaleFactor
        ?? NSScreen.main?.backingScaleFactor
        ?? 1.0
    )
    let targetScale = max(backingScale, Double(renderOptions.minPixelRatio))
    var pixelWidth = pointWidth * targetScale
    var pixelHeight = pointHeight * targetScale

    let maxPixels = Double(renderOptions.maxPixelCount)
    let targetPixels = pixelWidth * pixelHeight
    if maxPixels > 0, targetPixels > maxPixels {
      let downscale = (maxPixels / targetPixels).squareRoot()
      pixelWidth *= downscale
      pixelHeight *= downscale
    }

    let width = max(1, Int(pixelWidth.rounded()))
    let height = max(1, Int(pixelHeight.rounded()))
    return (width, height, Float(Double(width) / pointWidth))
  }

  private func pngData(for image: CGImage) -> Data? {
    let data = NSMutableData()
    guard
      let destination = CGImageDestinationCreateWithData(
        data, UTType.png.identifier as CFString, 1, nil)
    else {
      return nil
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { return nil }
    return data as Data
  }

  private func writePNG(_ image: CGImage, to url: URL) throws {
    guard
      let destination = CGImageDestinationCreateWithURL(
        url as CFURL, UTType.png.identifier as CFString, 1, nil)
    else {
      throw PreviewImageError.cannotCreatePNGDestination(url)
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
      throw PreviewImageError.cannotWritePNG(url)
    }
  }

  private func presentPreviewImageError(_ error: Error) {
    NSAlert(error: error).runModal()
  }

  private func copyCurrentCode() {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(currentCode, forType: .string)

    let feedbackID = UUID()
    copyFeedbackID = feedbackID
    withAnimation(.easeOut(duration: 0.16)) {
      didCopyCode = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
      guard copyFeedbackID == feedbackID else { return }
      withAnimation(.easeOut(duration: 0.16)) {
        didCopyCode = false
      }
    }
  }
}

private enum PreviewImageError: LocalizedError {
  case metalUnavailable
  case captureFailed
  case pngEncodingFailed
  case cannotCreatePNGDestination(URL)
  case cannotWritePNG(URL)

  var errorDescription: String? {
    switch self {
    case .metalUnavailable:
      "Metal is not available on this Mac."
    case .captureFailed:
      "Could not capture the current preview image."
    case .pngEncodingFailed:
      "Could not encode the preview image."
    case .cannotCreatePNGDestination(let url):
      "Could not create a PNG at \(url.path)."
    case .cannotWritePNG(let url):
      "Could not write the PNG at \(url.path)."
    }
  }
}

private enum StudioShader: String, CaseIterable, Identifiable {
  case meshGradient
  case smokeRing
  case neuroNoise
  case dotOrbit
  case dotGrid
  case simplexNoise
  case metaballs
  case waves
  case perlinNoise
  case voronoi
  case warp
  case godRays
  case spiral
  case swirl
  case dithering
  case grainGradient
  case pulsingBorder
  case colorPanels
  case staticMeshGradient
  case staticRadialGradient
  case paperTexture
  case flutedGlass
  case water
  case imageDithering
  case heatmap
  case liquidMetal
  case halftoneDots
  case halftoneCmyk
  case gemSmoke

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .meshGradient: "Mesh Gradient"
    case .smokeRing: "Smoke Ring"
    case .neuroNoise: "Neuro Noise"
    case .dotOrbit: "Dot Orbit"
    case .dotGrid: "Dot Grid"
    case .simplexNoise: "Simplex Noise"
    case .metaballs: "Metaballs"
    case .waves: "Waves"
    case .perlinNoise: "Perlin Noise"
    case .voronoi: "Voronoi"
    case .warp: "Warp"
    case .godRays: "God Rays"
    case .spiral: "Spiral"
    case .swirl: "Swirl"
    case .dithering: "Dithering"
    case .grainGradient: "Grain Gradient"
    case .pulsingBorder: "Pulsing Border"
    case .colorPanels: "Color Panels"
    case .staticMeshGradient: "Static Mesh Gradient"
    case .staticRadialGradient: "Static Radial Gradient"
    case .paperTexture: "Paper Texture"
    case .flutedGlass: "Fluted Glass"
    case .water: "Water"
    case .imageDithering: "Image Dithering"
    case .heatmap: "Heatmap"
    case .liquidMetal: "Liquid Metal"
    case .halftoneDots: "Halftone Dots"
    case .halftoneCmyk: "Halftone CMYK"
    case .gemSmoke: "Gem Smoke"
    }
  }

  var componentName: String {
    displayName.replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "CMYK", with: "Cmyk")
  }

  var presetArrayName: String {
    switch self {
    case .meshGradient: "meshGradientPresets"
    case .smokeRing: "smokeRingPresets"
    case .neuroNoise: "neuroNoisePresets"
    case .dotOrbit: "dotOrbitPresets"
    case .dotGrid: "dotGridPresets"
    case .simplexNoise: "simplexNoisePresets"
    case .metaballs: "metaballsPresets"
    case .waves: "wavesPresets"
    case .perlinNoise: "perlinNoisePresets"
    case .voronoi: "voronoiPresets"
    case .warp: "warpPresets"
    case .godRays: "godRaysPresets"
    case .spiral: "spiralPresets"
    case .swirl: "swirlPresets"
    case .dithering: "ditheringPresets"
    case .grainGradient: "grainGradientPresets"
    case .pulsingBorder: "pulsingBorderPresets"
    case .colorPanels: "colorPanelsPresets"
    case .staticMeshGradient: "staticMeshGradientPresets"
    case .staticRadialGradient: "staticRadialGradientPresets"
    case .paperTexture: "paperTexturePresets"
    case .flutedGlass: "flutedGlassPresets"
    case .water: "waterPresets"
    case .imageDithering: "imageDitheringPresets"
    case .heatmap: "heatmapPresets"
    case .liquidMetal: "liquidMetalPresets"
    case .halftoneDots: "halftoneDotsPresets"
    case .halftoneCmyk: "halftoneCmykPresets"
    case .gemSmoke: "gemSmokePresets"
    }
  }

  var presetCount: Int {
    switch self {
    case .meshGradient: meshGradientPresets.count
    case .smokeRing: smokeRingPresets.count
    case .neuroNoise: neuroNoisePresets.count
    case .dotOrbit: dotOrbitPresets.count
    case .dotGrid: dotGridPresets.count
    case .simplexNoise: simplexNoisePresets.count
    case .metaballs: metaballsPresets.count
    case .waves: wavesPresets.count
    case .perlinNoise: perlinNoisePresets.count
    case .voronoi: voronoiPresets.count
    case .warp: warpPresets.count
    case .godRays: godRaysPresets.count
    case .spiral: spiralPresets.count
    case .swirl: swirlPresets.count
    case .dithering: ditheringPresets.count
    case .grainGradient: grainGradientPresets.count
    case .pulsingBorder: pulsingBorderPresets.count
    case .colorPanels: colorPanelsPresets.count
    case .staticMeshGradient: staticMeshGradientPresets.count
    case .staticRadialGradient: staticRadialGradientPresets.count
    case .paperTexture: paperTexturePresets.count
    case .flutedGlass: flutedGlassPresets.count
    case .water: waterPresets.count
    case .imageDithering: imageDitheringPresets.count
    case .heatmap: heatmapPresets.count
    case .liquidMetal: liquidMetalPresets.count
    case .halftoneDots: halftoneDotsPresets.count
    case .halftoneCmyk: halftoneCmykPresets.count
    case .gemSmoke: gemSmokePresets.count
    }
  }

  var usesImage: Bool {
    switch self {
    case .flutedGlass, .water, .imageDithering, .heatmap, .liquidMetal, .halftoneDots,
      .halftoneCmyk, .gemSmoke:
      true
    default:
      false
    }
  }

  func presetName(at index: Int) -> String {
    switch self {
    case .meshGradient: meshGradientPresets[index].name
    case .smokeRing: smokeRingPresets[index].name
    case .neuroNoise: neuroNoisePresets[index].name
    case .dotOrbit: dotOrbitPresets[index].name
    case .dotGrid: dotGridPresets[index].name
    case .simplexNoise: simplexNoisePresets[index].name
    case .metaballs: metaballsPresets[index].name
    case .waves: wavesPresets[index].name
    case .perlinNoise: perlinNoisePresets[index].name
    case .voronoi: voronoiPresets[index].name
    case .warp: warpPresets[index].name
    case .godRays: godRaysPresets[index].name
    case .spiral: spiralPresets[index].name
    case .swirl: swirlPresets[index].name
    case .dithering: ditheringPresets[index].name
    case .grainGradient: grainGradientPresets[index].name
    case .pulsingBorder: pulsingBorderPresets[index].name
    case .colorPanels: colorPanelsPresets[index].name
    case .staticMeshGradient: staticMeshGradientPresets[index].name
    case .staticRadialGradient: staticRadialGradientPresets[index].name
    case .paperTexture: paperTexturePresets[index].name
    case .flutedGlass: flutedGlassPresets[index].name
    case .water: waterPresets[index].name
    case .imageDithering: imageDitheringPresets[index].name
    case .heatmap: heatmapPresets[index].name
    case .liquidMetal: liquidMetalPresets[index].name
    case .halftoneDots: halftoneDotsPresets[index].name
    case .halftoneCmyk: halftoneCmykPresets[index].name
    case .gemSmoke: gemSmokePresets[index].name
    }
  }

  @MainActor
  func configuration(at index: Int) -> ShaderConfiguration {
    switch self {
    case .meshGradient: MeshGradient(meshGradientPresets[index]).configuration
    case .smokeRing: SmokeRing(smokeRingPresets[index]).configuration
    case .neuroNoise: NeuroNoise(neuroNoisePresets[index]).configuration
    case .dotOrbit: DotOrbit(dotOrbitPresets[index]).configuration
    case .dotGrid: DotGrid(dotGridPresets[index]).configuration
    case .simplexNoise: SimplexNoise(simplexNoisePresets[index]).configuration
    case .metaballs: Metaballs(metaballsPresets[index]).configuration
    case .waves: Waves(wavesPresets[index]).configuration
    case .perlinNoise: PerlinNoise(perlinNoisePresets[index]).configuration
    case .voronoi: Voronoi(voronoiPresets[index]).configuration
    case .warp: Warp(warpPresets[index]).configuration
    case .godRays: GodRays(godRaysPresets[index]).configuration
    case .spiral: Spiral(spiralPresets[index]).configuration
    case .swirl: Swirl(swirlPresets[index]).configuration
    case .dithering: Dithering(ditheringPresets[index]).configuration
    case .grainGradient: GrainGradient(grainGradientPresets[index]).configuration
    case .pulsingBorder: PulsingBorder(pulsingBorderPresets[index]).configuration
    case .colorPanels: ColorPanels(colorPanelsPresets[index]).configuration
    case .staticMeshGradient: StaticMeshGradient(staticMeshGradientPresets[index]).configuration
    case .staticRadialGradient:
      StaticRadialGradient(staticRadialGradientPresets[index]).configuration
    case .paperTexture: PaperTexture(paperTexturePresets[index]).configuration
    case .flutedGlass: FlutedGlass(flutedGlassPresets[index]).configuration
    case .water: Water(waterPresets[index]).configuration
    case .imageDithering: ImageDithering(imageDitheringPresets[index]).configuration
    case .heatmap: Heatmap(heatmapPresets[index]).configuration
    case .liquidMetal: LiquidMetal(liquidMetalPresets[index]).configuration
    case .halftoneDots: HalftoneDots(halftoneDotsPresets[index]).configuration
    case .halftoneCmyk: HalftoneCmyk(halftoneCmykPresets[index]).configuration
    case .gemSmoke: GemSmoke(gemSmokePresets[index]).configuration
    }
  }
}
