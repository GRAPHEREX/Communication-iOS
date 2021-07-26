//
//  HttpTransportError.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

import Foundation

// TODO: Replace the Codable implementation to the one that uses the `code` property.

// MARK: - HttpTransportError

public struct HttpTransportError: RawRepresentable, Hashable, Codable {

	// MARK: Protocol: RawRepresentable

	public typealias RawValue = Int

	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	public let rawValue: RawValue
}

// MARK: Protocol: CustomNSError

extension HttpTransportError: CustomNSError {

	public static var errorDomain: String { NSURLErrorDomain }

	public var errorCode: Int { self.rawValue }
}

// MARK: Protocol: CustomStringConvertible

extension HttpTransportError: CustomDebugStringConvertible {

	public var debugDescription: String {
		if let code = self.code {
			return "\(Self.self)(code: \(String(reflecting: code)))"
		} else {
			return "\(Self.self)(rawValue: \(self.rawValue))"
		}
	}
}

// MARK: Topic: Standard

extension HttpTransportError {

	// MARK: Essential

	public static let unknown: Self = Self(rawValue: NSURLErrorUnknown)

	public static let cancelled: Self = Self(rawValue: NSURLErrorCancelled)

	public static let badUrl: Self = Self(rawValue: NSURLErrorBadURL)

	public static let timedOut: Self = Self(rawValue: NSURLErrorTimedOut)

	public static let unsupportedUrl: Self = Self(rawValue: NSURLErrorUnsupportedURL)

	public static let cannotFindHost: Self = Self(rawValue: NSURLErrorCannotFindHost)

	public static let cannotConnectToHost: Self = Self(rawValue: NSURLErrorCannotConnectToHost)

	public static let networkConnectionLost: Self = Self(rawValue: NSURLErrorNetworkConnectionLost)

	public static let dnsLookupFailed: Self = Self(rawValue: NSURLErrorDNSLookupFailed)

	public static let httpTooManyRedirects: Self = Self(rawValue: NSURLErrorHTTPTooManyRedirects)

	public static let resourceUnavailable: Self = Self(rawValue: NSURLErrorResourceUnavailable)

	public static let notConnectedToInternet: Self = Self(rawValue: NSURLErrorNotConnectedToInternet)

	public static let redirectToNonExistentLocation: Self = Self(rawValue: NSURLErrorRedirectToNonExistentLocation)

	public static let badServerResponse: Self = Self(rawValue: NSURLErrorBadServerResponse)

	public static let userCancelledAuthentication: Self = Self(rawValue: NSURLErrorUserCancelledAuthentication)

	public static let userAuthenticationRequired: Self = Self(rawValue: NSURLErrorUserAuthenticationRequired)

	public static let zeroByteResource: Self = Self(rawValue: NSURLErrorZeroByteResource)

	public static let cannotDecodeRawData: Self = Self(rawValue: NSURLErrorCannotDecodeRawData)

	public static let cannotDecodeContentData: Self = Self(rawValue: NSURLErrorCannotDecodeContentData)

	public static let cannotParseResponse: Self = Self(rawValue: NSURLErrorCannotParseResponse)

    @available(iOS 9.0, *)
    public static let appTransportSecurityRequiresSecureConnection: Self = Self(rawValue: NSURLErrorAppTransportSecurityRequiresSecureConnection)

	public static let fileDoesNotExist: Self = Self(rawValue: NSURLErrorFileDoesNotExist)

	public static let fileIsDirectory: Self = Self(rawValue: NSURLErrorFileIsDirectory)

	public static let noPermissionsToReadFile: Self = Self(rawValue: NSURLErrorNoPermissionsToReadFile)

	public static let dataLengthExceedsMaximum: Self = Self(rawValue: NSURLErrorDataLengthExceedsMaximum)

    @available(iOS 10.3, *)
    public static let fileOutsideSafeArea: Self = Self(rawValue: NSURLErrorFileOutsideSafeArea)

	public static let secureConnectionFailed: Self = Self(rawValue: NSURLErrorSecureConnectionFailed)

	public static let serverCertificateHasBadDate: Self = Self(rawValue: NSURLErrorServerCertificateHasBadDate)

	public static let serverCertificateUntrusted: Self = Self(rawValue: NSURLErrorServerCertificateUntrusted)

	public static let serverCertificateHasUnknownRoot: Self = Self(rawValue: NSURLErrorServerCertificateHasUnknownRoot)

	public static let serverCertificateNotYetValid: Self = Self(rawValue: NSURLErrorServerCertificateNotYetValid)

