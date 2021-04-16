//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol APIService {
    func initWallets(completion: @escaping (Result<(WalletResponse, [Currency]), Error>) -> Void)
    func getWallets(_ currencies: [Currency], completion: @escaping (Result<WalletResponse, Error>) -> Void)
    func getCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void)
    func getWalletInfo(wallet: Wallet, currencies: [Currency], completion: @escaping (Result<Wallet, Error>) -> Void)
    func createWallet(_ currency: Currency, password: String, completion: @escaping (Result<String, Error>) -> ())
    func sendCurrency(wallet: Wallet, password: String, destinationAddress: String, amount: String, fee: String?, customGasPrice: String?, customGasLimit: Int?, completion: @escaping (Result<String, Error>) -> ())
    func getTransactions(wallet: Wallet, limit: Int, offset: Int, tx_direction: String?, sortBy: String?, currencies: [Currency], ascending: Bool, completion: @escaping (Result<[Transaction], Error>) -> ())
    func setFirstPassword(wallet: Wallet, password: String, completion: @escaping (Result<Void, Error>) -> ())
    func changePassword(wallet: Wallet, oldPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> ())
    func getBaseFee(currency: Currency, completion: @escaping (Result<Fee, Error>) -> Void)
    func getRecipientWallets(accountId: String, currencies:[Currency], completion: @escaping (Result<[RecipientWallet], Error>) -> Void)
}

public class DefaultAPIService: APIService {
    // MARK: - Public Properties
//    public var config: WalletConfig? {
//        didSet {
//            updateConfig()
//        }
//    }
    
    // MARK: - Private Properties
//    private var basePath: String {
//        return config.cryptoServerBasePath
//    }
    private var token: String? = nil
    private let reachability = try! Reachability()
    
    // MARK: - Dependencies
    private let networkService: NetworkService
    private let authManager: AuthenticationManager
    private let credentialsManager: CredentialsManager
    private let basePath: String
    
    // MARK: - Private Methods
//    private func updateConfig() {
//        guard let config = config else { return }
//        networkService = DefaultNetworkService(baseHostURL: URL(string: config.cryptoServerURL)!)
//        authManager = DefaultAuthenticationManager(config: config)
//        credentialsManager = DefaultCredentialsManager()
//    }
    
    // MARK: - Reset
//    func reset() {
        //TODO: Credentials reset
//    }
    
    // MARK: - Initiation
    init(cryptoServerBasePath: String, networkService: NetworkService, authManager: AuthenticationManager, credentialsManager: CredentialsManager) {
//        self.config = config
//        updateConfig()
        self.basePath = cryptoServerBasePath
        self.networkService = networkService
        self.authManager = authManager
        self.credentialsManager = credentialsManager
    }
    
