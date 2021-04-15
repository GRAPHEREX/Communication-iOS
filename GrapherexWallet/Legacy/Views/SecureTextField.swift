//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class SecureTextField: UITextField {
    let button = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    internal
    func setup() {
        self.rightView = button
        button.frame = .init(x: 0, y: 0, width: 30, height: 30)
        self.rightViewMode = .always
        button.setTitle(nil, for: .normal)
        button.setImage(#imageLiteral(resourceName: "icon.secure.eye").withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.contentMode = .center
        button.addTarget(self, action: #selector(secureButtonTap), for: .touchUpInside)
        secureButtonTap()
    }
}

fileprivate extension SecureTextField {
    @objc
    func secureButtonTap() {
        self.isSecureTextEntry.toggle()
        button.tintColor = self.isSecureTextEntry ? .wlt_gray10 : .wlt_accentGreen
    }
}
