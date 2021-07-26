//
//  HttpResponse.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

import Foundation

// MARK: - HttpResponse

public struct HttpResponse {

	// MARK: Essential

	public init(
		statusCode: HttpStatusCode,
		header: [HttpHeaderFieldName: String],
		data: Data
	) {
		self.statusCode = statusCode
		self.header = header
		self.data = data
	}

	public let statusCode: HttpStatusCode
	public let header: [HttpHeaderFieldName: String]
	public let data: Data
}

extension HttpResponse {

	// MARK: Confidential

	internal init(_ other: HTTPURLResponse, data: Data?) {
		self.init(
			statusCode: HttpStatusCode(rawValue: other.statusCode),
			header: Dictionary(
				other.allHeaderFields.lazy.map {(
					key: HttpHeaderFieldName(rawValue: String(describing: $0.key.base)),
					value: String(describing: $0.value)
				)},
				uniquingKeysWith: { earlier, later in later }
			),
			data: data ?? .init()
		)
	}
}
