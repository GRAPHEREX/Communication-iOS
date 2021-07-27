//
//  HttpStatusCode.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

// MARK: - HttpStatusCode

public struct HttpStatusCode: RawRepresentable, Hashable, Codable {

	// MARK: Protocol: RawRepresentable

	public typealias RawValue = Int

	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	public let rawValue: RawValue
}

extension HttpStatusCode {

	// MARK: Essential

	public enum Kind {
		case informational
		case success
		case redirection
		case clientError
		case serverError
		case unassigned
	}

	public var kind: Kind {
		switch self.rawValue {
			case 100 ... 199:  return .informational
			case 200 ... 299:  return .success
			case 300 ... 399:  return .redirection
			case 400 ... 499:  return .clientError
			case 500 ... 599:  return .serverError
			default:           return .unassigned
		}
	}

	public static func ~= (_ some: Kind, _ other: HttpStatusCode) -> Bool {
		return some == other.kind
	}
}

// MARK: Topic: Standard

extension HttpStatusCode {

	// MARK: Essential

	// These values are taken from the [IANA HTTP Status Code Registry](https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml).

	/// Continue
	public static let `continue`: Self = Self(rawValue: 100)

	/// Switching Protocols
	public static let switchingProtocols: Self = Self(rawValue: 101)

	/// Processing
	public static let processing: Self = Self(rawValue: 102)

	/// Early Hints
	public static let earlyHints: Self = Self(rawValue: 103)

	/// OK
	public static let ok: Self = Self(rawValue: 200)

	/// Created
	public static let created: Self = Self(rawValue: 201)

	/// Accepted
	public static let accepted: Self = Self(rawValue: 202)

	/// Non-Authoritative Information
	public static let nonAuthoritativeInformation: Self = Self(rawValue: 203)

	/// No Content
	public static let noContent: Self = Self(rawValue: 204)

	/// Reset Content
	public static let resetContent: Self = Self(rawValue: 205)

	/// Partial Content
	public static let partialContent: Self = Self(rawValue: 206)

	/// Multi-Status
	public static let multiStatus: Self = Self(rawValue: 207)

	/// Already Reported
	public static let alreadyReported: Self = Self(rawValue: 208)

	/// IM Used
	public static let imUsed: Self = Self(rawValue: 226)

	/// Multiple Choices
	public static let multipleChoices: Self = Self(rawValue: 300)

	/// Moved Permanently
	public static let movedPermanently: Self = Self(rawValue: 301)

	/// Found
	public static let found: Self = Self(rawValue: 302)

	/// See Other
	public static let seeOther: Self = Self(rawValue: 303)

	/// Not Modified
	public static let notModified: Self = Self(rawValue: 304)

	/// Use Proxy
	public static let useProxy: Self = Self(rawValue: 305)

	/// Temporary Redirect
	public static let temporaryRedirect: Self = Self(rawValue: 307)

	/// Permanent Redirect
	public static let permanentRedirect: Self = Self(rawValue: 308)

	/// Bad Request
	public static let badRequest: Self = Self(rawValue: 400)

	/// Unauthorized
	public static let unauthorized: Self = Self(rawValue: 401)

	/// Payment Required
	public static let paymentRequired: Self = Self(rawValue: 402)

	/// Forbidden
	public static let forbidden: Self = Self(rawValue: 403)

	/// Not Found
	public static let notFound: Self = Self(rawValue: 404)

	/// Method Not Allowed
	public static let methodNotAllowed: Self = Self(rawValue: 405)

	/// Not Acceptable
	public static let notAcceptable: Self = Self(rawValue: 406)

	/// Proxy Authentication Required
	public static let proxyAuthenticationRequired: Self = Self(rawValue: 407)

	/// Request Timeout
	public static let requestTimeout: Self = Self(rawValue: 408)

	/// Conflict
	public static let conflict: Self = Self(rawValue: 409)

	/// Gone
	public static let gone: Self = Self(rawValue: 410)

	/// Length Required
	public static let lengthRequired: Self = Self(rawValue: 411)

	/// Precondition Failed
	public static let preconditionFailed: Self = Self(rawValue: 412)

	/// Payload Too Large
	public static let payloadTooLarge: Self = Self(rawValue: 413)

	/// URI Too Long
	public static let uriTooLong: Self = Self(rawValue: 414)

	/// Unsupported Media Type
	public static let unsupportedMediaType: Self = Self(rawValue: 415)

	/// Range Not Satisfiable
	public static let rangeNotSatisfiable: Self = Self(rawValue: 416)

	/// Expectation Failed
	public static let expectationFailed: Self = Self(rawValue: 417)

	/// Misdirected Request
	public static let misdirectedRequest: Self = Self(rawValue: 421)

	/// Unprocessable Entity
	public static let unprocessableEntity: Self = Self(rawValue: 422)

	/// Locked
	public static let locked: Self = Self(rawValue: 423)

	/// Failed Dependency
	public static let failedDependency: Self = Self(rawValue: 424)

	/// Too Early
	public static let tooEarly: Self = Self(rawValue: 425)

	/// Upgrade Required
	public static let upgradeRequired: Self = Self(rawValue: 426)

	/// Unassigned
	public static let unassigned: Self = Self(rawValue: 427)

	/// Precondition Required
	public static let preconditionRequired: Self = Self(rawValue: 428)

	/// Too Many Requests
	public static let tooManyRequests: Self = Self(rawValue: 429)

	/// Request Header Fields Too Large
	public static let requestHeaderFieldsTooLarge: Self = Self(rawValue: 431)

	/// Unavailable For Legal Reasons
	public static let unavailableForLegalReasons: Self = Self(rawValue: 451)

	/// Internal Server Error
	public static let internalServerError: Self = Self(rawValue: 500)

	/// Not Implemented
	public static let notImplemented: Self = Self(rawValue: 501)

	/// Bad Gateway
	public static let badGateway: Self = Self(rawValue: 502)

	/// Service Unavailable
	public static let serviceUnavailable: Self = Self(rawValue: 503)

	/// Gateway Timeout
	public static let gatewayTimeout: Self = Self(rawValue: 504)

	/// HTTP Version Not Supported
	public static let httpVersionNotSupported: Self = Self(rawValue: 505)

	/// Variant Also Negotiates
	public static let variantAlsoNegotiates: Self = Self(rawValue: 506)

	/// Insufficient Storage
	public static let insufficientStorage: Self = Self(rawValue: 507)

	/// Loop Detected
	public static let loopDetected: Self = Self(rawValue: 508)

	/// Not Extended
	public static let notExtended: Self = Self(rawValue: 510)

	/// Network Authentication Required
	public static let networkAuthenticationRequired: Self = Self(rawValue: 511)
}
