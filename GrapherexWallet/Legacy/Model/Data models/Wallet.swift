//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

public struct WalletResponse {
    let fiatTotalBalance: String
    let fiatCurrency: String
    let wallets: [Wallet]
}

public struct Wallet {
    public let id: String
    public let currency: Currency
    public let balance: String
    public let fiatBalance: String
    public let fiatCurrency: String
    public let address: String
    public let needPassword: Bool
    public let createdAt: Int64
    public var credentials: WalletCredentials?
    
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
