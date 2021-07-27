//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import AppsFlyerLib

typealias AnalyticsParameters = [String: Any]

@objc enum AnalyticsEvent: Int, CustomStringConvertible {
    // General events
    case sessionStart
    case signUpScreenOpened
    case signUpSuccess
    case appUpdated
    case osUpdated
    // Wallet related events
    case newWalletScreenOpened
    case newWalletSuccess
    case moneySendScreenOpenedFromWallet
    case moneySendScreenOpenedFromChat
    case moneySendScreenOpenedFromContacts
    case moneyReceiveScreenOpened
    case walletPasswordChangeScreenOpened
    case walletPasswordChangeSuccess
    case walletPinChangeScreenOpened
    case walletPinChangeSuccess
    case walletDetailsScreenOpened
    case moneySendSuccess
    case moneySendFailure
    
    var description: String {
        switch self {
        // General events
        case .sessionStart:
            return "session_start"
        case .signUpScreenOpened:
            return "app_registration"
        case .signUpSuccess:
            return "app_registration_success"
        case .appUpdated:
            return "app_update"
        case .osUpdated:
            return "os_update"
        // Wallet related events
        case .newWalletScreenOpened:
            return "wallet_create_new"
        case .newWalletSuccess:
            return "wallet_create_new_success"
        case .moneySendScreenOpenedFromWallet:
            return "wallet_send_crypto"
        case .moneySendScreenOpenedFromChat:
            return "chat_send_crypto"
        case .moneySendScreenOpenedFromContacts:
            return "contact_send_crypto"
        case .moneyReceiveScreenOpened:
            return "wallet_receive_crypto"
        case .walletPasswordChangeScreenOpened:
            return "wallet_change_password"
        case .walletPasswordChangeSuccess:
            return "wallet_change_password_success"
        case .walletPinChangeScreenOpened:
            return "wallet_change_pin"
        case .walletPinChangeSuccess:
            return "wallet_change_pin_success"
        case .walletDetailsScreenOpened:
            return "wallet_screen_view"
        case .moneySendSuccess:
            return "wallet_send_crypto_success"
        case .moneySendFailure:
            return "wallet_send_crypto_failure"
        }
    }
}

@objc class AnalyticsService: NSObject {
    // MARK: - Properties
    private struct Constants {
        static let eventNameLengthLimit = 45
    }
    
    // MARK: - Methods
    @objc static func log(event: AnalyticsEvent, parameters: AnalyticsParameters?) {
        if event.description.count > Constants.eventNameLengthLimit {
            Logger.warn("eventName length is exceeded 45 characters and can be cut by sdk")
        }
        
        AppsFlyerLib.shared().logEvent(event.description, withValues: parameters)
    }
}
