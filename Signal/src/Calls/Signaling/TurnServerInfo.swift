//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

struct TurnServerInfo {

    let password: String
    let username: String
    let urls: [String]

    init?(attributes: [String: AnyObject]) {
        if let passwordAttribute = (attributes["password"] as? String) {
            password = passwordAttribute
        } else {
            return nil
        }

        if let usernameAttribute = attributes["username"] as? String {
            username = usernameAttribute
        } else {
            return nil
        }

        if let urlsAttribute = attributes["urls"] as? [String] {
            urls = urlsAttribute
        } else {
            return nil
        }
    }
}

extension TurnServerInfo {
    init(username: String, password: String, urls: [String]) {
        self.username = username
        self.password = password
        self.urls = urls
    }
}
