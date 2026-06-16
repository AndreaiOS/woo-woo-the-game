import Foundation

/// Persistenza degli achievement sbloccati (id → timestamp). UserDefaults iniettabile per i test.
struct AchievementStore {
    private let defaults: UserDefaults
    private let key = "achievements_unlocked"
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    private func map() -> [String: Double] {
        defaults.dictionary(forKey: key) as? [String: Double] ?? [:]
    }

    func isUnlocked(_ id: String) -> Bool { map()[id] != nil }

    /// Sblocca; ritorna true solo se era ancora bloccato (idempotente).
    @discardableResult
    func unlock(_ id: String, at time: Double) -> Bool {
        var m = map()
        guard m[id] == nil else { return false }
        m[id] = time
        defaults.set(m, forKey: key)
        return true
    }

    func unlockDate(_ id: String) -> Date? {
        map()[id].map { Date(timeIntervalSince1970: $0) }
    }
}
