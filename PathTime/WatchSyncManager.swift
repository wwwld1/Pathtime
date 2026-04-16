import Foundation
import WatchConnectivity
import PathTimeShared

/// iPhone 侧：监听 PinnedRoutesStore 变化，推送给 Watch
final class WatchSyncManager: NSObject, WCSessionDelegate {
    static let shared = WatchSyncManager()

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func syncRoutes(_ routes: [PinnedRoute]) {
        guard WCSession.default.activationState == .activated,
              let data = try? JSONEncoder().encode(routes) else { return }
        let payload = ["pinnedRoutes": data]
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil)
        } else {
            WCSession.default.transferUserInfo(payload)
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
