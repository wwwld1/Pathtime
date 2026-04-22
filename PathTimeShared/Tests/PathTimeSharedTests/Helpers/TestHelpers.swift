import Foundation
@testable import PathTimeShared

enum Fixtures {
    static func loadJSON(_ name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json",
                                          subdirectory: "Fixtures") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try Data(contentsOf: url)
    }
}

extension TrainArrival {
    static func make(
        target: String = "WTC",
        headSign: String = "World Trade Center",
        secondsToArrival: Int = 300,
        lineColorHex: String = "D93B26",
        fetchedAt: Date = Date(timeIntervalSince1970: 1_000_000)
    ) -> TrainArrival {
        TrainArrival(
            target: target,
            headSign: headSign,
            secondsToArrival: secondsToArrival,
            lineColorHex: lineColorHex,
            fetchedAt: fetchedAt
        )
    }
}

extension PinnedRoute {
    static func make(
        station: Station = .JSQ,
        direction: Direction = .toNY,
        targetFilter: String? = nil
    ) -> PinnedRoute {
        PinnedRoute(station: station, direction: direction, targetFilter: targetFilter)
    }
}
