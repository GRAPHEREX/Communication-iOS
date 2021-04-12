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
