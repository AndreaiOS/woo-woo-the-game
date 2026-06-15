import UIKit

enum Haptics {
    /// Sostituisce AudioServicesPlayAlertSound(kSystemSoundID_Vibrate) al game over
    /// (MyScene.m:768). Rispetta il flag vibro.
    /// @MainActor richiesto da UINotificationFeedbackGenerator in Swift 6.
    @MainActor
    static func gameOverVibration(settings: Settings = Settings()) {
        guard settings.isVibroOn else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
