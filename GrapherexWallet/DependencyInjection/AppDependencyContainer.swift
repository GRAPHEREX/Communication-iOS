//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

class AppDependencyContainer {
    
    // MARK: - Properties
    // Long-living dependencies
    private let sharedNetworkService: NetworkService
    private let sharedAPIService: APIService
    
    // MARK: - Methods
    public init(config: WalletConfig) {
        func makeAPINetworkService() -> NetworkService {
            return DefaultNetworkService(baseHostURL: URL(string: config.cryptoServerURL)!)
        }
        
        func makeAuthNetworkService() -> NetworkService {
            return DefaultNetworkService(baseHostURL: URL(string: config.apiServerURL)!)
        }
        
        func makeAuthenticationService() -> AuthenticationService {
            let networkService = makeAuthNetworkService()
            return DefaultAuthenticationService(config: config, networkService: networkService)
        }
        
        func makeTokenStorageService() -> AuthTokenStorageService {
            return KeychainAuthTokenStorageService()
        }
        
        func makeAuthenticationManager() -> AuthenticationManager {
            let authenticationService = makeAuthenticationService()
            let tokenStorage = makeTokenStorageService()
            return DefaultAuthenticationManager(authService: authenticationService, tokenStorage: tokenStorage)
        }
        
        func makeCredentialsStorageService() -> CredentialsStorageService {
            return KeychainCredentialsStorageService()
        }
        
        func makeCredentialsManager() -> CredentialsManager {
            let credentialsStorageService = makeCredentialsStorageService()
            return DefaultCredentialsManager(storage: credentialsStorageService)
        }
        
        self.sharedNetworkService = makeAPINetworkService()
        self.sharedAPIService = DefaultAPIService(cryptoServerBasePath: config.cryptoServerBasePath, networkService: sharedNetworkService, authManager: makeAuthenticationManager(), credentialsManager: makeCredentialsManager())
    }
    
    // MARK: - Coins
    public func makeCoinsCoordinator() -> CoinsCoordinator {
        let navVC = makeCoinsRootViewController()
        return CoinsCoordinatorImpl(navigationController: navVC, apiService: sharedAPIService)
    }
    
    public func makeCoinsRootViewController() -> UINavigationController {
        return RootNavigationController()
    }
}
