//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol CredentialsStorageService {
    func loadCredentials(completion: @escaping (Result<[WalletCredentials], Error>) -> Void)
    func saveCredentials(_ credentials: [WalletCredentials], completion: @escaping (Error?) -> Void)
    func removeCredentials(completion: @escaping (Error?) -> Void)
}
