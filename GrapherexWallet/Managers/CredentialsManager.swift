//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

enum CredentialType {
    case name, pin
}

protocol CredentialsManager {
    func loadAllCredentials(completion: @escaping (Result<[WalletCredentials], Error>) -> Void)
    func saveAllCredentials(_ credentials: [WalletCredentials], completion: @escaping (Error?) -> Void)
    
    func loadCredentials(forWalletWithId walletId: WalletId, completion: @escaping (Result<WalletCredentials, Error>) -> Void)
    func updateCredential(ofType credentialType: CredentialType, newValue: String?, forWalletWithId walletId: WalletId, completion: @escaping (Error?) -> Void)
    func resetCredential(ofType credentialType: CredentialType, forWalletWithId walletId: WalletId, completion: @escaping (Error?) -> Void)
    func setHidden(forWalletWithId walletId: WalletId, isHidden: Bool, completion: @escaping (Error?) -> Void)
    
    func removeAllCredentials(completion: @escaping (Error?) -> Void)
}

class DefaultCredentialsManager: CredentialsManager {
    //MARK: - Private Properties
    private let storage: CredentialsStorageService!
    
    //MARK: - Public Methods
    init(storage: CredentialsStorageService) {
        self.storage = storage
    }
    
    func loadAllCredentials(completion: @escaping (Result<[WalletCredentials], Error>) -> Void) {
        storage.loadCredentials(completion: completion)
    }
    
    func saveAllCredentials(_ credentials: [WalletCredentials], completion: @escaping (Error?) -> Void) {
        storage.saveCredentials(credentials, completion: completion)
    }
    
    func loadCredentials(forWalletWithId walletId: WalletId, completion: @escaping (Result<WalletCredentials, Error>) -> Void) {
        loadAllCredentials { (result) in
            switch result {
            case .success(let credentialsList):
                if let credentials = credentialsList.first(where: {$0.id == walletId}) {
                    completion(.success(credentials))
                } else {
                    completion(.failure(WalletError.noWalletCredentialsFoundError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func resetCredential(ofType credentialType: CredentialType, forWalletWithId walletId: WalletId, completion: @escaping (Error?) -> Void) {
        updateCredential(ofType: credentialType, newValue: nil, forWalletWithId: walletId, completion: completion)
    }
    
    func updateCredential(ofType credentialType: CredentialType, newValue: String?, forWalletWithId walletId: WalletId, completion: @escaping (Error?) -> Void) {
        updateCredentials(forWalletWithId: walletId, updateBlock: { (credentials) in
            switch credentialType {
            case .name:
                return WalletCredentials(id: credentials.id,
                                         name: newValue,
                                         pin: credentials.pin,
                                         isHidden: credentials.isHidden)
            case .pin:
                return WalletCredentials(id: credentials.id,
                                         name: credentials.name,
                                         pin: newValue,
                                         isHidden: credentials.isHidden)
            }
            
        }, completion: completion)
    }
    
    func setHidden(forWalletWithId walletId: WalletId, isHidden: Bool, completion: @escaping (Error?) -> Void) {
        updateCredentials(forWalletWithId: walletId, updateBlock: { (credentials) in
            return WalletCredentials(id: credentials.id,
                                     name: credentials.name,
                                     pin: credentials.pin,
                                     isHidden: isHidden)
        }, completion: completion)
    }
    
    func removeAllCredentials(completion: @escaping (Error?) -> Void) {
        storage.saveCredentials([], completion: completion)
    }
    
    //MARK: - Private Methods

    private func updateCredentials(forWalletWithId walletId: WalletId, updateBlock: @escaping (WalletCredentials) -> WalletCredentials, completion: @escaping (Error?) -> Void) {
        storage.loadCredentials { [weak self](result) in
            guard let self = self else { return }
            switch result {
            case .success(let credentialsList):
                var elementFound = false
                let updatedList: [WalletCredentials] = credentialsList.compactMap({
                    if $0.id == walletId {
                        elementFound = true
                        return updateBlock($0)
                    } else {
                        return $0
                    }
                })
                if elementFound {
                    self.storage.saveCredentials(updatedList, completion: completion)
                } else {
                    completion(WalletError.noWalletCredentialsFoundError)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
}
