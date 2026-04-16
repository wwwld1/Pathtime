import SwiftUI
import WidgetKit
import PathTimeShared

@main
struct PathTimeApp: App {
    @StateObject private var arrivalsStore = ArrivalsStore()
    @StateObject private var pinnedStore = PinnedRoutesStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(arrivalsStore)
                .environmentObject(pinnedStore)
                .task { await arrivalsStore.fetch() }
                .onAppear { arrivalsStore.startAutoRefresh() }
                .onDisappear { arrivalsStore.stopAutoRefresh() }
                .onReceive(pinnedStore.$routes) { _ in
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
    }
}
