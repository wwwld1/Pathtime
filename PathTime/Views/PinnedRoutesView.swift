import SwiftUI
import PathTimeShared

struct PinnedRoutesView: View {
    @EnvironmentObject private var arrivalsStore: ArrivalsStore
    @EnvironmentObject private var pinnedStore: PinnedRoutesStore
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            Group {
                if pinnedStore.routes.isEmpty {
                    ContentUnavailableView(
                        "还没有收藏的路线",
                        systemImage: "star",
                        description: Text("在站台页面点击 ★ 收藏任意方向或终点")
                    )
                } else {
                    List {
                        ForEach(pinnedStore.routes) { route in
                            PinnedRouteCard(route: route)
                        }
                        .onMove(perform: pinnedStore.move)
                        .onDelete(perform: pinnedStore.delete)
                    }
                    .environment(\.editMode, $editMode)
                }
            }
            .navigationTitle("已收藏")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarLeading) {
                    if let updated = arrivalsStore.lastFetched {
                        Text("更新于 \(updated.formatted(.dateTime.hour().minute().second()))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .refreshable { await arrivalsStore.fetch() }
        }
    }
}

// MARK: - Card

struct PinnedRouteCard: View {
    let route: PinnedRoute
    @EnvironmentObject private var arrivalsStore: ArrivalsStore

    private var arrivals: [TrainArrival] { arrivalsStore.arrivals(for: route) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(route.fullTitle)
                    .font(.headline)
                Spacer()
                if arrivals.isEmpty {
                    Text("无数据")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            ForEach(arrivals.prefix(3)) { train in
                HStack {
                    Circle()
                        .fill(train.lineColor)
                        .frame(width: 10, height: 10)
                    Text(train.headSign)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(train.displayTime())
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }
        }
        .padding(.vertical, 6)
    }
}
