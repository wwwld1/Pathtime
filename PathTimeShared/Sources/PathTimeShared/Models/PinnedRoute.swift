import Foundation

public struct PinnedRoute: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let station: Station
    public let direction: Direction
    /// nil = 显示该方向所有终点; 非nil = 只显示该终点（如 "WTC"）
    public let targetFilter: String?

    public init(
        id: UUID = UUID(),
        station: Station,
        direction: Direction,
        targetFilter: String? = nil
    ) {
        self.id = id
        self.station = station
        self.direction = direction
        self.targetFilter = targetFilter
    }

    public var displayTitle: String {
        if let filter = targetFilter {
            return "\(station.shortName) → \(filter)"
        }
        return "\(station.shortName) \(direction.shortName)"
    }

    public var fullTitle: String {
        if let filter = targetFilter {
            return "\(station.displayName) → \(filter)"
        }
        return "\(station.displayName) \(direction.displayName)"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: PinnedRoute, rhs: PinnedRoute) -> Bool {
        lhs.station == rhs.station
            && lhs.direction == rhs.direction
            && lhs.targetFilter == rhs.targetFilter
    }
}
