import SwiftUI

struct OVTextField: View {
    var title: LocalizedStringKey
    var text: Binding<String>
    var placeholder: String?
    
    init(_ title: LocalizedStringKey, text: Binding<String>, placeholder: String? = nil) {
        self.title = title
        self.text = text
        self.placeholder = placeholder
    }
    
    var body: some View {
#if os(macOS)
        TextField(title, text: text, prompt: Text(placeholder ?? ""))
#else
        LabeledContent(title) {
            TextField(text: text, prompt: Text(placeholder ?? "")) {
                EmptyView()
            }
            .multilineTextAlignment(.trailing)
        }
#endif
    }
}

#Preview {
    @Previewable @State var value: String = "Test Value"
    return Form {
        OVTextField("Test", text: $value)
        OVTextField("Long Name", text: $value, placeholder: "Long Name Placeholder")
        OVTextField("Very Long Name", text: $value)
    }
}
