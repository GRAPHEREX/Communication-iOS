//
//  Copyright (c) 2020 Sky Tech. All rights reserved.
//

import Foundation
import Photos

final class GalleryManager {
    typealias FinishHandler = (Bool, String?) -> Void
    
    static func saveImage(image: UIImage, completion: FinishHandler?) {
        Logger.info("save Image")
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                completion?(true, nil)
            case .restricted:
                completion?(false, "Please, give Grapherex permission to use your photos")
            case .denied:
                completion?(false, "Please, give Grapherex permission to use your photos")
            case .notDetermined:
                completion?(false, "Please, give Grapherex permission to use your photos")
            @unknown default:
                break;
            }
        }
    }
}
