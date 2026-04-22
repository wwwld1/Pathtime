import XCTest
@testable import PathTimeShared

final class PathAPIServiceTests: XCTestCase {

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - Normal response

    func test_parse_normalResponse_correctStationCount() async throws {
        let data = try Fixtures.loadJSON("ridepath_normal")
        let service = MockURLProtocol.makeService(returning: data)
        let result = try await service.fetchArrivals()
        XCTAssertEqual(result.keys.count, 2)
        XCTAssertNotNil(result["JSQ"])
        XCTAssertNotNil(result["WTC"])
    }

    func test_parse_normalResponse_correctDirections() async throws {
        let data = try Fixtures.loadJSON("ridepath_normal")
        let service = MockURLProtocol.makeService(returning: data)
        let result = try await service.fetchArrivals()
        let jsq: [Direction: [TrainArrival]] = try XCTUnwrap(result["JSQ"])
        XCTAssertNotNil(jsq[Direction.toNY])
        XCTAssertNotNil(jsq[Direction.toNJ])
    }

    func test_parse_normalResponse_sortedBySecondsToArrival() async throws {
        let data = try Fixtures.loadJSON("ridepath_normal")
        let service = MockURLProtocol.makeService(returning: data)
        let result = try await service.fetchArrivals()
        let toNY: [TrainArrival] = try XCTUnwrap(result["JSQ"]?[Direction.toNY])
        XCTAssertEqual(toNY.count, 2)
        XCTAssertLessThanOrEqual(toNY[0].secondsToArrival, toNY[1].secondsToArrival)
        XCTAssertEqual(toNY[0].secondsToArrival, 120)
        XCTAssertEqual(toNY[1].secondsToArrival, 300)
    }

    func test_parse_normalResponse_correctTrainFields() async throws {
        let data = try Fixtures.loadJSON("ridepath_normal")
        let service = MockURLProtocol.makeService(returning: data)
        let result = try await service.fetchArrivals()
        let toNJ: [TrainArrival] = try XCTUnwrap(result["JSQ"]?[Direction.toNJ])
        XCTAssertEqual(toNJ.count, 1)
        XCTAssertEqual(toNJ[0].target, "NWK")
        XCTAssertEqual(toNJ[0].headSign, "Newark")
        XCTAssertEqual(toNJ[0].secondsToArrival, 180)
        XCTAssertEqual(toNJ[0].lineColorHex, "D93B26")
    }

    // MARK: - Invalid secondsToArrival

    func test_parse_invalidSecondsString_isFiltered() async throws {
        let data = try Fixtures.loadJSON("ridepath_invalid_secs")
        let service = MockURLProtocol.makeService(returning: data)
        let result = try await service.fetchArrivals()
        let toNY: [TrainArrival] = try XCTUnwrap(result["JSQ"]?[Direction.toNY])
        XCTAssertEqual(toNY.count, 1, "The entry with 'abc' should be filtered out")
        XCTAssertEqual(toNY[0].target, "33S")
    }

    // MARK: - Unknown direction

    func test_parse_unknownDirection_isSkipped() async throws {
        let data = try Fixtures.loadJSON("ridepath_unknown_direction")
        let service = MockURLProtocol.makeService(returning: data)
        let result = try await service.fetchArrivals()
        let jsq: [Direction: [TrainArrival]] = try XCTUnwrap(result["JSQ"])
        XCTAssertNil(jsq[Direction.toNJ], "ToMars should not appear")
        XCTAssertNotNil(jsq[Direction.toNY])
    }

    // MARK: - Empty results

    func test_parse_emptyResults_returnsEmptyDictionary() async throws {
        let data = try Fixtures.loadJSON("ridepath_empty")
        let service = MockURLProtocol.makeService(returning: data)
        let result = try await service.fetchArrivals()
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Network errors

    func test_fetchArrivals_propagatesNetworkError() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }
        let service = PathAPIService(session: session)
        do {
            _ = try await service.fetchArrivals()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    func test_fetchArrivals_propagatesDecodingError() async {
        let invalidData = Data("not json".utf8)
        let service = MockURLProtocol.makeService(returning: invalidData)
        do {
            _ = try await service.fetchArrivals()
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }
}
