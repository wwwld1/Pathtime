import SwiftUI
import PathTimeShared

struct StationsListView: View {
    @EnvironmentObject private var arrivalsStore: ArrivalsStore
    @State private var searchText = ""

    private var stations: [Station] {
        let all = Station.allCases
        guard !searchText.isEmpty else { return all }
        return all.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(stations, id: \.self) { station in
                NavigationLink {
                    StationDetailView(station: station)
                } label: {
                    StationRowView(station: station)
                }
            }
            .searchable(text: $searchText, prompt: "搜索站台")
            .navigationTitle("PATH Time")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if arrivalsStore.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            Task { await arrivalsStore.fetch() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .refreshable { await arrivalsStore.fetch() }
            .overlay {
                if let err = arrivalsStore.fetchError {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Row

struct StationRowView: View {
    let station: Station
    @EnvironmentObject private var arrivalsStore: ArrivalsStore

    private var nextNY: TrainArrival? { arrivalsStore.arrivals(for: station, direction: .toNY).first }
    private var nextNJ: TrainArrival? { arrivalsStore.arrivals(for: station, direction: .toNJ).first }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(station.displayName)
                .font(.headline)
            HStack(spacing: 16) {
                if let t = nextNY { ArrivalPill(arrival: t, label: "→NY") }
                if let t = nextNJ { ArrivalPill(arrival: t, label: "→NJ") }
                if nextNY == nil && nextNJ == nil {
                    Text("暂无数据")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ArrivalPill: View {
    let arrival: TrainArrival
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(arrival.lineColor)
                .frame(width: 9, height: 9)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(arrival.displayTime())
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}
