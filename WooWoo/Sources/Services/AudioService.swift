import AVFoundation

/// Musica di fondo + effetti. Rispetta Settings.isAudioOn (musica) e isSoundOn (effetti),
/// come i check `[singleton is_audio]/[singleton is_sound]` sparsi nell'originale.
/// Gli effetti usano un piccolo pool di player per nome così suoni ravvicinati si
/// SOVRAPPONGONO (come faceva OpenAL/ObjectAL), invece di tagliarsi a vicenda.
@MainActor
final class AudioService {
    static let shared = AudioService()
    let settings = Settings()

    private var musicPlayer: AVAudioPlayer?
    private var effectPool: [String: [AVAudioPlayer]] = [:]
    private let maxVoicesPerEffect = 4

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
        guard settings.isSoundOn,
              let url = Bundle.main.url(forResource: name, withExtension: nil) else { return }
        var voices = effectPool[name] ?? []
        // riusa una voce libera (non in riproduzione)
        if let free = voices.first(where: { !$0.isPlaying }) {
            free.currentTime = 0
            free.play()
        } else if voices.count < maxVoicesPerEffect {
            // crea una nuova voce per sovrapporsi a quelle in corso
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                player.play()
                voices.append(player)
                effectPool[name] = voices
            }
        } else {
            // pool pieno: riavvia la voce più vecchia (fallback, raro)
            voices.first?.currentTime = 0
            voices.first?.play()
        }
    }

    func stopAllEffects() {
        effectPool.values.forEach { $0.forEach { $0.stop() } }
    }
}
