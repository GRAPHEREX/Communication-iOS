//
//  NetworkService.swift
//  CryptoAuth
//
//  Created by Stacle iOS-2 on 16.07.2021.
//

import Foundation
import Dispatch
import Combine

public class NetworkService {

    // MARK: Essential

    private var cancellables: Set<AnyCancellable> = []
    private var sessionToken: String? = nil

    public init() {
    }

    public func subscribeToSessionTokenUpdates(_ sessionTokenPublisher: AnyPublisher<String?, Never>) {
        sessionTokenPublisher.sink { [weak self] (sessionToken: String?) in
            self?.sessionToken = sessionToken
        }.store(in: &self.cancellables)
    }
}

extension NetworkService {

    // MARK: Essential

    public func httpTransport<Coder>(coder: Coder, request: Coder.Request, completion: @escaping (_ result: Result<Coder.Response, Error>) -> Void) -> HttpTransport where Coder: HttpTransportCoder {
        .init(
            coder: NetworkServiceHttpTransportCoder(coder, sessionToken: self.sessionToken),
            request: request,
            completion: completion
        )
    }
}
