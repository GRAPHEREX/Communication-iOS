//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

struct WalletResponse {
    let fiatTotalBalance: String
    let fiatCurrency: String
    let wallets: [Wallet]
}

struct Wallet {
    let id: String
    let currency: Currency
    let balance: Double
    let fiatBalance: Double
    let fiatCurrency: String
    let address: String
    let needPassword: Bool
    let createdAt: Int64
    var credentials: WalletCredentials?
    
    var balanceStr: String {
        return "\(balance)"
    }
    var fiatBalanceStr: String {
        return "\(fiatBalance)"
    }
    
    static let empty: Wallet = .init(
        id: "",
        currency: Currency.default,
        balance: 0,
        fiatBalance: 0,
        fiatCurrency: "",
        address: "",
        needPassword: false,
        createdAt: 0,
        credentials: nil
    )
}

#if DEBUG

// MARK: - Mocked Data

extension WalletResponse {
    static let mockedData = WalletResponse(fiatTotalBalance: "fiatTotalBalance", fiatCurrency: "fiatCurrency", wallets: Wallet.mockedData)
}

extension Wallet {
    static let mockedData: [Wallet] = [
        Wallet(id: <#T##String#>, currency: <#T##Currency#>, balance: <#T##Double#>, fiatBalance: <#T##Double#>, fiatCurrency: <#T##String#>, address: <#T##String#>, needPassword: <#T##Bool#>, createdAt: <#T##Int64#>, credentials: <#T##WalletCredentials?#>),
    ]
}

#endif
