import SwiftUI

@main
struct ScreenshotClipboardApp: App {
    @StateObject private var capture = CaptureManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(capture)
        }
    }
}
