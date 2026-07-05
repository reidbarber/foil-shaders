import CoreGraphics
import FoilShaders
import Foundation
import ImageIO
import Metal
import UniformTypeIdentifiers

struct ExportOptions {
  var outputURL = defaultOutputURL()
  var shader = "mesh-gradient"
  var preset = "Default"
  var frame: Float = 0
  var width = 1280
  var height = 720
  var imageURL: URL?
}

enum ExportError: Error, CustomStringConvertible {
  case missingValue(String)
  case unknownArgument(String)
  case unexpectedPositionalArguments([String])
  case unknownShader(String)
  case missingPreset(shader: String, preset: String)
  case invalidNumber(option: String, value: String)
  case invalidImage(URL)
  case cannotCreateDestination(URL)
  case cannotWriteImage(URL)

  var description: String {
    switch self {
    case .missingValue(let option):
      return "\(option) requires a value."
    case .unknownArgument(let argument):
      return "Unknown argument: \(argument)"
    case .unexpectedPositionalArguments(let arguments):
      return "Unexpected positional arguments: \(arguments.joined(separator: ", "))"
    case .unknownShader(let shader):
      return "Unknown shader: \(shader)"
    case .missingPreset(let shader, let preset):
      return "Preset \"\(preset)\" was not found for shader \"\(shader)\"."
    case .invalidNumber(let option, let value):
      return "\(option) must be numeric, got \"\(value)\"."
    case .invalidImage(let url):
      return "Could not load image at \(url.path)."
    case .cannotCreateDestination(let url):
      return "Could not create PNG destination at \(url.path)."
    case .cannotWriteImage(let url):
      return "Could not write PNG at \(url.path)."
    }
  }
}

func defaultOutputURL() -> URL {
  URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("foil-shaders-export.png")
}

func usage() -> String {
  """
  Usage: swift run FoilShadersExport [output.png]
         swift run FoilShadersExport --shader <shader> --preset <preset> --frame <frame> --width <px> --height <px> --output <output.png>

  Options:
    --shader <slug>       Shader slug, for example mesh-gradient, swirl, dithering, voronoi, paper-texture, or liquid-metal.
    --preset <name>       Preset display name. Defaults to Default.
    --frame <number>      Animation frame in milliseconds. Defaults to 0.
    --width <px>          Output width. Defaults to 1280.
    --height <px>         Output height. Defaults to 720.
    --image <path>        Fixture image for image-based shaders.
    --output <path>       Output PNG path.
    -h, --help            Show this help message.
  """
}

func takeValue(_ option: String, from args: inout [String]) throws -> String {
  guard !args.isEmpty else { throw ExportError.missingValue(option) }
  return args.removeFirst()
}

func parseInt(_ value: String, option: String) throws -> Int {
  guard let parsed = Int(value) else {
    throw ExportError.invalidNumber(option: option, value: value)
  }
  return parsed
}

func parseFloat(_ value: String, option: String) throws -> Float {
  guard let parsed = Float(value) else {
    throw ExportError.invalidNumber(option: option, value: value)
  }
  return parsed
}

func parseArguments(_ rawArguments: [String]) throws -> ExportOptions {
  var args = rawArguments
  var options = ExportOptions()
  var positionalArguments: [String] = []

  while !args.isEmpty {
    let argument = args.removeFirst()
    switch argument {
    case "-h", "--help":
      print(usage())
      exit(0)
    case "--shader":
      options.shader = try takeValue(argument, from: &args)
    case "--preset":
      options.preset = try takeValue(argument, from: &args)
    case "--frame":
      options.frame = try parseFloat(try takeValue(argument, from: &args), option: argument)
    case "--width":
      options.width = try parseInt(try takeValue(argument, from: &args), option: argument)
    case "--height":
      options.height = try parseInt(try takeValue(argument, from: &args), option: argument)
    case "--image":
      options.imageURL = URL(fileURLWithPath: try takeValue(argument, from: &args))
    case "--output":
      options.outputURL = URL(fileURLWithPath: try takeValue(argument, from: &args))
    default:
      if argument.hasPrefix("-") {
        throw ExportError.unknownArgument(argument)
      }
      positionalArguments.append(argument)
    }
  }

  if positionalArguments.count == 1 {
    options.outputURL = URL(fileURLWithPath: positionalArguments[0])
  } else if positionalArguments.count > 1 {
    throw ExportError.unexpectedPositionalArguments(positionalArguments)
  }

  return options
}

