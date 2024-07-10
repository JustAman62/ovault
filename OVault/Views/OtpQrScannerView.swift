import SwiftUI
import CodeScanner
import Models

struct OtpQrScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.notifier) private var notifier
    @Environment(\.keychain) private var keychain
    
    private func onCodeScan(res: Result<ScanResult, ScanError>) {
        switch res {
        case .failure(let error):
            notifier.show(msg: .inAppError(error: error))
        case .success(let result):
            notifier.execute {
                if let url = URL(string: result.string) {
                    let (otp, secret) = try OtpMetadata.from(url: url)
                    try keychain.storeSecret(metadata: otp, secret: secret)
                    modelContext.insert(otp)
                    try modelContext.save()
                } else {
                    notifier.show(msg: .inApp(title: "Unable to parse URL", msg: "Unable to parse the URL in the QR code"))
                }
                
                DispatchQueue.main.async { dismiss() }
            }
        }
    }
    
    var body: some View {
        CodeScannerView(
            codeTypes: [.qr],
            scanMode: .once,
            manualSelect: false,
            scanInterval: 0.5,
            showViewfinder: true,
            simulatedData: "otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example",
            shouldVibrateOnSuccess: true,
            isGalleryPresented: .constant(false),
            videoCaptureDevice: .zoomedCameraForQRCode(withMinimumCodeSize: 20),
            completion: onCodeScan)
        .ignoresSafeArea(.all)
    }
}

#if DEBUG
#Preview {
    OtpQrScannerView()
        .previewEnvironment()
}
#endif
