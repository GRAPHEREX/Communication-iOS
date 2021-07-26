//
//  HttpAuthenticationScheme.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

// MARK: - HttpAuthenticationScheme

public struct HttpAuthenticationScheme: RawRepresentable, Hashable, Codable {

	// MARK: Protocol: RawRepresentable

	public typealias RawValue = String

	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	public let rawValue: RawValue
}

// MARK: Protocol: CustomStringConvertible

extension HttpAuthenticationScheme: CustomStringConvertible {

	public var description: String { self.rawValue }
}

// MARK: Topic: Standard

extension HttpAuthenticationScheme {

	// These values are taken from the [IANA HTTP Authentication Scheme Registry](https://www.iana.org/assignments/http-authschemes/http-authschemes.xhtml).

	public static let basic: Self = Self(rawValue: "Basic")

	public static let bearer: Self = Self(rawValue: "Bearer")

	public static let digest: Self = Self(rawValue: "Digest")

	public static let hoba: Self = Self(rawValue: "HOBA")

	public static let mutual: Self = Self(rawValue: "Mutual")

	public static let negotiate: Self = Self(rawValue: "Negotiate")

	public static let oAuth: Self = Self(rawValue: "OAuth")

	public static let scramSha1: Self = Self(rawValue: "SCRAM-SHA-1")

	public static let scramSha256: Self = Self(rawValue: "SCRAM-SHA-256")

	public static let vapid: Self = Self(rawValue: "vapid")
}
