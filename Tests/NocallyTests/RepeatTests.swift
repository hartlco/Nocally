import XCTest
@testable import Nocally

final class RepeatTests: XCTestCase {
    func test_encodingDecoding_everyDay() {
        let times = [Trigger.Time(hour: 12, minute: 12)]
        let everyDay = Repeat.everyDay(times: times)

        let encodedString = encodeRepeat(everyDay)
        XCTAssertEqual(encodedString, "{\"everyDay\":[{\"minute\":12,\"hour\":12}]}")
        let decodedRepeat = decodeString("{\"everyDay\":[{\"minute\":12,\"hour\":12}]}")
        XCTAssertEqual(decodedRepeat, everyDay)
    }

    func test_encodingDecoding_daily() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let daily = Repeat.everyDays(2, time: time)

        let encodedString = encodeRepeat(daily)
        XCTAssertEqual(encodedString, "{\"daily\":[2,{\"minute\":12,\"hour\":12}]}")
        let decodedRepeat = decodeString("{\"daily\":[2,{\"minute\":12,\"hour\":12}]}")
        XCTAssertEqual(decodedRepeat, daily)
    }

    func test_encodingDecoding_weekly() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let weekly = Repeat.weekly(time: time)

        let encodedString = encodeRepeat(weekly)
        XCTAssertEqual(encodedString, "{\"weekly\":{\"minute\":12,\"hour\":12}}")
        let decodedRepeat = decodeString("{\"weekly\":{\"minute\":12,\"hour\":12}}")
        XCTAssertEqual(decodedRepeat, weekly)
    }

    func test_encodingDecoding_weekdays() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let days = [1,4,6]
        let weekdays = Repeat.weekdays(days, time: time)

        let encodedString = encodeRepeat(weekdays)
        XCTAssertEqual(encodedString, "{\"weekdays\":[[1,4,6],{\"minute\":12,\"hour\":12}]}")
        let decodedRepeat = decodeString("{\"weekdays\":[[1,4,6],{\"minute\":12,\"hour\":12}]}")
        XCTAssertEqual(decodedRepeat, weekdays)
    }

    func test_encodingDecoding_monthly() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let monthly = Repeat.monthly(time: time)

        let encodedString = encodeRepeat(monthly)
        XCTAssertEqual(encodedString, "{\"monthly\":{\"minute\":12,\"hour\":12}}")
        let decodedRepeat = decodeString("{\"monthly\":{\"minute\":12,\"hour\":12}}")
        XCTAssertEqual(decodedRepeat, monthly)
    }

    func test_encodingDecoding_yearly() {
        let time = Trigger.Time(hour: 12, minute: 12)
        let yearly = Repeat.yearly(time: time)

        let encodedString = encodeRepeat(yearly)
        XCTAssertEqual(encodedString, "{\"yearly\":{\"minute\":12,\"hour\":12}}")
        let decodedRepeat = decodeString("{\"yearly\":{\"minute\":12,\"hour\":12}}")
        XCTAssertEqual(decodedRepeat, yearly)
    }

    private func encodeRepeat(_ repeat: Repeat) -> String {
        let encoder = JSONEncoder()


        do {
            let encodedState = try encoder.encode(`repeat`)
            let encodedStateString = String(data: encodedState, encoding: .utf8)

            return encodedStateString!
        } catch {
            print(error.localizedDescription)
            fatalError()
        }
    }

    private func decodeString(_ string: String) -> Repeat {
        let decoder = JSONDecoder()
        let data = string.data(using: .utf8)

        do {
            let decodedViewState = try decoder.decode(Repeat.self, from: data!)
            return decodedViewState
        } catch {
            print(error.localizedDescription)
            fatalError()
        }
    }
}
