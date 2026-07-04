import Foundation
import Metal

enum ShaderLibraryLoader {
  static func makeLibrary(device: MTLDevice, shaderNames: [String]) throws -> MTLLibrary {
    for bundle in FoilShadersResourceBundles.candidates {
      if let defaultLibrary = try? device.makeDefaultLibrary(bundle: bundle) {
        return defaultLibrary
      }
    }
    return try makeLibraryFromSources(device: device, shaderNames: shaderNames)
  }

  private static func makeLibraryFromSources(device: MTLDevice, shaderNames: [String]) throws
    -> MTLLibrary
  {
    var commonURL: URL?
    var vertexURL: URL?
    var shaderURLs: [URL] = []
    for bundle in FoilShadersResourceBundles.candidates {
      commonURL =
        commonURL
        ?? bundle.url(forResource: "Common", withExtension: "metal", subdirectory: "Shaders")
      commonURL = commonURL ?? bundle.url(forResource: "Common", withExtension: "metal")
      vertexURL =
        vertexURL
        ?? bundle.url(forResource: "Vertex", withExtension: "metal", subdirectory: "Shaders")
      vertexURL = vertexURL ?? bundle.url(forResource: "Vertex", withExtension: "metal")
      for shader in shaderNames {
        if shaderURLs.contains(where: { $0.lastPathComponent == "\(shader).metal" }) {
          continue
        }
        if let url = bundle.url(
          forResource: shader, withExtension: "metal", subdirectory: "Shaders")
          ?? bundle.url(forResource: shader, withExtension: "metal")
        {
          shaderURLs.append(url)
        }
      }
    }
    guard let commonURL, let vertexURL, shaderURLs.count == shaderNames.count else {
      throw RendererError.libraryCompileError(
        "Missing shader source in resources (Shaders/*.metal)")
    }

    let commonSource = try String(contentsOf: commonURL)
    let vertexSource = try String(contentsOf: vertexURL)
      .replacingOccurrences(of: "#include \"Common.metal\"", with: "")
    let shaderSources = try shaderURLs.map { url in
      try String(contentsOf: url)
        .replacingOccurrences(of: "#include \"Common.metal\"", with: "")
    }

    let merged = ([commonSource, vertexSource] + shaderSources).joined(separator: "\n")
    do {
      return try device.makeLibrary(source: merged, options: nil)
    } catch {
      let message = (error as NSError).localizedDescription
      throw RendererError.libraryCompileError(message)
    }
  }
}
