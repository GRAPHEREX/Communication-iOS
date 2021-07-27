import Foundation

public enum UserAvailability {
    case online
    case offline(Date?)
    
    public static func title(of userAvailability: UserAvailability) -> String{
        let prefixKey: String
        let infix: String?
        let suffixKey: String?
        switch userAvailability {
            case .online:
                prefixKey = NSLocalizedString("userAvailability.online.title", comment: "")
                infix = nil
                suffixKey = nil
            case .offline(nil):
                prefixKey = NSLocalizedString("userAvailability.offline.title", comment: "")
                infix = nil
                suffixKey = nil
            case .offline(let lastSeenDate?):
                prefixKey = NSLocalizedString("userAvailability.lastSeen.title.prefix", comment: "")
                infix = Self.userAvailabilityTimeIntervalFormatter.string(from: lastSeenDate, to: Date())?.lowercased()
                suffixKey = NSLocalizedString("userAvailability.lastSeen.title.suffix", comment: "")
        }
        if let theInfix = infix, let theSuffixKey = suffixKey {
            return prefixKey + " " + theInfix + " " + theSuffixKey
        } else {
            return prefixKey
        }
    }

    private static let userAvailabilityTimeIntervalFormatter: DateComponentsFormatter = {
        let result = DateComponentsFormatter()
        result.includesApproximationPhrase = true
        result.maximumUnitCount = 1
        result.unitsStyle = .full
        return result
    }()
}

