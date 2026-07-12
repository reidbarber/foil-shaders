import SwiftUI

struct StudioCodeView: View {
  let code: String
  let didCopy: Bool
  let copy: () -> Void

  var body: some View {
    GroupBox("Code") {
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
    }
  }
}
