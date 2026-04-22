import Foundation

// MARK: - Raw API response types

private struct RidePathResponse: Decodable {
    let results: [StationResult]
}

private struct StationResult: Decodable {
    let consideredStation: String
    let destinations: [DestinationResult]
}

private struct DestinationResult: Decodable {
    let label: String
    let messages: [MessageResult]
}

private struct MessageResult: Decodable {
    let target: String
    let secondsToArrival: String
    let lineColor: String
    let headSign: String
    let lastUpdated: String
}

// MARK: - Service

public final class PathAPIService: Sendable {
    public static let shared = PathAPIService()

    let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private static let baseURL = "https://www.panynj.gov/bin/portauthority/ridepath.json"

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// Returns a map of stationCode → direction → arrivals (sorted by arrival time).
    public func fetchArrivals() async throws -> [String: [Direction: [TrainArrival]]] {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        guard var components = URLComponents(string: Self.baseURL) else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "timeStamp", value: "\(timestamp)")]
        guard let url = components.url else { throw URLError(.badURL) }

        let fetchedAt = Date()
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(RidePathResponse.self, from: data)

        var result: [String: [Direction: [TrainArrival]]] = [:]

        for station in response.results {
            var dirMap: [Direction: [TrainArrival]] = [:]
            for dest in station.destinations {
                guard let direction = Direction(rawValue: dest.label) else { continue }
                let arrivals: [TrainArrival] = dest.messages.compactMap { msg in
                    guard let secs = Int(msg.secondsToArrival) else { return nil }
                    return TrainArrival(
                        target: msg.target,
                        headSign: msg.headSign,
                        secondsToArrival: secs,
                        lineColorHex: msg.lineColor,
                        fetchedAt: fetchedAt
                    )
                }.sorted { $0.secondsToArrival < $1.secondsToArrival }
                dirMap[direction] = arrivals
            }
            result[station.consideredStation] = dirMap
        }

        return result
    }
}
