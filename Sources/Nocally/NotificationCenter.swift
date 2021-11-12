import Foundation

protocol NotificationCenter {
    var triggerFactory: NotificationTriggerFactory { get }

    func requestAuthorization(options: AuthorizationOption,
                              completionHandler: @escaping (Bool, Error?) -> Void)

    func add(notification: Notification, completion: @escaping (([Error]) -> Void))
    func nextFireDate(for notification: Notification) -> Date?

    func removeAllPendingNotificationRequests()
    func removePendingNotificationRequest(for notification: Notification)
}

#if os(iOS)
import NotificationCenter

extension UNUserNotificationCenter: NotificationCenter {
    public var triggerFactory: NotificationTriggerFactory {
        return SystemNotificationTriggerFactory()
    }

    public func requestAuthorization(options: AuthorizationOption,
                                     completionHandler: @escaping (Bool, Error?) -> Void) {
        var systemOptions: UNAuthorizationOptions = []

        if options.contains(.alert) {
            systemOptions.insert(.alert)
        }

        if options.contains(.badge) {
            systemOptions.insert(.badge)
        }

        if options.contains(.sound) {
            systemOptions.insert(.sound)
        }

        requestAuthorization(options: systemOptions, completionHandler: completionHandler)
    }

    public func add(notification: Notification, completion: @escaping (([Error]) -> Void)) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message

        let triggers = triggerFactory.makeNotificationTriggers(using: notification.trigger)

        let requests: [UNNotificationRequest] = triggers
            .enumerated()
            .compactMap { offset, trigger in
            guard let trigger = trigger as? UNNotificationTrigger else {
                return nil
            }

            return UNNotificationRequest(identifier: "\(notification.identifier)-\(offset)",
                                         content: content,
                                         trigger: trigger)
        }

        let group = DispatchGroup()
        var errors: [Error] = []

        for request in requests {
            group.enter()
            add(request) { error in
                if let error = error {
                    errors.append(error)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(errors)
        }
    }

    func nextFireDate(for notification: Notification) -> Date? {
        var triggers = triggerFactory.makeNotificationTriggers(using: notification.trigger)
        triggers = triggers.sorted { (lhs, rhs) -> Bool in
            guard let lhsDate = lhs.nextTriggerDate(), let rhsDate = rhs.nextTriggerDate() else {
                return false
            }

            return lhsDate < rhsDate
        }

        return triggers.first?.nextTriggerDate()
    }

    public func removePendingNotificationRequest(for notification: Notification) {
        let identifier = "\(notification.identifier)-"
        getPendingNotificationRequests { requests in
            let requestIdentifiers = requests
                .filter { $0.identifier.starts(with: identifier) }
                .map { $0.identifier }

            self.removePendingNotificationRequests(withIdentifiers: requestIdentifiers)
        }
    }
}
#endif
