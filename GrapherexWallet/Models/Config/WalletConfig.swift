//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

public struct WalletConfig {
    let apiServerURL: String
    let cryptoServerURL: String
    let cryptoServerBasePath: String
    let authUsername: String
    let authPassword: String
    
    public init(apiServerURL: String, cryptoServerURL: String, cryptoServerBasePath: String, authUsername: String, authPassword: String) {
        self.apiServerURL = apiServerURL
        self.cryptoServerURL = cryptoServerURL
        self.cryptoServerBasePath = cryptoServerBasePath
        self.authUsername = authUsername
        self.authPassword = authPassword
    }
}
