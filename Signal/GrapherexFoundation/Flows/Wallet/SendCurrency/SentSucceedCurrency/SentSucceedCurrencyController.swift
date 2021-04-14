//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class SentSucceedCurrencyController: ActionSheetController {
    
    private let finishButton = STPrimaryButton()
    
    weak var fromViewController: UIViewController?
    
    public var sentMoneyInfo: String!
    
    override func setup() {
        super.setup()
        stackView.spacing = 20
        setupMargins(margin: 16)
        setupCenterHeader(title: "", close: #selector(close))
        setupContent()
        setupButton()
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        isCancelable = true
        AnalyticsService.log(event: .moneySendSuccess, parameters: nil)
    }
    
}

fileprivate extension SentSucceedCurrencyController {
    func setupButton() {
        finishButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        finishButton.setTitle(NSLocalizedString("MAIN_THANK_YOU", comment: ""), for: .normal)
        finishButton.setContentHuggingVerticalHigh()
        stackView.addArrangedSubview(finishButton)
    }
    
    func setupContent() {
        let topSpacer = UIView.hStretchingSpacer()
        let bottomSpacer = UIView.hStretchingSpacer()
        
        stackView.addArrangedSubview(topSpacer)
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Success"))
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingVerticalHigh()
        stackView.addArrangedSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.textColor = Theme.primaryTextColor
        titleLabel.font = UIFont.st_robotoRegularFont(withSize: 18).ows_semibold
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("SENT_SUCCEED_TITLE", comment: "")
        stackView.addArrangedSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = sentMoneyInfo
        subtitleLabel.textColor = Theme.secondaryTextAndIconColor
        subtitleLabel.font = UIFont.st_robotoRegularFont(withSize: 14)
        
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(bottomSpacer)
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.fromViewController?.navigationController?.popToRootViewController(animated: true)
        })
    }
}
