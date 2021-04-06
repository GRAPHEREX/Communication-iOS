//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class EnterPasswordBeforeSendingController: ActionSheetController {
    
    public var onSendTap: ((String) -> Void)!
    
    public var recieverAddress: String! {
        didSet {
            recieverAddressLabel.text = recieverAddress
        }
    }
    private let sendButton = STPrimaryButton()
    private let recieverAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 16)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 16).wlt_semibold
        label.text = "Password"
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = SecureTextField()
        textField.placeholder = "Enter password"
        return textField
    }()
    private var spacer = UIView.vStretchingSpacer(minHeight: 8.0, maxHeight: UIScreen.main.bounds.size.height * 0.2)
    private var bottomSpacer = UIView()
    private var bottomSpacerHeight: NSLayoutConstraint!
    private var bottomPadding: CGFloat!
    
    override func setup() {
        super.setup()
        sendButton.handleEnabled(false)
        setupCenterHeader(title: "Send to", close: #selector(close))
        
        isCancelable = true
        stackView.spacing = 16
        setupMargins(margin: 16)

        stackView.addArrangedSubview(recieverAddressLabel)
        sendButton.setTitle("Send", for: .normal)
        stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nothing)))
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        passwordTextField.addTarget(self, action: #selector(getStr), for: .editingChanged)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(sendButton)
        stackView.addArrangedSubview(bottomSpacer)
        bottomSpacerHeight = bottomSpacer.autoSetDimension(.height, toSize: 0)
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        bottomPadding = window?.safeAreaInsets.bottom ?? 0
        scrollView.bounces = false
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topPadding + topSpace, relation: .greaterThanOrEqual)
        
        setupKeyboardNotifications()
    }
    
    @objc func nothing() {}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = passwordTextField.becomeFirstResponder()
    }
    
    @objc
    func getStr() {
        let text: String = passwordTextField.text ?? ""
        sendButton.handleEnabled(!text.isEmpty)
    }
    
    @objc
    func sendButtonPressed() {
        self.dismiss(animated: true) {
            self.onSendTap(self.passwordTextField.text!)
        }
    }
}

fileprivate extension EnterPasswordBeforeSendingController {
    @objc
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

fileprivate extension EnterPasswordBeforeSendingController {
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func handleKeyboardNotification(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            else { return }
        
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        
        if isKeyboardShowing {
            bottomSpacerHeight.constant = keyboardFrame.height - bottomPadding + 8
        } else {
            bottomSpacerHeight.constant = 0
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}
