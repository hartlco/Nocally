import Foundation

protocol NotificationUserDefaults {
    var allNotifications: [Notification] { get set }
}

protocol NotificationStore {
    func store(notification: Notification) throws
    func remove(notification: Notification)
    var allNotifications: [Notification] { get }
}

final class DefaultNotificationStore: NotificationStore {
    enum NotificationStoreError: Error {
        case notificationIdentifierNotUnique
    }

    public static let suiteName = "Nocally.NotificationStore.UserDefaults"

    private var userDefaults: NotificationUserDefaults

    public init(userDefaults: NotificationUserDefaults = UserDefaults(suiteName: DefaultNotificationStore.suiteName)
            ?? .standard) {
        self.userDefaults = userDefaults
    }

    var allNotifications: [Notification] {
        return userDefaults.allNotifications
    }

    func store(notification: Notification) throws {
        var allNotifications = self.allNotifications

        if allNotifications.contains(where: {
            notification.identifier == $0.identifier
        }) {
            throw NotificationStoreError.notificationIdentifierNotUnique
        }

        allNotifications.append(notification)
        userDefaults.allNotifications = allNotifications
    }

    func remove(notification: Notification) {
        var allNotifications = self.allNotifications

        allNotifications.removeAll { $0.identifier == notification.identifier }
        userDefaults.allNotifications = allNotifications
    }
}

extension UserDefaults: NotificationUserDefaults {
    static let notifications = "Nocally.NotificationStore.UserDefaults.notifications"

    public var allNotifications: [Notification] {
        get {
            guard let data = data(forKey: Self.notifications),
                  let array = try? JSONDecoder().decode([Notification].self, from: data) else {
                return []
            }

            return array
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }

            set(data, forKey: Self.notifications)
        }
    }
}
