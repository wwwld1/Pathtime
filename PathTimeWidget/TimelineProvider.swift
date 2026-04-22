import WidgetKit
import SwiftUI
import PathTimeShared

// MARK: - Timeline Entry

struct PathTimeEntry: TimelineEntry {
    let date: Date
    let route: PinnedRoute?
    let arrivals: [TrainArrival]
    let fetchedAt: Date
    var isPlaceholder = false

    static var placeholder: PathTimeEntry {
        PathTimeEntry(
            date: .now,
            route: PinnedRoute(station: .JSQ, direction: .toNY),
            arrivals: [
                TrainArrival(target: "33S", headSign: "33rd Street", secondsToArrival: 180, lineColorHex: "FF9900"),
                TrainArrival(target: "WTC", headSign: "World Trade Ctr", secondsToArrival: 360, lineColorHex: "D93A30")
            ],
            fetchedAt: .now,
            isPlaceholder: true
        )
    }
}

// MARK: - Provider

struct PathTimeProvider: AppIntentTimelineProvider {
    typealias Intent = SelectRouteIntent
    typealias Entry = PathTimeEntry

    func placeholder(in context: Context) -> PathTimeEntry {
        .placeholder
    }

    func snapshot(for configuration: SelectRouteIntent, in context: Context) async -> PathTimeEntry {
        await makeEntry(for: configuration)
    }

    func timeline(for configuration: SelectRouteIntent, in context: Context) async -> Timeline<PathTimeEntry> {
        let route = resolveRoute(from: configuration)
        let fetchedAt = Date.now
        do {
            let all = try await PathAPIService.shared.fetchArrivals()
            var arrivals = all[route.station.rawValue]?[route.direction] ?? []
            if let filter = route.targetFilter {
                arrivals = arrivals.filter { $0.target == filter }
            }
            arrivals.sort { $0.arrivalDate < $1.arrivalDate }

            // 每班车出发时刻生成一条 entry，系统自动切换，.timer 始终倒计未来的车
            var entries: [PathTimeEntry] = []
            entries.append(PathTimeEntry(date: fetchedAt, route: route, arrivals: arrivals, fetchedAt: fetchedAt))
            for i in arrivals.indices {
                entries.append(PathTimeEntry(
                    date: arrivals[i].arrivalDate,
                    route: route,
                    arrivals: Array(arrivals.dropFirst(i + 1)),
                    fetchedAt: fetchedAt
                ))
            }
            return Timeline(entries: entries, policy: .atEnd)
        } catch {
            let nextRefresh = Calendar.current.date(byAdding: .minute, value: 10, to: fetchedAt)!
            return Timeline(
                entries: [PathTimeEntry(date: fetchedAt, route: route, arrivals: [], fetchedAt: fetchedAt)],
                policy: .after(nextRefresh)
            )
        }
    }

    // MARK: -

    private func makeEntry(for configuration: SelectRouteIntent) async -> PathTimeEntry {
        let route = resolveRoute(from: configuration)
        do {
            let all = try await PathAPIService.shared.fetchArrivals()
            var arrivals = all[route.station.rawValue]?[route.direction] ?? []
            if let filter = route.targetFilter {
                arrivals = arrivals.filter { $0.target == filter }
            }
            return PathTimeEntry(date: .now, route: route, arrivals: arrivals, fetchedAt: .now)
        } catch {
            return PathTimeEntry(date: .now, route: route, arrivals: [], fetchedAt: .now)
        }
    }

    private func resolveRoute(from intent: SelectRouteIntent) -> PinnedRoute {
        if let entity = intent.route,
           let station = Station(rawValue: entity.station),
           let direction = Direction(rawValue: entity.direction) {
            return PinnedRoute(station: station, direction: direction, targetFilter: entity.targetFilter)
        }
        return PinnedRoutesStore.shared.routes.first
            ?? PinnedRoute(station: .JSQ, direction: .toNY)
    }
}
