import CoreGraphics
import Foundation
import ImageIO
import Metal
import MetalKit

@MainActor
final class FoilShadersMetalContext {
  private static var contextsByDeviceID: [ObjectIdentifier: FoilShadersMetalContext] = [:]

  static func sharedDefault() throws -> FoilShadersMetalContext {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw FoilShadersError.deviceUnavailable
    }
    return try shared(for: device)
  }

  static func shared(for device: MTLDevice) throws -> FoilShadersMetalContext {
    let deviceID = ObjectIdentifier(device as AnyObject)
    if let context = contextsByDeviceID[deviceID] {
      return context
    }
    let context = try FoilShadersMetalContext(device: device)
    contextsByDeviceID[deviceID] = context
    return context
  }

  let device: MTLDevice
  let commandQueue: MTLCommandQueue
  let textureLoader: MTKTextureLoader
  let noiseTexture: MTLTexture?
  let fallbackNoiseTexture: MTLTexture?

  private var sharedLibrary: MTLLibrary?
  private var pipelineStatesByFragmentFunctionName: [String: MTLRenderPipelineState] = [:]

  private init(device: MTLDevice) throws {
    self.device = device
    guard let commandQueue = device.makeCommandQueue() else {
      throw FoilShadersError.deviceError
    }
    self.commandQueue = commandQueue
    self.textureLoader = MTKTextureLoader(device: device)
    self.noiseTexture = Self.makeNoiseTexture(device: device)
    self.fallbackNoiseTexture = Self.makeSolidTexture(
      device: device,
      color: SIMD4<UInt8>(127, 127, 127, 255)
    )
  }

  func library() throws -> MTLLibrary {
    if let sharedLibrary {
      return sharedLibrary
    }
    let library = try ShaderLibraryLoader.makeLibrary(device: device)
    sharedLibrary = library
    return library
  }

  func pipelineState(fragmentFunctionName: String, library: MTLLibrary) throws
    -> MTLRenderPipelineState
  {
    if let pipelineState = pipelineStatesByFragmentFunctionName[fragmentFunctionName] {
      return pipelineState
    }
    guard let vertexFunction = library.makeFunction(name: "vertex_main") else {
      throw FoilShadersError.shaderError("vertex_main")
    }
    guard let fragmentFunction = library.makeFunction(name: fragmentFunctionName) else {
      throw FoilShadersError.shaderError(fragmentFunctionName)
    }

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float2
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 2
    pipelineDescriptor.vertexDescriptor = vertexDescriptor

    do {
      let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
      pipelineStatesByFragmentFunctionName[fragmentFunctionName] = pipelineState
      return pipelineState
    } catch {
      throw FoilShadersError.pipelineError(error)
    }
  }

  private static func makeNoiseTexture(device: MTLDevice) -> MTLTexture? {
    for bundle in FoilShadersResourceBundles.candidates {
      if let url = bundle.url(forResource: "noise-texture", withExtension: "png") {
        // The bundled noise texture is a palette (indexed-color) PNG.
        // MTKTextureLoader cannot decode those, so expand it to RGBA8 through
        // a device-RGB bitmap context before uploading the raw bytes.
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { break }
        return makeTexture(expandingPalette: image, device: device)
      }
    }
    return nil
  }

  private static func makeTexture(expandingPalette image: CGImage, device: MTLDevice)
    -> MTLTexture?
  {
    let width = image.width
    let height = image.height
    var rgba = [UInt8](repeating: 0, count: width * height * 4)
    guard
      let context = CGContext(
        data: &rgba,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
      )
    else { return nil }
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

    let descriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: .rgba8Unorm,
      width: width,
      height: height,
      mipmapped: false
    )
    descriptor.usage = [.shaderRead, .renderTarget]
    guard let texture = device.makeTexture(descriptor: descriptor) else { return nil }
    rgba.withUnsafeBytes { buffer in
      texture.replace(
        region: MTLRegionMake2D(0, 0, width, height),
        mipmapLevel: 0,
        withBytes: buffer.baseAddress!,
        bytesPerRow: width * 4
      )
    }
    return texture
  }

  private static func makeSolidTexture(device: MTLDevice, color: SIMD4<UInt8>) -> MTLTexture? {
    let descriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: .rgba8Unorm,
      width: 1,
      height: 1,
      mipmapped: false
    )
    descriptor.usage = [.shaderRead]
    guard let texture = device.makeTexture(descriptor: descriptor) else {
      return nil
    }
    var pixel = [color.x, color.y, color.z, color.w]
    texture.replace(
      region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, withBytes: &pixel, bytesPerRow: 4)
    return texture
  }
}