func preset<Params>(
  _ presets: [ShaderPreset<Params>], shader: String, name: String
) throws -> ShaderPreset<Params> {
  guard let preset = presets.first(where: { $0.name == name }) else {
    throw ExportError.missingPreset(shader: shader, preset: name)
  }
  return preset
}

func configuration(for shader: String, presetName: String, image: ShaderImage?) throws
  -> ShaderConfiguration
{
  var configuration: ShaderConfiguration

  func makeConfiguration<Params>(
    presets: [ShaderPreset<Params>],
    wrap: (Params) -> ShaderParameters
  ) throws -> ShaderConfiguration {
    let selectedPreset = try preset(presets, shader: shader, name: presetName)
    return ShaderConfiguration(
      parameters: wrap(selectedPreset.params),
      sizing: selectedPreset.sizing,
      motion: selectedPreset.motion,
      renderOptions: selectedPreset.renderOptions,
      image: selectedPreset.image
    )
  }

  switch shader {
  case "mesh-gradient":
    configuration = try makeConfiguration(presets: AnimatedMeshGradient.presets) {
      .animatedMeshGradient($0)
    }
  case "swirl":
    configuration = try makeConfiguration(presets: Swirl.presets) { .swirl($0) }
  case "dithering":
    configuration = try makeConfiguration(presets: Dithering.presets) {
      .dithering($0)
    }
  case "voronoi":
    configuration = try makeConfiguration(presets: Voronoi.presets) { .voronoi($0) }
  case "paper-texture":
    configuration = try makeConfiguration(presets: PaperTexture.presets) {
      .paperTexture($0)
    }
  case "liquid-metal":
    configuration = try makeConfiguration(presets: LiquidMetal.presets) {
      .liquidMetal($0)
    }
  default:
    throw ExportError.unknownShader(shader)
  }

  if let image {
    configuration.image = image
  }
  return configuration
}

func loadImage(at url: URL) throws -> CGImage {
  guard
    let source = CGImageSourceCreateWithURL(url as CFURL, nil),
    let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
  else {
    throw ExportError.invalidImage(url)
  }
  return image
}

func writePNG(_ image: CGImage, to url: URL) throws {
  try FileManager.default.createDirectory(
    at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
  guard
    let destination = CGImageDestinationCreateWithURL(
      url as CFURL, UTType.png.identifier as CFString, 1, nil)
  else {
    throw ExportError.cannotCreateDestination(url)
  }
  CGImageDestinationAddImage(destination, image, nil)
  guard CGImageDestinationFinalize(destination) else {
    throw ExportError.cannotWriteImage(url)
  }
}

do {
  let options = try parseArguments(Array(CommandLine.arguments.dropFirst()))
  guard let device = MTLCreateSystemDefaultDevice() else {
    fputs("Metal is not available on this machine.\n", stderr)
    exit(1)
  }

  let fixture = try options.imageURL.map { ShaderImage.cgImage(try loadImage(at: $0)) }
  let renderer = try FoilShadersRenderer(device: device)
  var shaderConfiguration = try configuration(
    for: options.shader, presetName: options.preset, image: fixture)
  shaderConfiguration.motion.speed = 0
  shaderConfiguration.motion.frame = options.frame

  try renderer.render(shaderConfiguration)
  let image = try renderer.captureImage(width: options.width, height: options.height)

  try writePNG(image, to: options.outputURL)
  print(options.outputURL.path)
} catch {
  fputs("Export failed: \(error)\n\n\(usage())\n", stderr)
  exit(1)
}
