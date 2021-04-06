//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

//public typealias JSON = [String: Any]
//
//protocol NetworkService {
//    func loadRequest<ResponseType: Decodable>(url: URL, parameters: [String: String], responseQueue: DispatchQueue, completion: @escaping(Result<ResponseType>) -> Void) -> URLSessionDataTask
//}
//
//extension NetworkService {
//    func loadRequest<ResponseType: Decodable>(url: URL, parameters: [String: String], completion: @escaping(Result<ResponseType>) -> Void) -> URLSessionDataTask {
//        loadRequest(url: url, parameters: parameters, responseQueue: .main, completion: completion)
//    }
//    
//    func loadRequest<ResponseType: Decodable>(url: URL, completion: @escaping(Result<ResponseType>) -> Void) -> URLSessionDataTask {
//        loadRequest(url: url, parameters: [:], responseQueue: .main, completion: completion)
//    }
//}
//
