import XCTest
@testable import PathTimeShared

final class PinnedRouteTests: XCTestCase {

    func test_displayTitle_withoutFilter_showsDirectionShortName() {
        let route = PinnedRoute.make(station: .JSQ, direction: .toNY, targetFilter: nil)
        XCTAssertEqual(route.displayTitle, "JSQ →NY")
    }

    func test_displayTitle_withFilter_showsDestination() {
        let route = PinnedRoute.make(station: .JSQ, direction: .toNY, targetFilter: "WTC")
        XCTAssertEqual(route.displayTitle, "JSQ → WTC")
    }

    func test_fullTitle_withoutFilter_showsFullNames() {
        let route = PinnedRoute.make(station: .JSQ, direction: .toNY, targetFilter: nil)
        XCTAssertEqual(route.fullTitle, "Journal Square To NY")
    }

    func test_fullTitle_withFilter_showsFullStationAndDestination() {
        let route = PinnedRoute.make(station: .JSQ, direction: .toNY, targetFilter: "WTC")
        XCTAssertEqual(route.fullTitle, "Journal Square → WTC")
    }

    func test_equality_basedOnContent_ignoringID() {
        let route1 = PinnedRoute(id: UUID(), station: .JSQ, direction: .toNY, targetFilter: "WTC")
        let route2 = PinnedRoute(id: UUID(), station: .JSQ, direction: .toNY, targetFilter: "WTC")
        XCTAssertNotEqual(route1.id, route2.id)
        XCTAssertEqual(route1, route2)
    }

    func test_inequality_differentStation() {
        let route1 = PinnedRoute.make(station: .JSQ)
        let route2 = PinnedRoute.make(station: .WTC)
        XCTAssertNotEqual(route1, route2)
    }

    func test_inequality_differentDirection() {
        let route1 = PinnedRoute.make(direction: .toNY)
        let route2 = PinnedRoute.make(direction: .toNJ)
        XCTAssertNotEqual(route1, route2)
    }

    func test_inequality_differentTargetFilter() {
        let route1 = PinnedRoute.make(targetFilter: "WTC")
        let route2 = PinnedRoute.make(targetFilter: "33S")
        XCTAssertNotEqual(route1, route2)
    }

    func test_inequality_nilVsNonNilFilter() {
        let route1 = PinnedRoute.make(targetFilter: nil)
        let route2 = PinnedRoute.make(targetFilter: "WTC")
        XCTAssertNotEqual(route1, route2)
    }

    func test_codableRoundtrip() throws {
        let original = PinnedRoute.make(station: .JSQ, direction: .toNY, targetFilter: "WTC")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PinnedRoute.self, from: data)
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.station, original.station)
        XCTAssertEqual(decoded.direction, original.direction)
        XCTAssertEqual(decoded.targetFilter, original.targetFilter)
    }

    // 已知问题：hash 基于 id，== 基于内容，违反 Hashable 契约。
    // 两个内容相同但 id 不同的 route 在 Set 中会被视为不同元素。
    func test_hashable_inconsistency_KNOWN_ISSUE() {
        XCTExpectFailure("Known bug: hash is id-based but == is content-based, so Set deduplication fails")
        let route1 = PinnedRoute(id: UUID(), station: .JSQ, direction: .toNY, targetFilter: nil)
        let route2 = PinnedRoute(id: UUID(), station: .JSQ, direction: .toNY, targetFilter: nil)
        XCTAssertEqual(route1, route2)
        let set: Set<PinnedRoute> = [route1, route2]
        XCTAssertEqual(set.count, 1, "Equal routes should deduplicate in a Set")
    }
}
