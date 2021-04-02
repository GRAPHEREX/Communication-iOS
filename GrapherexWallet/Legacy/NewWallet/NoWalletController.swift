//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

final public class NoWalletController: ActionSheetController {
    
    private let createButton = STPrimaryButton()
    
    public var onDoneButtonClicked: (() -> Void)?
    
    public override func setup() {
        super.setup()
        stackView.spacing = 20
        setupMargins(margin: 16)
        setupCenterHeader(title: "", close: #selector(close))
        setupContent()
        setupButton()
        isCancelable = true
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nothing)))
    }
}

fileprivate extension NoWalletController {
    func setupButton() {
        createButton.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        createButton.setTitle("Create wallet", for: .normal)
        createButton.setContentHuggingVerticalHigh()
        stackView.addArrangedSubview(createButton)
    }
    
    func setupContent() {
        let topSpacer = UIView.hStretchingSpacer()
        let bottomSpacer = UIView.hStretchingSpacer()
        
        stackView.addArrangedSubview(topSpacer)
        let imageView = UIImageView(image: UIImage.image(named: "wallet"))
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingVerticalHigh()
        stackView.addArrangedSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.textColor = Theme.primaryTextColor
        titleLabel.font = UIFont.st_robotoRegularFont(withSize: 18).ows_semibold
        titleLabel.textAlignment = .center
        titleLabel.text = "You have no wallets"
        stackView.addArrangedSubview(titleLabel)
                
        stackView.addArrangedSubview(bottomSpacer)
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)
    }
    
    @objc
    func nothing() {}
    
    @objc
    func doneButtonClicked() {
        onDoneButtonClicked?()
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
