import XCTest
@testable import PathTimeShared

final class StationTests: XCTestCase {

    func test_allCasesCount_is13() {
        XCTAssertEqual(Station.allCases.count, 13)
    }

    func test_rawValues_matchAPIContract_alphaStations() {
        XCTAssertEqual(Station.NWK.rawValue, "NWK")
        XCTAssertEqual(Station.HAR.rawValue, "HAR")
        XCTAssertEqual(Station.JSQ.rawValue, "JSQ")
        XCTAssertEqual(Station.GRV.rawValue, "GRV")
        XCTAssertEqual(Station.NEW.rawValue, "NEW")
        XCTAssertEqual(Station.EXP.rawValue, "EXP")
        XCTAssertEqual(Station.HOB.rawValue, "HOB")
        XCTAssertEqual(Station.WTC.rawValue, "WTC")
        XCTAssertEqual(Station.CHR.rawValue, "CHR")
    }

    func test_rawValues_matchAPIContract_numericStations() {
        XCTAssertEqual(Station.nineS.rawValue, "09S")
        XCTAssertEqual(Station.fourteenS.rawValue, "14S")
        XCTAssertEqual(Station.twentyThreeS.rawValue, "23S")
        XCTAssertEqual(Station.thirtyThreeS.rawValue, "33S")
    }

    func test_displayName_isNotEmpty_forAllStations() {
        for station in Station.allCases {
            XCTAssertFalse(station.displayName.isEmpty, "\(station) has empty displayName")
        }
    }

    func test_shortName_isNotEmpty_forAllStations() {
        for station in Station.allCases {
            XCTAssertFalse(station.shortName.isEmpty, "\(station) has empty shortName")
        }
    }

    func test_isNJSide_trueForNJStations() {
        let njStations: [Station] = [.NWK, .HAR, .JSQ, .GRV, .NEW, .EXP, .HOB]
        for station in njStations {
            XCTAssertTrue(station.isNJSide, "\(station) should be NJ side")
        }
    }

    func test_isNJSide_falseForNYStations() {
        let nyStations: [Station] = [.WTC, .CHR, .nineS, .fourteenS, .twentyThreeS, .thirtyThreeS]
        for station in nyStations {
            XCTAssertFalse(station.isNJSide, "\(station) should not be NJ side")
        }
    }

    func test_station_codableRoundtrip() throws {
        for station in Station.allCases {
            let data = try JSONEncoder().encode(station)
            let decoded = try JSONDecoder().decode(Station.self, from: data)
            XCTAssertEqual(decoded, station)
        }
    }

    func test_direction_rawValues_matchAPI() {
        XCTAssertEqual(Direction.toNY.rawValue, "ToNY")
        XCTAssertEqual(Direction.toNJ.rawValue, "ToNJ")
    }

    func test_direction_codableRoundtrip() throws {
        for direction in Direction.allCases {
            let data = try JSONEncoder().encode(direction)
            let decoded = try JSONDecoder().decode(Direction.self, from: data)
            XCTAssertEqual(decoded, direction)
        }
    }

    func test_direction_displayName_isNotEmpty() {
        for direction in Direction.allCases {
            XCTAssertFalse(direction.displayName.isEmpty)
            XCTAssertFalse(direction.shortName.isEmpty)
        }
    }
}
