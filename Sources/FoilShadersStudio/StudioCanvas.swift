import CoreGraphics

enum StudioCanvasPreset: String, CaseIterable, Identifiable {
  case iPhone
  case square
  case portrait
  case widescreen
  case custom

  var id: String { rawValue }

  var title: String {
    switch self {
    case .iPhone: "iPhone"
    case .square: "Square"
    case .portrait: "Portrait"
    case .widescreen: "16:9"
    case .custom: "Custom"
    }
  }

  func size(customWidth: Double, customHeight: Double) -> CGSize {
    switch self {
    case .iPhone: CGSize(width: 393, height: 852)
    case .square: CGSize(width: 1080, height: 1080)
    case .portrait: CGSize(width: 1080, height: 1350)
    case .widescreen: CGSize(width: 1280, height: 720)
    case .custom: CGSize(width: customWidth, height: customHeight)
    }
  }
}

enum StudioCodeOutputMode: String, CaseIterable, Identifiable {
  case presetBased
  case standalone

  var id: String { rawValue }

  var title: String {
    switch self {
    case .presetBased: "Preset"
    case .standalone: "Standalone"
    }
  }
}
