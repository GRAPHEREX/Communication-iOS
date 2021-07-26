//
//  HttpTransportCoderError.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

// MARK: - HttpTransportCoderError

public enum HttpTransportCoderError: Error {
	case requestEncodingFailure(Error)
	case responseDecodingFailure(Error)
}

extension HttpTransportCoderError {
    var underlying: Error {
        switch self {
        case let .requestEncodingFailure(error),
             let .responseDecodingFailure(error):
            return error
        }
    }
}
