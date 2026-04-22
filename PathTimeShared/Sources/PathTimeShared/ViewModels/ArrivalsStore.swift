import Foundation
import SwiftUI

@MainActor
public final class ArrivalsStore: ObservableObject {
    @Published public var data: [String: [Direction: [TrainArrival]]] = [:]
    @Published public var isLoading = false
    @Published public var lastFetched: Date?
    @Published public var fetchError: String?

    private var refreshTask: Task<Void, Never>?

    public init() {}

    // MARK: - Auto-refresh

    public func startAutoRefresh(interval: TimeInterval = 30) {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.fetch()
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }

    public func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    // MARK: - Fetch

    public func fetch() async {
        isLoading = true
        fetchError = nil
        do {
            let fresh = try await PathAPIService.shared.fetchArrivals()
            data = merge(old: data, new: fresh)
            lastFetched = .now
        } catch {
            fetchError = error.localizedDescription
        }
        isLoading = false
    }

    // 若新旧班次 arrivalDate 差距 ≤5s，保留旧对象，避免秒级计时器跳变
    private func merge(
        old: [String: [Direction: [TrainArrival]]],
        new: [String: [Direction: [TrainArrival]]]
    ) -> [String: [Direction: [TrainArrival]]] {
        var result = new
        for (station, directions) in new {
            for (direction, newTrains) in directions {
                guard let oldTrains = old[station]?[direction] else { continue }
                result[station]![direction] = newTrains.map { newTrain in
                    if let match = oldTrains.first(where: { $0.target == newTrain.target && $0.headSign == newTrain.headSign }),
                       abs(match.arrivalDate.timeIntervalSince(newTrain.arrivalDate)) <= 5 {
                        return match
                    }
                    return newTrain
                }
            }
        }
        return result
    }

    // MARK: - Query helpers

    public func arrivals(for station: Station, direction: Direction) -> [TrainArrival] {
        data[station.rawValue]?[direction] ?? []
    }

    public func arrivals(for route: PinnedRoute) -> [TrainArrival] {
        var result = arrivals(for: route.station, direction: route.direction)
        if let filter = route.targetFilter {
            result = result.filter { $0.target == filter }
        }
        return result
    }

    public func nextArrival(for route: PinnedRoute) -> TrainArrival? {
        arrivals(for: route).first
    }
}
