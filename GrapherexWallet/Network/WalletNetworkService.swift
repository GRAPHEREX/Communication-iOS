////
////  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
////
//
//import Foundation
//import os.log
//
//class WalletNetworkService: NetworkService {
//
//    // MARK: - Properties
//    let session: URLSession
//
//    private let logger = //Logger()
//
//    // MARK: - Methods
//    required init(session: URLSession = .shared) {
//        self.session = session
//    }
//
//    func constructURL(baseURL: URL, parameters: [String: String]) -> URL {
//        guard !parameters.isEmpty else {
//            return baseURL
//        }
//        // Parse and add URL request parameters here from 'parameters' dict
//        // Force unwrap since valid URL is given by input
//        guard var components = URLComponents(string: baseURL.absoluteString) else {
//            fatalError()
//        }
//        components.queryItems = parameters.map { (key, value) in
//            URLQueryItem(name: key, value: value)
//        }
//
//        // Need to escape '+' manually
//        // More: https://stackoverflow.com/questions/41561853/couldnt-encode-plus-character-in-url-swift
//        // And here: http://www.ietf.org/rfc/rfc1738.txt
//        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
//        guard let finalURL = components.url else {
//            fatalError()
//        }
//        return finalURL
//    }
//
//    func loadRequest<ResponseType: Decodable>(url: URL,
//                                              parameters: [String: String],
//                                              responseQueue: DispatchQueue,
//                                              completion: @escaping(Result<ResponseType>) -> Void) -> URLSessionDataTask {
//
//        let finalURL = constructURL(baseURL: url, parameters: parameters)
//
//        logger.debug("called URL: \(finalURL.absoluteString)")
//
//        let task = session.dataTask(with: finalURL) { [weak self](data, response, error) in
//            guard let response = response as? HTTPURLResponse,
//                  response.statusCode == 200,
//                  error == nil,
//                  let data = data else {
//                if let error = error {
//                    responseQueue.async {
//                        completion(.failure(error))
//                    }
//                } else {
//                    responseQueue.async {
//                        completion(.failure(AppError.unknown))
//                    }
//                }
//                return
//            }
//
//            self?.debugPrint(url: finalURL, data: data, params: parameters)
//
//            let decoder = JSONDecoder()
//            do {
//                let result = try decoder.decode(ResponseType.self, from: data)
//                responseQueue.async {
//                    completion(.success(result))
//                }
//            } catch {
//                responseQueue.async {
//                    completion(.failure(error))
//                }
//            }
//
//        }
//        task.resume()
//        return task
//    }
//
//    private func debugPrint(url: URL, data: Data, params: [String: Any]) {
//        let string = String(data: data, encoding: .utf8) ?? "DATA STRING CONVERSION ERROR"
//        logger.info("""
//            API call
//            To \(url.absoluteString).
//            Parameter: \(self.jsonString(dict: params)).
//            Response: \(string)
//            """)
//    }
//
//    private func jsonString(dict: [String: Any]) -> String {
//        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else {
//            return "JSON STRING ERROR"
//        }
//        return String(data: data, encoding: .utf8) ?? "JSON STRING ERROR"
//    }
//}
