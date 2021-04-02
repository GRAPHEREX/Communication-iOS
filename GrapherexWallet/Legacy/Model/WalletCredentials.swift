//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

public struct WalletCredentials: Codable {
    let id: String
    let name: String?
    let pin: String?
    let isHidden: Bool
}

@objc
public class WalletCredentialsManager: NSObject {
    
    private override init() { }
    
    enum CredentialType {
        case name, pin
    }
    
    static func getWalletCredentials() -> [WalletCredentials] {
        do {
            let jsonData = try CurrentAppContext().keychainStorage().data(forService: "Wallet", key: "Credentials")
            let decodedWalletCredentials: [WalletCredentials] = try JSONDecoder().decode([WalletCredentials].self, from: jsonData)
            return decodedWalletCredentials
        } catch {
            return []
        }
    }
    
    static func saveWalletCredentials(walletCredentials: [WalletCredentials]) -> Bool {
        do {
            let jsonData = try JSONEncoder().encode(walletCredentials)
            try CurrentAppContext().keychainStorage().set(data: jsonData, service: "Wallet", key: "Credentials")
            NotificationCenter.default.post(name: WalletModel.walletCredentionalsNeedUpdate, object: self)
            return true
            
        } catch(let error) {
            Logger.error(error.localizedDescription)
            owsFailDebug("saveWalletCredentials failure")
            return false
        }
    }
    
    static func resetPin(walletId: String) -> Bool {
        return update(credentialType: .pin, newValue: nil, walletId: walletId)
    }
    
    static func resetName(walletId: String) -> Bool {
        return update(credentialType: .name, newValue: nil, walletId: walletId)
    }
    
    static func update(credentialType: CredentialType, newValue: String?, walletId: String) -> Bool {
        var credentialsArr = getWalletCredentials()
        let credentials = credentialsArr.first(where: { walletId == $0.id } )
        credentialsArr.removeAll(where: { $0.id == credentials?.id } )
        switch credentialType {
        case .pin:
            if credentials?.name != nil || newValue != nil {
                credentialsArr.append(
                    WalletCredentials(id: walletId,
                                      name: credentials?.name,
                                      pin: newValue,
                                      isHidden: credentials?.isHidden ?? false))
            }
        case .name:
            if credentials?.pin != nil || newValue != nil {
                credentialsArr.append(
                    WalletCredentials(id: walletId,
                                      name: nil,
                                      pin: credentials?.pin,
                                      isHidden: credentials?.isHidden ?? false))
            }
        }
        
        return saveWalletCredentials(walletCredentials: credentialsArr)
    }
    
    static func update(isHidden: Bool, walletId: String) -> Bool {
        var credentialsArr = getWalletCredentials()
        let credentials = credentialsArr.first(where: { walletId == $0.id } )
        credentialsArr.removeAll(where: { $0.id == credentials?.id } )
        credentialsArr.append(
            WalletCredentials(id: walletId,
                              name: credentials?.name,
                              pin: credentials?.pin,
                              isHidden: isHidden))
        return saveWalletCredentials(walletCredentials: credentialsArr)
    }
    
    @objc
    public static func reset() {
       _ = saveWalletCredentials(walletCredentials: [])
    }
}
