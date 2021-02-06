import XCTest
@testable import Nocally

final class NotificationStoreTests: XCTestCase {
    var userDefaults: MockNotificationUserDefaults!

    override func setUp() {
        self.userDefaults = MockNotificationUserDefaults()
    }

    func test_allNotifications_isEmpty_withoutInsert() {
        let store = DefaultNotificationStore(userDefaults: userDefaults)
        XCTAssert(store.allNotifications.count == 0)
    }

    func test_allNotification_containsNotification() {
        let trigger = Trigger(startDate: Date(), repeat: .yearly(time: Trigger.Time(hour: 12, minute: 12)))
        let notification = Nocally.Notification(identifier: "test",
                                                title: "hi",
                                                message: "body",
                                                trigger: trigger)
        userDefaults.allNotifications.append(notification)
        let store = DefaultNotificationStore(userDefaults: userDefaults)

        XCTAssert(store.allNotifications.count == 1)
        XCTAssert(store.allNotifications.first?.identifier == "test")
    }

    func test_store_insertsNotification() {
        let trigger = Trigger(startDate: Date(), repeat: .yearly(time: Trigger.Time(hour: 12, minute: 12)))
        let notification = Nocally.Notification(identifier: "test",
                                                title: "hi",
                                                message: "body",
                                                trigger: trigger)

        let store = DefaultNotificationStore(userDefaults: userDefaults)
        try? store.store(notification: notification)

        XCTAssert(userDefaults.allNotifications.count == 1)
        XCTAssert(userDefaults.allNotifications.first?.identifier == "test")
    }

    func test_store_throwsIfIdentifierExists() {
        let trigger = Trigger(startDate: Date(), repeat: .yearly(time: Trigger.Time(hour: 12, minute: 12)))
        let notification = Nocally.Notification(identifier: "test",
                                                title: "hi",
                                                message: "body",
                                                trigger: trigger)
        userDefaults.allNotifications.append(notification)

        let store = DefaultNotificationStore(userDefaults: userDefaults)
        XCTAssertThrowsError(try store.store(notification: notification))
    }

    func test_remove_removesNotification() {
        let trigger = Trigger(startDate: Date(), repeat: .yearly(time: Trigger.Time(hour: 12, minute: 12)))
        let notification = Nocally.Notification(identifier: "test",
                                                title: "hi",
                                                message: "body",
                                                trigger: trigger)
        userDefaults.allNotifications.append(notification)

        let store = DefaultNotificationStore(userDefaults: userDefaults)
        store.remove(notification: notification)

        XCTAssertEqual(userDefaults.allNotifications.count, 0)
    }
}

final class MockNotificationUserDefaults: NotificationUserDefaults {
    var allNotifications: [Nocally.Notification] = []
}
