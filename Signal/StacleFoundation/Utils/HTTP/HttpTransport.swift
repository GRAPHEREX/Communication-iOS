//
//  HttpTransport.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

import Foundation
import Dispatch


// MARK: - HttpTransport

public struct HttpTransport {

	// MARK: Confidential

	private init(urlSessionTask: URLSessionTask?) {
		self.urlSessionTask = urlSessionTask
	}

	private let urlSessionTask: URLSessionTask?
}

extension HttpTransport {

	// MARK: Essential

	public init(
		request: HttpRequest,
		completion: @escaping (Result<HttpResponse, HttpTransportError>) -> Void
	) {
		let session: URLSession = .shared
		guard let rawRequest = URLRequest(request) else {
			self.init(urlSessionTask: nil)
			completion(.failure(.badUrl)); return
		}
		let urlSessionTask = session.dataTask(with: rawRequest) { data, response, error in
			if let error = error {
				if let httpError = HttpTransportError(error) {
					completion(.failure(httpError)); return
				}
				NSLog("Unknown HTTP error: \(error).")
				completion(.failure(.unknown)); return
			}
			guard let rawResponse = response as? HTTPURLResponse else {
				completion(.failure(.cannotParseResponse)); return
			}
			let response = HttpResponse(rawResponse, data: data)
			completion(.success(response)); return
		}
		self.init(urlSessionTask: urlSessionTask)
	}

	public var isRunning: Bool {
		get {
			guard let urlSessionTask = self.urlSessionTask else {
				return false
			}
			switch urlSessionTask.state {
				case .running, .canceling:
					return true
				case .suspended, .completed:
					return false
				@unknown default:
					return false
			}
		}

		nonmutating set {
			guard let urlSessionTask = self.urlSessionTask else {
				return
			}
			if newValue {
				urlSessionTask.resume()
			} else {
				urlSessionTask.suspend()
			}
		}
	}

	public func cancel() {
		self.urlSessionTask?.cancel()
	}

	// MARK: Incidental

	public init<Coder>(
		coder: Coder,
		request: Coder.Request,
		completion: @escaping (Result<Coder.Response, Error>) -> Void
	) where Coder: HttpTransportCoder {
		var encodedRequest: HttpRequest = .init()
		do {
			try coder.encodeRequest(request, to: &encodedRequest)
		} catch {
			self.init(urlSessionTask: nil)
			completion(.failure(HttpTransportCoderError.requestEncodingFailure(error))); return
		}

        print("⬆️ HttpTransport - Request:\n\(encodedRequest)")
        print("Request body:\n\(String(data: encodedRequest.body, encoding: .utf8) ?? ""))")

        self.init(request: encodedRequest) { (result: Result<HttpResponse, HttpTransportError>) in
			switch result {
				case .success(let response):
                    print("⬇️ HttpTransport - Response:\n\(response)")
					let decodedResponse: Coder.Response
					do {
						decodedResponse = try coder.decodeResponse(from: response)
					} catch {
                        print("⚠️ HttpTransport - Response decoding failed. Printing response data:\n\(String(data: response.data, encoding: .utf8) ?? "")")
						completion(.failure(HttpTransportCoderError.responseDecodingFailure(error))); return
					}
					completion(.success(decodedResponse)); return
				case .failure(let error):
                    print("🛑 HttpTransport - Response failure:\n\(error)")
					completion(.failure(error)); return
			}
		}
	}
}

// MARK: Protocol: Equatable

extension HttpTransport: Equatable {

	public static func == (_ some: Self, _ other: Self) -> Bool {
		some.urlSessionTask?.taskIdentifier == other.urlSessionTask?.taskIdentifier
	}
}

// MARK: Protocol: Hashable

extension HttpTransport: Hashable {

	public func hash(into hasher: inout Hasher) {
		guard let taskIdentifier = self.urlSessionTask?.taskIdentifier else {
			return
		}
		hasher.combine(taskIdentifier)
	}
}
