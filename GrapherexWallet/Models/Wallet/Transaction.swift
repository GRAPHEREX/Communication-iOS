//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

struct Transaction {
    enum Direction: String, CaseIterable {
        case `in`, out
        
        static func directionByName(_ name: String) -> Direction? {
            var direction: Direction?
            Direction.allCases.forEach { if $0.rawValue == name { direction = $0; return } }
            return direction
        }
    }
    
    let id: String
    let hash: String
    let currency: Currency
    let amount: String
    let direction: Direction
    let sender: String
    let recipient: String
    let createdAt: Int64
}

