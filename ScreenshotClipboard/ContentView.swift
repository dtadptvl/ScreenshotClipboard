import SwiftUI
import ReplayKit

struct ContentView: View {
    @EnvironmentObject var capture: CaptureManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: capture.isCapturing ? "record.circle.fill" : "record.circle")
                    .font(.system(size: 54))

                Text("Screenshot → Clipboard")
                    .font(.title2.bold())

                Text(capture.status)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    Text("Start / stop full-screen capture")
                        .font(.headline)
                    BroadcastPicker()
                        .frame(width: 64, height: 64)
                }

                Button("Copy Latest Frame Now") {
                    _ = capture.copyLatestFrame()
                }
                .buttonStyle(.borderedProminent)

                Button("Refresh Status") {
                    capture.refreshState()
                }
                .buttonStyle(.bordered)

                Text("Xcode 26 mode uses a ReplayKit Broadcast Upload extension. Start the broadcast once and leave it running. The extension continuously keeps only the newest screen frame in the shared App Group; no image is written to Photos.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("ScreenshotClipboard")
            .task { capture.refreshState() }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active { capture.refreshState() }
            }
        }
    }
}

private struct BroadcastPicker: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: .zero)
        picker.preferredExtension = "com.dtadptvl.ScreenshotClipboard.Broadcast"
        picker.showsMicrophoneButton = false
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}
