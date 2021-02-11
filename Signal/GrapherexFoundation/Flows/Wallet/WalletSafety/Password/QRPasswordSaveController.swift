//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class QRPasswordSaveController: ActionSheetController {
    typealias CompletionHandler = () -> Void
    public var completion: CompletionHandler?
    
    private let saveButton = STPrimaryButton()
    private let saveLabel = UILabel()
    
    var password: String!
    
    private var qrImage: UIImage!
    
    var fromViewController: UIViewController!
    
    override func setup() {
        super.setup()
        
        isCancelable = true
        stackView.spacing = 8
        setupMargins(margin: 16)
        setupCenterHeader(title: "", close: #selector(close))
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nothing)))

        setupLabels()
        setupCode()
        setupButton()
    }
    
    @objc func nothing() {}
}

fileprivate extension QRPasswordSaveController {
    func setupLabels() {
        let confirmationLabel = UILabel()
        confirmationLabel.numberOfLines = 2
        confirmationLabel.textAlignment = .center
        confirmationLabel.textColor = Theme.primaryTextColor
        confirmationLabel.text = NSLocalizedString("WALLET_NEW_PASSWORD_CONFIRMATION", comment: "")
        confirmationLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 16).ows_semibold
        
        let restoreLabel = UILabel()
        restoreLabel.textAlignment = .center
        restoreLabel.textColor = Theme.primaryTextColor
        restoreLabel.text = NSLocalizedString("WALLET_CODE_FOR_RESTORE_INFO", comment: "")
        restoreLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        
        stackView.addArrangedSubview(confirmationLabel)
        stackView.addArrangedSubview(UIView.vStretchingSpacer(minHeight: 4, maxHeight: 24))
        stackView.addArrangedSubview(restoreLabel)
    }
    
    func setupCode() {
        let topSpacer = UIView.hStretchingSpacer()
        let middleSpacer = UIView.hStretchingSpacer()
        let bottomSpacer = UIView.hStretchingSpacer()
        
        stackView.addArrangedSubview(topSpacer)
        
        qrImage = QRCreator.createQr(qrString: password, size: UIScreen.main.bounds.size.height * 0.33)
        let imageView = UIImageView(image: qrImage)
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingVerticalHigh()
        stackView.addArrangedSubview(imageView)
        imageView.autoMatch(.height, to: .height, of: view, withMultiplier: 0.33)
        stackView.addArrangedSubview(middleSpacer)
        
        saveLabel.textColor = Theme.primaryTextColor
        saveLabel.font = UIFont.st_robotoRegularFont(withSize: 16).ows_semibold
        saveLabel.textAlignment = .center
        saveLabel.text = NSLocalizedString("WALLET_SAVE_IT", comment: "")
        stackView.addArrangedSubview(saveLabel)
        stackView.addArrangedSubview(bottomSpacer)
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)
        topSpacer.autoMatch(.height, to: .height, of: middleSpacer)
        
        stackView.addArrangedSubview(UIView.hStretchingSpacer())
    }
    
    func setupButton() {
        saveButton.addTarget(self, action: #selector(saveButtonTap), for: .touchUpInside)
        saveButton.setTitle(NSLocalizedString("MAIN_SAVE", comment: ""), for: .normal)
        saveButton.autoSetDimension(.height, toSize: 56)
        saveButton.icon = .ok
        stackView.addArrangedSubview(saveButton)
    }
    
    @objc
    func saveButtonTap() {
        saveImage(image: qrImage)
    }
    
    func saveImage(image: UIImage) {
        DispatchQueue.main.async {
            GalleryManager.saveImage(image: image, completion: { isSuccess, errorMessage in
                DispatchQueue.main.async {
                    if isSuccess {
                        self.saveButton.setTitle(NSLocalizedString("MAIN_SAVED", comment: ""), for: .normal)
                        self.dismiss(animated: true, completion: {
                            self.fromViewController.dismiss(animated: true) {
                                self.completion?()
                            }
                        })
                    } else {
                        self.saveLabel.text = errorMessage
                        self.saveLabel.textColor = .red
                    }
                }
            })
        }
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
