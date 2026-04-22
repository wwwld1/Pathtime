import XCTest
@testable import PathTimeShared

final class TrainArrivalTests: XCTestCase {

    private let fetchedAt = Date(timeIntervalSince1970: 1_000_000)

    func test_arrivalDate_equalsFetchedAtPlusSeconds() {
        let train = TrainArrival.make(secondsToArrival: 300, fetchedAt: fetchedAt)
        XCTAssertEqual(train.arrivalDate, fetchedAt.addingTimeInterval(300))
    }

    func test_remainingSeconds_fullAmountWhenJustFetched() {
        let train = TrainArrival.make(secondsToArrival: 300, fetchedAt: fetchedAt)
        XCTAssertEqual(train.remainingSeconds(at: fetchedAt), 300)
    }

    func test_remainingSeconds_decreasesWithElapsedTime() {
        let train = TrainArrival.make(secondsToArrival: 300, fetchedAt: fetchedAt)
        let now = fetchedAt.addingTimeInterval(100)
        XCTAssertEqual(train.remainingSeconds(at: now), 200)
    }

    func test_remainingSeconds_exactlyAtArrivalReturnsZero() {
        let train = TrainArrival.make(secondsToArrival: 300, fetchedAt: fetchedAt)
        let now = fetchedAt.addingTimeInterval(300)
        XCTAssertEqual(train.remainingSeconds(at: now), 0)
    }

    func test_remainingSeconds_clampsToZeroAfterArrival() {
        let train = TrainArrival.make(secondsToArrival: 300, fetchedAt: fetchedAt)
        let now = fetchedAt.addingTimeInterval(400)
        XCTAssertEqual(train.remainingSeconds(at: now), 0)
    }

    func test_remainingMinutes_isFloorDivision() {
        let train = TrainArrival.make(secondsToArrival: 359, fetchedAt: fetchedAt)
        XCTAssertEqual(train.remainingMinutes(at: fetchedAt), 5)
    }

    func test_remainingMinutes_zeroWhenUnder60Seconds() {
        let train = TrainArrival.make(secondsToArrival: 59, fetchedAt: fetchedAt)
        XCTAssertEqual(train.remainingMinutes(at: fetchedAt), 0)
    }

    func test_displayTime_returnsNow_when0Seconds() {
        let train = TrainArrival.make(secondsToArrival: 0, fetchedAt: fetchedAt)
        XCTAssertEqual(train.displayTime(at: fetchedAt), "Now")
    }

    func test_displayTime_returnsNow_when59Seconds() {
        let train = TrainArrival.make(secondsToArrival: 59, fetchedAt: fetchedAt)
        XCTAssertEqual(train.displayTime(at: fetchedAt), "Now")
    }

    func test_displayTime_returns1Min_when60Seconds() {
        let train = TrainArrival.make(secondsToArrival: 60, fetchedAt: fetchedAt)
        XCTAssertEqual(train.displayTime(at: fetchedAt), "1 min")
    }

    func test_displayTime_returns1Min_when119Seconds() {
        let train = TrainArrival.make(secondsToArrival: 119, fetchedAt: fetchedAt)
        XCTAssertEqual(train.displayTime(at: fetchedAt), "1 min")
    }

    func test_displayTime_returns2Min_when120Seconds() {
        let train = TrainArrival.make(secondsToArrival: 120, fetchedAt: fetchedAt)
        XCTAssertEqual(train.displayTime(at: fetchedAt), "2 min")
    }

    func test_displayTime_returnsNow_afterTrainHasPassed() {
        let train = TrainArrival.make(secondsToArrival: 60, fetchedAt: fetchedAt)
        let now = fetchedAt.addingTimeInterval(200)
        XCTAssertEqual(train.displayTime(at: now), "Now")
    }
}
