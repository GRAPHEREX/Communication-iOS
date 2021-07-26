//
//  HttpHeaderFieldName.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

// MARK: - HttpHeaderFieldName

public struct HttpHeaderFieldName: RawRepresentable, Hashable, Codable {

	// MARK: Protocol: RawRepresentable

	public typealias RawValue = String

	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	public let rawValue: RawValue
}

// MARK: Protocol: CustomStringConvertible

extension HttpHeaderFieldName: CustomStringConvertible {

	public var description: String { self.rawValue }
}

// MARK: Topic: Standard

extension HttpHeaderFieldName {

	// These values are taken from the [IANA HTTP Header Registry](https://www.iana.org/assignments/message-headers/message-headers.xhtml).

	// MARK: Topic: Permanent

	public static let aIm: Self = Self(rawValue: "A-IM")

	public static let accept: Self = Self(rawValue: "Accept")

	public static let acceptAdditions: Self = Self(rawValue: "Accept-Additions")

	public static let acceptCharset: Self = Self(rawValue: "Accept-Charset")

	public static let acceptDatetime: Self = Self(rawValue: "Accept-Datetime")

	public static let acceptEncoding: Self = Self(rawValue: "Accept-Encoding")

	public static let acceptFeatures: Self = Self(rawValue: "Accept-Features")

	public static let acceptLanguage: Self = Self(rawValue: "Accept-Language")

	public static let acceptPatch: Self = Self(rawValue: "Accept-Patch")

	public static let acceptPost: Self = Self(rawValue: "Accept-Post")

	public static let acceptRanges: Self = Self(rawValue: "Accept-Ranges")

	public static let age: Self = Self(rawValue: "Age")

	public static let allow: Self = Self(rawValue: "Allow")

	public static let alpn: Self = Self(rawValue: "ALPN")

	public static let altSvc: Self = Self(rawValue: "Alt-Svc")

	public static let altUsed: Self = Self(rawValue: "Alt-Used")

	public static let alternates: Self = Self(rawValue: "Alternates")

	public static let applyToRedirectRef: Self = Self(rawValue: "Apply-To-Redirect-Ref")

	public static let authenticationControl: Self = Self(rawValue: "Authentication-Control")

	public static let authenticationInfo: Self = Self(rawValue: "Authentication-Info")

	public static let authorization: Self = Self(rawValue: "Authorization")

	public static let cExt: Self = Self(rawValue: "C-Ext")

	public static let cMan: Self = Self(rawValue: "C-Man")

	public static let cOpt: Self = Self(rawValue: "C-Opt")

	public static let cPep: Self = Self(rawValue: "C-PEP")

	public static let cPepInfo: Self = Self(rawValue: "C-PEP-Info")

	public static let cacheControl: Self = Self(rawValue: "Cache-Control")

	public static let calManagedId: Self = Self(rawValue: "Cal-Managed-ID")

	public static let calDavTimezones: Self = Self(rawValue: "CalDAV-Timezones")

	public static let cdnLoop: Self = Self(rawValue: "CDN-Loop")

	public static let certNotAfter: Self = Self(rawValue: "Cert-Not-After")

	public static let certNotBefore: Self = Self(rawValue: "Cert-Not-Before")

	public static let close: Self = Self(rawValue: "Close")

	public static let connection: Self = Self(rawValue: "Connection")

	public static let contentBase: Self = Self(rawValue: "Content-Base")

	public static let contentDisposition: Self = Self(rawValue: "Content-Disposition")

	public static let contentEncoding: Self = Self(rawValue: "Content-Encoding")

	public static let contentId: Self = Self(rawValue: "Content-ID")

	public static let contentLanguage: Self = Self(rawValue: "Content-Language")

	public static let contentLength: Self = Self(rawValue: "Content-Length")

	public static let contentLocation: Self = Self(rawValue: "Content-Location")

	public static let contentMd5: Self = Self(rawValue: "Content-MD5")

	public static let contentRange: Self = Self(rawValue: "Content-Range")

	public static let contentScriptType: Self = Self(rawValue: "Content-Script-Type")

