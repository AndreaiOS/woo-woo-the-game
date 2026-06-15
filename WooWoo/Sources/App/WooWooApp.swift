import SwiftUI

@main
struct WooWooApp: App {
    var body: some Scene {
        WindowGroup {
            GameViewport()
                .ignoresSafeArea()
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}
