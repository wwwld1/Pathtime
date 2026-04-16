import SwiftUI
import PathTimeShared

// MARK: - Station picker

struct WatchStationPickerView: View {
    @EnvironmentObject private var pinnedStore: PinnedRoutesStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(Station.allCases, id: \.self) { station in
            NavigationLink(station.displayName) {
                WatchDirectionPickerView(station: station)
            }
        }
        .navigationTitle("选站台")
    }
}

// MARK: - Direction + confirm

struct WatchDirectionPickerView: View {
    let station: Station
    @EnvironmentObject private var pinnedStore: PinnedRoutesStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(Direction.allCases, id: \.self) { direction in
                let route = PinnedRoute(station: station, direction: direction)
                Button {
                    pinnedStore.toggle(route)
                    dismiss()
                } label: {
                    HStack {
                        Text(direction.displayName)
                        Spacer()
                        if pinnedStore.contains(route) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .navigationTitle(station.shortName)
    }
}
