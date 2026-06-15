import CoreGraphics
import Foundation

/// Costanti di gameplay estratte 1:1 dai sorgenti 2014.
/// NON modificare i valori: la parità di gameplay si verifica confrontando
/// questo file con i riferimenti file:riga indicati.
enum GameConfig {
    /// Altezza logica della scena (design iPhone 5 landscape: 568x320 pt)
    static let designHeight: CGFloat = 320

    enum Figlia {                                    // MyScene.m
        static let spawnThreshold: TimeInterval = 5.2    // :331
        static let spawnReset: TimeInterval = 3.0        // :332
        static let velocityBase: CGFloat = 180.0         // :431 (durata = 180/(mostri+90))
        static let playerStart = CGPoint(x: 100, y: 105) // :93
        static let accelDeceleration: CGFloat = 0.1      // :293
        static let accelSensitivity: CGFloat = 20.0      // :293
        static let accelMaxVelocity: CGFloat = 1400      // :293
        static let pauseResumePos = CGPoint(x: 0.50, y: 0.50)  // :892
        static let pauseExitPos = CGPoint(x: 0.50, y: 0.65)    // :903
    }

    enum Mamma {                                     // MyScene2.m
        static let spawnThreshold: TimeInterval = 5.2    // :461
        static let spawnReset: TimeInterval = 4.5        // :462
        static let velocityBase: CGFloat = 360.0         // :532, :859 (durata = 360/(mostri+180))
        static let touchRadiusBegan: CGFloat = 50        // :289
        static let touchRadiusMoved: CGFloat = 40        // :339
        static let bonusGates: Set<Int> = [17, 34, 51, 68, 81, 98, 115, 132]  // :466
        static let bonusHealAmount = 3                   // :301-306
        static let streakFade: TimeInterval = 0.3        // :197
        static let streakMinSegment: CGFloat = 20        // :197
        static let streakWidth: CGFloat = 6              // :197
        static let pauseResumePos = CGPoint(x: 0.50, y: 0.35)  // :1292
        static let pauseExitPos = CGPoint(x: 0.50, y: 0.65)    // :1303
    }

    // Comuni a entrambe le modalità
    static let maxColpi = 9                          // MyScene.m:766, MyScene2.m:1188
    static let gameOverDelay: TimeInterval = 0.90    // MyScene.m:774
    static let countdownStart = 3                    // MyScene.m:832
    static let countdownInterval: TimeInterval = 1.0 // MyScene.m:834
    static let gameTimerInterval: TimeInterval = 0.1 // MyScene.m:856
    static let musicVolume: Float = 0.5              // MyScene.m:175
    static let cloudCycleDuration: TimeInterval = 60 // MyScene.m:70-71
    static let waypointCount = 10                    // MyScene.m:439
    static let spawnMargin: CGFloat = 30             // MyScene.m:408, :415, :440-441
    static let gabbianoScale: CGFloat = 1.4          // GabbianoSprite.m:44
    static let lifeBarScale: CGFloat = 1.4           // MyScene.m:161 (ramo iPhone 5)
    static let hudFontSize: CGFloat = 30             // MyScene.m:545
    static let hudY: CGFloat = 40                    // MyScene.m:549 (height - 40)
    static let countdownFontSize: CGFloat = 120      // MyScene.m:825
    static let buttonFontSize: CGFloat = 28          // IntroScene.m e ovunque
    static let fontName = "Moon Flower"
    static let fontNameBold = "Moon Flower Bold"
}
