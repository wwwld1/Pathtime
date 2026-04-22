import XCTest
@testable import PathTimeShared

final class PinnedRoutesStoreTests: XCTestCase {

    private var store: PinnedRoutesStore!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = UUID().uuidString
        let ud = UserDefaults(suiteName: suiteName)!
        store = PinnedRoutesStore(userDefaults: ud)
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        store = nil
        super.tearDown()
    }

    func test_initialState_isEmpty() {
        XCTAssertTrue(store.routes.isEmpty)
    }

    func test_add_appendsRoute() {
        let route = PinnedRoute.make()
        store.add(route)
        XCTAssertEqual(store.routes.count, 1)
        XCTAssertEqual(store.routes.first, route)
    }

    func test_add_preventsDuplicates() {
        let route = PinnedRoute.make(station: .JSQ, direction: .toNY)
        store.add(route)
        store.add(PinnedRoute(id: UUID(), station: .JSQ, direction: .toNY))
        XCTAssertEqual(store.routes.count, 1)
    }

    func test_add_allowsDifferentRoutes() {
        store.add(PinnedRoute.make(station: .JSQ, direction: .toNY))
        store.add(PinnedRoute.make(station: .WTC, direction: .toNJ))
        XCTAssertEqual(store.routes.count, 2)
    }

    func test_add_preservesOrder() {
        let r1 = PinnedRoute.make(station: .JSQ, direction: .toNY)
        let r2 = PinnedRoute.make(station: .WTC, direction: .toNJ)
        let r3 = PinnedRoute.make(station: .HOB, direction: .toNY)
        store.add(r1); store.add(r2); store.add(r3)
        XCTAssertEqual(store.routes, [r1, r2, r3])
    }

    func test_contains_returnsTrueForExistingRoute() {
        let route = PinnedRoute.make()
        store.add(route)
        XCTAssertTrue(store.contains(route))
    }

    func test_contains_returnsFalseForMissingRoute() {
        XCTAssertFalse(store.contains(PinnedRoute.make()))
    }

    func test_remove_deletesMatchingRoute() {
        let route = PinnedRoute.make()
        store.add(route)
        store.remove(route)
        XCTAssertTrue(store.routes.isEmpty)
    }

    func test_remove_doesNothing_whenRouteNotPresent() {
        store.add(PinnedRoute.make(station: .JSQ))
        store.remove(PinnedRoute.make(station: .WTC))
        XCTAssertEqual(store.routes.count, 1)
    }

    func test_toggle_addsWhenAbsent() {
        let route = PinnedRoute.make()
        store.toggle(route)
        XCTAssertTrue(store.contains(route))
    }

    func test_toggle_removesWhenPresent() {
        let route = PinnedRoute.make()
        store.add(route)
        store.toggle(route)
        XCTAssertFalse(store.contains(route))
    }

    func test_move_reordersCorrectly() {
        let r1 = PinnedRoute.make(station: .JSQ, direction: .toNY)
        let r2 = PinnedRoute.make(station: .WTC, direction: .toNJ)
        let r3 = PinnedRoute.make(station: .HOB, direction: .toNY)
        store.add(r1); store.add(r2); store.add(r3)
        store.move(from: IndexSet(integer: 0), to: 3)
        XCTAssertEqual(store.routes, [r2, r3, r1])
    }

    func test_delete_atOffsets_removesCorrectElements() {
        let r1 = PinnedRoute.make(station: .JSQ, direction: .toNY)
        let r2 = PinnedRoute.make(station: .WTC, direction: .toNJ)
        store.add(r1); store.add(r2)
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.routes, [r2])
    }

    func test_replaceAll_replacesEntireList() {
        store.add(PinnedRoute.make(station: .JSQ))
        let newRoutes = [PinnedRoute.make(station: .WTC), PinnedRoute.make(station: .HOB)]
        store.replaceAll(with: newRoutes)
        XCTAssertEqual(store.routes, newRoutes)
    }

    func test_replaceAll_withEmptyArray_clearsRoutes() {
        store.add(PinnedRoute.make())
        store.replaceAll(with: [])
        XCTAssertTrue(store.routes.isEmpty)
    }

    func test_persistence_survivesStoreRecreation() throws {
        let route = PinnedRoute.make(station: .JSQ, direction: .toNY, targetFilter: "WTC")
        store.add(route)

        let ud = UserDefaults(suiteName: suiteName)!
        let newStore = PinnedRoutesStore(userDefaults: ud)
        XCTAssertEqual(newStore.routes.count, 1)
        XCTAssertEqual(newStore.routes.first, route)
    }
}
