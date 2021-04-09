//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol AuthenticationManager {
    func getWalletToken(completion: @escaping (Result<AuthToken, Error>) -> Void)
    func refreshWalletToken(completion: @escaping (Result<AuthToken, Error>) -> Void)
}

class WalletAuthenticationManager: AuthenticationManager {
    //MARK: - Properties
    private let authService: AuthenticationService!
    private let tokenStorage: AuthTokenStorageService!
    
    //MARK: - Methods
    init(config: WalletConfig) {
        authService = WalletAuthenticationService(config: config)
        tokenStorage = KeychainAuthTokenStorageService()
    }
    
    func refreshWalletToken(completion: @escaping (Result<AuthToken, Error>) -> Void) {
        tokenStorage.removeToken { [weak self](_) in
            guard let self = self else { return }
            self.authService.getToken { [weak self](result) in
                guard let self = self else { return }
                switch result {
                case .success(let token):
                    self.tokenStorage.saveToken(token: token) { (_) in
                        completion(.success(token))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getWalletToken(completion: @escaping (Result<AuthToken, Error>) -> Void) {
        tokenStorage.loadToken { [weak self](result) in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                completion(.success(token))
            case .failure(_):
                self.authService.getToken { [weak self](result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let token):
                        self.tokenStorage.saveToken(token: token) { (_) in
                            completion(.success(token))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
