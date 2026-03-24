import AVFoundation
import Foundation

@Observable
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    var isSpeaking: Bool = false

    private init() {}

    func speak(_ text: String, author: String? = nil) {
        stop()

        var fullText = text
        if let author {
            fullText += "... by \(author)"
        }

        let utterance = AVSpeechUtterance(string: fullText)
        let storedRate = UserDefaults.standard.double(forKey: "speechRate")
        utterance.rate = Float(storedRate > 0 ? storedRate : AVSpeechUtteranceDefaultSpeechRate)
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        isSpeaking = true
        synthesizer.speak(utterance)

        // Monitor completion
        Task { @MainActor in
            while synthesizer.isSpeaking {
                try? await Task.sleep(for: .milliseconds(100))
            }
            isSpeaking = false
        }
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
}
