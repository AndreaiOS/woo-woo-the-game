import Foundation

/// Flag audio/sound/vibro + first-launch. Chiavi e formato (Int 0/1) di Singleton.m:49-117.
struct Settings {
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    var isAudioOn: Bool {
        get { defaults.integer(forKey: "audio") != 0 }
        nonmutating set { defaults.set(newValue ? 1 : 0, forKey: "audio") }
    }
    var isSoundOn: Bool {
        get { defaults.integer(forKey: "sound") != 0 }
        nonmutating set { defaults.set(newValue ? 1 : 0, forKey: "sound") }
    }
    var isVibroOn: Bool {
        get { defaults.integer(forKey: "vibro") != 0 }
        nonmutating set { defaults.set(newValue ? 1 : 0, forKey: "vibro") }
    }
    var isFirstTime: Bool { defaults.integer(forKey: "first") == 0 }   // Singleton.m:49
    func markFirstTimeDone() { defaults.set(1, forKey: "first") }      // Singleton.m:55
}
