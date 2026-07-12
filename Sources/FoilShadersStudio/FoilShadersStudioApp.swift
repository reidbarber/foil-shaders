import SwiftUI

@main
struct FoilShadersStudioApp: App {
  var body: some Scene {
    WindowGroup("Foil Shader Studio") {
      StudioEditorView()
    }
    .defaultSize(width: 1180, height: 760)
  }
}
