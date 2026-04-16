import Foundation
import SwiftUI

public struct TrainArrival: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let target: String
    public let headSign: String
    public let secondsToArrival: Int
    public let lineColorHex: String
    public let fetchedAt: Date

    public init(
        id: UUID = UUID(),
        target: String,
        headSign: String,
        secondsToArrival: Int,
        lineColorHex: String,
        fetchedAt: Date = .now
    ) {
        self.id = id
        self.target = target
        self.headSign = headSign
        self.secondsToArrival = secondsToArrival
        self.lineColorHex = lineColorHex
        self.fetchedAt = fetchedAt
    }

    public var lineColor: Color {
        Color(hex: lineColorHex) ?? .gray
    }

    /// Remaining seconds accounting for elapsed time since fetch
    public func remainingSeconds(at now: Date = .now) -> Int {
        let elapsed = Int(now.timeIntervalSince(fetchedAt))
        return max(0, secondsToArrival - elapsed)
    }

    /// Remaining minutes (floor)
    public func remainingMinutes(at now: Date = .now) -> Int {
        remainingSeconds(at: now) / 60
    }

    public func displayTime(at now: Date = .now) -> String {
        let secs = remainingSeconds(at: now)
        if secs < 60 { return "Now" }
        return "\(secs / 60) min"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: TrainArrival, rhs: TrainArrival) -> Bool {
        lhs.id == rhs.id
    }
}
