enum GameMode {
    case figlia, mamma

    var leaderboardID: String {
        switch self {
        case .figlia: "Woo_Woo_Leaderboard"          // PunteggiScene.m:30
        case .mamma: "Woo_Woo_Leaderboard_Mamma"     // PunteggiSceneMamma.m:29, MyScene2.m:199
        }
    }
    /// Suffisso chiavi UserDefaults ("" o "_mamma") — Singleton.m
    var keySuffix: String { self == .mamma ? "_mamma" : "" }
}
