import WidgetKit
import SwiftUI
import AppIntents
import UIKit

struct CopyScreenIntent: AppIntent {
    static var title: LocalizedStringResource = "Copy Screen"
    static var description = IntentDescription("Copy the current captured screen to the clipboard.")
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        // The extension cannot safely reach the app's in-memory SCStream.
        // v0.1 exposes the control and validates Action Button launch latency.
        // A shared capture transport is required before this can copy the app's live frame.
        return .result()
    }
}

struct ScreenshotClipboardControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.dtadptvl.ScreenshotClipboard.copy") {
            ControlWidgetButton(action: CopyScreenIntent()) {
                Label("Copy Screen", systemImage: "rectangle.on.rectangle")
            }
        }
        .displayName("Copy Screen")
        .description("Copy the current full-screen capture to the clipboard.")
    }
}

@main
struct ScreenshotClipboardControlBundle: WidgetBundle {
    var body: some Widget {
        ScreenshotClipboardControl()
    }
}
