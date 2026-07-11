import Foundation

/// A JSON value from the manifest's `swiftParams` dictionaries.
enum ParityValue: Decodable {
  case bool(Bool)
  case number(Double)
  case array([ParityValue])

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let bool = try? container.decode(Bool.self) {
      self = .bool(bool)
    } else if let number = try? container.decode(Double.self) {
      self = .number(number)
    } else if let array = try? container.decode([ParityValue].self) {
      self = .array(array)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container, debugDescription: "Expected a bool, number, or array")
    }
  }

  var boolValue: Bool? {
    if case .bool(let value) = self { return value }
    return nil
  }

  var doubleValue: Double? {
    if case .number(let value) = self { return value }
    return nil
  }

  var arrayValue: [ParityValue]? {
    if case .array(let values) = self { return values }
    return nil
  }
}

struct ParityCanvas: Decodable {
  var width: Int
  var height: Int
  var pixelRatio: Float
}

struct ParitySizing: Decodable {
  var fit: Float
  var scale: Float
  var rotation: Float
  var originX: Float
  var originY: Float
  var offsetX: Float
  var offsetY: Float
  var worldWidth: Float
  var worldHeight: Float
}

struct ParityCase: Decodable {
  var id: String
  var shader: String
  var component: String
  var presetName: String
  var presetIndex: Int
  var frame: Float
  var usesImage: Bool
  var goldenPath: String
  var swiftParams: [String: ParityValue]
  var sizing: ParitySizing
}

struct ParityManifest: Decodable {
  var version: Int
  var canvas: ParityCanvas
  var environment: [String: String]
  var cases: [ParityCase]

  static func load() throws -> ParityManifest {
    guard let url = Bundle.module.url(forResource: "Goldens/manifest", withExtension: "json")
    else {
      throw ParityError.missingResource("Goldens/manifest.json")
    }
    return try JSONDecoder().decode(ParityManifest.self, from: Data(contentsOf: url))
  }

  func goldenURL(for parityCase: ParityCase) throws -> URL {
    guard
      let url = Bundle.module.url(
        forResource: "Goldens/\(parityCase.goldenPath)", withExtension: nil)
    else {
      throw ParityError.missingResource("Goldens/\(parityCase.goldenPath)")
    }
    return url
  }
}

enum ParityError: Error, CustomStringConvertible {
  case missingResource(String)
  case unexpectedPNGLayout(String)
  case unknownShader(String)
  case missingPreset(shader: String, preset: String)
  case paramsMismatch(String)

  var description: String {
    switch self {
    case .missingResource(let name):
      return "Missing test resource: \(name)"
    case .unexpectedPNGLayout(let details):
      return "Golden PNG decoded to an unexpected layout: \(details)"
    case .unknownShader(let name):
      return "Manifest references unknown shader: \(name)"
    case .missingPreset(let shader, let preset):
      return
        "Preset \"\(preset)\" for \(shader) not found in Presets.swift — regenerate presets and goldens (see Scripts/parity-harness/README.md)"
    case .paramsMismatch(let details):
      return
        "Preset params drifted from the manifest — regenerate Presets.swift and the goldens together. \(details)"
    }
  }
}
