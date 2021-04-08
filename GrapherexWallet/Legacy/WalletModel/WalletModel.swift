//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation

public class WalletModel {
    
    public static let walletsNeedUpdate = NSNotification.Name(rawValue: "walletsNeedUpdate")
    public static let walletCredentionalsDidChange: NSNotification.Name = NSNotification.Name(rawValue: "walletCredentionalsDidChangeNotification")
    public static let walletCredentionalsNeedUpdate: NSNotification.Name = NSNotification.Name(rawValue: "walletCredentionalsNeedUpdateNotification")
    
    static let passwordLenght: Int = 8
    public static let shared = WalletModel()
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(walletCredentionalsUpdate),
            name: WalletModel.walletCredentionalsNeedUpdate, object: nil)
    }

    // MARK: - Dependencies

    private var walletManager: WalletManager {
        return WalletManager.shared
    }
    public var wallets: [Wallet] = []
    public var currencies: [Currency] = []
    
    // MARK: - Public Interface
    
    public func isValidPassword(password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    func getCurrencyIconUrl(_ currency: Currency) -> String? {
        return currencies.first(where: { $0.name.lowercased() == currency.name.lowercased() })?.icon
    }
    
    @objc
    func walletCredentionalsUpdate() {
        let credentionals = WalletCredentialsManager.getWalletCredentials()
        let result: [Wallet] = wallets.map { wallet in
            var wallet = wallet
            wallet.credentials = credentionals.first(where: { wallet.id == $0.id })
            return wallet
        }
        wallets = result
        NotificationCenter.default.post(name: WalletModel.walletCredentionalsDidChange, object: self)
    }
    
    public func getWalletById(id: String) -> Wallet? {
        return wallets.first(where: {$0.id == id})
    }
    
    public func initWallets(completion: @escaping ((Result<WalletResponse, Error>) -> Void)) {
        walletManager.initWallets { result in
            switch result {
            case let .success((walletsResponse, currencies)):
                self.wallets = walletsResponse.wallets
                self.currencies = currencies
                completion(.success(walletsResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func walletInfo(_ wallet: Wallet, completion: @escaping ((Result<Wallet, Error>) -> Void)) {
        walletManager.getWalletInfo(wallet: wallet, currencies: currencies) { result in
            completion(result)
        }
    }
    
    public func createWallet(_ currency: Currency, password: String, completion: @escaping ((Result<String, Error>) -> Void)) {
        walletManager.createWallet(currency, password: password) { result in
            completion(result)
        }
    }
    
    public func sendCurrency(wallet: Wallet, password: String, destinationAddress: String,
                      amount: String, fee: String?, customGasPrice: String?, customGasLimit: Int?,
                      completion: @escaping (Result<String, Error>) -> ()
    ) {
        walletManager.sendCurrency(wallet: wallet, password: password, destinationAddress: destinationAddress,
                                   amount: amount, fee: fee, customGasPrice: customGasPrice, customGasLimit: customGasLimit) { result in
            completion(result)
        }
    }
    
    public func getTransactions( wallet: Wallet, limit: Int, offset: Int,
                          tx_direction: String?, sortBy: String?, ascending: Bool,
                          completion: @escaping (Result<[Transaction], Error>) -> ()) {
        walletManager.getTransactions(
            wallet: wallet,
            limit: limit,
            offset: offset,                                      
            tx_direction: tx_direction,
            sortBy: sortBy,
            currencies: currencies,
            ascending: ascending
        ) { result in
            completion(result)
        }
    }
    
    public func changePassword(wallet: Wallet, oldPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> ()) {
        walletManager.changePassword(wallet: wallet, oldPassword: oldPassword, newPassword: newPassword) { result in
            completion(result)
        }
    }
    
    public func setFirstPassword(for wallet: Wallet, password: String, completion: @escaping (Result<Void, Error>) -> ()) {
        walletManager.setFirstPassword(wallet: wallet, password: password) { result in
            completion(result)
        }
    }
    
    public func getBaseFee(currency: Currency, completion: @escaping (Result<Fee, Error>) -> Void) {
        walletManager.getBaseFee(currency: currency) { result in
            completion(result)
        }
    }
    
    public func getRecipientWallets(accountId: String, completion: @escaping (Result<[RecipientWallet], Error>) -> Void) {
        walletManager.getRecipientWallets(accountId: accountId, currencies: currencies) { result in
            completion(result)
        }
    }
}
