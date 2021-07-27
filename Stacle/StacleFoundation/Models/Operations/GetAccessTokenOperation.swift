//
//  GetAccessTokenOperation.swift
//  CryptoAuth
//
//  Created by Stacle iOS-2 on 16.07.2021.
//

import Foundation

struct GetAccessTokenOperation: HttpTransportCoder {

    public struct Request {
        public let userName: String
        public let password: String
    }

    public struct Response {
        public let accessToken: String
        public let refreshToken: String
        public let expiresIn: TimeInterval
    }

    public func encodeRequest(_ request: Request, to encoded: inout HttpRequest) throws {
        encoded.method = .post
        encoded.path.append(contentsOf: ["oauth", "token"])
        encoded.header[.contentType] = MediaTypeName("application/x-www-form-urlencoded")
        encoded.header[.accept] = MediaTypeName("application/json")
        encoded.body = "grant_type=password&username=\(request.userName)&password=\(request.password)".data(using: .utf8) ?? Data()
    }

    public func decodeResponse(from response: HttpResponse) throws -> Response {
        let decoder = JSONDecoder()
        let responseModel = try decoder.decode(ResponseModel.self, from: response.data)
        return .init(accessToken: responseModel.accessToken, refreshToken: responseModel.refreshToken, expiresIn: responseModel.expiresIn)
    }
}

extension GetAccessTokenOperation {

    // MARK: - Private
    fileprivate struct ResponseModel: Decodable {

        fileprivate let accessToken: String
        fileprivate let refreshToken: String
        fileprivate let expiresIn: TimeInterval

        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
            case expiresIn = "expires_in"
        }
    }
}

