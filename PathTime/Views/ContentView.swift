import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            StationsListView()
                .tabItem { Label("所有站台", systemImage: "tram.fill") }

            PinnedRoutesView()
                .tabItem { Label("已收藏", systemImage: "star.fill") }
        }
    }
}