	public static let contentStyleType: Self = Self(rawValue: "Content-Style-Type")

	public static let contentType: Self = Self(rawValue: "Content-Type")

	public static let contentVersion: Self = Self(rawValue: "Content-Version")

	public static let cookie: Self = Self(rawValue: "Cookie")

	public static let cookie2: Self = Self(rawValue: "Cookie2")

	public static let dasl: Self = Self(rawValue: "DASL")

	public static let dav: Self = Self(rawValue: "DAV")

	public static let date: Self = Self(rawValue: "Date")

	public static let defaultStyle: Self = Self(rawValue: "Default-Style")

	public static let deltaBase: Self = Self(rawValue: "Delta-Base")

	public static let depth: Self = Self(rawValue: "Depth")

	public static let derivedFrom: Self = Self(rawValue: "Derived-From")

	public static let destination: Self = Self(rawValue: "Destination")

	public static let differentialId: Self = Self(rawValue: "Differential-ID")

	public static let digest: Self = Self(rawValue: "Digest")

	public static let earlyData: Self = Self(rawValue: "Early-Data")

	public static let eTag: Self = Self(rawValue: "ETag")

	public static let expect: Self = Self(rawValue: "Expect")

	public static let expectCt: Self = Self(rawValue: "Expect-CT")

	public static let expires: Self = Self(rawValue: "Expires")

	public static let ext: Self = Self(rawValue: "Ext")

	public static let forwarded: Self = Self(rawValue: "Forwarded")

	public static let from: Self = Self(rawValue: "From")

	public static let getProfile: Self = Self(rawValue: "GetProfile")

	public static let hobareg: Self = Self(rawValue: "Hobareg")

	public static let host: Self = Self(rawValue: "Host")

	public static let http2Settings: Self = Self(rawValue: "HTTP2-Settings")

	public static let im: Self = Self(rawValue: "IM")

	public static let `if`: Self = Self(rawValue: "If")

	public static let ifMatch: Self = Self(rawValue: "If-Match")

	public static let ifModifiedSince: Self = Self(rawValue: "If-Modified-Since")

	public static let ifNoneMatch: Self = Self(rawValue: "If-None-Match")

	public static let ifRange: Self = Self(rawValue: "If-Range")

	public static let ifScheduleTagMatch: Self = Self(rawValue: "If-Schedule-Tag-Match")

	public static let ifUnmodifiedSince: Self = Self(rawValue: "If-Unmodified-Since")

	public static let includeReferredTokenBindingId: Self = Self(rawValue: "Include-Referred-Token-Binding-ID")

	public static let keepAlive: Self = Self(rawValue: "Keep-Alive")

	public static let label: Self = Self(rawValue: "Label")

	public static let lastModified: Self = Self(rawValue: "Last-Modified")

	public static let link: Self = Self(rawValue: "Link")

	public static let location: Self = Self(rawValue: "Location")

	public static let lockToken: Self = Self(rawValue: "Lock-Token")

	public static let man: Self = Self(rawValue: "Man")

	public static let maxForwards: Self = Self(rawValue: "Max-Forwards")

	public static let mementoDatetime: Self = Self(rawValue: "Memento-Datetime")

	public static let meter: Self = Self(rawValue: "Meter")

	public static let mimeVersion: Self = Self(rawValue: "MIME-Version")

	public static let negotiate: Self = Self(rawValue: "Negotiate")

	public static let opt: Self = Self(rawValue: "Opt")

	public static let optionalWwwAuthenticate: Self = Self(rawValue: "Optional-WWW-Authenticate")

	public static let orderingType: Self = Self(rawValue: "Ordering-Type")

	public static let origin: Self = Self(rawValue: "Origin")

	public static let oscore: Self = Self(rawValue: "OSCORE")

	public static let overwrite: Self = Self(rawValue: "Overwrite")

	public static let p3P: Self = Self(rawValue: "P3P")

	public static let pep: Self = Self(rawValue: "PEP")

	public static let picsLabel: Self = Self(rawValue: "PICS-Label")

	public static let pepInfo: Self = Self(rawValue: "Pep-Info")

