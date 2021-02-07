import UIKit

public enum UserIcon {
    case specific(UIImage)
    case generic(PersonName?)
}

public struct User {
    public var displayName: PersonName?
    public var picture: UIImage?
    public var availability: UserAvailability
    public let id: UUID
}

public enum IconVariant {
    case regular
    case selected
}
