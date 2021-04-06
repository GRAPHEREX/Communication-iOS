//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final
class NewWalletSuccessController: ActionSheetController {
    
    private let saveButton = STPrimaryButton()
    private let saveLabel = UILabel()
    private var imageViewCoeff: CGFloat = 0.33
    
    var password: String!
    
    private var qrImage: UIImage!
    
    var fromViewController: UIViewController!
    
    override func setup() {
        super.setup()
        
        isCancelable = true
        stackView.spacing = 8
        setupMargins(margin: 16)
        setupCenterHeader(title: "Success", close: #selector(close))
        
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

fileprivate extension NewWalletSuccessController {
    func setupLabels() {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        titleLabel.text = "Wallet was created successfully"
        titleLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 16).wlt_semibold
        
        let confirmationLabel = UILabel()
        confirmationLabel.numberOfLines = 2
        confirmationLabel.textAlignment = .center
        confirmationLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        confirmationLabel.text = "Password for transaction\nconfirmation was set";
        confirmationLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
        
        let restoreLabel = UILabel()
        restoreLabel.textAlignment = .center
        restoreLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        restoreLabel.text = NSLocalizedString("WALLET_CODE_FOR_RESTORE_INFO", comment: "")
        restoreLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
        
        stackView.addArrangedSubview(UIView.vStretchingSpacer(minHeight: 4, maxHeight: 16))
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(UIView.vStretchingSpacer(minHeight: 0, maxHeight: 16))
        stackView.addArrangedSubview(confirmationLabel)
        stackView.addArrangedSubview(UIView.vStretchingSpacer(minHeight: 0, maxHeight: 16))
        stackView.addArrangedSubview(restoreLabel)
    }
    
    func setupCode() {
        let topSpacer = UIView.hStretchingSpacer()
        let middleSpacer = UIView.hStretchingSpacer()
        let bottomSpacer = UIView.hStretchingSpacer()
        
        stackView.addArrangedSubview(topSpacer)
        
        qrImage = QRCreator.createQr(qrString: password, size: UIScreen.main.bounds.size.height * imageViewCoeff)
        let imageView = UIImageView(image: qrImage)
        imageView.contentMode = .scaleAspectFit
        imageView.wltSetContentHuggingVerticalHigh()
        stackView.addArrangedSubview(imageView)
        imageView.autoMatch(.height, to: .height, of: view, withMultiplier: imageViewCoeff)
        stackView.addArrangedSubview(middleSpacer)
        
        saveLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        saveLabel.numberOfLines = 2
        saveLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 16).wlt_semibold
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
        saveButton.autoMatch(.width, to: .width, of: view, withOffset: -32)
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
                        self.close()
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
        self.dismiss(animated: true, completion: {
            self.fromViewController.dismiss(animated: true, completion: nil)
        })
    }
}
