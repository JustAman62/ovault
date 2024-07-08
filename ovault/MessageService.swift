import Foundation
import SwiftUI

enum Message {
    case inApp(error: LocalizedError)
    case inApp(msg: String)
}

final class MessageService {
    private var _message: Message?

    var message: Message? { get { _message } }
    
    func show(msg: Message, duration: DispatchTimeInterval) {
        self._message = msg
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: duration)) {
            self._message = nil
        }
    }
    
    func show(msg: Message) {
        self._message = msg
    }
}

struct MessageServiceKey: EnvironmentKey {
    static let defaultValue = MessageService()
}

extension EnvironmentValues {
    var messageService: MessageService {
        get { self[MessageServiceKey.self] }
        set { self[MessageServiceKey.self] = newValue }
    }
}
