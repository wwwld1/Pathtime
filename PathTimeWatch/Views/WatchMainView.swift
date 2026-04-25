import SwiftUI
import PathTimeShared

struct WatchMainView: View {
    @EnvironmentObject private var arrivalsStore: ArrivalsStore
    @EnvironmentObject private var pinnedStore: PinnedRoutesStore
    @State private var showAddPin = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(pinnedStore.routes) { route in
                    WatchRouteRow(route: route)
                }
                .onDelete(perform: pinnedStore.delete)

                // 新增 Pin 入口（列表底部）
                NavigationLink {
                    WatchStationPickerView()
                } label: {
                    Label("添加路线", systemImage: "plus.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            }
            .navigationTitle("PATH")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if arrivalsStore.isLoading { ProgressView() }
                }
            }
        }
        .refreshable { await arrivalsStore.fetch() }
    }
}

// MARK: - Route row

struct WatchRouteRow: View {
    let route: PinnedRoute
    @EnvironmentObject private var arrivalsStore: ArrivalsStore

    private var arrivals: [TrainArrival] { arrivalsStore.arrivals(for: route) }

    var body: some View {
        TimelineView(.explicit(arrivals.map(\.arrivalDate))) { tl in
            let upcoming = arrivals.filter { $0.arrivalDate > tl.date }
            VStack(alignment: .leading, spacing: 4) {
                Text(route.displayTitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if let first = upcoming.first {
                    HStack(spacing: 4) {
                        Circle().fill(first.lineColor).frame(width: 8, height: 8)
                        Text(first.arrivalDate, style: .timer)
                            .font(.title3).fontWeight(.bold).monospacedDigit()
                    }
                }

                if let second = upcoming.dropFirst().first {
                    HStack(spacing: 4) {
                        Circle().fill(second.lineColor).frame(width: 6, height: 6)
                        Text(second.arrivalDate, style: .relative)
                            .font(.caption).fontWeight(.medium).monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
}
