//
//  NetworkServiceHttpTransportCoder.swift
//  CryptoAuth
//
//  Created by Stacle iOS-2 on 16.07.2021.
//

import Foundation

internal struct NetworkServiceHttpTransportCoder<Underlying> where Underlying: HttpTransportCoder {
    
    internal init(_ underlying: Underlying, sessionToken: String?) {
        self.underlying = underlying
        self.sessionToken = sessionToken
    }

    private let underlying: Underlying
    private let sessionToken: String?
}

// MARK: Protocol: HttpTransportCoder

extension NetworkServiceHttpTransportCoder: HttpTransportCoder {

    internal typealias Request = Underlying.Request

    internal typealias Response = Underlying.Response

    // FIXME: Move HttpRequest host, port and headers setup into some separate object like StacleServiceRequestConfigurator
    // And remove Device dependacy from StacleService after that
    internal func encodeRequest(_ request: Request, to encoded: inout HttpRequest) throws {
        encoded.scheme = .https
        encoded.host = "apidev.stacle.com"
        encoded.path = ["api", "v1", "messenger"]
        encoded.header[.xDeviceId] = Device.current.id
        encoded.header[.contentType] = MediaTypeName("application/json")
        if let token = self.sessionToken {
            encoded.header[.authorization] = "Bearer \(token)"
        }

        try self.underlying.encodeRequest(request, to: &encoded)
    }

    internal func decodeResponse(from response: HttpResponse) throws -> Response {
        switch response.statusCode {
            case .success:
                return try self.underlying.decodeResponse(from: response)
            case .clientError, .serverError:
                let decoder = JSONDecoder()
                let errorModel: ErrorModel
                do {
                    errorModel = try decoder.decode(ErrorModel.self, from: response.data)
                } catch {
                    throw CryptoAuthError.unexpected
                }
                throw CryptoAuthError(rawValue: errorModel.error)
            default:
                throw CryptoAuthError.unexpected
        }
    }
}

extension NetworkServiceHttpTransportCoder {

    // MARK: Confidential

    fileprivate struct ErrorModel: Decodable {

        // MARK: Essential

        fileprivate let code: Int
        fileprivate let error: String
        fileprivate let errorDescription: String

        // MARK: Confidential

        private enum CodingKeys: String, CodingKey {
            case code = "code"
            case error = "error"
            case errorDescription = "error_description"
        }
    }
}

extension HttpHeaderFieldName {

    fileprivate static let xDeviceId: Self = Self(rawValue: "X-Device-ID")
}
