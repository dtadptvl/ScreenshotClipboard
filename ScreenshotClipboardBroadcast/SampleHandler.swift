import ReplayKit
import CoreImage
import UIKit
import QuartzCore

final class SampleHandler: RPBroadcastSampleHandler {
    private let context = CIContext(options: [.cacheIntermediates: false])
    private let queue = DispatchQueue(label: "ScreenshotClipboard.broadcast.encode", qos: .userInteractive)
    private var lastWrite: CFTimeInterval = 0
    private let minInterval: CFTimeInterval = 1.0 / 12.0

    private var frameURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.dtadptvl.ScreenshotClipboard")?
            .appendingPathComponent("latest.jpg")
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        UserDefaults(suiteName: "group.com.dtadptvl.ScreenshotClipboard")?.set(true, forKey: "broadcastActive")
    }

    override func broadcastPaused() {
        UserDefaults(suiteName: "group.com.dtadptvl.ScreenshotClipboard")?.set(false, forKey: "broadcastActive")
    }

    override func broadcastResumed() {
        UserDefaults(suiteName: "group.com.dtadptvl.ScreenshotClipboard")?.set(true, forKey: "broadcastActive")
    }

    override func broadcastFinished() {
        UserDefaults(suiteName: "group.com.dtadptvl.ScreenshotClipboard")?.set(false, forKey: "broadcastActive")
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let frameURL else { return }

        let now = CACurrentMediaTime()
        guard now - lastWrite >= minInterval else { return }
        lastWrite = now

        let capturedPixelBuffer = pixelBuffer
        queue.async { [context, capturedPixelBuffer] in
            let ciImage = CIImage(cvPixelBuffer: capturedPixelBuffer)
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            let image = UIImage(cgImage: cgImage)
            guard let data = image.jpegData(compressionQuality: 0.96) else { return }

            do {
                try data.write(to: frameURL, options: .atomic)
                let defaults = UserDefaults(suiteName: "group.com.dtadptvl.ScreenshotClipboard")
                defaults?.set(Date().timeIntervalSince1970, forKey: "latestFrameTime")
            } catch {
                // Drop this frame; the next video sample will retry.
            }
        }
    }
}
