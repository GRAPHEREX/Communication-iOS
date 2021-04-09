//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol AuthenticationService {
    func getToken(completion: @escaping (Result<AuthToken, Error>) -> Void)
}

class WalletAuthenticationService: AuthenticationService {
    // MARK: - Dependencies
    private var networkService: NetworkService!
    private let config: WalletConfig
    
    // MARK: - Methods
    init(config: WalletConfig) {
        self.config = config
        networkService = WalletNetworkService(baseHostURL: URL(string: config.apiServerURL)!)
    }
    
    func getToken(completion: @escaping (Result<AuthToken, Error>) -> Void) {
        let request = NetworkRequest(urlPath: "/v1/wallet/token", method: .get, parameters: [:])
        request.authUserName = config.authUsername
        request.authPassword = config.authPassword
        networkService.makeRequest(request) { (result) in
            switch result {
            case .success(let response):
                guard
                    let responseDict = response as? [String: AnyObject],
                    let token = responseDict["token"] as? String
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                completion(.success(token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
