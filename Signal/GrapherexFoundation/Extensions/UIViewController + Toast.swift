//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation

extension UIViewController {
    func presentToast(text: String, fromViewController: UIViewController) {
        let toastController = ToastController(text: text)

        let bottomInset = fromViewController.bottomLayoutGuide.length + 8
        toastController.presentToastView(fromBottomOfView: fromViewController.view, inset: bottomInset)
    }
}