	public static let clientCertificateRejected: Self = Self(rawValue: NSURLErrorClientCertificateRejected)

	public static let clientCertificateRequired: Self = Self(rawValue: NSURLErrorClientCertificateRequired)

	public static let cannotLoadFromNetwork: Self = Self(rawValue: NSURLErrorCannotLoadFromNetwork)

	public static let cannotCreateFile: Self = Self(rawValue: NSURLErrorCannotCreateFile)

	public static let cannotOpenFile: Self = Self(rawValue: NSURLErrorCannotOpenFile)

	public static let cannotCloseFile: Self = Self(rawValue: NSURLErrorCannotCloseFile)

	public static let cannotWriteToFile: Self = Self(rawValue: NSURLErrorCannotWriteToFile)

	public static let cannotRemoveFile: Self = Self(rawValue: NSURLErrorCannotRemoveFile)

	public static let cannotMoveFile: Self = Self(rawValue: NSURLErrorCannotMoveFile)

	public static let downloadDecodingFailedMidStream: Self = Self(rawValue: NSURLErrorDownloadDecodingFailedMidStream)

	public static let downloadDecodingFailedToComplete: Self = Self(rawValue: NSURLErrorDownloadDecodingFailedToComplete)

	public static let internationalRoamingOff: Self = Self(rawValue: NSURLErrorInternationalRoamingOff)

	public static let callIsActive: Self = Self(rawValue: NSURLErrorCallIsActive)

	public static let dataNotAllowed: Self = Self(rawValue: NSURLErrorDataNotAllowed)

	public static let requestBodyStreamExhausted: Self = Self(rawValue: NSURLErrorRequestBodyStreamExhausted)

	public static let backgroundSessionRequiresSharedContainer: Self = Self(rawValue: NSURLErrorBackgroundSessionRequiresSharedContainer)

	public static let backgroundSessionInUseByAnotherProcess: Self = Self(rawValue: NSURLErrorBackgroundSessionInUseByAnotherProcess)

	public static let backgroundSessionWasDisconnected: Self = Self(rawValue: NSURLErrorBackgroundSessionWasDisconnected)
}

// MARK: Topic: Code

extension HttpTransportError {

	// MARK: Essential

