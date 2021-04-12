//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

typealias AuthToken = String

struct NetworkRequest {
    // MARK: - Properties
    let urlPath: String
    let parameters: HTTPParameters
    let httpMethod: HTTPMethod
    
    var authToken: AuthToken?
    var authUserName: String?
    var authPassword: String?
    
    // MARK: - Public Methods
    init(urlPath: String, method: HTTPMethod, parameters: HTTPParameters) {
        self.urlPath = urlPath
        self.httpMethod = method
        self.parameters = parameters
    }
}
