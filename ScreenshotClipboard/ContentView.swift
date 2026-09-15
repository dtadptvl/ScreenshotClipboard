import SwiftUI

struct ContentView: View {
    @EnvironmentObject var capture: CaptureManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: capture.isCapturing ? "rectangle.inset.filled.and.person.filled" : "rectangle.dashed")
                    .font(.system(size: 54))
                Text("Screenshot → Clipboard")
                    .font(.title2.bold())
                Text(capture.status)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button(capture.isCapturing ? "Stop Capture" : "Start Full-Screen Capture") {
                    Task {
                        if capture.isCapturing { await capture.stop() }
                        else { await capture.start() }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Copy Current Frame") {
                    Task { _ = await capture.copyLatestFrame() }
                }
                .buttonStyle(.bordered)
                .disabled(!capture.isCapturing)

                Text("Start capture once and approve full-display capture. Keep capture active; the Action Button control copies the latest full-screen frame directly to the clipboard without saving to Photos.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("ScreenshotClipboard")
        }
    }
}
