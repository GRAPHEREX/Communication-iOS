//
//  HttpRequest.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

import Foundation

// MARK: - HttpRequest

public struct HttpRequest {

	// MARK: Essential

	public init(
		scheme: UriScheme = .http,
		host: String = "",
		port: Int = 0,
		path: [String] = [],
		query: [String: String] = [:],
		fragment: String = "",
		method: HttpMethod = .get,
		header: [HttpHeaderFieldName: String] = [:],
		body: Data = .init()
	) {
		self.scheme = scheme
		self.host = host
		self.port = port
		self.path = path
		self.query = query
		self.fragment = fragment
		self.method = method
		self.header = header
		self.body = body
	}

	public var scheme: UriScheme
	public var host: String
	public var port: Int
	public var path: [String]
	public var query: [String: String]
	public var fragment: String
	public var method: HttpMethod
	public var header: [HttpHeaderFieldName: String]
	public var body: Data
}

extension URLRequest {

	// MARK: Confidential

	internal init?(_ other: HttpRequest) {

		let url: URL
		do {
			var decomposed = URLComponents()
			decomposed.scheme = other.scheme.rawValue
			decomposed.host = other.host.isEmpty ? nil : other.host
			decomposed.port = other.port == 0 ? nil : other.port
			decomposed.path = ""
			decomposed.queryItems = other.query.isEmpty ? nil : other.query
				.sorted { $0.key < $1.key }
				.map { URLQueryItem(name: $0.key, value: $0.value) }
			decomposed.fragment = other.fragment.isEmpty ? nil : other.fragment

			guard var composed = decomposed.url else {
				return nil
			}
			for pathSegment in other.path {
				composed.appendPathComponent(pathSegment)
			}
			url = composed
		}
		self.init(url: url)
		self.httpMethod = other.method.rawValue
		for headerField in other.header {
			self.setValue(headerField.value, forHTTPHeaderField: headerField.key.rawValue)
		}
		self.httpBody = other.body.isEmpty ? nil : other.body
	}
}
