import SwiftUI
import PathTimeShared

@main
struct PathTimeWatchApp: App {
    @StateObject private var arrivalsStore = ArrivalsStore()
    @StateObject private var pinnedStore = PinnedRoutesStore.shared

    var body: some Scene {
        WindowGroup {
            WatchMainView()
                .environmentObject(arrivalsStore)
                .environmentObject(pinnedStore)
                .task { await arrivalsStore.fetch() }
                .onAppear { arrivalsStore.startAutoRefresh(interval: 60) }
        }
    }
}
