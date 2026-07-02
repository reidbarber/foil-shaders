import Foundation

public enum AluminumFoilCodeGenerator {
  public static func swiftUICode(
    componentName: String,
    presetReference: String,
    sizing: ShaderSizingParams,
    motion: ShaderMotionParams,
    renderOptions: ShaderRenderOptions
  ) -> String {
    let qualifiedName =
      componentName == "MeshGradient" ? "AluminumFoil.MeshGradient" : componentName
    var lines: [String] = [
      "import AluminumFoil",
      "",
      "\(qualifiedName)(",
      "    params: \(presetReference).params,",
      "    sizing: \(sizingCode(sizing)),",
      "    motion: ShaderMotionParams(speed: \(number(motion.speed)), frame: \(number(motion.frame))),",
      "    renderOptions: \(renderOptionsCode(renderOptions))",
      ")",
    ]
    if let width = renderOptions.width, let height = renderOptions.height {
      lines.append(".frame(width: \(number(Float(width))), height: \(number(Float(height))))")
    }
    return lines.joined(separator: "\n")
  }

  public static func sizingCode(_ sizing: ShaderSizingParams) -> String {
    "ShaderSizingParams(fit: .\(sizing.fit), scale: \(number(sizing.scale)), rotation: \(number(sizing.rotation)), originX: \(number(sizing.originX)), originY: \(number(sizing.originY)), offsetX: \(number(sizing.offsetX)), offsetY: \(number(sizing.offsetY)), worldWidth: \(number(sizing.worldWidth)), worldHeight: \(number(sizing.worldHeight)))"
  }

  public static func renderOptionsCode(_ options: ShaderRenderOptions) -> String {
    var args = [
      "minPixelRatio: \(number(options.minPixelRatio))",
      "maxPixelCount: \(options.maxPixelCount)",
    ]
    if let width = options.width {
      args.append("width: \(number(Float(width)))")
    }
    if let height = options.height {
      args.append("height: \(number(Float(height)))")
    }
    return "ShaderRenderOptions(\(args.joined(separator: ", ")))"
  }

  private static func number(_ value: Float) -> String {
    if value.rounded() == value {
      return String(Int(value))
    }
    return String(format: "%.3f", value)
      .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
      .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
  }
}

extension ShaderFit: CustomStringConvertible {
  public var description: String {
    switch self {
    case .none: "none"
    case .contain: "contain"
    case .cover: "cover"
    }
  }
}
