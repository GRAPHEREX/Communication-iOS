//
//  VerifyCodeOperation.swift
//  CryptoAuth
//
//  Created by Stacle iOS-2 on 16.07.2021.
//

import Foundation

struct VerifyCodeOperation: HttpTransportCoder {
    struct Request {
        let userName: String
        let verificationCode: String
        
        public init(userName: String, verificationCode: String) {
            self.userName = userName
            self.verificationCode = verificationCode
        }
    }

    public struct Response {
        public let accessToken: String
        public let tokenType: String
        public let expiresIn: TimeInterval
    }

    public func encodeRequest(_ request: Request, to encoded: inout HttpRequest) throws {
        encoded.method = .post
        encoded.path.append("code")
        encoded.path.append("verify")
        let jsonObject =  [
            "user_id" : request.userName,
            "code" : request.verificationCode
        ]
        encoded.body = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }

    public func decodeResponse(from response: HttpResponse) throws -> Response {
        let decoder = JSONDecoder()
        let responseModel = try decoder.decode(ResponseModel.self, from: response.data)
        return .init(accessToken: responseModel.accessToken, tokenType: responseModel.tokenType, expiresIn: responseModel.expiresIn)
    }
}

extension VerifyCodeOperation {
    // MARK: - Private
    fileprivate struct ResponseModel: Decodable {

        fileprivate let accessToken: String
        fileprivate let tokenType: String
        fileprivate let expiresIn: TimeInterval

        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case expiresIn = "expires_in"
        }
    }
}
