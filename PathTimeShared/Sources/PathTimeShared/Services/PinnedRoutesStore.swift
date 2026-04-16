import Foundation

public final class PinnedRoutesStore: ObservableObject {
    public static let shared = PinnedRoutesStore()

    private let appGroupID = "group.com.pathtime.shared"
    private let storageKey = "pinnedRoutes_v1"

    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    @Published public var routes: [PinnedRoute] = []

    private init() {
        load()
    }

    // MARK: - Persistence

    private func load() {
        guard let data = userDefaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([PinnedRoute].self, from: data)
        else { return }
        routes = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(routes) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    // MARK: - Mutations

    public func add(_ route: PinnedRoute) {
        guard !contains(route) else { return }
        routes.append(route)
        persist()
    }

    public func remove(_ route: PinnedRoute) {
        routes.removeAll { $0 == route }
        persist()
    }

    public func toggle(_ route: PinnedRoute) {
        contains(route) ? remove(route) : add(route)
    }

    public func move(from source: IndexSet, to destination: Int) {
        routes.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    public func delete(at offsets: IndexSet) {
        routes.remove(atOffsets: offsets)
        persist()
    }

    public func contains(_ route: PinnedRoute) -> Bool {
        routes.contains(where: { $0 == route })
    }

    /// 用于 WatchConnectivity 接收方直接替换全部数据
    public func replaceAll(with newRoutes: [PinnedRoute]) {
        routes = newRoutes
        persist()
    }
}
