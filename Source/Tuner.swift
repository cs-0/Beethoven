import Foundation
import AVFoundation
import Pitchy

public protocol TunerDelegate: class {
  func tunerDidRecievePitch(tuner: Tuner, pitch: Pitch)
}

public class Tuner {

  public weak var delegate: TunerDelegate?
  public var active = false

  private let bufferSize: AVAudioFrameCount
  private var frequencies = [Float]()

  private lazy var audioInputProcessor: AudioInputProcessor = { [unowned self] in
    let audioInputProcessor = AudioInputProcessor(
      bufferSize: self.bufferSize,
      delegate: self
    )

    return audioInputProcessor
    }()

  private lazy var frequencyDetector: FrequencyDetector = { [unowned self] in
    let frequencyDetector = FrequencyDetector(
      sampleRate: 44100.0,
      bufferSize: self.bufferSize,
      delegate: self)

    return frequencyDetector
    }()

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 2048, delegate: TunerDelegate?) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Processing

  public func start() {
    do {
      try audioInputProcessor.start()
      active = true
    } catch {}
  }

  public func stop() {
    audioInputProcessor.stop()
    frequencies = [Float]()
    active = false
  }

  // MARK: - Helpers

  private func averageFrequency(frequency: Float) -> Float {
    var result = frequency

    frequencies.insert(frequency, atIndex: 0)

    if frequencies.count > 22 {
      frequencies.removeAtIndex(frequencies.count - 1)
    }

    let count = frequencies.count

    if count > 1 {
      var sortedFrequencies = frequencies.sort { $0 > $1 }

      if count % 2 == 0 {
        let value1 = sortedFrequencies[count / 2 - 1]
        let value2 = sortedFrequencies[count / 2]
        result = (value1 + value2) / 2
      } else {
        result = sortedFrequencies[count / 2]
      }
    }

    return result
  }
}

// MARK: - AudioInputProcessorDelegate

extension Tuner: AudioInputProcessorDelegate {

  public func audioInputProcessor(audioInputProcessor: AudioInputProcessor,
    didReceiveBuffer buffer: AVAudioPCMBuffer) {
      frequencyDetector.readBuffer(buffer)
  }
}

// MARK: - FrequencyDetectorDelegate

extension Tuner: FrequencyDetectorDelegate {

  public func frequencyDetector(frequencyDetector: FrequencyDetector,
    didRetrieveFrequency frequency: Float) {
      let pitch = Pitch(frequency: Double(averageFrequency(frequency)))
      delegate?.tunerDidRecievePitch(self, pitch: pitch)
  }
}
