import Photos
import UIKit

enum SaveManager {
    static func saveToPhotos(image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        let saveBlock = {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    if let error = error { completion(.failure(error)) }
                    else if success { completion(.success(())) }
                    else { completion(.failure(NSError(domain: "Save", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown save error"])))}
                }
            }
        }

        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            saveBlock()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async { newStatus == .authorized || newStatus == .limited ? saveBlock() : completion(.failure(NSError(domain: "Save", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photos permission denied"])))}
            }
        default:
            completion(.failure(NSError(domain: "Save", code: 2, userInfo: [NSLocalizedDescriptionKey: "Photos permission denied"])) )
        }
    }
}

