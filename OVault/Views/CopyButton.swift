import SwiftUI

struct CopyButton: View {
    var title: String
    var value: String
    
    @State private var internalTitle: String
    
    init(_ title: String, value: String) {
        self.title = title
        self._internalTitle = State(initialValue: title)
        self.value = value
    }
    
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
                internalTitle = "Copied!"
                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(2))) {
                    withAnimation {
                        internalTitle = title
                    }
                }
            }
        } label: {
            Label(internalTitle, systemImage: "rectangle.portrait.on.rectangle.portrait.fill")
                .fixedSize()
        }
        .buttonStyle(.borderedProminent)
        .disabled(internalTitle != title)
    }
}

#Preview {
    CopyButton("Copy!", value: "123456")
}
