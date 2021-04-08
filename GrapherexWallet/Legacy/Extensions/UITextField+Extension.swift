//
//  UITextField.swift
//  CurrencyText
//
//  Created by Felipe Lefèvre Marino on 12/26/18.
//

import UIKit

public extension UITextField {
    func disableAutoFill() {
        if #available(iOS 12, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}
