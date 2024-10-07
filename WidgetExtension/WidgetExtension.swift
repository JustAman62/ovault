import WidgetKit
import SwiftUI
import Models

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping @Sendable (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date(), otps: [.sample], showCodeForId: nil, code: nil, expiryDate: nil))
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<SimpleEntry>) -> Void) {
        Task {
            let showCodeForId = UserDefaults.standard.string(forKey: "WidgetShowCodeForId")
            let expiryDate = UserDefaults.standard.object(forKey: "WidgetShowCodeExpiryDate") as? Date
            let otps = (try? await Keychain.shared.getAll()) ?? []
            
            if let expiryDate, let showCodeForId, expiryDate > Date() {
                let otp = otps.first(where: { $0.id.uuidString == showCodeForId })
                let code = try? otp?.getOtp()
                
                let entries: [SimpleEntry] = [
                    .init(date: Date(), otps: otps, showCodeForId: showCodeForId, code: code, expiryDate: expiryDate),
                    .init(date: expiryDate.addingTimeInterval(1), otps: otps, showCodeForId: nil, code: nil, expiryDate: nil),
                ]
                completion(Timeline(entries: entries, policy: .atEnd))
                return
            }
            
            let entries: [SimpleEntry] = [
                .init(date: Date(), otps: otps, showCodeForId: nil, code: nil, expiryDate: nil)
            ]
            completion(Timeline(entries: entries, policy: .never))
            return
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), otps: [.sample], showCodeForId: nil, code: nil, expiryDate: nil)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let otps: [Otp]
    let showCodeForId: String?
    let code: String?
    let expiryDate: Date?
}


struct WidgetExtensionEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    private var columnCount: Int {
        switch widgetFamily {
        case .systemSmall: 1
        case .systemMedium: 2
        case .systemLarge: 2
        case .systemExtraLarge: 2
        default: 1
        }
    }
    
    private var maxOtps: Int {
        switch widgetFamily {
        case .systemSmall: 3
        case .systemMedium: 6
        case .systemLarge: 12
        case .systemExtraLarge: 12
        default: 1
        }
    }
    
    var rows: [[Otp]] { entry.otps.chunked(into: columnCount) }
    
    @ViewBuilder func buttonLabel(_ otp: Otp) -> some View {
        HStack(spacing: 0) {
            if let code = entry.code, entry.showCodeForId == otp.id.uuidString {
                VStack(spacing: 0) {
                    Text(code)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .lineLimit(1)
                    ProgressView(timerInterval: otp.lastExpiryDate...otp.nextExpiryDate)
                        .labelsHidden()
                }
                Spacer()
                Image(systemName: "eye.fill")
                    .font(.footnote)
            } else {
                VStack(alignment: .leading, spacing: 1) {
                    Text(otp.accountName)
                        .font(.caption2)
                        .lineLimit(1)
                    Text(otp.issuer)
                        .font(.caption2.bold())
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "eye")
                    .font(.footnote)
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(.accent.opacity(0.2)).stroke(.accent.secondary))
        .foregroundStyle(.accent)
        .tint(.accent)
        .contentShape(.rect(cornerRadius: 16))
    }
    
    var body: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            if entry.otps.isEmpty {
                Text("No OTPs selected")
            } else {
                ForEach(rows, id: \.first!.id) { row in
                    GridRow {
                        ForEach(row) { otp in
                            Button(intent: GenerateOtpAppIntent(id: otp.id.uuidString)) {
                                buttonLabel(otp)
                            }
                            .buttonStyle(.plain)
                            .buttonBorderShape(.roundedRectangle(radius: 16))
                        }
                    }
                }
            }
        }
        .padding(8)
    }
}

struct WidgetExtension: Widget {
    let kind: String = "WidgetExtension"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetExtensionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .containerBackgroundRemovable()
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

#if DEBUG
#Preview(as: .systemMedium) {
    Keychain.shared = FakeKeychain(withData: true)
    return WidgetExtension()
} timeline: {
    SimpleEntry(date: Date(), otps: [.testTotp15sec], showCodeForId: nil, code: nil, expiryDate: nil)
    SimpleEntry(date: Date(), otps: [.testTotp15sec], showCodeForId: Otp.testTotp30sec.id.uuidString, code: "123456", expiryDate: .now.addingTimeInterval(5))
}
#endif
