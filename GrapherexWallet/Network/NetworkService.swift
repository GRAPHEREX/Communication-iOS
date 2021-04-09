//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import XCGLogger

typealias JSON = [String: Any]
typealias HTTPParameters = [String: Any]

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

protocol NetworkService {
    @discardableResult
    func makeRequest(_ request: NetworkRequest, completion: @escaping(Result<Any, Error>) -> Void) -> URLSessionDataTask?
}


class WalletNetworkService: NetworkService {
    
    // MARK: - Properties
    let session: URLSession
    
    private let responseQueue: DispatchQueue
    private let baseHostURL: URL
    private let logger: XCGLogger = XCGLogger.default
    
    // MARK: - Methods
    required init(session: URLSession = .shared, responseQueue: DispatchQueue = .main, baseHostURL: URL) {
        self.session = session
        self.responseQueue = responseQueue
        self.baseHostURL = baseHostURL
    }
    
    func makeRequest(_ request: NetworkRequest, completion: @escaping(Result<Any, Error>) -> Void) -> URLSessionDataTask? {
        var urlRequest: URLRequest
        do {
            urlRequest = try constructURLRequest(withNetworkRequest: request)
        } catch {
            completion(.failure(error))
            return nil
        }
            
        let task = session.dataTask(with: urlRequest) { [weak self](data, response, error) in
            guard let self = self else { return }
            guard let response = response as? HTTPURLResponse else {
                self.responseQueue.async {
                    completion(.failure(WalletError.unableToProcessServerResponseError))
                }
                return
            }
            switch response.statusCode {
            case 401:
                self.responseQueue.async {
                    completion(.failure(WalletError.tokenExpiredError))
                }
                return
            case 200:
                guard error == nil, let data = data else {
                    if let error = error {
                        self.responseQueue.async {
                            completion(.failure(error))
                        }
                    } else {
                        self.responseQueue.async {
                            completion(.failure(WalletError.unknown))
                        }
                    }
                    return
                }
                
                self.debugPrint(url: urlRequest.url, data: data, params: request.parameters)
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                    self.responseQueue.async {
                        completion(.success(result))
                    }
                } catch {
                    self.responseQueue.async {
                        completion(.failure(error))
                    }
                }
            default:
                self.responseQueue.async {
                    completion(.failure(WalletError.unknown))
                }
            }
        }
        
        task.resume()
        return task
    }
    
    // MARK: - Private Methods
    private func constructURLRequest(withNetworkRequest request: NetworkRequest) throws -> URLRequest {
        var resRequest: URLRequest
        if let finalURL = URL(string: baseHostURL.absoluteString.removingTrailingSlash())?.appendingPathComponent(request.urlPath) {
            resRequest = URLRequest(url: finalURL)
        } else {
            throw WalletError.requestConstructionError
        }
        
        if let authUserName = request.authUserName,
           let authPassword = request.authPassword {
            let authString = generateBasicAuthorizationString(username: authUserName, password: authPassword)
            resRequest.addValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        } else if let authToken = request.authToken {
            resRequest.addValue(authToken, forHTTPHeaderField: "Authorization")
        }
        
        
        resRequest.httpMethod = request.httpMethod.rawValue
        if request.httpMethod != .get, request.parameters.count > 0 {
            do {
                let data = try JSONSerialization.data(withJSONObject: request.parameters, options: [.fragmentsAllowed])
                resRequest.httpBody = data
                resRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                resRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            } catch {
                throw WalletError.requestConstructionError
            }
        }
        
        return resRequest
    }
    
    private func generateBasicAuthorizationString(username: String, password: String) -> String {
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        return base64LoginString
    }
    
    private func debugPrint(url: @autoclosure () -> URL?, data: @autoclosure () -> Data, params: @autoclosure () -> [String: Any]) {
        let string: (Data) -> String = { (data) in
            return String(data: data, encoding: .utf8) ?? "DATA STRING CONVERSION ERROR"
        }
        
        logger.debug("""
            API call
            To \(url()?.absoluteString ?? "").
            Parameter: \(self.jsonString(dict: params())).
            Response: \(string(data()))
            """)
    }
    
    private func jsonString(dict: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else {
            return "JSON STRING ERROR"
        }
        return String(data: data, encoding: .utf8) ?? "JSON STRING ERROR"
    }
}
