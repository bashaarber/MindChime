import AVFoundation
import Foundation

@Observable
final class AudioService {
    static let shared = AudioService()

    private var audioPlayer: AVAudioPlayer?

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    func playChimeSound(named name: String = "chime_gentle") {
        // Try to load from bundle, fall back to system sound
        if let url = Bundle.main.url(forResource: name, withExtension: "wav") {
            playSound(url: url)
        } else if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            playSound(url: url)
        } else {
            playSystemSound()
        }
    }

    private func playSound(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Audio playback failed: \(error)")
            playSystemSound()
        }
    }

    private func playSystemSound() {
        AudioServicesPlaySystemSound(1007) // Chime-like system sound
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
