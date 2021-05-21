//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalServiceKit
import CryptoWallet

extension TSAccountManager {
    @objc func setupGrapherexWallet() {
        NotificationCenter.default.addObserver(self, selector: #selector(onRegistrationStateChanged), name: NSNotification.Name.registrationStateDidChange, object: nil)
        onRegistrationStateChanged()
    }
    
    @objc func resetGrapherexWallet() {
        AppEnvironment.shared.wallet.reset()
    }
    
    // MARK: - Private Methods
    @objc private func onRegistrationStateChanged() {
        if (isRegisteredAndReady) {
            configureWallet()
        } else if (isDeregistered()) {
            resetGrapherexWallet()
        }
    }
    
    private func configureWallet() {
        guard let authUserName = storedServerUsername,
              let authPassword = storedServerAuthToken() else { return }
        let config = WalletConfig(apiServerURL: TSConstants.textSecureServerURL,
                                  cryptoServerURL: TSConstants.walletServerURL,
                                  cryptoServerBasePath: "/api/crypto-backend/v2/",
                                  authUsername: authUserName,
                                  authPassword: authPassword)
        AppEnvironment.shared.wallet.setup(withConfig: config)
    }
}
