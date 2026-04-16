import SwiftUI

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
        }
    }
}
