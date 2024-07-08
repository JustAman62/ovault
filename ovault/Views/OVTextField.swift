import SwiftUI

struct OVTextField: View {
    var title: LocalizedStringKey
    var text: Binding<String>
    
    init(_ title: LocalizedStringKey, text: Binding<String>) {
        self.title = title
        self.text = text
    }
    
    var body: some View {
#if os(macOS)
        TextField(title, text: text)
#else
        LabeledContent(title) {
            TextField(text: text) {
                EmptyView()
            }
            .multilineTextAlignment(.trailing)
        }
#endif
    }
}

#Preview {
    @State var value: String = "Test Value"
    return Form {
        OVTextField("Test", text: $value)
        OVTextField("Long Name", text: $value)
        OVTextField("Very Long Name", text: $value)
    }
}
