import SwiftUI

struct StudioEditorView: View {
  @Environment(\.undoManager) private var undoManager
  @StateObject private var model = StudioEditorModel()

  var body: some View {
    NavigationSplitView {
      StudioSidebarView(model: model)
    } detail: {
      HSplitView {
        StudioPreviewView(model: model)
          .frame(minWidth: 300)
          .layoutPriority(1)

        StudioInspectorView(model: model)
          .frame(minWidth: 280, idealWidth: 380, maxWidth: 520)
      }
      .navigationTitle(model.selectedShader.displayName)
    }
    .onAppear {
      model.undoManager = undoManager
    }
  }
}
