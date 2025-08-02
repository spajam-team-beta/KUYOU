import AVFoundation
import Combine
import SwiftUI

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private var audioPlayer: AVAudioPlayer?
    private let haptics = UIImpactFeedbackGenerator(style: .light)
    
    private init() {
        haptics.prepare()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playMokugyo() {
        haptics.impactOccurred()
        
        guard let soundURL = Bundle.main.url(forResource: "mokugyo", withExtension: "mp3") else {
            playSystemSound()
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
        } catch {
            print("Failed to play mokugyo sound: \(error)")
            playSystemSound()
        }
    }
    
    func playAscension() {
        guard let soundURL = Bundle.main.url(forResource: "ascension", withExtension: "mp3") else {
            playSystemSound(id: 1016)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = 0.7
            audioPlayer?.play()
        } catch {
            print("Failed to play ascension sound: \(error)")
            playSystemSound(id: 1016)
        }
    }
    
    func playLevelUp() {
        haptics.impactOccurred()
        playSystemSound(id: 1025)
    }
    
    private func playSystemSound(id: SystemSoundID = 1104) {
        AudioServicesPlaySystemSound(id)
    }
}

extension AudioService {
    static func createMockMokugyoSound() {
        print("Note: Add 'mokugyo.mp3' to the project for authentic sound")
        print("For now, using system sounds as fallback")
    }
    
    static func createMockAscensionSound() {
        print("Note: Add 'ascension.mp3' to the project for ascension effect")
        print("For now, using system sounds as fallback")
    }
}