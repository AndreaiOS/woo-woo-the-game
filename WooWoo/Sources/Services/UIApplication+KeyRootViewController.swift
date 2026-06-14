import UIKit

extension UIApplication {
    /// Root view controller della key window, per presentare UIKit (alert, camera,
    /// share sheet, pannelli Game Center) sopra la SKView.
    var keyRootViewController: UIViewController? {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}
