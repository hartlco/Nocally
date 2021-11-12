import Foundation

public enum Repeat: Codable, Equatable {
    case everyDay(times: [Trigger.Time])
    case everyDays(UInt = 2, time: Trigger.Time)

    /// Based on `DateComponents.weekday`
    case weekdays([Int], time: Trigger.Time)
    case weekly(time: Trigger.Time)
    case monthly(time: Trigger.Time)
    case yearly(time: Trigger.Time)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .everyDay:
            let times = try container.decode(
                [Trigger.Time].self,
                forKey: .everyDay
            )
            self = .everyDay(times: times)
        case .daily:
            let (daily, time): (UInt, Trigger.Time) = try container.decodeValues(for: .daily)
            self = .everyDays(daily, time: time)
        case .weekdays:
            let (days, time): ([Int], Trigger.Time) = try container.decodeValues(for: .weekdays)
            self = .weekdays(days, time: time)
        case .weekly:
            let time = try container.decode(
                Trigger.Time.self,
                forKey: .weekly
            )
            self = .weekly(time: time)
        case .monthly:
            let time = try container.decode(
                Trigger.Time.self,
                forKey: .monthly
            )
            self = .monthly(time: time)
        case .yearly:
            let time = try container.decode(
                Trigger.Time.self,
                forKey: .yearly
            )
            self = .yearly(time: time)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .everyDay(let times):
            try container.encode(times, forKey: .everyDay)
        case .everyDays(let daily, let time):
            try container.encodeValues(daily, time, for: .daily)
        case .weekdays(let days, let time):
            try container.encodeValues(days, time, for: .weekdays)
        case .weekly(let time):
            try container.encode(time, forKey: .weekly)
        case .monthly(let time):
            try container.encode(time, forKey: .monthly)
        case .yearly(let time):
            try container.encode(time, forKey: .yearly)
        }
    }
}

extension Repeat {
    enum CodingKeys: CodingKey {
        case everyDay, daily, weekdays, weekly, monthly, yearly
    }
}

extension KeyedEncodingContainer {
    mutating func encodeValues<V1: Encodable, V2: Encodable>(
        _ v1: V1,
        _ v2: V2,
        for key: Key) throws {

        var container = self.nestedUnkeyedContainer(forKey: key)
        try container.encode(v1)
        try container.encode(v2)
    }
}

extension KeyedDecodingContainer {
    func decodeValues<V1: Decodable, V2: Decodable>(
        for key: Key) throws -> (V1, V2) {

        var container = try self.nestedUnkeyedContainer(forKey: key)
        return (
            try container.decode(V1.self),
            try container.decode(V2.self)
        )
    }
}
