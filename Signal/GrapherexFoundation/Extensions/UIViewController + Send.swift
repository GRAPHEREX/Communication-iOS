//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation

@objc
extension UIViewController {
    public func showSendFromChat(recipient: SignalRecipient) {
        let sendController = SendCurrencyFromChatController()
        sendController.recipient = recipient
        
        let walletModel = WalletModel.shared
        ModalActivityIndicatorViewController.present(
            fromViewController: self,
            canCancel: true,
            backgroundBlock: { [weak self] modal in
                guard let self = self else { return }
                walletModel.initWallets { result in
                    switch result {
                    case .success(_):
                        walletModel.getRecipientWallets(accountId: recipient.address.phoneNumber!) { result in
                            switch result {
                            case .success(let recipientWallets):
                                sendController.recipeintWallets = recipientWallets
                                
                                let myCurrencies: [Currency] = walletModel.wallets.map { return $0.currency }
                                let recipientCurrencies: [Currency] = recipientWallets.map { return $0.currency }
                                let currencies: [Currency] = myCurrencies.filter { recipientCurrencies.contains($0) }
                                
                                let allowedCurrencies = currencies.removeDuplicates()
                                sendController.allowedCurrencies = allowedCurrencies
                                
                                modal.dismiss {
                                    if walletModel.wallets.isEmpty {
                                        let controller = NoWalletController()
                                        controller.onDoneButtonClicked = { [weak self] in
                                            controller.dismiss(animated: true, completion: { [weak self] in
                                                self?.presentActionSheet(NewWalletController())
                                            })
                                        }
                                        OWSActionSheets.showActionSheet(controller)
                                    } else if allowedCurrencies.isEmpty {
                                        OWSActionSheets.showActionSheet(
                                            title: "No currencies are currently enabled",
                                            message: "You can't send money to this user, as he does not have available wallets",
                                            image: #imageLiteral(resourceName: "Wallet")
                                        )
                                    } else {
                                        sendController.hidesBottomBarWhenPushed = true
                                        self.navigationController?.pushViewController(sendController, animated: true)
                                    }
                                }
                            case .failure(let error):
                                print(error)
                                modal.dismiss {
                                    self.handleError(error: error)
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                        modal.dismiss {
                            self.handleError(error: error)
                        }
                    }
                }
        })
    }
    
    public func showSendFromChat(recipientAddress: SignalServiceAddress) {
        var signalRecipient: SignalRecipient!
        SDSDatabaseStorage.shared.read { transaction in
            signalRecipient = AnySignalRecipientFinder().signalRecipient(for: recipientAddress, transaction: transaction)
        }
        showSendFromChat(recipient: signalRecipient)
    }
    
    fileprivate func handleError(error: Error) {
        OWSActionSheets.showErrorAlert(message: error.localizedDescription)
    }
}
