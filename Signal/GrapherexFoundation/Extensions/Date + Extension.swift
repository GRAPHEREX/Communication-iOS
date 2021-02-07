//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

extension Date {
    
    func mainFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter.string(from: self)
    }
    
    static func getDate(timestamp: Int64) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

}
