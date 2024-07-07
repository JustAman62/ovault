//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [OtpEntry]

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    OtpEntryView(otp: item)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .previewEnvironment()
}
#endif
