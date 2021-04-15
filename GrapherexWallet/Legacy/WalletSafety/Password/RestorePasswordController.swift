//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation
import Photos
import PromiseKit

final class RestorePasswordController: ActionSheetController {
    
    private enum Constant {
        static let imageBackground: UIColor = UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 0.2)
    }

    private var password: String = "" {
        didSet {
            restoreButton.handleEnabled(!password.isEmpty)
        }
    }
    
    private let imageManager = PHCachingImageManager()
    private let imageView = UIImageView()
    private let restoreButton = STPrimaryButton()
    private let selectInfoLabel = UILabel()
    private let errorLabel = UILabel()
    private let scanButton = UIButton()
    
    private var image: UIImage? {
        didSet {
            imageSelected()
        }
    }
    
    var walletId: String!
    
    override func setup() {
        super.setup()
        
        isCancelable = true
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 16, left: 16, bottom: 8, right: 16)
        setupCenterHeader(title: "Restore password", close: #selector(close))
        
        setupLabels()
        setupImage()
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nothing)))
        setupButton()
    }
    
    @objc func nothing() {}
}

fileprivate extension RestorePasswordController {
    func setupLabels() {
        selectInfoLabel.numberOfLines = 2
        selectInfoLabel.text = "Tap here\nto select image"
        selectInfoLabel.textAlignment = .center
        selectInfoLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        selectInfoLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextSemiboldFont(withSize: 20)
        
        errorLabel.isHidden = true
        errorLabel.textAlignment = .center
        errorLabel.textColor = .wlt_otherRed
        errorLabel.text = "Choose QR code image"
        errorLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextSemiboldFont(withSize: 12)
        
        let restoreLabel = UILabel()
        restoreLabel.textAlignment = .center
        restoreLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        restoreLabel.text = "Set QR code for restore password"
        restoreLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 16).wlt_semibold
        
        stackView.addArrangedSubview(restoreLabel)
    }
    
    func setupImage() {
        let topSpacer = UIView.hStretchingSpacer()
        let bottomSpacer = UIView.hStretchingSpacer()
        
        stackView.addArrangedSubview(topSpacer)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(bottomSpacer)
        
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = Constant.imageBackground
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMedia)))
        imageView.autoMatch(.width, to: .width, of: view, withOffset: -32, relation: .lessThanOrEqual)
        imageView.autoMatch(.height, to: .height, of: view, withMultiplier: 0.5, relation: .lessThanOrEqual)
        imageView.autoMatch(.height, to: .height, of: view, withMultiplier: 0.35, relation: .greaterThanOrEqual)

        imageView.addSubview(selectInfoLabel)
        selectInfoLabel.autoCenterInSuperview()
        
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)
    }
    
    func setupButton() {
        restoreButton.handleEnabled(false)
        stackView.addArrangedSubview(scanButton)
        stackView.addArrangedSubview(UIView.spacer(withHeight: 12))
        scanButton.addTarget(self, action: #selector(scanQRcode), for: .touchUpInside)
        scanButton.setTitle("Scan QR code", for: .normal)
//        scanButton.setTitleColor(Theme.secondaryTextAndIconColor, for: .normal)
        restoreButton.setTitle(NSLocalizedString("MAIN_RESTORE", comment: ""), for: .normal)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        stackView.addArrangedSubview(restoreButton)
    }
    
    @objc
    func openMedia() {
        //Logger.info(#function)
        self.wlt_askForMediaLibraryPermissions() { [weak self] isEnabled in
            guard let self = self else { return }
            let navController = SendMediaNavigationController()
            let vc = ImagePickerGridController()
            vc.delegate = self
            navController.setViewControllers([vc], animated: false)
            self.presentFullScreen(navController, animated: true)
        }
    }
    
    @objc
    func scanQRcode() {
        let controller = ScanQRController()
        controller.returnScreen = self
        controller.result = { [weak controller] secureCode in
            //Analytics.logEvent("Wallet.QRCodeScanned.Success", parameters: nil)
            self.password = secureCode
            controller?.dismiss(animated: true, completion: nil)
        }
        let navController = WLTNavigationController(rootViewController: controller)
        self.presentFullScreen(navController, animated: true)

    }
    
    @objc
    func restore() {
        //Logger.info(#function)
        let controller = PasswordController()
        controller.mode = .changePassword
        controller.walletId = walletId
        controller.setCurrentPassword(password: password)
        controller.completion = { [weak self] in
            self?.close()
        }
        self.presentActionSheet(controller)
    }
    
    @objc
    func imageSelected() {
        guard let image = self.image else { return }
        password = image.parseQR().joined()
        if password.isEmpty {
            imageView.image = nil
            errorLabel.isHidden = false
            selectInfoLabel.isHidden = false
            imageView.backgroundColor = Constant.imageBackground
        } else {
            imageView.image = image
            errorLabel.isHidden = true
            selectInfoLabel.isHidden = true
            imageView.backgroundColor = .clear
        }
    }
    
    @objc
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc
    func close() {
        hideKeyboard()
        self.dismiss(animated: true, completion:  nil)
    }
}

extension RestorePasswordController: ImagePickerGridControllerDelegate {
    func imagePickerDidCompleteSelection(_ imagePicker: ImagePickerGridController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerDidCancel(_ imagePicker: ImagePickerGridController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePicker(_ imagePicker: ImagePickerGridController, isAssetSelected asset: PHAsset) -> Bool { return true }
    
//    func imagePicker(_ imagePicker: ImagePickerGridController, didSelectAsset asset: PHAsset, attachmentPromise: Promise<SignalAttachment>) {
//        _ = imageManager.requestImageData(for: asset, options: .none) { imageData, dataUTI, _, _ in
//            guard let imageData = imageData else { return }
//            self.image = UIImage(data: imageData)
//        }
//    }
    
    func imagePicker(_ imagePicker: ImagePickerGridController, didDeselectAsset asset: PHAsset) { }
    
    var isInBatchSelectMode: Bool {
        return false
    }
    
    var isPickingAsDocument: Bool {
        return false
    }
    
    func imagePickerCanSelectMoreItems(_ imagePicker: ImagePickerGridController) -> Bool { return true }
    
    func imagePickerDidTryToSelectTooMany(_ imagePicker: ImagePickerGridController) { }
    
}
