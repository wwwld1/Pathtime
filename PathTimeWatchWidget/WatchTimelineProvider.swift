import WidgetKit
import PathTimeShared

struct WatchComplicationEntry: TimelineEntry {
    let date: Date
    let route: PinnedRoute?
    let nextArrival: TrainArrival?
    let secondArrival: TrainArrival?

    static var placeholder: WatchComplicationEntry {
        WatchComplicationEntry(
            date: .now,
            route: PinnedRoute(station: .JSQ, direction: .toNY),
            nextArrival: TrainArrival(
                target: "33S", headSign: "33rd Street",
                secondsToArrival: 300, lineColorHex: "FF9900"
            ),
            secondArrival: TrainArrival(
                target: "WTC", headSign: "World Trade Ctr",
                secondsToArrival: 660, lineColorHex: "D93A30"
            )
        )
    }
}

struct WatchTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchComplicationEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchComplicationEntry) -> Void) {
        Task { completion(await fetchEntry()) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchComplicationEntry>) -> Void) {
        Task {
            let entry = await fetchEntry()
            let nextRefresh = Calendar.current.date(byAdding: .minute, value: 10, to: entry.date)!
            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
    }

    private func fetchEntry() async -> WatchComplicationEntry {
        guard let route = PinnedRoutesStore.shared.routes.first else {
            return WatchComplicationEntry(date: .now, route: nil, nextArrival: nil, secondArrival: nil)
        }
        do {
            let all = try await PathAPIService.shared.fetchArrivals()
            var arrivals = all[route.station.rawValue]?[route.direction] ?? []
            if let filter = route.targetFilter {
                arrivals = arrivals.filter { $0.target == filter }
            }
            return WatchComplicationEntry(
                date: .now,
                route: route,
                nextArrival: arrivals.first,
                secondArrival: arrivals.dropFirst().first
            )
        } catch {
            return WatchComplicationEntry(date: .now, route: route, nextArrival: nil, secondArrival: nil)
        }
    }
}
