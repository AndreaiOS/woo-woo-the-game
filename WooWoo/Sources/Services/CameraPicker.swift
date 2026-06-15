import UIKit

/// Fotocamera frontale come SelfieScene.m:194-301.
/// Gestisce il permesso negato/assente: completion(nil) → la scena mostra un alert (degradazione con grazia).
///
/// Swift 6: `UIImagePickerControllerDelegate`/`UINavigationControllerDelegate` sono
/// protocolli `@MainActor`; marcando l'intera classe `@MainActor` la conformità è
/// soddisfatta senza `nonisolated`/`assumeIsolated`. I metodi delegate sono comunque
/// invocati da UIKit sul main thread, quindi l'isolamento è corretto e non c'è
/// hop di attore. `static let shared` è `@MainActor` di conseguenza.
@MainActor
final class CameraPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let shared = CameraPicker()
    private var completion: ((UIImage?) -> Void)?

    func pick(completion: @escaping (UIImage?) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { completion(nil); return }
        self.completion = completion
        let picker = UIImagePickerController()
        picker.sourceType = .camera                     // :268
        picker.cameraDevice = .front                    // :277
        picker.cameraCaptureMode = .photo               // :271
        picker.allowsEditing = true                     // :274
        picker.delegate = self
        UIApplication.shared.keyRootViewController?.present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        completion?((info[.editedImage] ?? info[.originalImage]) as? UIImage)   // :303-310
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        completion?(nil)
    }
}
