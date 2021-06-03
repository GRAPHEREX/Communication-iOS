//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation
import CryptoWallet

@objc
extension UIViewController {
    public func showSendFromChat(recipient: SignalRecipient, isOpenedFromContacts: Bool) {
        guard let userId = recipient.recipientPhoneNumber else { return }
        let sendController = AppEnvironment.shared.wallet.createSendMoneyController(forUserId: userId) { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        navigationController?.present(sendController, animated: true)
    }
    
    public func showSendFromChat(recipientAddress: SignalServiceAddress) {
        var signalRecipient: SignalRecipient!
        SDSDatabaseStorage.shared.read { transaction in
            signalRecipient = AnySignalRecipientFinder().signalRecipient(for: recipientAddress, transaction: transaction)
        }
        showSendFromChat(recipient: signalRecipient, isOpenedFromContacts: false)
    }
    
    public func showSendFromContacts(recipientAddress: SignalServiceAddress) {
        var signalRecipient: SignalRecipient!
        SDSDatabaseStorage.shared.read { transaction in
            signalRecipient = AnySignalRecipientFinder().signalRecipient(for: recipientAddress, transaction: transaction)
        }
        showSendFromChat(recipient: signalRecipient, isOpenedFromContacts: true)
    }
    
    fileprivate func handleError(error: Error) {
        OWSActionSheets.showErrorAlert(message: error.localizedDescription)
    }
}
