//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol AuthTokenStorageService {
    func loadToken(completion: @escaping (Result<AuthToken, Error>) -> Void)
    func saveToken(token: AuthToken, completion: @escaping (Error?) -> Void)
    func removeToken(completion: @escaping (Error?) -> Void)
}
