import SwiftUI
import PathTimeShared

struct WatchMainView: View {
    @EnvironmentObject private var arrivalsStore: ArrivalsStore
    @EnvironmentObject private var pinnedStore: PinnedRoutesStore

    var body: some View {
        NavigationStack {
            if pinnedStore.routes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "star.slash")
                        .font(.title2)
                    Text("在 iPhone 上收藏路线")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.secondary)
            } else {
                List(pinnedStore.routes) { route in
                    WatchRouteRow(route: route)
                }
                .navigationTitle("PATH")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if arrivalsStore.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

struct WatchRouteRow: View {
    let route: PinnedRoute
    @EnvironmentObject private var arrivalsStore: ArrivalsStore

    private var arrivals: [TrainArrival] { arrivalsStore.arrivals(for: route) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(route.displayTitle)
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let first = arrivals.first {
                HStack(spacing: 4) {
                    Circle().fill(first.lineColor).frame(width: 8, height: 8)
                    Text(first.displayTime())
                        .font(.title3).fontWeight(.bold).monospacedDigit()
                }
            }

            if let second = arrivals.dropFirst().first {
                HStack(spacing: 4) {
                    Circle().fill(second.lineColor).frame(width: 6, height: 6)
                    Text(second.displayTime())
                        .font(.caption).fontWeight(.medium).monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
