//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalServiceKit
import GrapherexWallet

extension TSAccountManager {
    @objc func startWalletConfigurationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onRegStateChanged), name: NSNotification.Name.registrationStateDidChange, object: nil)
        onRegStateChanged()
    }
    
    @objc func resetWalletConfiguration() {
        AppEnvironment.shared.wallet.reset()
    }
    
    // MARK: - Private Methods
    @objc private func onRegStateChanged() {
        if (isRegisteredAndReady) {
            configureWallet()
        }
    }
    
    private func configureWallet() {
        guard let authUserName = TSAccountManager.shared().storedServerUsername,
              let authPassword = TSAccountManager.shared().storedServerAuthToken() else { return }
        let config = WalletConfig(apiServerURL: TSConstants.textSecureServerURL,
                                  cryptoServerURL: TSConstants.walletServerURL,
                                  cryptoServerBasePath: "/api/crypto-backend/v2/",
                                  authUsername: authUserName,
                                  authPassword: authPassword)
        AppEnvironment.shared.wallet.setup(withConfig: config)
    }
}

