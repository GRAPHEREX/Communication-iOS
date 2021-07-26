//
//  SetPasswordOperation.swift
//  CryptoAuth
//
//  Created by Stacle iOS-2 on 16.07.2021.
//

import Foundation

struct SetPasswordOperation: HttpTransportCoder {

    public struct Request {
        public let password: String
        public let verificationToken: String
    }

    public struct Response {
        public let accessToken: String
        public let refreshToken: String
        public let expiresIn: TimeInterval
    }

    public func encodeRequest(_ request: Request, to encoded: inout HttpRequest) throws {
        encoded.method = .put
        encoded.path.append("password")
        encoded.path.append("set")
        let jsonObject =  ["password" : request.password]
        encoded.body = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        encoded.header[.authorization] = "\(HttpAuthenticationScheme.bearer) \(request.verificationToken)"
    }

    public func decodeResponse(from response: HttpResponse) throws -> Response {
        return try JSONDecoder().decode(Response.self, from: response.data)
    }
}

extension SetPasswordOperation.Response: Codable {
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
