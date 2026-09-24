// Re-encodes the raw simulator recording to a small H.264 file for the
// README. Usage: swift scripts/shrink_video.swift <in.mp4> <out.mp4> [bitrate]
import AVFoundation
let args = CommandLine.arguments
let src = URL(fileURLWithPath: args[1]), dst = URL(fileURLWithPath: args[2])
let width = 590, height = 1282, bitrate = Int(args.count > 3 ? args[3] : "700000")!
try? FileManager.default.removeItem(at: dst)
let asset = AVURLAsset(url: src)
let track = asset.tracks(withMediaType: .video)[0]
let reader = try! AVAssetReader(asset: asset)
let out = AVAssetReaderTrackOutput(track: track, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
reader.add(out)
let writer = try! AVAssetWriter(outputURL: dst, fileType: .mp4)
let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
  AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: width, AVVideoHeightKey: height,
  AVVideoScalingModeKey: AVVideoScalingModeResizeAspect,
  AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: bitrate, AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel, AVVideoMaxKeyFrameIntervalKey: 60]])
input.expectsMediaDataInRealTime = false
writer.add(input)
reader.startReading(); writer.startWriting(); writer.startSession(atSourceTime: .zero)
let q = DispatchQueue(label: "w"); let done = DispatchSemaphore(value: 0)
input.requestMediaDataWhenReady(on: q) {
  while input.isReadyForMoreMediaData {
    if let s = out.copyNextSampleBuffer() { input.append(s) } else { input.markAsFinished(); writer.finishWriting { done.signal() }; return }
  }
}
done.wait()
print(writer.status == .completed ? "ok" : "failed: \(String(describing: writer.error))")
