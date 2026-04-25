import SwiftUI
import PathTimeShared

struct StationDetailView: View {
    let station: Station
    @EnvironmentObject private var arrivalsStore: ArrivalsStore
    @EnvironmentObject private var pinnedStore: PinnedRoutesStore

    var body: some View {
        List {
            ForEach(Direction.allCases, id: \.self) { direction in
                let arrivals = arrivalsStore.arrivals(for: station, direction: direction)
                if !arrivals.isEmpty {
                    directionSection(direction: direction, arrivals: arrivals)
                }
            }
        }
        .navigationTitle(station.displayName)
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await arrivalsStore.fetch() }
    }

    @ViewBuilder
    private func directionSection(direction: Direction, arrivals: [TrainArrival]) -> some View {
        Section {
            // Direction-level pin row
            HStack {
                Label(direction.displayName, systemImage: "tram")
                    .font(.headline)
                Spacer()
                PinButton(route: PinnedRoute(station: station, direction: direction))
            }
            .padding(.vertical, 2)

            // Group by target terminal
            let grouped = Dictionary(grouping: arrivals, by: \.target)
            ForEach(grouped.keys.sorted(), id: \.self) { target in
                if let trains = grouped[target] {
                    targetGroup(trains: trains, target: target, direction: direction)
                }
            }
        }
    }

    @ViewBuilder
    private func targetGroup(trains: [TrainArrival], target: String, direction: Direction) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(trains.first?.lineColor ?? .gray)
                    .frame(width: 11, height: 11)
                Text(trains.first?.headSign ?? target)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                PinButton(
                    route: PinnedRoute(station: station, direction: direction, targetFilter: target)
                )
            }
            TimelineView(.periodic(from: .now, by: 30)) { tl in
                let upcoming = trains.filter { $0.arrivalDate > tl.date }.prefix(3)
                HStack(spacing: 12) {
                    if upcoming.isEmpty {
                        Text("No trains")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(upcoming)) { train in
                            Text(train.arrivalDate, style: .timer)
                                .font(.title3)
                                .fontWeight(.bold)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .padding(.leading, 18)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Pin toggle button

struct PinButton: View {
    let route: PinnedRoute
    @EnvironmentObject private var pinnedStore: PinnedRoutesStore

    private var isPinned: Bool { pinnedStore.contains(route) }

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.25)) {
                pinnedStore.toggle(route)
            }
        } label: {
            Image(systemName: isPinned ? "star.fill" : "star")
                .foregroundStyle(isPinned ? .yellow : .secondary)
                .symbolEffect(.bounce, value: isPinned)
        }
        .buttonStyle(.plain)
    }
}
