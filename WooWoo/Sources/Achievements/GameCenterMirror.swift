/// Astrazione per il mirror Game Center (testabile). GameCenterService la implementa già.
@MainActor
protocol GameCenterMirror {
    func report(achievementIDs: [String])
}

extension GameCenterService: GameCenterMirror {}
