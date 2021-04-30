//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import UIKit

final class WalletExchangeController: OWSViewController {
    
    private var contentStack: UIStackView!
    
    // From View
    private let containerFromViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var fromWalletView = WalletExchangeSelectionView()
    
    // Change Button
    private let changeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon.exchange")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = Theme.primaryTextColor
        return button
    }()
    
    // To View
    private let containerToViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var toWalletView = WalletExchangeSelectionView()
    
    // Send Button
    private var sendButton: STPrimaryButton = {
        let button = STPrimaryButton()
        button.handleEnabled(false)
        button.setTitle(NSLocalizedString("MAIN_CONFIRM", comment: ""), for: .normal)
        return button
    }()

    override func setup() {
        super.setup()
        title = NSLocalizedString("WALLET_EXCHANGE_TITLE", comment: "")
        setupView()
        
        fromWalletView.onRecalculate = { [weak self] newFromValue in
            print(newFromValue)
            self?.calculateFrom(newFromValue)
        }
        
        toWalletView.onRecalculate = { [weak self] newToValue  in
            print(newToValue)
            self?.calculateTo(newToValue)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "plus-24"),
            style: .plain,
            target: self,
            action: #selector(plusButtonPressed)
        )
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTheme),
                                               name: .ThemeDidChange, object: nil)
    }
    
    override func applyTheme() {
        view.backgroundColor = Theme.backgroundColor
        changeButton.tintColor = Theme.primaryTextColor
    }
}

// MARK: - Convertation

fileprivate extension WalletExchangeController {
    
    func calculateFrom(_ newFromValue: String) {
        toWalletView.setNewValue(value: newFromValue, multiplier: "2")
        sendButton.handleEnabled(
            fromWalletView.getCurrentWallet() != nil
                && toWalletView.getCurrentWallet() != nil
                && newFromValue.isNotZero
                && toWalletView.isNotEmptyAmount
        )
    }
    
    func calculateTo(_ newToValue: String) {
        fromWalletView.setNewValue(value: newToValue, divider: "2")
        sendButton.handleEnabled(
            fromWalletView.getCurrentWallet() != nil
                && toWalletView.getCurrentWallet() != nil
                && fromWalletView.isNotEmptyAmount
                && newToValue.isNotZero
        )
    }
}

// MARK: - Configure View

fileprivate extension WalletExchangeController {
    func setupView() {
        view.backgroundColor = Theme.backgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        let spacers = [UIView.vStretchingSpacer(),
                       UIView.vStretchingSpacer(),
                       UIView.vStretchingSpacer(),
                       UIView.vStretchingSpacer()]
        
        let buttonBackground = UIView.vStretchingSpacer()
        buttonBackground.addSubview(changeButton)
        changeButton.autoPinEdge(.top, to: .top, of: buttonBackground)
        changeButton.autoPinEdge(.bottom, to: .bottom, of: buttonBackground)
        changeButton.autoHCenterInSuperview()
        changeButton.autoSetDimension(.width, toSize: 240)
        changeButton.autoSetDimension(.height, toSize: 40, relation: .lessThanOrEqual)
        changeButton.addTarget(self, action: #selector(swapWallets), for: .touchUpInside)
        
        contentStack = UIStackView(arrangedSubviews: [
            spacers[0],
            containerFromViewContainer,
            spacers[1],
            buttonBackground,
            spacers[2],
            containerToViewContainer,
            spacers[3],
            sendButton
        ])
        
        view.addSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
        autoPinView(toBottomOfViewControllerOrKeyboard: contentStack, avoidNotch: true,
                    withInset: 8.0, saveInset: true)
        
        spacers.enumerated().forEach { offset, element in
            if offset != 0 {
                element.autoMatch(.height, to: .height, of: spacers[0])
            }
        }
        
        containerFromViewContainer.addSubview(fromWalletView)
        containerToViewContainer.addSubview(toWalletView)

        fromWalletView.autoPinEdge(.top, to: .top, of: containerFromViewContainer)
        fromWalletView.autoPinEdge(.bottom, to: .bottom, of: containerFromViewContainer)
        fromWalletView.autoPinLeadingToSuperviewMargin(withInset: 8)
        fromWalletView.autoPinTrailingToSuperviewMargin(withInset: 8)
        
        toWalletView.autoPinEdge(.top, to: .top, of: containerToViewContainer)
        toWalletView.autoPinEdge(.bottom, to: .bottom, of: containerToViewContainer)
        toWalletView.autoVCenterInSuperview()
        toWalletView.autoPinLeadingToSuperviewMargin(withInset: 8)
        toWalletView.autoPinTrailingToSuperviewMargin(withInset: 8)

        sendButton.autoSetDimension(.height, toSize: 56)
        containerFromViewContainer.autoMatch(.height, to: .height, of: containerToViewContainer)
        
        fromWalletView.changeWalletAction = { [weak self] in
            guard let self = self else { return }
            self.dismissKeyboard()
            let controller = WalletPickerController()
            controller.finish = { [weak self] wallet in
                self?.fromWalletView.update(wallet)
            }
            self.presentActionSheet(controller)
        }
        
        toWalletView.changeWalletAction = { [weak self] in
            guard let self = self else { return }
            self.dismissKeyboard()
            let controller = WalletPickerController()
            controller.finish = { [weak self] wallet in
                self?.toWalletView.update(wallet)
            }
            self.presentActionSheet(controller)        }
    }

}

// MARK:- Actions
fileprivate extension WalletExchangeController {
    
    @objc
    func plusButtonPressed() {
        let controller = WalletExchangeHistoryController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc
    func swapWallets() {
        guard
            let fromWallet = fromWalletView.getCurrentWallet(),
            let toWallet = toWalletView.getCurrentWallet()
        else {
            return
        }
        fromWalletView.configure(toWallet)
        toWalletView.configure(fromWallet)
    }
    
    func validation() -> Bool {
        if fromWalletView.getCurrentAmount().doubleValue > fromWalletView.getCurrentWallet()!.balance.doubleValue {
            let errorSheet = ActionSheetController(title: "Your balance is too low", message: nil)
            self.presentActionSheet(errorSheet)
            return false
        } else if !fromWalletView.isNotEmptyAmount {
            let errorSheet = ActionSheetController(title: "Enter amount", message: nil)
            self.presentActionSheet(errorSheet)
            return false
        }
        
        return true
    }
    
    @objc
    func sendButtonPressed() {
        view.endEditing(true)
        guard validation() else { return }
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { [weak self] modal in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                modal.dismiss {
                    guard let self = self else { return }
                    let controller = ExchangeCreatedController()
                    controller.fromViewController = self
                    let fromAmount = self.fromWalletView.getFormatAmount()
                    let toAmount = self.toWalletView.getFormatAmount()
                    
                    let fromCurrency = self.fromWalletView.getCurrentWallet()?.currency.symbol ?? "none"
                    let toCurrency = self.toWalletView.getCurrentWallet()?.currency.symbol ?? "none"
                    controller.exchangeText = "\(fromAmount) \(fromCurrency) = \(toAmount) \(toCurrency)"
                    self.presentActionSheet(controller)
                }
            }
        }
    }
    
    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
