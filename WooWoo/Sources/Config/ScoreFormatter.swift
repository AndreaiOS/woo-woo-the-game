/// Formattazione delle stringhe HUD, estratta 1:1 da MyScene.m.
/// - `hits`: il triplo if dell'originale (Hits 00N / Hits 0N / Hits N) è equivalente a un
///   padding a 3 cifre (MyScene.m:752-759).
/// - `time`: una cifra decimale (MyScene.m:566).
enum ScoreFormatter {
    static func hits(_ score: Int) -> String { String(format: "Hits %03d", score) }   // MyScene.m:752-759
    static func time(_ t: Double) -> String { String(format: "Time %.1f", t) }        // MyScene.m:566
}
