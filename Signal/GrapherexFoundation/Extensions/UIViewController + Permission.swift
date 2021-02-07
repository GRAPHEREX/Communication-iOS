//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation
import UIKit

extension UIViewController {
    func askForCameraPermission(completion: ((Bool)->Void)? ) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            completion?(true)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success { // if request is granted (success is true)
                    completion?(true)
                } else {
                    completion?(false)
                    // if request is denied (success is false)
                    // Create Alert
                    let alert = UIAlertController(title: "Camera", message: "Camera access is necessary to use this app", preferredStyle: .alert)
                    
                    // Add "OK" Button to alert, pressing it will bring you to the settings app
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }))
                    // Show the alert with animation
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
