import SwiftUI

struct CopyButton: View {
    var title: LocalizedStringKey
    var value: String
    
    @State private var internalTitle: LocalizedStringKey
    
    init(_ title: LocalizedStringKey, value: String) {
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
        if #available(iOS 26.0, macOS 26.0, *) {
            self.button
                .labelIconToTitleSpacing(8)
        } else {
            self.button
        }
    }
    
    @ViewBuilder
    var button: some View {
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
                .foregroundStyle(.white)
        }
        .disabled(internalTitle != title)
    }
}

#Preview {
    CopyButton("Copy", value: "123456")
}
