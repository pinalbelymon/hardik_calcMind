import AVFoundation
import AudioToolbox
import UIKit

/// Audio player for CalcMind providing audible sound feedback on real iOS devices.
/// Configures AVAudioSession category to ensure sounds are audible on physical iPhones.
enum SoundPlayer {
    /// SystemSoundID 1104 — Standard keyboard tock sound
    private static let tockSoundID: SystemSoundID = 1104

    /// SystemSoundID 1054 / 1025 — Success chime sound for calculations & photo solves
    private static let successSoundID: SystemSoundID = 1025

    /// Configures AVAudioSession so sounds are audible on real physical devices without interrupting user background music
    private static func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("SoundPlayer: AVAudioSession configuration error: \(error.localizedDescription)")
        }
    }

    /// Plays a clear, subtle button tap tock sound
    static func playTock(enabled: Bool) {
        guard enabled else { return }
        configureAudioSession()
        AudioServicesPlaySystemSound(tockSoundID)
    }

    /// Plays an audible completion chime sound when a calculation or photo solve completes
    static func playCompletion(enabled: Bool) {
        guard enabled else { return }
        configureAudioSession()
        AudioServicesPlaySystemSound(successSoundID)
    }
}