    func initWallets(completion: @escaping (Result<(WalletResponse, [Currency]), Error>) -> Void) {
        let getCurrenciesSuccess: (([Currency]) -> Void) = { [weak self] currencies in
            self?.getWallets(currencies) { result in
                switch result {
                case .success(let wallets):
                    completion(.success((wallets, currencies)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        getCurrencies { result in
            switch result {
            case .success(let currencies):
                getCurrenciesSuccess(currencies)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Get Wallets
    func getWallets(_ currencies: [Currency], completion: @escaping (Result<WalletResponse, Error>) -> Void) {
        var request = NetworkRequest(urlPath: basePath + "wallets", method: .get, parameters: [:])
        request.authToken = token
        networkService.makeRequest(request) { [weak self](result) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard
                    //TODO: Replace dictionary parsing with Codable structures
                    let responseDict = response as? [String: AnyObject],
                    let wallets = responseDict["wallets"] as? [Any],
                    let fiatCurrency = responseDict["fiat_currency"] as? String,
                    let fiatBalance = responseDict["fiat_total_balance_formatted"] as? String
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                
                self.credentialsManager.loadAllCredentials { (result) in
                    let resultWallets: [Wallet] = wallets.compactMap { value in
                        guard
                            let dict = value as? [String: Any],
                            let needPassword = dict["need_password"] as? Bool,
                            let createdAt = dict["created_at"] as? Int64,
                            let id = dict["id"] as? String,
                            let currencyCode = dict["currency"] as? String,
                            let currency = currencies.first(where: { $0.symbol == currencyCode }),
                            let address = dict["address"] as? String,
                            let balance = dict["balance_formatted"] as? String,
                            let fiatBalance = dict["fiat_balance_formatted"] as? String,
                            let fiatCurrency = dict["fiat_currency"] as? String
                        else {
                            return nil
                        }
                        var wallet = Wallet(
                            id: id,
                            currency: currency,
                            balance: balance.doubleValue,
                            fiatBalance: fiatBalance.doubleValue,
                            fiatCurrency: fiatCurrency,
                            address: address,
                            needPassword: needPassword,
                            createdAt: createdAt,
                            credentials: nil
                        )
                        switch result {
                        case .success(let credentials):
                            wallet.credentials = credentials.first(where: { $0.id == id })
                        case .failure(_):
                            break
                        }
                        return wallet
                    }
                    completion(.success(.init(
                        fiatTotalBalance: fiatBalance,
                        fiatCurrency: fiatCurrency,
                        wallets: resultWallets
                    )))
                }
            case .failure(let error):
                self.handle(error) { [weak self] result in
                    guard let result = result else {
                        self?.getWallets(currencies, completion: completion)
                        return
                    }
                    completion(.failure(result))
                }
            }
        }
    }
    
    // MARK: - Get Currencies
    
    func getCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        var request = NetworkRequest(urlPath: basePath + "currencies", method: .get, parameters: [:])
        request.authToken = token
        networkService.makeRequest(request) { [weak self](result) in
            switch result {
            case .success(let response):
                guard
                    let wallets = response as? [Any]
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                
                let result: [Currency] = wallets.compactMap { value in
                    guard
                        let dict = value as? [String: Any],
                        let name = dict["name"] as? String,
                        let symbol = dict["symbol"] as? String,
                        let icon = dict["icon"] as? String,
                        let rate = dict["rate"] as? String,
                        let denominator = dict["denominator"] as? String,
                        let decimalDigits = Int(denominator),
                        let path = dict["path"] as? String,
                        let rateSymbol = dict["rate_symbol"] as? String,
                        let baseFee = dict["base_fee"] as? String
                    else {
                        return nil
                    }
                    
                    return Currency(
                        name: name,
                        symbol: symbol,
                        icon: icon,
                        rate: rate,
                        path: path,
                        rateSymbol: rateSymbol,
                        decimalDigits: decimalDigits,
                        baseFee: baseFee
                    )
                }
                completion(.success(result))
            case .failure(let error):
                self?.handle(error) { [weak self] result in
                    guard let result = result else {
                        self?.getCurrencies(completion: completion)
                        return
                    }
                    completion(.failure(result))
                }
            }
        }
    }
    
    // MARK: - Get Wallets Info
    
    func getWalletInfo(wallet: Wallet, currencies: [Currency], completion: @escaping (Result<Wallet, Error>) -> Void) {
        let urlPath = basePath + wallet.currency.path + "/wallet/" + wallet.id
        var request = NetworkRequest(urlPath: urlPath, method: .get, parameters: [:])
        request.authToken = token
        networkService.makeRequest(request) { [weak self](result) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard
                    let dict = response as? [String: Any],
                    let createdAt = dict["created_at"] as? Int64,
                    let needPassword = dict["need_password"] as? Bool,
                    let balance = dict["balance_formatted"] as? String,
                    let fiatBalance = dict["fiat_balance_formatted"] as? String,
                    let fiatCurrency = dict["fiat_currency"] as? String
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                
                self.credentialsManager.loadCredentials(forWalletWithId: wallet.id) { (result) in
                    var wallet = Wallet(
                        id: wallet.id,
                        currency: wallet.currency,
                        balance: balance.doubleValue,
                        fiatBalance: fiatBalance.doubleValue,
                        fiatCurrency: fiatCurrency,
                        address: wallet.address,
                        needPassword: needPassword,
                        createdAt: createdAt,
                        credentials: nil)
                    switch result {
                    case .success(let credentials):
                        wallet.credentials = credentials
                    case .failure(_):
                        break
                    }
                    
                    completion(.success(wallet))
                }

            case .failure(let error):
                self.handle(error) { [weak self] result in
                    guard let result = result else {
                        self?.getWalletInfo(wallet: wallet, currencies: currencies, completion: completion)
                        return
                    }
                    completion(.failure(result))
                }
            }
        }
    }
    
    // MARK: - Create Wallets
    
    func createWallet(_ currency: Currency, password: String, completion: @escaping (Result<String, Error>) -> ()) {
        let urlPath = basePath + currency.path + "/wallet"
        var request = NetworkRequest(urlPath: urlPath, method: .post, parameters: [
            "password" : password
        ])
        request.authToken = token
        networkService.makeRequest(request) { [weak self](result) in
            switch result {
            case .success(let response):
                guard
                    let responseDict = response as? [String: AnyObject],
                    let address = responseDict["address"] as? String
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                completion(.success(address))
            case .failure(let error):
                self?.handle(error) { [weak self] result in
                    guard let result = result else {
                        self?.createWallet(currency, password: password, completion: completion)
                        return
                    }
                    completion(.failure(result))
                }
            }
        }
    }
    
    // MARK: - Send Currency
    
    func sendCurrency(
        wallet: Wallet,
        password: String,
        destinationAddress: String,
        amount: String,
        fee: String?,
        customGasPrice: String?,
        customGasLimit: Int?,
        completion: @escaping (Result<String, Error>) -> ()
    ) {
        var parameters: [String : Any] = [
            "password" : password,
            "destination" : destinationAddress,
            "amount" : amount
        ]
        
        if SpecialCurrency.ethereum.rawValue == wallet.currency.name.lowercased() {
            if customGasPrice != nil && customGasLimit != nil {
                parameters["custom_gas_price"] = customGasPrice!
                parameters["custom_gas_limit"] = customGasLimit!
            }
        } else if fee != nil { parameters["custom_fee"] = fee! }
        
        let urlPath = basePath + wallet.currency.path + "/wallet/" + wallet.id + "/send"
        var request = NetworkRequest(urlPath: urlPath, method: .post, parameters: parameters)
        request.authToken = token
        networkService.makeRequest(request) { (result) in
            switch result {
            case .success(let response):
                guard
                    let responseDict = response as? [String: AnyObject],
                    let address = responseDict["transaction_hash"] as? String
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                completion(.success(address))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Transactions
    
    func getTransactions(
        wallet: Wallet,
        limit: Int,
        offset: Int,
        tx_direction: String?,
        sortBy: String?,
        currencies: [Currency],
        ascending: Bool,
        completion: @escaping (Result<[Transaction], Error>) -> ()
    ) {
        var parameters: [String : Any] = [
            "limit" : limit,
            "offset" : offset
        ]
        if sortBy != nil { parameters["sort_by"] = sortBy! }
        if tx_direction != nil { parameters["tx_direction"] = tx_direction! }
        parameters["ascending"] = ascending
        
        let urlPath = basePath + "wallets" + "/" + wallet.id + "/" + "transactions"
        var request = NetworkRequest(urlPath: urlPath, method: .get, parameters: parameters)
        request.authToken = token
        networkService.makeRequest(request) { [weak self](result) in
            switch result {
            case .success(let response):
                guard
                    let transactions = response as? [Any]
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                
                let result: [Transaction] = transactions.compactMap { value in
                    guard
                        let dict = value as? [String: Any],
                        let id = dict["id"] as? String,
                        let hash = dict["hash"] as? String,
                        let currencyCode = dict["currency"] as? String,
                        let currency = currencies.first(where: { $0.symbol == currencyCode }),
                        let amount = dict["amount"] as? String,
                        let directionCode = dict["direction"] as? String,
                        let direction = Transaction.Direction.directionByName(directionCode),
                        let sender = dict["sender"] as? String,
                        let recipient = dict["recipient"] as? String,
                        let createdAt = dict["created_at"] as? Int64
                    else {
                        return nil
                    }
                    return Transaction(
                        id: id,
                        hash: hash,
                        currency: currency,
                        amount: amount,
                        direction: direction,
                        sender: sender,
                        recipient: recipient,
                        createdAt: createdAt)
                }
                completion(.success(result))
            case .failure(let error):
                self?.handle(error) { [weak self] result in
                    guard let result = result else {
                        self?.getTransactions(wallet: wallet, limit: limit, offset: offset,
                                              tx_direction: tx_direction, sortBy: sortBy, currencies: currencies,
                                              ascending: ascending, completion: completion)
                        return
                    }
                    completion(.failure(result))
                }
            }
        }
    }
    
    // MARK: - Passwords
    
    func setFirstPassword(
        wallet: Wallet,
        password: String,
        completion: @escaping (Result<Void, Error>) -> ()
    ) {
        let urlPath = basePath + wallet.currency.path + "/wallet/" + wallet.id + "/password/first"
        var request = NetworkRequest(urlPath: urlPath, method: .patch, parameters: [
            "new_password" : password
        ])
        request.authToken = token
        networkService.makeRequest(request) { (result) in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func changePassword(
        wallet: Wallet,
        oldPassword: String,
        newPassword: String,
        completion: @escaping (Result<Void, Error>) -> ()
    ) {
        let urlPath = basePath + wallet.currency.path + "/wallet/" + wallet.id + "/password"
        var request = NetworkRequest(urlPath: urlPath, method: .patch, parameters: [
            "password" : oldPassword,
            "new_password" : newPassword
        ])
        request.authToken = token
        networkService.makeRequest(request) { (result) in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getBaseFee(currency: Currency, completion: @escaping (Result<Fee, Error>) -> Void) {
        let urlPath = basePath + currency.path + "/base_fee"
        var request = NetworkRequest(urlPath: urlPath, method: .get, parameters: [:])
        request.authToken = token
        networkService.makeRequest(request) { (result) in
            switch result {
            case .success(let response):
                guard let dict = response as? [String: Any],
                      let formatted = dict["formatted"] as? String
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                completion(.success(Fee(formatted: formatted)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getRecipientWallets(
        accountId: String,
        currencies:[Currency],
        completion: @escaping (Result<[RecipientWallet], Error>) -> Void) {
        
        let urlPath = basePath + "wallets/accounts/" + accountId
        var request = NetworkRequest(urlPath: urlPath, method: .get, parameters: [:])
        request.authToken = token
        networkService.makeRequest(request) { (result) in
            switch result {
            case .success(let response):
                guard
                    let recipientWallets = (response as? [String:Any])?["wallets"] as? [Any]
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                
                let result: [RecipientWallet] = recipientWallets.compactMap { value in
                    guard
                        let dict = value as? [String: Any],
                        let id = dict["id"] as? String,
                        let address = dict["address"] as? String,
                        let currencyCode = dict["currency"] as? String,
                        let currency = currencies.first(where: { $0.symbol == currencyCode }),
                        let createdAt = dict["created_at"] as? Int64
                    else {
                        return nil
                    }
                    return RecipientWallet(
                        id: id,
                        currency: currency,
                        address: address,
                        createdAt: createdAt)
                }

                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

fileprivate extension DefaultAPIService {

    // MARK: - Error Handling
    
    func handle(_ error: Error, completion: @escaping (Error?) -> Void) {
        if reachability.connection == .unavailable {
            completion(WalletError.networkConnectionError)
            return
        }
        if let wltError = error as? WalletError,
           wltError == .tokenExpiredError {
            authManager.refreshWalletToken(completion: { [weak self] result in
                switch result {
                case .success(let token):
                    self?.token = token
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            })
        }
    }
}
