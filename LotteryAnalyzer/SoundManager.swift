//
//  SoundManager.swift
//  LotteryAnalyzer
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {}
    
    func playSound(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("❌ Sound file not found: \(soundName).mp3")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayers[soundName] = player
            player.play()
        } catch {
            print("❌ Error playing sound: \(error)")
        }
    }
}
