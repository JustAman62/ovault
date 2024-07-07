import SwiftUI

struct CopyButton: View {
    var value: String
    
    @State private var title: String = "Copy"
    
#if os(macOS)
    private func copy() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }
#else
    private func copy() {
        UIPasteboard.general.string = value
    }
#endif

    var body: some View {
        Button {
            copy()
            
            withAnimation {
                title = "Copied!"
                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(2))) {
                    withAnimation {
                        title = "Copy"
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.on.rectangle.portrait.fill")
                Text(title)
                    .fixedSize()
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(title != "Copy")
    }
}

#Preview {
    CopyButton(value: "123456")
}
