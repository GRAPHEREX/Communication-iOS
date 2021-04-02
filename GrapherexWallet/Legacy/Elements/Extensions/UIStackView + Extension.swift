//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

extension UIStackView {
    func removeAllArrangedSubviews(deactivateConstraints: Bool = false) {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        guard deactivateConstraints else { return }
        for view in removedSubviews {
            if view.superview != nil {
                NSLayoutConstraint.deactivate(view.constraints)
                view.removeFromSuperview()
            }
        }
    }
}
