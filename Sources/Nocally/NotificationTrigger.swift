import Foundation

public protocol NotificationTrigger {
    func nextTriggerDate() -> Date?
}

public protocol TimeIntervalNotificationTrigger: NotificationTrigger {
    init(timeInterval: TimeInterval, repeats: Bool)

    var timeInterval: TimeInterval { get }
}

public protocol CalendarNotificationTrigger: NotificationTrigger {
    init(dateMatching: DateComponents, repeats: Bool)
}

public protocol NotificationTriggerFactory {
    var calendar: Calendar { get }

    func makeTimeIntervalNotificationTrigger(
        timeInterval: TimeInterval,
        repeats: Bool
    ) -> TimeIntervalNotificationTrigger

    func makeCalendarNotificationTrigger(
        dateMatching: DateComponents,
        repeats: Bool
    ) -> CalendarNotificationTrigger
}

extension NotificationTriggerFactory {
    var manualScheduleConstant: Int {
        return 5
    }

    func makeNotificationTriggers(using trigger: Trigger) -> [NotificationTrigger] {
        makeNotificationTrigger(using: trigger.startDate,
                                repeat: trigger.repeat)
    }

    func makeNotificationTrigger(
        using startDate: Date,
        `repeat`: Repeat
    ) -> [NotificationTrigger] {
        switch `repeat` {
        case .everyDay(let times):
            return makeEveryDayTrigger(using: startDate, times: times)
        case .daily(let everyDays, let time):
            switch everyDays {
            case 1:
                return makeEveryDayTrigger(using: startDate, times: [time])
            default:
                return makeDailyTrigger(everyDays: everyDays,
                                        using: startDate,
                                        time: time)
            }
        case .weekdays(let days, let time):
            return makeWeekdaysTrigger(days: days, time: time)
        case .weekly(let time):
            return makeWeeklyTrigger(using: startDate,
                                     time: time)
        case .monthly(let time):
            return makeMonthlyTrigger(using: startDate,
                                      time: time)
        case .yearly(let time):
            return makeYearlyTrigger(using: startDate,
                                     time: time)
        }
    }

    private func makeEveryDayTrigger(
        using startDate: Date,
        times: [Trigger.Time]
    ) -> [NotificationTrigger] {
        times.map { time in
            var daily = DateComponents()
            daily.hour = time.hour
            daily.minute = time.minute
            return makeCalendarNotificationTrigger(dateMatching: daily,
                                                   repeats: true)
        }
    }

    private func makeDailyTrigger(
        everyDays: UInt,
        using startDate: Date,
        time: Trigger.Time
    ) -> [NotificationTrigger] {
        var trigger = [NotificationTrigger]()
        var firstTrigger = startDate
        var addingComponents = DateComponents()

        addingComponents.day = Int(everyDays)

        let fullComponentsSet: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        var firstTriggerComponents = calendar.dateComponents(fullComponentsSet,
                                                             from: firstTrigger)
        firstTriggerComponents.hour = time.hour
        firstTriggerComponents.minute = time.minute
        firstTrigger = calendar.date(from: firstTriggerComponents) ?? firstTrigger

        while firstTrigger < Date() {
            firstTrigger = calendar.date(byAdding: addingComponents,
                                         to: firstTrigger) ?? firstTrigger
        }

        for _ in 0..<manualScheduleConstant {
            var components = calendar.dateComponents([.year, .month, .day],
                                                     from: firstTrigger)
            components.hour = time.hour
            components.minute = time.minute
            trigger.append(makeCalendarNotificationTrigger(dateMatching: components,
                                                           repeats: false))
            firstTrigger = calendar.date(byAdding: addingComponents,
                                         to: firstTrigger) ?? firstTrigger
        }

        return trigger
    }

    private func makeWeekdaysTrigger(
        days: [Int],
        time: Trigger.Time
    ) -> [NotificationTrigger] {
        let trigger: [NotificationTrigger] = days.map { day in
            var calendarComponents = DateComponents()

            calendarComponents.weekday = day
            calendarComponents.hour = time.hour
            calendarComponents.minute = time.minute

            return makeCalendarNotificationTrigger(dateMatching: calendarComponents,
                                                   repeats: true)
        }

        return trigger
    }

    private func makeWeeklyTrigger(
        using startDate: Date,
        time: Trigger.Time
    ) -> [NotificationTrigger] {
        let components = calendar.dateComponents([.weekday], from: startDate)

        var calendarComponents = DateComponents()
        calendarComponents.weekday = components.weekday
        calendarComponents.hour = time.hour
        calendarComponents.minute = time.minute

        return [
            makeCalendarNotificationTrigger(dateMatching: calendarComponents,
                                            repeats: true)
        ]
    }

    private func makeMonthlyTrigger(
        using startDate: Date,
        time: Trigger.Time
    ) -> [NotificationTrigger] {
        let components = calendar.dateComponents([.day], from: startDate)

        var calendarComponents = DateComponents()
        calendarComponents.day = components.day
        calendarComponents.hour = time.hour
        calendarComponents.minute = time.minute

        return [
            makeCalendarNotificationTrigger(dateMatching: calendarComponents,
                                            repeats: true)
        ]
    }

    private func makeYearlyTrigger(
        using startDate: Date,
        time: Trigger.Time
    ) -> [NotificationTrigger] {
        let components = calendar.dateComponents([.day, .month], from: startDate)

        var calendarComponents = DateComponents()
        calendarComponents.day = components.day
        calendarComponents.month = components.month
        calendarComponents.hour = time.hour
        calendarComponents.minute = time.minute

        return [
            makeCalendarNotificationTrigger(dateMatching: calendarComponents,
                                            repeats: true)
        ]
    }
}

#if os(iOS)

import NotificationCenter

public final class SystemNotificationTriggerFactory: NotificationTriggerFactory {
    public var calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func makeTimeIntervalNotificationTrigger(timeInterval: TimeInterval, repeats: Bool) -> TimeIntervalNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
    }

    public func makeCalendarNotificationTrigger(dateMatching: DateComponents, repeats: Bool) -> CalendarNotificationTrigger {
        return UNCalendarNotificationTrigger(dateMatching: dateMatching, repeats: repeats)
    }
}

extension UNTimeIntervalNotificationTrigger: TimeIntervalNotificationTrigger { }
extension UNCalendarNotificationTrigger: CalendarNotificationTrigger { }

#endif
