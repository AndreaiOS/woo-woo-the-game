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
    private var wasPlayingMusic = false

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        // Spec "Gestione errori": interruzioni audio (telefonate, Siri) → pausa/ripresa pulite.
        // La notification con `queue: .main` arriva sul main thread; AudioService è @MainActor
        // → assumeIsolated è sicuro (stesso pattern usato altrove nel progetto).
        // Estraggo i raw value (UInt, Sendable) dalla Notification *fuori* dall'hop @MainActor:
        // così la Notification (non-Sendable) non attraversa il confine di isolamento (Swift 6).
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
        ) { [weak self] note in
            let info = note.userInfo
            let typeRaw = info?[AVAudioSessionInterruptionTypeKey] as? UInt
            let optionRaw = info?[AVAudioSessionInterruptionOptionKey] as? UInt
            MainActor.assumeIsolated { self?.handleInterruption(typeRaw: typeRaw, optionRaw: optionRaw) }
        }
    }

    private func handleInterruption(typeRaw: UInt?, optionRaw: UInt?) {
        guard let typeRaw, let type = AVAudioSession.InterruptionType(rawValue: typeRaw) else { return }
        switch type {
        case .began:
            break // il sistema ha già messo in pausa l'audio; wasPlayingMusic conserva lo stato
        case .ended:
            let opts = optionRaw.map(AVAudioSession.InterruptionOptions.init(rawValue:)) ?? []
            if opts.contains(.shouldResume), wasPlayingMusic {
                try? AVAudioSession.sharedInstance().setActive(true)
                musicPlayer?.play()
            }
        @unknown default:
            break
        }
    }

    func playMusic(_ name: String, volume: Float = 1.0, loop: Bool = true) {
        guard settings.isAudioOn,
              let url = Bundle.main.url(forResource: name, withExtension: nil) else { return }
        musicPlayer = try? AVAudioPlayer(contentsOf: url)
        musicPlayer?.numberOfLoops = loop ? -1 : 0
        musicPlayer?.volume = volume
        musicPlayer?.play()
        wasPlayingMusic = true
    }

    func stopMusic() { musicPlayer?.stop(); musicPlayer = nil; wasPlayingMusic = false }

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
