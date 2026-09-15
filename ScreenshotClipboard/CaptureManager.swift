import Foundation
import UIKit

@MainActor
final class CaptureManager: ObservableObject {
    static let shared = CaptureManager()
    static let appGroup = "group.com.dtadptvl.ScreenshotClipboard"

    @Published private(set) var isCapturing = false
    @Published private(set) var status = "Start the ReplayKit broadcast once, then leave it running."

    private var frameURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Self.appGroup)?
            .appendingPathComponent("latest.jpg")
    }

    func refreshState() {
        let defaults = UserDefaults(suiteName: Self.appGroup)
        isCapturing = defaults?.bool(forKey: "broadcastActive") ?? false

        if isCapturing {
            if let time = defaults?.double(forKey: "latestFrameTime"), time > 0 {
                let age = max(0, Date().timeIntervalSince1970 - time)
                status = String(format: "Broadcast active — latest frame %.2fs old", age)
            } else {
                status = "Broadcast active — waiting for first video frame"
            }
        } else {
            status = "Broadcast inactive — tap the broadcast picker to start"
        }
    }

    @discardableResult
    func copyLatestFrame() -> Bool {
        guard let frameURL,
              let data = try? Data(contentsOf: frameURL),
              let image = UIImage(data: data) else {
            status = "No captured frame available yet"
            return false
        }

        UIPasteboard.general.image = image
        status = "Copied latest full-screen frame to clipboard"
        return true
    }
}
