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
        } else if storedServerUsername != nil,
               storedServerAuthToken() != nil {
            // Intentionally configure the wallet to show no data state (the case when phone is de-registered)
            configureWallet()
        } else {
            resetGrapherexWallet()
        }
    }
    
    private func configureWallet() {
        guard let authUserName = storedServerUsername,
              let authPassword = storedServerAuthToken() else { return }
        let serviceName = normalizeService(service: "Wallet")
        let config = WalletConfig(apiServerURL: TSConstants.textSecureServerURL,
                                  cryptoServerURL: TSConstants.walletServerURL,
                                  cryptoServerBasePath: "/api/crypto-backend/v2/",
                                  websocketServerURL: TSConstants.walletSocketServerURL,
                                  authUsername: authUserName,
                                  authPassword: authPassword,
                                  serviceName: serviceName)
        AppEnvironment.shared.wallet.setup(withConfig: config)
        AppEnvironment.shared.wallet.preloadWalletData()
    }
    
    private func normalizeService(service: String) -> String {
        return (FeatureFlags.isUsingProductionService
            ? service
            : service + ".staging")
    }
}
