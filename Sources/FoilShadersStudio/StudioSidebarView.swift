import SwiftUI

struct StudioSidebarView: View {
  @Binding var selectedShader: StudioShader

  var body: some View {
    List(StudioShader.allCases, selection: $selectedShader) { shader in
      Text(shader.displayName)
        .tag(shader)
    }
    .navigationTitle("Shaders")
    .navigationSplitViewColumnWidth(min: 180, ideal: 240, max: 320)
  }
}
