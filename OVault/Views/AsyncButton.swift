import SwiftUI
import Models

struct AsyncButton<T: View>: View {
    var role: ButtonRole?
    var action: () async throws -> Void
    @ViewBuilder var label: () -> T
    
    @Environment(\.notifier) private var notifier
    
    @State private var isDisabled = false
    @State private var showProgressView = false
    
    var body: some View {
        Button(role: role) {
            isDisabled = true
            
            Task {
                let progressViewTask = Task {
                    try await Task.sleep(nanoseconds: 100_000_000)
                    showProgressView = true
                }
                
                await notifier.execute {
                    try await action()
                }
                progressViewTask.cancel()
                
                isDisabled = false
                showProgressView = false
            }
        } label: {
            ZStack {
                label().opacity(showProgressView ? 0 : 1)
                
                if showProgressView {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .disabled(isDisabled)
    }
}

extension AsyncButton where T == Text {
    init(_ label: String,
         action: @escaping () async throws -> Void) {
        self.init(action: action) {
            Text(label)
        }
    }
    
    init(role: ButtonRole,
         _ label: String,
         action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            Text(label)
        }
    }
}

extension AsyncButton where T == Image {
    init(systemImage: String,
         action: @escaping () async throws -> Void) {
        self.init(action: action) {
            Image(systemName: systemImage)
        }
    }
    
    init(role: ButtonRole,
         systemImage: String,
         action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            Image(systemName: systemImage)
        }
    }
}

extension AsyncButton where T == Label<Text, Image> {
    init(_ label: String,
         systemImage: String,
         action: @escaping () async throws -> Void) {
        self.init(action: action) {
            Label(label, systemImage: systemImage)
        }
    }
    
    init(_ label: String,
         systemImage: String,
         role: ButtonRole,
         action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            Label(label, systemImage: systemImage)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        AsyncButton("Submit", action: { print("run action") })
        AsyncButton("Submit Delayed", action: {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000);
                print("run delayed action")
            } catch { }
        })
        AsyncButton("Submit Erroring", action: {
            print("run erroring action")
            throw OtpError.unexpectedSecretFormat
        })
        AsyncButton(role: .destructive, "Submit Destructive", action: {
            print("run destructive action")
        })
        AsyncButton("Labelled", systemImage: "trash") {
            print("run labelled action")
        }
        AsyncButton("Labelled Destructive", systemImage: "trash", role: .destructive) {
            print("run labelled destructive action")
        }
    }
    .withNotifierSupport()
    .previewEnvironment()
}
#endif
