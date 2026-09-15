import Foundation
import ScreenCaptureKit
import CoreMedia
import CoreImage
import UIKit

@MainActor
final class CaptureManager: NSObject, ObservableObject {
    static let shared = CaptureManager()

    @Published private(set) var isCapturing = false
    @Published private(set) var status = "Not capturing"

    private var stream: SCStream?
    private let output = FrameOutput()

    func start() async {
        guard !isCapturing else { return }
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            guard let display = content.displays.first else {
                status = "No display available"
                return
            }

            let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
            let config = SCStreamConfiguration()
            config.width = display.width
            config.height = display.height
            config.minimumFrameInterval = CMTime(value: 1, timescale: 30)
            config.queueDepth = 3
            config.showsCursor = false
            config.capturesAudio = false

            let stream = SCStream(filter: filter, configuration: config, delegate: nil)
            try stream.addStreamOutput(output, type: .screen, sampleHandlerQueue: output.queue)
            try await stream.startCapture()
            self.stream = stream
            isCapturing = true
            status = "Ready — screen capture active"
        } catch {
            status = "Capture failed: \(error.localizedDescription)"
        }
    }

    func stop() async {
        guard let stream else { return }
        do { try await stream.stopCapture() } catch { }
        self.stream = nil
        isCapturing = false
        status = "Not capturing"
    }

    func copyLatestFrame() async -> Bool {
        guard let image = output.latestImage() else {
            status = "No frame available"
            return false
        }
        UIPasteboard.general.image = image
        status = "Copied to clipboard"
        return true
    }
}

private final class FrameOutput: NSObject, SCStreamOutput, @unchecked Sendable {
    let queue = DispatchQueue(label: "ScreenshotClipboard.frames", qos: .userInteractive)
    private let lock = NSLock()
    private var image: UIImage?
    private let ciContext = CIContext(options: [.cacheIntermediates: false])

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen,
              sampleBuffer.isValid,
              let pixelBuffer = sampleBuffer.imageBuffer else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }
        let next = UIImage(cgImage: cgImage)
        lock.lock()
        image = next
        lock.unlock()
    }

    func latestImage() -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return image
    }
}
