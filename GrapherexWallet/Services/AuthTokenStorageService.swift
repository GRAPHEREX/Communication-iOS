//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

protocol AuthTokenStorageService {
    func loadToken(completion: @escaping (Result<AuthToken, Error>) -> Void)
    func saveToken(token: AuthToken, completion: @escaping (Error?) -> Void)
    func removeToken(completion: @escaping (Error?) -> Void)
}

class WalletAuthTokenStorageService: AuthTokenStorageService {
    // MARK: - Private Properties
    private struct Keys {
        static let token = "grapherexWallet.authToken"
    }
    
    // MARK: - Methods
    func loadToken(completion: @escaping (Result<AuthToken, Error>) -> Void) {
        if let token = KeychainWrapper.standard.string(forKey: Keys.token) {
            completion(.success(token))
        } else {
            completion(.failure(WalletAuthError.noAuthTokenFound))
        }
    }
    
    func saveToken(token: AuthToken, completion: @escaping (Error?) -> Void) {
        if KeychainWrapper.standard.set(token, forKey: Keys.token) {
            completion(nil)
        } else {
            completion(WalletAuthError.authTokenSavingError)
        }
    }
    
    func removeToken(completion: @escaping (Error?) -> Void) {
        if KeychainWrapper.standard.removeObject(forKey: Keys.token) {
            completion(nil)
        } else {
            completion(WalletAuthError.authTokenRemovingError)
        }
    }
}
