import WidgetKit
import SwiftUI
import AppIntents
import UIKit

struct CopyScreenIntent: AppIntent {
    static var title: LocalizedStringResource = "Copy Screen"
    static var description = IntentDescription("Copy the latest ReplayKit screen frame to the clipboard.")
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let group = "group.com.dtadptvl.ScreenshotClipboard"
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: group)?
            .appendingPathComponent("latest.jpg"),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return .result(dialog: "No captured frame yet")
        }

        UIPasteboard.general.image = image
        return .result(dialog: "Copied")
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
        .description("Copy the latest full-screen ReplayKit frame to the clipboard.")
    }
}

@main
struct ScreenshotClipboardControlBundle: WidgetBundle {
    var body: some Widget {
        ScreenshotClipboardControl()
    }
}