	public static let position: Self = Self(rawValue: "Position")

	public static let pragma: Self = Self(rawValue: "Pragma")

	public static let prefer: Self = Self(rawValue: "Prefer")

	public static let preferenceApplied: Self = Self(rawValue: "Preference-Applied")

	public static let profileObject: Self = Self(rawValue: "ProfileObject")

	public static let `protocol`: Self = Self(rawValue: "Protocol")

	public static let protocolInfo: Self = Self(rawValue: "Protocol-Info")

	public static let protocolQuery: Self = Self(rawValue: "Protocol-Query")

	public static let protocolRequest: Self = Self(rawValue: "Protocol-Request")

	public static let proxyAuthenticate: Self = Self(rawValue: "Proxy-Authenticate")

	public static let proxyAuthenticationInfo: Self = Self(rawValue: "Proxy-Authentication-Info")

	public static let proxyAuthorization: Self = Self(rawValue: "Proxy-Authorization")

	public static let proxyFeatures: Self = Self(rawValue: "Proxy-Features")

	public static let proxyInstruction: Self = Self(rawValue: "Proxy-Instruction")

	public static let `public`: Self = Self(rawValue: "Public")

	public static let publicKeyPins: Self = Self(rawValue: "Public-Key-Pins")

	public static let publicKeyPinsReportOnly: Self = Self(rawValue: "Public-Key-Pins-Report-Only")

	public static let range: Self = Self(rawValue: "Range")

	public static let redirectRef: Self = Self(rawValue: "Redirect-Ref")

	public static let referer: Self = Self(rawValue: "Referer")

	public static let replayNonce: Self = Self(rawValue: "Replay-Nonce")

	public static let retryAfter: Self = Self(rawValue: "Retry-After")
    
    public static let requestId: Self = Self(rawValue: "X-Request-Id")

	public static let safe: Self = Self(rawValue: "Safe")

	public static let scheduleReply: Self = Self(rawValue: "Schedule-Reply")

	public static let scheduleTag: Self = Self(rawValue: "Schedule-Tag")

	public static let secTokenBinding: Self = Self(rawValue: "Sec-Token-Binding")

	public static let secWebSocketAccept: Self = Self(rawValue: "Sec-WebSocket-Accept")

	public static let secWebSocketExtensions: Self = Self(rawValue: "Sec-WebSocket-Extensions")

	public static let secWebSocketKey: Self = Self(rawValue: "Sec-WebSocket-Key")

	public static let secWebSocketProtocol: Self = Self(rawValue: "Sec-WebSocket-Protocol")

	public static let secWebSocketVersion: Self = Self(rawValue: "Sec-WebSocket-Version")

	public static let securityScheme: Self = Self(rawValue: "Security-Scheme")

	public static let server: Self = Self(rawValue: "Server")

	public static let setCookie: Self = Self(rawValue: "Set-Cookie")

	public static let setCookie2: Self = Self(rawValue: "Set-Cookie2")

	public static let setProfile: Self = Self(rawValue: "SetProfile")

	public static let slug: Self = Self(rawValue: "SLUG")

	public static let soapAction: Self = Self(rawValue: "SoapAction")

	public static let statusUri: Self = Self(rawValue: "Status-URI")

	public static let strictTransportSecurity: Self = Self(rawValue: "Strict-Transport-Security")

	public static let sunset: Self = Self(rawValue: "Sunset")

	public static let surrogateCapability: Self = Self(rawValue: "Surrogate-Capability")

	public static let surrogateControl: Self = Self(rawValue: "Surrogate-Control")

	public static let tcn: Self = Self(rawValue: "TCN")

	public static let te: Self = Self(rawValue: "TE")

	public static let timeout: Self = Self(rawValue: "Timeout")

	public static let topic: Self = Self(rawValue: "Topic")

	public static let trailer: Self = Self(rawValue: "Trailer")

	public static let transferEncoding: Self = Self(rawValue: "Transfer-Encoding")

	public static let ttl: Self = Self(rawValue: "TTL")

	public static let urgency: Self = Self(rawValue: "Urgency")

