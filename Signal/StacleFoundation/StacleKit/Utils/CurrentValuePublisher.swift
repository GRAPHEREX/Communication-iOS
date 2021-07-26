//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import Combine

public struct CurrentValuePublisher<Output, Failure>: Publisher where Failure: Error {

    public var value: Output {
        return subject.value
    }
    private let subject: CurrentValueSubject<Output, Failure>

    public init(_ subject: CurrentValueSubject<Output, Failure>) {
        self.subject = subject
    }


    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.subject.receive(subscriber: subscriber)
    }
}

public extension CurrentValueSubject {
    func asPublisher() -> CurrentValuePublisher<Output, Failure> {
        return CurrentValuePublisher(self)
    }
}
