enum SpawnKind { case amico, bonus, monster }

enum SpawnDecision {
    /// MyScene2.m:458-474 — port esatto della catena if/else che decide cosa spawnare
    /// in modalità mamma in base al numero di gabbiani già apparsi (`mostri`).
    /// Ordine fedele: primo è amico → gate bonus → `% 5 != 0` amico → altrimenti mostro.
    static func mamma(mostri: Int) -> SpawnKind {
        if mostri == 0 { return .amico }
        if GameConfig.Mamma.bonusGates.contains(mostri) { return .bonus }
        if mostri % 5 != 0 { return .amico }
        return .monster
    }
}
