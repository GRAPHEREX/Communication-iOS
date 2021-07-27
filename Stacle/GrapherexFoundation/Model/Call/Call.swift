import Foundation

public struct Call {
    
    public enum Kind {
        case incoming
        case outgoing
    }
    
    public typealias ID = UUID

    public let collocutor: User
    public let kind: CallKind
    public let startDate: Date
    public var duration: TimeInterval?
    public let id: ID
}
