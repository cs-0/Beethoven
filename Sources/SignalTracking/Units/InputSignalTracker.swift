import AVFoundation
import Accelerate

public enum InputSignalTrackerError: Error {
  case inputNodeMissing
}

#if os(watchOS)
final class AWInputSignalTracker: SignalTracker {
  weak var delegate: SignalTrackerDelegate?
  var levelThreshold: Float?
  
  private var audioEngine: AVAudioEngine?
  // 44.1 kHz
  private let sampleRate: Double = 44100
  private let bufferSize: AVAudioFrameCount
  private let bus = 0
  
  var mode: SignalTrackerMode {
    return .record
  }
  
  var peakLevel: Float?
  
  var averageLevel: Float?
  
  init(bufferSize: AVAudioFrameCount = 2048,
       delegate: SignalTrackerDelegate? = nil) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }
  
  func start() throws {
    self.audioEngine = AVAudioEngine()
    guard let inputNode = self.audioEngine?.inputNode else {
      throw InputSignalTrackerError.inputNodeMissing
    }
    
    let format = inputNode.outputFormat(forBus: self.bus)
    
    inputNode.installTap(onBus: self.bus, bufferSize: self.bufferSize, format: format) { buffer, time in
      // calculate the root mean square of the channels to determine the volume
      guard let channelData = buffer.floatChannelData else { return }
      let frames = UInt(buffer.frameLength)
      var rms: Float = 0
      vDSP_measqv(channelData[0], 1, &rms, frames)
      rms = sqrt(rms)
      var db: Float = if rms > 0 {
        20 * log10(rms)
      } else {
        0
      }
      let normalizedLevel = max(0, (db + 50) / 50)
      if normalizedLevel > 0 {
        DispatchQueue.main.async {
          self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
        }
      }
    }
    try audioEngine?.start()
  }
  
  func stop() {
    guard audioEngine != nil else {
      return
    }
    audioEngine?.stop()
    audioEngine?.reset()
    audioEngine = nil
  }
  
  
}

#else
final class InputSignalTracker: SignalTracker {
  weak var delegate: SignalTrackerDelegate?
  var levelThreshold: Float?

  private let bufferSize: AVAudioFrameCount
  private var audioChannel: AVCaptureAudioChannel?
  private let captureSession = AVCaptureSession()
  private var audioEngine: AVAudioEngine?
  private let session = AVAudioSession.sharedInstance()
  private let bus = 0

  var peakLevel: Float? {
    return audioChannel?.peakHoldLevel
  }

  var averageLevel: Float? {
    return audioChannel?.averagePowerLevel
  }

  var mode: SignalTrackerMode {
    return .record
  }

  // MARK: - Initialization

  required init(bufferSize: AVAudioFrameCount = 2048,
                delegate: SignalTrackerDelegate? = nil) {
    self.bufferSize = bufferSize
    self.delegate = delegate
    setupAudio()
  }

  // MARK: - Tracking

  func start() throws {
    try session.setCategory(AVAudioSession.Category.playAndRecord)

    // check input type
    let currentRoute = session.currentRoute
    if currentRoute.outputs.count != 0 {
        for description in currentRoute.outputs {
            if (description.portType != AVAudioSession.Port.headphones) { // input from speaker if port is not headphones
                try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } else { // input from default (headphones)
                try session.overrideOutputAudioPort(.none)
            }
        }
    }
    
    audioEngine = AVAudioEngine()

    guard let inputNode = audioEngine?.inputNode else {
      throw InputSignalTrackerError.inputNodeMissing
    }

    let format = inputNode.outputFormat(forBus: bus)

    inputNode.installTap(onBus: bus, bufferSize: bufferSize, format: format) { buffer, time in
      guard let averageLevel = self.averageLevel else { return }

      let levelThreshold = self.levelThreshold ?? -1000000.0

      if averageLevel > levelThreshold {
        DispatchQueue.main.async {
          self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
        }
      } else {
        DispatchQueue.main.async {
          self.delegate?.signalTrackerWentBelowLevelThreshold(self)
        }
      }
    }

    try audioEngine?.start()
    DispatchQueue.global(qos: .userInitiated).async {
      self.captureSession.startRunning()
    }
    guard captureSession.isRunning == true else {
        throw InputSignalTrackerError.inputNodeMissing
    }
  }

  func stop() {
    guard audioEngine != nil else {
      return
    }

    audioEngine?.stop()
    audioEngine?.reset()
    audioEngine = nil
    captureSession.stopRunning()
  }

  private func setupAudio() {
    do {
      let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
      let audioCaptureInput = try AVCaptureDeviceInput(device: audioDevice!)

      captureSession.addInput(audioCaptureInput)

      let audioOutput = AVCaptureAudioDataOutput()
      captureSession.addOutput(audioOutput)

      let connection = audioOutput.connections[0]
      audioChannel = connection.audioChannels[0]
    } catch {}
  }
}

#endif // os(watchOS)
