import CoreFoundation
@_spi(Studio) import FoilShaders
import Foundation

enum StudioParameterValue: Equatable {
  case number(Float)
  case boolean(Bool)
  case option(String, options: [String])
  case color(ShaderColor)
  case palette([ShaderColor])
}

struct StudioParameterDescriptor: Identifiable, Equatable {
  let name: String
  let value: StudioParameterValue
  let range: ClosedRange<Float>?

  var id: String { name }

  var title: String {
    name.unCamelCased.capitalized
  }
}

enum StudioParameterCodec {
  static func descriptors(
    for parameters: ShaderParameters,
    shader: StudioShader
  ) -> [StudioParameterDescriptor] {
    guard let values = parameterObject(parameters) else { return [] }
    return values.keys.sorted().compactMap { name in
      descriptor(name: name, jsonValue: values[name] as Any, shader: shader)
    }
  }

  static func value(
    named name: String,
    in parameters: ShaderParameters,
    shader: StudioShader
  ) -> StudioParameterValue? {
    guard let jsonValue = parameterObject(parameters)?[name] else { return nil }
    return descriptor(name: name, jsonValue: jsonValue, shader: shader)?.value
  }

  static func setting(
    _ name: String,
    to value: StudioParameterValue,
    in parameters: ShaderParameters
  ) -> ShaderParameters? {
    guard
      var root = encodedObject(parameters),
      var parameterValues = root["params"] as? [String: Any]
    else { return nil }
    parameterValues[name] = jsonValue(value)
    root["params"] = parameterValues
    guard
      JSONSerialization.isValidJSONObject(root),
      let data = try? JSONSerialization.data(withJSONObject: root)
    else { return nil }
    return try? JSONDecoder().decode(ShaderParameters.self, from: data)
  }

  private static func descriptor(
    name: String,
    jsonValue: Any,
    shader: StudioShader
  ) -> StudioParameterDescriptor? {
    if let object = jsonValue as? [String: Any], let color = shaderColor(object) {
      return StudioParameterDescriptor(name: name, value: .color(color), range: nil)
    }
    if let array = jsonValue as? [[String: Any]] {
      let colors = array.compactMap(shaderColor)
      guard colors.count == array.count else { return nil }
      return StudioParameterDescriptor(name: name, value: .palette(colors), range: nil)
    }
    if let string = jsonValue as? String {
      let metadata = StudioParameterMetadata.metadata(shader: shader, parameter: name)
      return StudioParameterDescriptor(
        name: name,
        value: .option(string, options: metadata.options),
        range: nil
      )
    }
    if let number = jsonValue as? NSNumber {
      if CFGetTypeID(number) == CFBooleanGetTypeID() {
        return StudioParameterDescriptor(
          name: name,
          value: .boolean(number.boolValue),
          range: nil
        )
      }
      let float = number.floatValue
      let metadata = StudioParameterMetadata.metadata(
        shader: shader,
        parameter: name,
        currentValue: float
      )
      return StudioParameterDescriptor(name: name, value: .number(float), range: metadata.range)
    }
    return nil
  }

  private static func parameterObject(_ parameters: ShaderParameters) -> [String: Any]? {
    encodedObject(parameters)?["params"] as? [String: Any]
  }

  private static func encodedObject(_ parameters: ShaderParameters) -> [String: Any]? {
    guard
      let data = try? JSONEncoder().encode(parameters),
      let object = try? JSONSerialization.jsonObject(with: data)
    else { return nil }
    return object as? [String: Any]
  }

  private static func shaderColor(_ object: [String: Any]) -> ShaderColor? {
    guard
      let red = (object["red"] as? NSNumber)?.floatValue,
      let green = (object["green"] as? NSNumber)?.floatValue,
      let blue = (object["blue"] as? NSNumber)?.floatValue,
      let alpha = (object["alpha"] as? NSNumber)?.floatValue
    else { return nil }
    return ShaderColor(red: red, green: green, blue: blue, alpha: alpha)
  }

  private static func jsonValue(_ value: StudioParameterValue) -> Any {
    switch value {
    case .number(let number):
      number
    case .boolean(let boolean):
      boolean
    case .option(let option, _):
      option
    case .color(let color):
      colorObject(color)
    case .palette(let colors):
      colors.map(colorObject)
    }
  }

  private static func colorObject(_ color: ShaderColor) -> [String: Float] {
    ["red": color.red, "green": color.green, "blue": color.blue, "alpha": color.alpha]
  }
}

extension String {
  fileprivate var unCamelCased: String {
    unicodeScalars.reduce(into: "") { result, scalar in
      if CharacterSet.uppercaseLetters.contains(scalar), !result.isEmpty {
        result.append(" ")
      }
      result.append(Character(scalar))
    }
  }
}
