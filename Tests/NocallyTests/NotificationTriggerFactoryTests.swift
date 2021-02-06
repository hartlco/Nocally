import XCTest
@testable import Nocally

final class NotificationTriggerFactoryTests: XCTestCase {
    // MARK: - makeNotificationTriggers
    let calendar = Calendar(identifier: .gregorian)
    let factory = MockNotificationTriggerFactory(calendar: Calendar(identifier: .gregorian))

    func test_makeNotificationTriggers_everyDayTrigger_singleTime() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let date = Date().addingTimeInterval(86399)

        let trigger = Trigger(startDate: date,
                              repeat: .everyDay(times: [time]))

        let triggers = factory.makeNotificationTriggers(using: trigger)
        XCTAssertEqual(triggers.count, 1)
        let dateComponents = DateComponents(hour: 12, minute: 12)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)
        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).repeats, true)
    }

    func test_makeNotificationTriggers_everyDayTrigger_multipleTimes() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let time2 = Trigger.Time(hour: 22, minute: 22)
        let date = Date().addingTimeInterval(86399)

        let trigger = Trigger(startDate: date,
                              repeat: .everyDay(times: [time, time2]))

        let triggers = factory.makeNotificationTriggers(using: trigger)
        XCTAssertEqual(triggers.count, 2)
        let dateComponents = DateComponents(hour: 12, minute: 12)
        let dateComponents2 = DateComponents(hour: 22, minute: 22)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)
        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).repeats, true)

        XCTAssertEqual((triggers[1] as! MockCalendarNotificationTrigger).dateMatching, dateComponents2)
        XCTAssertEqual((triggers[1] as! MockCalendarNotificationTrigger).repeats, true)
    }

    func test_makeNotificationTrigger_dailyTrigger_startsBeforeNow() {
        var minusMinute = DateComponents()
        minusMinute.day = -1
        let pastDate = calendar.date(byAdding: minusMinute,
                                           to: Date())!
        let pastComponents = calendar.dateComponents([.year, .month, .day], from: pastDate)
        let time = Trigger.Time(hour: 12, minute: 12)

        let trigger = Trigger(startDate: pastDate,
                              repeat: .daily(2, time: time))

        let triggers = factory.makeNotificationTriggers(using: trigger)
        XCTAssertEqual(triggers.count, 5)


        var dateComponents = DateComponents(year: pastComponents.year,
                                            month: pastComponents.month,
                                            day: pastComponents.day,
                                            hour: 12,
                                            minute: 12)
        var compareDate = calendar.date(from: dateComponents)!
        let plusComponent = DateComponents(day: 2)

        compareDate = calendar.date(byAdding: plusComponent, to: compareDate)!
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: compareDate)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)

        compareDate = calendar.date(byAdding: plusComponent, to: compareDate)!
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: compareDate)

        XCTAssertEqual((triggers[1] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).repeats, false)
    }

    func test_makeNotificationTrigger_dailyTrigger_startsPastNow() {
        var minusMinute = DateComponents()
        minusMinute.minute = 2
        let pastDate = calendar.date(byAdding: minusMinute,
                                           to: Date())!
        let pastComponents = calendar.dateComponents([.year, .month, .day], from: pastDate)
        let time = Trigger.Time(hour: 12, minute: 12)

        let trigger = Trigger(startDate: pastDate,
                              repeat: .daily(2, time: time))

        let triggers = factory.makeNotificationTriggers(using: trigger)
        XCTAssertEqual(triggers.count, 5)


        var dateComponents = DateComponents(year: pastComponents.year,
                                            month: pastComponents.month,
                                            day: pastComponents.day,
                                            hour: 12,
                                            minute: 12)
        var compareDate = calendar.date(from: dateComponents)!
        let plusComponent = DateComponents(day: 2)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)

        compareDate = calendar.date(byAdding: plusComponent, to: compareDate)!
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: compareDate)

        XCTAssertEqual((triggers[1] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).repeats, false)
    }

    func test_makeNotificationTrigger_dailyTrigger_startsSameDayBeforeNow() {
        var pastComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        pastComponents.day = (pastComponents.day ?? 0) - 1
        pastComponents.hour = 12
        pastComponents.minute = 10
        let pastDate = calendar.date(from: pastComponents)!

        let time = Trigger.Time(hour: 12, minute: 12)

        let trigger = Trigger(startDate: pastDate,
                              repeat: .daily(2, time: time))

        let triggers = factory.makeNotificationTriggers(using: trigger)
        XCTAssertEqual(triggers.count, 5)


        var dateComponents = DateComponents(year: pastComponents.year,
                                            month: pastComponents.month,
                                            day: pastComponents.day,
                                            hour: 12,
                                            minute: 12)
        var compareDate = calendar.date(from: dateComponents)!
        let plusComponent = DateComponents(day: 2)

        compareDate = calendar.date(byAdding: plusComponent, to: compareDate)!
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: compareDate)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)

        compareDate = calendar.date(byAdding: plusComponent, to: compareDate)!
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: compareDate)

        XCTAssertEqual((triggers[1] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).repeats, false)
    }

    func test_makeNotificationTrigger_weekdays() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let date = Date().addingTimeInterval(86399)

        let trigger = Trigger(startDate: date,
                              repeat: .weekdays([2,3], time: time))

        let triggers = factory.makeNotificationTriggers(using: trigger)

        XCTAssertEqual(triggers.count, 2)
        let dateComponents1 = DateComponents(hour: 12, minute: 12, weekday: 2)
        let dateComponents2 = DateComponents(hour: 12, minute: 12, weekday: 3)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).dateMatching, dateComponents1)
        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).repeats, true)

        XCTAssertEqual((triggers[1] as! MockCalendarNotificationTrigger).dateMatching, dateComponents2)
        XCTAssertEqual((triggers[1] as! MockCalendarNotificationTrigger).repeats, true)
    }

    func test_makeNotificationTrigger_weekly() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let date = Date().addingTimeInterval(86399)

        let trigger = Trigger(startDate: date,
                              repeat: .weekly(time: time))

        let triggers = factory.makeNotificationTriggers(using: trigger)
        XCTAssertEqual(triggers.count, 1)
        let weekday = calendar.dateComponents([.weekday], from: date).weekday
        let dateComponents = DateComponents(hour: 12, minute: 12, weekday: weekday!)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)
        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).repeats, true)
    }

    func test_makeNotificationTrigger_monthly() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let date = Date().addingTimeInterval(86399)

        let trigger = Trigger(startDate: date,
                              repeat: .monthly(time: time))

        let triggers = factory.makeNotificationTriggers(using: trigger)
        XCTAssertEqual(triggers.count, 1)
        let day = calendar.dateComponents([.day], from: date).day
        let dateComponents = DateComponents(day: day!, hour: 12, minute: 12)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)
        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).repeats, true)
    }

    func test_makeNotificationTrigger_yearly() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let date = Date().addingTimeInterval(86399)

        let trigger = Trigger(startDate: date,
                              repeat: .yearly(time: time))

        let triggers = factory.makeNotificationTriggers(using: trigger)
        XCTAssertEqual(triggers.count, 1)
        let todayComponents = calendar.dateComponents([.day, .month], from: date)
        let day = todayComponents.day
        let month = todayComponents.month
        let dateComponents = DateComponents(month: month!,day: day!, hour: 12, minute: 12)

        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).dateMatching, dateComponents)
        XCTAssertEqual((triggers[0] as! MockCalendarNotificationTrigger).repeats, true)
    }

    static var allTests = [
        ("test_makeNotificationTriggers_everyDayTrigger_singleTime", test_makeNotificationTriggers_everyDayTrigger_singleTime),
        ("test_makeNotificationTriggers_everyDayTrigger_multipleTimes", test_makeNotificationTriggers_everyDayTrigger_multipleTimes)
    ]
}

struct MockNotificationTriggerFactory: NotificationTriggerFactory {
    var calendar: Calendar

    func makeTimeIntervalNotificationTrigger(timeInterval: TimeInterval, repeats: Bool) -> TimeIntervalNotificationTrigger {
        MockTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                            repeats: repeats)
    }

    func makeCalendarNotificationTrigger(dateMatching: DateComponents, repeats: Bool) -> CalendarNotificationTrigger {
        MockCalendarNotificationTrigger(dateMatching: dateMatching,
                                        repeats: repeats)
    }
}

struct MockTimeIntervalNotificationTrigger: TimeIntervalNotificationTrigger {
    init(timeInterval: TimeInterval, repeats: Bool) {
        self.timeInterval = timeInterval
        self.repeats = repeats
    }

    func nextTriggerDate() -> Date? {
        fatalError()
    }

    var repeats: Bool
    var timeInterval: TimeInterval
}

struct MockCalendarNotificationTrigger: CalendarNotificationTrigger {
    init(dateMatching: DateComponents, repeats: Bool) {
        self.dateMatching = dateMatching
        self.repeats = repeats
    }

    func nextTriggerDate() -> Date? {
        fatalError()
    }

    var repeats: Bool
    var dateMatching: DateComponents
}
