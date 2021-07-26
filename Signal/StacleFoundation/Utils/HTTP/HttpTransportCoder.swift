//
//  HttpTransportCoder.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

// MARK: - HttpTransportCoder

public protocol HttpTransportCoder {

	associatedtype Request

	associatedtype Response

	func encodeRequest(_ request: Request, to encoded: inout HttpRequest) throws

	func decodeResponse(from response: HttpResponse) throws -> Response
}