	public init?(code: String) {
		switch code {
			case "unknown": self = .unknown
			case "cancelled": self = .cancelled
			case "bad_url": self = .badUrl
			case "timed_out": self = .timedOut
			case "unsupported_url": self = .unsupportedUrl
			case "cannot_find_host": self = .cannotFindHost
			case "cannot_connect_to_host": self = .cannotConnectToHost
			case "network_connection_lost": self = .networkConnectionLost
			case "dns_lookup_failed": self = .dnsLookupFailed
			case "http_too_many_redirects": self = .httpTooManyRedirects
			case "resource_unavailable": self = .resourceUnavailable
			case "not_connected_to_internet": self = .notConnectedToInternet
			case "redirect_to_non_existent_location": self = .redirectToNonExistentLocation
			case "bad_server_response": self = .badServerResponse
			case "user_cancelled_authentication": self = .userCancelledAuthentication
			case "user_authentication_required": self = .userAuthenticationRequired
			case "zero_byte_resource": self = .zeroByteResource
			case "cannot_decode_raw_data": self = .cannotDecodeRawData
			case "cannot_decode_content_data": self = .cannotDecodeContentData
			case "cannot_parse_response": self = .cannotParseResponse
            case "app_transport_security_requires_secure_connection":
                if #available(iOS 9.0, *) {
                    self = .appTransportSecurityRequiresSecureConnection
                } else { return nil }
			case "file_does_not_exist": self = .fileDoesNotExist
			case "file_is_directory": self = .fileIsDirectory
			case "no_permissions_to_read_file": self = .noPermissionsToReadFile
			case "data_length_exceeds_maximum": self = .dataLengthExceedsMaximum
			case "file_outside_safe_area":
                if #available(iOS 10.3, *) {
                    self = .fileOutsideSafeArea
                } else { return nil }
			case "secure_connection_failed": self = .secureConnectionFailed
			case "server_certificate_has_bad_date": self = .serverCertificateHasBadDate
			case "server_certificate_untrusted": self = .serverCertificateUntrusted
			case "server_certificate_has_unknown_root": self = .serverCertificateHasUnknownRoot
			case "server_certificate_not_yet_valid": self = .serverCertificateNotYetValid
			case "client_certificate_rejected": self = .clientCertificateRejected
			case "client_certificate_required": self = .clientCertificateRequired
			case "cannot_load_from_network": self = .cannotLoadFromNetwork
			case "cannot_create_file": self = .cannotCreateFile
			case "cannot_open_file": self = .cannotOpenFile
			case "cannot_close_file": self = .cannotCloseFile
			case "cannot_write_to_file": self = .cannotWriteToFile
			case "cannot_remove_file": self = .cannotRemoveFile
			case "cannot_move_file": self = .cannotMoveFile
			case "download_decoding_failed_mid_stream": self = .downloadDecodingFailedMidStream
			case "download_decoding_failed_to_complete": self = .downloadDecodingFailedToComplete
			case "international_roaming_off": self = .internationalRoamingOff
			case "call_is_active": self = .callIsActive
			case "data_not_allowed": self = .dataNotAllowed
			case "request_body_stream_exhausted": self = .requestBodyStreamExhausted
			case "background_session_requires_shared_container": self = .backgroundSessionRequiresSharedContainer
			case "background_session_in_use_by_another_process": self = .backgroundSessionInUseByAnotherProcess
			case "background_session_was_disconnected": self = .backgroundSessionWasDisconnected
			default: return nil
		}
	}

	public var code: String? {
		switch self {
			case .unknown: return "unknown"
			case .cancelled: return "cancelled"
			case .badUrl: return "bad_url"
			case .timedOut: return "timed_out"
			case .unsupportedUrl: return "unsupported_url"
			case .cannotFindHost: return "cannot_find_host"
			case .cannotConnectToHost: return "cannot_connect_to_host"
			case .networkConnectionLost: return "network_connection_lost"
			case .dnsLookupFailed: return "dns_lookup_failed"
			case .httpTooManyRedirects: return "http_too_many_redirects"
			case .resourceUnavailable: return "resource_unavailable"
			case .notConnectedToInternet: return "not_connected_to_internet"
			case .redirectToNonExistentLocation: return "redirect_to_non_existent_location"
			case .badServerResponse: return "bad_server_response"
			case .userCancelledAuthentication: return "user_cancelled_authentication"
			case .userAuthenticationRequired: return "user_authentication_required"
			case .zeroByteResource: return "zero_byte_resource"
			case .cannotDecodeRawData: return "cannot_decode_raw_data"
			case .cannotDecodeContentData: return "cannot_decode_content_data"
			case .cannotParseResponse: return "cannot_parse_response"
			case .fileDoesNotExist: return "file_does_not_exist"
			case .fileIsDirectory: return "file_is_directory"
			case .noPermissionsToReadFile: return "no_permissions_to_read_file"
			case .dataLengthExceedsMaximum: return "data_length_exceeds_maximum"
			case .secureConnectionFailed: return "secure_connection_failed"
			case .serverCertificateHasBadDate: return "server_certificate_has_bad_date"
			case .serverCertificateUntrusted: return "server_certificate_untrusted"
			case .serverCertificateHasUnknownRoot: return "server_certificate_has_unknown_root"
			case .serverCertificateNotYetValid: return "server_certificate_not_yet_valid"
			case .clientCertificateRejected: return "client_certificate_rejected"
			case .clientCertificateRequired: return "client_certificate_required"
			case .cannotLoadFromNetwork: return "cannot_load_from_network"
			case .cannotCreateFile: return "cannot_create_file"
			case .cannotOpenFile: return "cannot_open_file"
			case .cannotCloseFile: return "cannot_close_file"
			case .cannotWriteToFile: return "cannot_write_to_file"
			case .cannotRemoveFile: return "cannot_remove_file"
			case .cannotMoveFile: return "cannot_move_file"
			case .downloadDecodingFailedMidStream: return "download_decoding_failed_mid_stream"
			case .downloadDecodingFailedToComplete: return "download_decoding_failed_to_complete"
			case .internationalRoamingOff: return "international_roaming_off"
			case .callIsActive: return "call_is_active"
			case .dataNotAllowed: return "data_not_allowed"
			case .requestBodyStreamExhausted: return "request_body_stream_exhausted"
			case .backgroundSessionRequiresSharedContainer: return "background_session_requires_shared_container"
			case .backgroundSessionInUseByAnotherProcess: return "background_session_in_use_by_another_process"
			case .backgroundSessionWasDisconnected: return "background_session_was_disconnected"
			default:
                if #available(iOS 9.0, *), self == .appTransportSecurityRequiresSecureConnection {
                    return "app_transport_security_requires_secure_connection"
                }
                if #available(iOS 10.3, *), self == .fileOutsideSafeArea {
                    return "file_outside_safe_area"
                }
                return nil
        }
	}
}
