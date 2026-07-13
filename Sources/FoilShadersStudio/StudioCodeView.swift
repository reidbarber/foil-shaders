import SwiftUI

struct StudioCodeView: View {
  let code: String
  @Binding var outputMode: StudioCodeOutputMode
  let canUsePreset: Bool
  let didCopy: Bool
  let copy: () -> Void

  var body: some View {
    GroupBox {
      ZStack(alignment: .topTrailing) {
        GeometryReader { proxy in
          ScrollView([.horizontal, .vertical]) {
            Text(code)
              .font(.system(.caption, design: .monospaced))
              .textSelection(.enabled)
              .padding(12)
              .padding(.top, 30)
              .frame(
                minWidth: proxy.size.width,
                minHeight: proxy.size.height,
                alignment: .topLeading
              )
          }
          .frame(width: proxy.size.width, height: proxy.size.height)
        }

        Button(
          didCopy ? "Copied" : "Copy",
          systemImage: didCopy ? "checkmark" : "doc.on.doc",
          action: copy
        )
        .controlSize(.small)
        .padding(8)
      }
      .frame(maxWidth: .infinity, minHeight: 220)
    } label: {
      HStack {
        Text("Code")
        Spacer()
        Picker("Output", selection: $outputMode) {
          ForEach(StudioCodeOutputMode.allCases) { mode in
            Text(mode.title)
              .tag(mode)
              .disabled(mode == .presetBased && !canUsePreset)
          }
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        .controlSize(.small)
        .frame(width: 150)
      }
    }
  }
}
