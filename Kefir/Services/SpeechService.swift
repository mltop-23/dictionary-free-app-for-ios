import Foundation
import AVFoundation

final class SpeechService {
    static let shared = SpeechService()
    private let synth = AVSpeechSynthesizer()

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers, .duckOthers])
    }

    func speak(_ text: String, language: String = "en-US", rate: Float = 0.5) {
        guard !text.isEmpty else { return }
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = bestVoice(for: language)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        synth.speak(utterance)
    }

    func stop() {
        if synth.isSpeaking {
            synth.stopSpeaking(at: .immediate)
        }
    }

    private func bestVoice(for language: String) -> AVSpeechSynthesisVoice? {
        // Пробуем точный, потом по префиксу языка
        if let v = AVSpeechSynthesisVoice(language: language) { return v }
        let prefix = String(language.prefix(2))
        let all = AVSpeechSynthesisVoice.speechVoices()
        let enhanced = all.first { $0.language.hasPrefix(prefix) && $0.quality == .enhanced }
        if let e = enhanced { return e }
        return all.first { $0.language.hasPrefix(prefix) }
    }
}
