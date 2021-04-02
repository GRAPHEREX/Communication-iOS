//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalServiceKit

class WalletManager {
    
    static let shared = WalletManager()
    
    private init() {}

    private let basePath = "/api/crypto-backend/v2/"
    
    private var token: String? = nil
    
    private let reachabilityManager = SSKEnvironment.shared.reachabilityManager
    
    // MARK: - Dependencies

    private var networkManager: TSNetworkManager {
        return SSKEnvironment.shared.networkManager
    }
    
    // MARK: - Token
    
    func token(completion: @escaping (Result<String, Error>) -> Void) {
        let request = TSRequest(url: URL(string: "/v1/wallet/token")!, method: "GET", parameters: [:])
        networkManager.makeRequest(
            request,            
            success: { _, response in
                guard
                    let responseDict = response as? [String: AnyObject],
                    let token = responseDict["token"] as? String
                else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
                    return
                }
                completion(.success(token))
            },
            failure: { task, error in
                completion(.failure(error))
            }
        )
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
        let request = TSRequest(url: URL(string: basePath + "wallets")!, method: "GET", parameters: [:])
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")
        networkManager.makeRequest(
            request,
            success: { _, response in
                guard
                    let responseDict = response as? [String: AnyObject],
                    let wallets = responseDict["wallets"] as? [Any],
                    let fiatCurrency = responseDict["fiat_currency"] as? String,
                    let fiatBalance = responseDict["fiat_total_balance_formatted"] as? String
                else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
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
                //Analytics.logEvent("wallet_get_wallets_success", parameters: nil)
                completion(.success(.init(
                    fiatTotalBalance: fiatBalance,
                    fiatCurrency: fiatCurrency,
                    wallets: resultWallets
                )))
            },
            failure: { [weak self] task, error in
                self?.handle(error, task: task) { [weak self] result in
                    guard let result = result else {
                        self?.getWallets(currencies, completion: completion)
                        return
                    }
                    //Analytics.logEvent("wallet_get_wallets_failure", parameters: nil)
                    completion(.failure(result))
                }
            }
        )
    }
    
    // MARK: - Get Currencies
    
    func getCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        let request = TSRequest(url: URL(string: basePath + "currencies")!, method: "GET", parameters: [:])
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")
        networkManager.makeRequest(
            request,
            success: { _, response in
                guard
                    let wallets = response as? [Any]
                else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
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
                //Analytics.logEvent("wallet_get_currencies_success", parameters: nil)
                completion(.success(result))
            },
            failure: { [weak self] task, error in
                self?.handle(error, task: task) { [weak self] result in
                    guard let result = result else {
                        self?.getCurrencies(completion: completion)
                        return
                    }
                    //Analytics.logEvent("wallet_get_currencies_failure", parameters: nil)
                    completion(.failure(result))
                }
            }
        )
    }
    
    // MARK: - Get Wallets Info
    
    func getWalletInfo(wallet: Wallet, currencies: [Currency], completion: @escaping (Result<Wallet, Error>) -> Void) {
        let request = TSRequest(
            url: URL(string: basePath + wallet.currency.path + "/wallet/" + wallet.id)!,
            method: "GET",
            parameters: [:]
        )
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")
        networkManager.makeRequest(
            request,
            success: { _, response in
                guard
                    let dict = response as? [String: Any],
                    let createdAt = dict["created_at"] as? Int64,
                    let needPassword = dict["need_password"] as? Bool,
                    let balance = dict["balance_formatted"] as? String,
                    let fiatBalance = dict["fiat_balance_formatted"] as? String,
                    let fiatCurrency = dict["fiat_currency"] as? String
                else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
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
                //Analytics.logEvent("wallet_get_wallet_info_success", parameters: nil)
                completion(.success(wallet))
            },
            failure: { [weak self] task, error in
                self?.handle(error, task: task) { [weak self] result in
                    guard let result = result else {
                        self?.getWalletInfo(wallet: wallet, currencies: currencies, completion: completion)
                        return
                    }
                    //Analytics.logEvent("wallet_get_wallet_info_failure", parameters: nil)
                    completion(.failure(result))
                }
            }
        )
    }
    
    // MARK: - Create Wallets
    
    func createWallet(
        _ currency: Currency,
        password: String,
        completion: @escaping (Result<String, Error>) -> ()
    ) {
        
        let request = TSRequest(
            url: URL(string: basePath + currency.path + "/wallet")!,
            method: "POST",
            parameters: [
                "password" : password
            ]
        )
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        networkManager.makeRequest(
            request,
            success: { _, response in
                guard
                    let responseDict = response as? [String: AnyObject],
                    let address = responseDict["address"] as? String
                else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
                    return
                }
                //Analytics.logEvent("Wallet.CreateWallet.Success", parameters: nil)
                completion(.success(address))
            },
            failure: { [weak self] task, error in
//                self?.handle(responseObject: responseObject as AnyObject) { error in
//                    completion(.failure(error))
//                }
                self?.handle(error, task: task) { [weak self] result in
                    guard let result = result else {
                        self?.createWallet(currency, password: password, completion: completion)
                        return
                    }
                    //Analytics.logEvent("wallet_create_wallet_failure", parameters: nil)
                    completion(.failure(result))
                }
            }
        )
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
        
        let request = TSRequest(
            url: URL(string: basePath + wallet.currency.path + "/wallet/" + wallet.id + "/send")!,
            method: "POST",
            parameters: parameters
        )
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")

        networkManager.makeRequest(
            request,
            success: { task, response in
                guard
                    let responseDict = response as? [String: AnyObject],
                    let address = responseDict["transaction_hash"] as? String
                else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
                    return
                }
                //Analytics.logEvent("wallet_send_currencies_success", parameters: nil)
                completion(.success(address))
            },
            failure: { task, error in
//                self.handle(responseObject: responseObject as AnyObject) { error in
//                    completion(.failure(error))
//                }
                //Analytics.logEvent("wallet_send_currencies_failure", parameters: nil)
                guard let _ = task.response as? HTTPURLResponse else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
                    return
                }
                completion(.failure(error))
            }
        )
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
        
        let request = TSRequest(
            url: URL(string: basePath + "wallets" + "/" + wallet.id + "/" + "transactions")!,
                     method: "GET",
                     parameters: parameters
            )
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")

        networkManager.makeRequest(
            request,
            success: { _, response in
                guard
                    let transactions = response as? [Any]
                else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
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
                //Analytics.logEvent("wallet_get_transaction_success", parameters: nil)
                completion(.success(result))
            },
            failure: { [weak self] task, error in
                self?.handle(error, task: task) { [weak self] result in
                    guard let result = result else {
                        self?.getTransactions(wallet: wallet, limit: limit, offset: offset,
                                              tx_direction: tx_direction, sortBy: sortBy, currencies: currencies,
                                              ascending: ascending, completion: completion)
                        return
                    }
                    //Analytics.logEvent("wallet_get_transaction_failure", parameters: nil)
                    completion(.failure(result))
                }
            }
        )
    }
    
    // MARK: - Passwords
    
    func setFirstPassword(
        wallet: Wallet,
        password: String,
        completion: @escaping (Result<Void, Error>) -> ()
    ) {
        let request = TSRequest(
            url: URL(string: basePath + wallet.currency.path + "/wallet/" + wallet.id + "/password/first")!,
            method: "PATCH",
            parameters: [
                "new_password" : password
            ]
        )
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")

        networkManager.makeRequest(
            request,
            success: { task, response in
                //Analytics.logEvent("wallet_set_first_password_success", parameters: nil)
                completion(.success(()))
            },
            failure: { task, error in
                //Analytics.logEvent("wallet_set_first_password_failure", parameters: nil)
                guard let _ = task.response as? HTTPURLResponse else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
                    return
                }
                completion(.failure(error))
            }
        )
    }
    
    func changePassword(
        wallet: Wallet,
        oldPassword: String,
        newPassword: String,
        completion: @escaping (Result<Void, Error>) -> ()
    ) {
        let request = TSRequest(
            url: URL(string: basePath + wallet.currency.path + "/wallet/" + wallet.id + "/password")!,
            method: "PATCH",
            parameters: [
                "password" : oldPassword,
                "new_password" : newPassword
            ]
        )
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")

        networkManager.makeRequest(
            request,
            success: { task, response in
                //Analytics.logEvent("wallet_change_password_success", parameters: nil)
                completion(.success(()))
            },
            failure: { task, error in
                //Analytics.logEvent("wallet_change_password_failure", parameters: nil)
                guard let _ = task.response as? HTTPURLResponse else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
                    return
                }
//                self.handle(responseObject: responseObject as AnyObject) { error in
//                    completion(.failure(error))
//                }
            }
        )
    }
    
    func getBaseFee(currency: Currency, completion: @escaping (Result<Fee, Error>) -> Void) {
        let request = TSRequest(
            url: URL(string: basePath + currency.path + "/base_fee")!,
            method: "GET",
            parameters: [ : ]
        )
        
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")

        networkManager.makeRequest(
            request,
            success: { task, response in
                guard let dict = response as? [String: Any],
                    let formatted = dict["formatted"] as? String
                    else {
                        completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
                        return
                }
                //Analytics.logEvent("wallet_get_base_fee_success", parameters: nil)
                completion(.success(Fee(formatted: formatted)))
            },
            failure: { task, error in
                //Analytics.logEvent("wallet_get_base_fee_failure", parameters: nil)
                guard let _ = task.response as? HTTPURLResponse else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
                    return
                }
                completion(.failure(error))
            }
        )
    }
    
    func getRecipientWallets(
        accountId: String,
        currencies:[Currency],
        completion: @escaping (Result<[RecipientWallet], Error>) -> Void) {
        let request = TSRequest(
            url: URL(string: basePath + "wallets/accounts/" + accountId)!,
            method: "GET",
            parameters: [ : ]
        )
        
        request.customHost = TSConstants.walletServerURL
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        networkManager.makeRequest(
            request,
            success: { task, response in
                guard
                    let recipientWallets = (response as? [String:Any])?["wallets"] as? [Any]
                else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
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
                
                
                //Analytics.logEvent("wallet_get_recipient_wallets_success", parameters: nil)
                completion(.success(result))
        },
            failure: { task, error in
                //Analytics.logEvent("wallet_get_recipient_wallets_failure", parameters: nil)
                guard let _ = task.response as? HTTPURLResponse else {
                    completion(.failure(OWSErrorMakeUnableToProcessServerResponseError()))
                    return
                }
                completion(.failure(error))
        }
        )
    }
}

