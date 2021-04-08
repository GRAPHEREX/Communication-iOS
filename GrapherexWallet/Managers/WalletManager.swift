//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

public class WalletManager {
    // MARK: - Public Properties
    public static let shared = WalletManager()
    public var config: WalletConfig? {
        didSet {
            updateConfig()
        }
    }
    
    // MARK: - Private Properties
    private var basePath: String {
        return config?.cryptoServerBasePath ?? ""
    }
    private var walletServerURL: String {
        return config?.cryptoServerURL ?? ""
    }
    private var token: String? = nil
    private let reachability = try! Reachability()
    
    // MARK: - Dependencies
    private var networkService: NetworkService!
    
    // MARK: - Private Methods
    private init() {}
    
    private func updateConfig() {
        guard let config = config else { return }
        networkService = WalletNetworkService(baseHostURL: URL(string: config.apiServerURL)!)
    }
    
    private func setAuthRequestToApiServer(_ request: NetworkRequest, config: WalletConfig) {
        request.authUserName = config.authUsername
        request.authPassword = config.authPassword
        request.shouldHaveAuthorizationHeaders = true
    }
    
    private func setAuthRequestToWalletServer(_ request: NetworkRequest) {
        request.customHost = walletServerURL
        request.authToken = token
        request.shouldHaveAuthorizationHeaders = true
    }
    
    // MARK: - Token & Auth
    func token(completion: @escaping (Result<String, Error>) -> Void) {
        guard let config = config else {
            completion(.failure(WalletError.noWalletConfigurationFound))
            return
        }
        let request = NetworkRequest(urlPath: "/v1/wallet/token", method: .get, parameters: [:])
        setAuthRequestToApiServer(request, config: config)
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
    
    // MARK: - Initiation
    
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
        let request = NetworkRequest(urlPath: basePath + "wallets", method: .get, parameters: [:])
        setAuthRequestToWalletServer(request)
        networkService.makeRequest(request) { [weak self](result) in
            switch result {
            case .success(let response):
                guard
                    let responseDict = response as? [String: AnyObject],
                    let wallets = responseDict["wallets"] as? [Any],
                    let fiatCurrency = responseDict["fiat_currency"] as? String,
                    let fiatBalance = responseDict["fiat_total_balance_formatted"] as? String
                else {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                    return
                }
                
                let credentionals = WalletCredentialsManager.getWalletCredentials()
                
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
                    return Wallet(
                        id: id,
                        currency: currency,
                        balance: balance,
                        fiatBalance: fiatBalance,
                        fiatCurrency: fiatCurrency,
                        address: address,
                        needPassword: needPassword,
                        createdAt: createdAt,
                        credentials: credentionals.first(where: { $0.id == id })
                    )
                }
                completion(.success(.init(
                    fiatTotalBalance: fiatBalance,
                    fiatCurrency: fiatCurrency,
                    wallets: resultWallets
                )))
            case .failure(let error):
                self?.handle(error) { [weak self] result in
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
        let request = NetworkRequest(urlPath: basePath + "currencies", method: .get, parameters: [:])
        setAuthRequestToWalletServer(request)
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
        let request = NetworkRequest(urlPath: urlPath, method: .get, parameters: [:])
        setAuthRequestToWalletServer(request)
        networkService.makeRequest(request) { [weak self](result) in
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
                let credentionals = WalletCredentialsManager.getWalletCredentials()
                
                let wallet = Wallet(
                    id: wallet.id,
                    currency: wallet.currency,
                    balance: balance,
                    fiatBalance: fiatBalance,
                    fiatCurrency: fiatCurrency,
                    address: wallet.address,
                    needPassword: needPassword,
                    createdAt: createdAt,
                    credentials: credentionals.first(where: { $0.id == wallet.id })
                )
                
                completion(.success(wallet))
            case .failure(let error):
                self?.handle(error) { [weak self] result in
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
        let request = NetworkRequest(urlPath: urlPath, method: .post, parameters: [
            "password" : password
        ])
        setAuthRequestToWalletServer(request)
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
        let request = NetworkRequest(urlPath: urlPath, method: .post, parameters: parameters)
        setAuthRequestToWalletServer(request)
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
        let request = NetworkRequest(urlPath: urlPath, method: .get, parameters: parameters)
        setAuthRequestToWalletServer(request)
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
        let request = NetworkRequest(urlPath: urlPath, method: .patch, parameters: [
            "new_password" : password
        ])
        setAuthRequestToWalletServer(request)
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
        let request = NetworkRequest(urlPath: urlPath, method: .patch, parameters: [
            "password" : oldPassword,
            "new_password" : newPassword
        ])
        setAuthRequestToWalletServer(request)
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
        let request = NetworkRequest(urlPath: urlPath, method: .get, parameters: [:])
        setAuthRequestToWalletServer(request)
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
        let request = NetworkRequest(urlPath: urlPath, method: .get, parameters: [:])
        setAuthRequestToWalletServer(request)
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

fileprivate extension WalletManager {

    // MARK: - Error Handling
    
    func handle(_ error: Error, completion: @escaping (Error?) -> Void) {
        if reachability.connection == .unavailable {
            completion(WalletError.networkConnectionError)
            return
        }
        if let wltError = error as? WalletError,
           wltError == .tokenExpiredError {
            token(completion: { [weak self] result in
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
