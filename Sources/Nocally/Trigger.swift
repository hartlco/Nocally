import Foundation
import NotificationCenter

public struct Trigger: Codable {
    public struct Time: Codable, Equatable {
        public init(hour: Int, minute: Int) {
            self.hour = hour
            self.minute = minute
        }

        let hour: Int
        let minute: Int
    }

    public init(startDate: Date, repeat: Repeat) {
        self.startDate = startDate
        self.repeat = `repeat`
    }

    /// The initial day used to schedule the notification.
    let startDate: Date

    /// The interval for re-triggering the notification.
    let `repeat`: Repeat
}

public struct Notification: Codable {
    public let identifier: String
    public let title: String
    public let message: String
    public let trigger: Trigger

    // TODO: Add private schedule identifier to avoid collisions

    public init(identifier: String, title: String, message: String, trigger: Trigger) {
        self.identifier = identifier
        self.title = title
        self.message = message
        self.trigger = trigger
    }
}
