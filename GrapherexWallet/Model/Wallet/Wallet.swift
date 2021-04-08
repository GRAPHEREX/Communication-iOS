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
    let balance: String
    let fiatBalance: String
    let fiatCurrency: String
    let address: String
    let needPassword: Bool
    let createdAt: Int64
    var credentials: WalletCredentials?
    
    static let empty: Wallet = .init(
        id: "",
        currency: Currency.default,
        balance: "",
        fiatBalance: "",
        fiatCurrency: "",
        address: "",
        needPassword: false,
        createdAt: 0,
        credentials: nil
    )
}