	public static let uri: Self = Self(rawValue: "URI")

	public static let upgrade: Self = Self(rawValue: "Upgrade")

	public static let userAgent: Self = Self(rawValue: "User-Agent")

	public static let variantVary: Self = Self(rawValue: "Variant-Vary")

	public static let vary: Self = Self(rawValue: "Vary")

	public static let via: Self = Self(rawValue: "Via")

	public static let wwwAuthenticate: Self = Self(rawValue: "WWW-Authenticate")

	public static let wantDigest: Self = Self(rawValue: "Want-Digest")

	public static let warning: Self = Self(rawValue: "Warning")

	public static let xContentTypeOptions: Self = Self(rawValue: "X-Content-Type-Options")

	public static let xFrameOptions: Self = Self(rawValue: "X-Frame-Options")

	// MARK: Topic: Provisional


	public static let accessControl: Self = Self(rawValue: "Access-Control")

	public static let accessControlAllowCredentials: Self = Self(rawValue: "Access-Control-Allow-Credentials")

	public static let accessControlAllowHeaders: Self = Self(rawValue: "Access-Control-Allow-Headers")

	public static let accessControlAllowMethods: Self = Self(rawValue: "Access-Control-Allow-Methods")

	public static let accessControlAllowOrigin: Self = Self(rawValue: "Access-Control-Allow-Origin")

	public static let accessControlMaxAge: Self = Self(rawValue: "Access-Control-Max-Age")

	public static let accessControlRequestMethod: Self = Self(rawValue: "Access-Control-Request-Method")

	public static let accessControlRequestHeaders: Self = Self(rawValue: "Access-Control-Request-Headers")

	public static let ampCacheTransform: Self = Self(rawValue: "AMP-Cache-Transform")

	public static let compliance: Self = Self(rawValue: "Compliance")

	public static let contentTransferEncoding: Self = Self(rawValue: "Content-Transfer-Encoding")

	public static let cost: Self = Self(rawValue: "Cost")

	public static let ediintFeatures: Self = Self(rawValue: "EDIINT-Features")

	public static let messageId: Self = Self(rawValue: "Message-ID")

	public static let methodCheck: Self = Self(rawValue: "Method-Check")

	public static let methodCheckExpires: Self = Self(rawValue: "Method-Check-Expires")

	public static let nonCompliance: Self = Self(rawValue: "Non-Compliance")

	public static let optional: Self = Self(rawValue: "Optional")

	public static let refererRoot: Self = Self(rawValue: "Referer-Root")

	public static let resolutionHint: Self = Self(rawValue: "Resolution-Hint")

	public static let resolverLocation: Self = Self(rawValue: "Resolver-Location")

	public static let subOk: Self = Self(rawValue: "SubOK")

	public static let subst: Self = Self(rawValue: "Subst")

	public static let timingAllowOrigin: Self = Self(rawValue: "Timing-Allow-Origin")

	public static let title: Self = Self(rawValue: "Title")

	public static let traceparent: Self = Self(rawValue: "Traceparent")

	public static let tracestate: Self = Self(rawValue: "Tracestate")

	public static let uaColor: Self = Self(rawValue: "UA-Color")

	public static let uaMedia: Self = Self(rawValue: "UA-Media")

	public static let uaPixels: Self = Self(rawValue: "UA-Pixels")

	public static let uaResolution: Self = Self(rawValue: "UA-Resolution")

	public static let uaWindowpixels: Self = Self(rawValue: "UA-Windowpixels")

	public static let version: Self = Self(rawValue: "Version")

	public static let xDeviceAccept: Self = Self(rawValue: "X-Device-Accept")

	public static let xDeviceAcceptCharset: Self = Self(rawValue: "X-Device-Accept-Charset")

	public static let xDeviceAcceptEncoding: Self = Self(rawValue: "X-Device-Accept-Encoding")

	public static let xDeviceAcceptLanguage: Self = Self(rawValue: "X-Device-Accept-Language")

	public static let xDeviceUserAgent: Self = Self(rawValue: "X-Device-User-Agent")
}
