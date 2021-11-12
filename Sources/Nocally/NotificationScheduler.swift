import Foundation
import NotificationCenter

public struct AuthorizationOption: OptionSet {
    public static let alert = AuthorizationOption(rawValue: 1)
    public static let badge = AuthorizationOption(rawValue: 1 << 1)
    public static let sound = AuthorizationOption(rawValue: 1 << 3)

    public let rawValue: Int8

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}

// TODO: Add tests

public final class NotificationScheduler {
    let notificationCenter: NotificationCenter
    let notificationStore: NotificationStore

    #if os(iOS)
    convenience public init() {
        self.init(notificationCenter: UNUserNotificationCenter.current(),
                  notificationStore: DefaultNotificationStore())
    }
    #endif

    internal init(
        notificationCenter: NotificationCenter,
        notificationStore: NotificationStore
    ) {
        self.notificationCenter = notificationCenter
        self.notificationStore = notificationStore
    }

    public func requestAuthorization(
        options: AuthorizationOption,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        notificationCenter.requestAuthorization(options: options,
                                                completionHandler: completionHandler)
    }

    public func schedule(notification: Notification) {
        do {
            try notificationStore.store(notification: notification)
            notificationCenter.add(notification: notification) { [weak self] errors in
                guard let self = self else { return }

                if !errors.isEmpty {
                    self.notificationCenter.removePendingNotificationRequest(for: notification)
                }
            }
        } catch {
            // TODO: Error handling
        }
    }

    public func remove(notification: Notification) {
        notificationCenter.removePendingNotificationRequest(for: notification)
        notificationStore.remove(notification: notification)
    }

    public var scheduledNotifications: [Notification] {
        return notificationStore.allNotifications
    }

    public func nextFireDate(for notification: Notification) -> Date? {
        notificationCenter.nextFireDate(for: notification)
    }

    // TODO: Reschedule
}


