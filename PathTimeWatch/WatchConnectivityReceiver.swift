import Foundation
import WatchConnectivity
import PathTimeShared

/// Watch 侧：接收 iPhone 推来的 PinnedRoutes 并更新本地 Store
final class WatchConnectivityReceiver: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityReceiver()

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {}

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        applyPayload(message)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        applyPayload(userInfo)
    }

    private func applyPayload(_ payload: [String: Any]) {
        guard let data = payload["pinnedRoutes"] as? Data,
              let routes = try? JSONDecoder().decode([PinnedRoute].self, from: data)
        else { return }
        DispatchQueue.main.async {
            PinnedRoutesStore.shared.replaceAll(with: routes)
        }
    }
}
