import AVFoundation

class TTSManager {
    static let shared = TTSManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    private let ttsEnabledKey = "ttsEnabled"
    
    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: ttsEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: ttsEnabledKey) }
    }
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("[TTSManager] Failed to configure audio session: \(error)")
        }
    }
    
    func speak(_ text: String) {
        guard isEnabled, !text.isEmpty else { return }
        
        configureAudioSession()
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: detectLanguage(text))
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func detectLanguage(_ text: String) -> String {
        if text.range(of: "\\p{Hangul}", options: .regularExpression) != nil {
            return "ko-KR"
        }
        if text.range(of: "[\\p{Hiragana}\\p{Katakana}]", options: .regularExpression) != nil {
            return "ja-JP"
        }
        if text.range(of: "\\p{Han}", options: .regularExpression) != nil {
            return "zh-CN"
        }
        return "en-US"
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
