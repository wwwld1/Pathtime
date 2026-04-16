import SwiftUI
import WidgetKit
import PathTimeShared

@main
struct PathTimeApp: App {
    @StateObject private var arrivalsStore = ArrivalsStore()
    @StateObject private var pinnedStore = PinnedRoutesStore.shared

    init() {
        _ = WatchSyncManager.shared  // 激活 WCSession
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(arrivalsStore)
                .environmentObject(pinnedStore)
                .task { await arrivalsStore.fetch() }
                .onAppear { arrivalsStore.startAutoRefresh() }
                .onDisappear { arrivalsStore.stopAutoRefresh() }
                .onReceive(pinnedStore.$routes) { routes in
                    WidgetCenter.shared.reloadAllTimelines()
                    WatchSyncManager.shared.syncRoutes(routes)
                }
        }
    }
}
