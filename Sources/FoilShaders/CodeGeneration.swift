import CoreGraphics
import Foundation

@_spi(Studio)
public enum FoilShadersCodeGenerator {
  @_spi(Studio)
  public static func swiftUICode(
    componentName: String,
    presetReference: String,
    sizing: ShaderSizingParams,
    motion: ShaderMotionParams,
    renderOptions: ShaderRenderOptions,
    layoutSize: CGSize? = nil
  ) -> String {
    let arguments = sharedInitializerArguments(
      sizing: sizing,
      motion: motion,
      renderOptions: renderOptions
    )

    let callLines: [String]
    if isDefaultPresetReference(presetReference) {
      callLines = initializerCallLines(componentName: componentName, arguments: arguments.flat)
    } else {
      callLines = presetInitializerCallLines(
        componentName: componentName,
        presetReference: presetReference,
        arguments: arguments
      )
    }

    var lines: [String] = [
      "import FoilShaders",
      "",
    ]
    lines.append(contentsOf: callLines)
    if let layoutSize {
      let width = Float(layoutSize.width)
      let height = Float(layoutSize.height)
      lines.append("  .frame(width: \(number(width)), height: \(number(height)))")
    }
    return lines.joined(separator: "\n")
  }

  private struct SharedInitializerArguments {
    var sizing: [String]
    var motion: [String]
    var renderOptions: [String]

    var flat: [String] {
      sizing + motion + renderOptions
    }
  }

  private static func sharedInitializerArguments(
    sizing: ShaderSizingParams,
    motion: ShaderMotionParams,
    renderOptions: ShaderRenderOptions
  ) -> SharedInitializerArguments {
    var sizingArguments: [String] = []
    let defaultSizing = ShaderSizingParams()
    if sizing.fit != defaultSizing.fit {
      sizingArguments.append("fit: .\(fitCaseName(sizing.fit))")
    }
    appendFloatArgument("scale", sizing.scale, default: defaultSizing.scale, to: &sizingArguments)
    appendFloatArgument(
      "rotation", sizing.rotation, default: defaultSizing.rotation, to: &sizingArguments)
    appendFloatArgument(
      "originX", sizing.originX, default: defaultSizing.originX, to: &sizingArguments)
    appendFloatArgument(
      "originY", sizing.originY, default: defaultSizing.originY, to: &sizingArguments)
    appendFloatArgument(
      "offsetX", sizing.offsetX, default: defaultSizing.offsetX, to: &sizingArguments)
    appendFloatArgument(
      "offsetY", sizing.offsetY, default: defaultSizing.offsetY, to: &sizingArguments)
    appendFloatArgument(
      "worldWidth", sizing.worldWidth, default: defaultSizing.worldWidth, to: &sizingArguments)
    appendFloatArgument(
      "worldHeight", sizing.worldHeight, default: defaultSizing.worldHeight, to: &sizingArguments)

    var motionArguments: [String] = []
    let defaultMotion = ShaderMotionParams()
    appendFloatArgument("speed", motion.speed, default: defaultMotion.speed, to: &motionArguments)
    appendFloatArgument("frame", motion.frame, default: defaultMotion.frame, to: &motionArguments)

    var renderOptionsArguments: [String] = []
    let defaultRenderOptions = ShaderRenderOptions()
    appendFloatArgument(
      "minPixelRatio",
      renderOptions.minPixelRatio,
      default: defaultRenderOptions.minPixelRatio,
      to: &renderOptionsArguments
    )
    if renderOptions.maxPixelCount != defaultRenderOptions.maxPixelCount {
      renderOptionsArguments.append("maxPixelCount: \(renderOptions.maxPixelCount)")
    }
    return SharedInitializerArguments(
      sizing: sizingArguments,
      motion: motionArguments,
      renderOptions: renderOptionsArguments
    )
  }

  private static func appendFloatArgument(
    _ label: String,
    _ value: Float,
    default defaultValue: Float,
    to arguments: inout [String]
  ) {
    if value != defaultValue {
      arguments.append("\(label): \(number(value))")
    }
  }

  private static func initializerCallLines(componentName: String, arguments: [String]) -> [String] {
    guard !arguments.isEmpty else {
      return ["\(componentName)()"]
    }

    let singleLine = "\(componentName)(\(arguments.joined(separator: ", ")))"
    if singleLine.count <= 100 {
      return [singleLine]
    }

    return [
      "\(componentName)("
    ]
      + arguments.enumerated().map { index, argument in
        let comma = index == arguments.count - 1 ? "" : ","
        return "  \(argument)\(comma)"
      } + [
        ")"
      ]
  }

  private static func presetInitializerCallLines(
    componentName: String,
    presetReference: String,
    arguments: SharedInitializerArguments
  ) -> [String] {
    [
      "\(componentName)(",
      "  params: \(presetReference).params,",
      "  sizing: \(inlineInitializerCall(name: "ShaderSizingParams", arguments: arguments.sizing)),",
      "  motion: \(inlineInitializerCall(name: "ShaderMotionParams", arguments: arguments.motion)),",
      "  renderOptions: \(inlineInitializerCall(name: "ShaderRenderOptions", arguments: arguments.renderOptions))",
      ")",
    ]
  }

  private static func inlineInitializerCall(name: String, arguments: [String]) -> String {
    guard !arguments.isEmpty else {
      return "\(name)()"
    }
    return "\(name)(\(arguments.joined(separator: ", ")))"
  }

  private static func isDefaultPresetReference(_ presetReference: String) -> Bool {
    presetReference.hasSuffix(".default")
  }

  private static func number(_ value: Float) -> String {
    if value.rounded() == value {
      return String(Int(value))
    }
    return String(format: "%.3f", value)
      .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
      .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
  }

  private static func fitCaseName(_ fit: ShaderFit) -> String {
    switch fit {
    case .none: "none"
    case .contain: "contain"
    case .cover: "cover"
    }
  }
}
