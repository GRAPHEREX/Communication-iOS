//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class PastelessTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return super.canPerformAction(action, withSender: sender)
            && (action == #selector(UIResponderStandardEditActions.cut)
            || action == #selector(UIResponderStandardEditActions.copy))
    }
}
