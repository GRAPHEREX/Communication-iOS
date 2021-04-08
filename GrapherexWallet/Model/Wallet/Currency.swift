//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

enum SpecialCurrency: String {
    case ethereum
}

struct Currency: Equatable {
    let name: String
    let symbol: String
    let icon: String
    let rate: String
    let path: String
    let rateSymbol: String
    let decimalDigits: Int
    let baseFee: String
    
    static let `default` = Currency(
        name: "Bitcoin",
        symbol: "BTC",
        icon: "",
        rate: "",
        path: "",
        rateSymbol: "",
        decimalDigits: 8,
        baseFee: "0.0"
    )
}
