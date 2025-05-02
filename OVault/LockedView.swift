import Foundation
import LocalAuthentication
import OSLog
import SwiftUI

struct LockedView<T: View>: View {
    init(lockEnabled: Bool, @ViewBuilder _ content: @escaping () -> T) {
        self.lockEnabled = lockEnabled
        self.content = content
    }
    
    @Environment(\.notifier) private var notifier
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isAuthenticated: Bool? = nil
    private var logger: Logger = .init(LockedView.self)
    
    private var lockEnabled: Bool
    private var content: () -> T
    
    private func authenticate() async -> Bool? {
        if !lockEnabled {
            self.logger.info("App Lock is disabled")
            return true
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            self.logger.info("Asking device to authenticate owner")
            
            let reason = "to unlock your OTPs"
            
            do {
                return try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: reason
                )
            } catch {
                logger.error("Failed to authenticate, \(error)")
                return false
            }
        } else {
            logger.info("Device does not support authentication")
            return true
        }
    }
    
    var body: some View {
        switch isAuthenticated {
        case .none:
            VStack {
                Image(.launchScreen)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200)
                ProgressView("Authenticating...")
                    .foregroundStyle(.secondaryAccent)
                    .tint(.secondaryAccent)
                    .font(.headline.bold())
                    .controlSize(.large)
                    .task {
                        self.isAuthenticated = await authenticate()
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.accent)
        case .some(false):
            VStack {
                Image(.launchScreen)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200)
                Text("Failed to unlock. Please try again.")
                    .foregroundStyle(.secondaryAccent)
                    .font(.headline.bold())

                AsyncButton {
                    self.isAuthenticated = await authenticate()
                } label: {
                    Label("Unlock", systemImage: "lock.open")
                        .font(.headline.bold())
                        .padding()
                        .background(.secondaryAccent)
                        .foregroundStyle(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.accent)
        case .some(true):
            content()
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background {
                        isAuthenticated = nil
                    }
                }
        }
    }
}

#if DEBUG
#Preview("Enabled") {
    LockedView(lockEnabled: true) {
        Text("Hidden View")
    }
    .withNotifierSupport()
}

#Preview("Disabled") {
    LockedView(lockEnabled: false) {
        Text("Hidden View")
    }
    .withNotifierSupport()
}

#endif

