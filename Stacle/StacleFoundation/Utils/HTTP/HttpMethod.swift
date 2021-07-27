

// MARK: - HttpMethod

public struct HttpMethod: RawRepresentable, Hashable, Codable {

	// MARK: Protocol: RawRepresentable

	public typealias RawValue = String

	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	public let rawValue: RawValue
}

// MARK: Protocol: CustomStringConvertible

extension HttpMethod: CustomStringConvertible {

	public var description: String { self.rawValue }
}

// MARK: Topic: Standard

extension HttpMethod {

	// MARK: Essential

	// These values are taken from the [IANA HTTP Method Registry](https://www.iana.org/assignments/http-methods/http-methods.xhtml).

	public static let acl: Self = Self(rawValue: "ACL")

	public static let baselineControl: Self = Self(rawValue: "BASELINE-CONTROL")

	public static let bind: Self = Self(rawValue: "BIND")

	public static let checkin: Self = Self(rawValue: "CHECKIN")

	public static let checkout: Self = Self(rawValue: "CHECKOUT")

	public static let connect: Self = Self(rawValue: "CONNECT")

	public static let copy: Self = Self(rawValue: "COPY")

	public static let delete: Self = Self(rawValue: "DELETE")

	public static let get: Self = Self(rawValue: "GET")

	public static let head: Self = Self(rawValue: "HEAD")

	public static let label: Self = Self(rawValue: "LABEL")

	public static let link: Self = Self(rawValue: "LINK")

	public static let lock: Self = Self(rawValue: "LOCK")

	public static let merge: Self = Self(rawValue: "MERGE")

	public static let mkactivity: Self = Self(rawValue: "MKACTIVITY")

	public static let mkcalendar: Self = Self(rawValue: "MKCALENDAR")

	public static let mkcol: Self = Self(rawValue: "MKCOL")

	public static let mkredirectref: Self = Self(rawValue: "MKREDIRECTREF")

	public static let mkworkspace: Self = Self(rawValue: "MKWORKSPACE")

	public static let move: Self = Self(rawValue: "MOVE")

	public static let options: Self = Self(rawValue: "OPTIONS")

	public static let orderpatch: Self = Self(rawValue: "ORDERPATCH")

	public static let patch: Self = Self(rawValue: "PATCH")

	public static let post: Self = Self(rawValue: "POST")

	public static let pri: Self = Self(rawValue: "PRI")

	public static let propfind: Self = Self(rawValue: "PROPFIND")

	public static let proppatch: Self = Self(rawValue: "PROPPATCH")

	public static let put: Self = Self(rawValue: "PUT")

	public static let rebind: Self = Self(rawValue: "REBIND")

	public static let report: Self = Self(rawValue: "REPORT")

	public static let search: Self = Self(rawValue: "SEARCH")

	public static let trace: Self = Self(rawValue: "TRACE")

	public static let unbind: Self = Self(rawValue: "UNBIND")
	
	public static let uncheckout: Self = Self(rawValue: "UNCHECKOUT")

	public static let unlink: Self = Self(rawValue: "UNLINK")

	public static let unlock: Self = Self(rawValue: "UNLOCK")

	public static let update: Self = Self(rawValue: "UPDATE")

	public static let updateredirectref: Self = Self(rawValue: "UPDATEREDIRECTREF")

	public static let versionControl: Self = Self(rawValue: "VERSION-CONTROL")
}
