//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Theme.isDarkThemeEnabled = traitCollection.userInterfaceStyle == .dark
        
        onThemeChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onThemeChanged), name: Notification.themeChanged, object: nil)
    }
    

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard #available(iOS 13, *) else {
            Theme.isDarkThemeEnabled = false
            return
        }
        
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            Theme.isDarkThemeEnabled = traitCollection.userInterfaceStyle == .dark
        }
    }

    @objc private func onThemeChanged() {
        //navigationBar.backgroundColor = Theme.navbarBackgroundColor
        navigationBar.barTintColor = Theme.navbarBackgroundColor
        navigationBar.tintColor = Theme.navbarTintColor
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.navbarTintColor]
    }
}