fileprivate extension WalletManager {

    // MARK: - Error Handling
    
    func handle(_ error: Error, task: URLSessionDataTask, completion: @escaping (Error?) -> Void) {
        if !reachabilityManager.isReachable {
            completion(OWSErrorMakeNetworkError())
            return
        }
        guard let response = task.response as? HTTPURLResponse else {
            completion(OWSErrorMakeUnableToProcessServerResponseError())
            return
        }
        switch response.statusCode {
        case 401:
            token(completion: { [weak self] result in
                switch result {
                case .success(let token):
                    self?.token = token
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            })
        default:
            completion(error)
        }
    }
    
    func handle(responseObject: AnyObject, completion: @escaping (Error) -> Void) {
        if !reachabilityManager.isReachable {
            completion(OWSErrorMakeNetworkError())
            return
        }
        
        guard let dict = responseObject as? [String: AnyObject],
            let errorDisct = dict["error"] as? [String: AnyObject],
            let code = errorDisct["code"] as? Int,
            let errorMessage = errorDisct["message"] as? String else {
                completion(OWSErrorMakeUnableToProcessServerResponseError())
                return
        }
        
        let serverError = NSError(domain:"", code: code,
                                  userInfo:[ NSLocalizedDescriptionKey: errorMessage ]) as Error
        completion(serverError)
    }
}
