enum AchievementCatalog {
    static let all: [Achievement] = [
        // 🔥 Combo
        Achievement(id: "combo_5",  title: "Raffica",   detail: "5 gabbiani di fila senza farti colpire",  category: .combo, rarity: .comune, trigger: .streak(5),  gcID: nil, isSecret: false),
        Achievement(id: "combo_10", title: "Furia",     detail: "10 di fila senza farti colpire",           category: .combo, rarity: .raro,   trigger: .streak(10), gcID: nil, isSecret: false),
        Achievement(id: "combo_20", title: "Scatenato", detail: "20 di fila senza farti colpire",           category: .combo, rarity: .epico,  trigger: .streak(20), gcID: nil, isSecret: false),
        // 🎯 Punteggio
        Achievement(id: "score_25",  title: "Cacciatore",   detail: "25 gabbiani in una partita",  category: .punteggio, rarity: .comune, trigger: .scoreInGame(25),  gcID: nil,               isSecret: false),
        Achievement(id: "score_50",  title: "Cecchino",     detail: "50 gabbiani in una partita",  category: .punteggio, rarity: .raro,   trigger: .scoreInGame(50),  gcID: "badge_50uccisi",  isSecret: false),
        Achievement(id: "score_100", title: "Sterminatore", detail: "100 gabbiani in una partita", category: .punteggio, rarity: .epico,  trigger: .scoreInGame(100), gcID: "badge_100uccisi", isSecret: false),
        // ⏱️ Sopravvivenza
        Achievement(id: "time_60",  title: "Resistente", detail: "Sopravvivi 60 secondi",  category: .sopravvivenza, rarity: .comune, trigger: .survival(60),  gcID: nil, isSecret: false),
        Achievement(id: "time_120", title: "Maratoneta", detail: "Sopravvivi 120 secondi", category: .sopravvivenza, rarity: .raro,   trigger: .survival(120), gcID: nil, isSecret: false),
        // 📈 Carriera
        Achievement(id: "games_10",   title: "Habitué",      detail: "Gioca 10 partite",        category: .carriera, rarity: .comune, trigger: .gamesPlayed(10),  gcID: "badge_10partite",  isSecret: false),
        Achievement(id: "total_500",  title: "Collezionista", detail: "500 gabbiani in totale",  category: .carriera, rarity: .raro,   trigger: .totalKills(500),  gcID: nil,                isSecret: false),
        Achievement(id: "games_100",  title: "Veterano",     detail: "Gioca 100 partite",       category: .carriera, rarity: .epico,  trigger: .gamesPlayed(100), gcID: "badge_100partite", isSecret: false),
        Achievement(id: "total_1000", title: "Millennio",    detail: "1000 gabbiani in totale", category: .carriera, rarity: .epico,  trigger: .totalKills(1000), gcID: nil,                isSecret: false),
        // 🎉 Chicche
        Achievement(id: "first_game", title: "Battesimo",     detail: "Completa la prima partita",                       category: .chicche, rarity: .comune, trigger: .gamesPlayed(1),  gcID: nil,        isSecret: false),
        Achievement(id: "answer_42",  title: "Niente panico", detail: "Colpisci esattamente 42 gabbiani in una partita", category: .chicche, rarity: .raro,   trigger: .scoreExact(42),  gcID: "badge_42", isSecret: true),
        Achievement(id: "selfie_1",   title: "Star",          detail: "Scatta il tuo primo Woowoo Selfie",               category: .chicche, rarity: .comune, trigger: .selfie,          gcID: nil,        isSecret: false),
    ]

    static func with(id: String) -> Achievement? { all.first { $0.id == id } }
}
