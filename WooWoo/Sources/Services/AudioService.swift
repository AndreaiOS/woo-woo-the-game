import AVFoundation

/// Musica di fondo + effetti. Rispetta Settings.isAudioOn (musica) e isSoundOn (effetti),
/// come i check `[singleton is_audio]/[singleton is_sound]` sparsi nell'originale.
/// Gira sul main thread (come tutto il gioco SpriteKit), quindi @MainActor elimina
/// i warning Swift 6 su mutazione dello stato condiviso.
@MainActor
final class AudioService {
    static let shared = AudioService()
    var settings = Settings()
    private var musicPlayer: AVAudioPlayer?
    private var effectPlayers: [String: AVAudioPlayer] = [:]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func playMusic(_ name: String, volume: Float = 1.0, loop: Bool = true) {
        guard settings.isAudioOn,
              let url = Bundle.main.url(forResource: name, withExtension: nil) else { return }
        musicPlayer = try? AVAudioPlayer(contentsOf: url)
        musicPlayer?.numberOfLoops = loop ? -1 : 0
        musicPlayer?.volume = volume
        musicPlayer?.play()
    }

    func stopMusic() { musicPlayer?.stop(); musicPlayer = nil }

    func playEffect(_ name: String) {
        guard settings.isSoundOn else { return }
        if effectPlayers[name] == nil,
           let url = Bundle.main.url(forResource: name, withExtension: nil) {
            effectPlayers[name] = try? AVAudioPlayer(contentsOf: url)
            effectPlayers[name]?.prepareToPlay()
        }
        effectPlayers[name]?.currentTime = 0
        effectPlayers[name]?.play()
    }

    func stopAllEffects() { effectPlayers.values.forEach { $0.stop() } }
}
