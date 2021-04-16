//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import XCGLogger

class KeychainCredentialsStorageService: CredentialsStorageService {
    // MARK: - Private Properties
    private struct Keys {
        static let walletCredentials = "grapherexWallet.walletCredentials"
    }
    
    private let logger = XCGLogger.default
    
    //MARK: - Methods
    func loadCredentials(completion: @escaping (Result<[WalletCredentials], Error>) -> Void) {
        do {
            guard let jsonData = KeychainWrapper.standard.data(forKey: Keys.walletCredentials) else {
                completion(.failure(WalletError.noWalletCredentialsFoundError))
                return
            }
            let decodedWalletCredentials: [WalletCredentials] = try JSONDecoder().decode([WalletCredentials].self, from: jsonData)
            completion(.success(decodedWalletCredentials))
        } catch {
            logger.error(error.localizedDescription)
            completion(.failure(error))
        }
    }
    
    func saveCredentials(_ credentials: [WalletCredentials], completion: @escaping (Error?) -> Void) {
        do {
            let jsonData = try JSONEncoder().encode(credentials)
            KeychainWrapper.standard.set(jsonData, forKey: Keys.walletCredentials)
            NotificationCenter.default.post(name: WalletModel.walletCredentionalsNeedUpdate, object: self)
            completion(nil)
        } catch(let error) {
            logger.error(error.localizedDescription)
            completion(error)
        }
    }
    
    func removeCredentials(completion: @escaping (Error?) -> Void) {
        if KeychainWrapper.standard.removeObject(forKey: Keys.walletCredentials) {
            completion(nil)
        } else {
            completion(WalletError.noWalletCredentialsFoundError)
        }
    }
}
