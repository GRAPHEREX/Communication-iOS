//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard #available(iOS 13, *) else { return }
        
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            //Theme.systemThemeChanged()
        }
    }

}
