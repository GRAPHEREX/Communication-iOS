//
//  Copyright (c) 2021 SkyTech. All rights reserved.
//

import Foundation

struct CallKitUUIDManager {
    
    private init() {}
    
    private static var currentCallUUID: UUID?
    
    static func getUUID() -> UUID {
        if let uuid = currentCallUUID {
            currentCallUUID = nil
            return uuid
        }
        else {
            currentCallUUID = UUID()
            return currentCallUUID!
        }
    }
    
}
