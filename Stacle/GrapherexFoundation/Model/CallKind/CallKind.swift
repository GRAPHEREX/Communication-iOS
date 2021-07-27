import UIKit

public enum CallKind {
    case incoming
    case outgoing
    
    public static func title(of callKind: CallKind, startDate: Date, duration: TimeInterval?) -> String {
        let color: UIColor
        let prefixKey: String
        let infix: String?
        switch (callKind, duration) {
            case (.incoming, nil):
                color = .red
                prefixKey = NSLocalizedString("callKind[missed].description", comment: "")
                infix = nil
            case (.incoming, let duration?):
                color = .gray
                prefixKey = NSLocalizedString("callKind[incoming].description", comment: "")
                infix = Self.callKindTimeIntervalFormatter.string(from: startDate, to: startDate.addingTimeInterval(duration))?.lowercased()
            case (.outgoing, nil):
                color = .red
                prefixKey = NSLocalizedString("callKind[failed].description", comment: "")
                infix = nil
            case (.outgoing, let duration?):
                color = .gray
                prefixKey = NSLocalizedString("callKind[outgoing].description", comment: "")
                infix = Self.callKindTimeIntervalFormatter.string(from: startDate, to: startDate.addingTimeInterval(duration))?.lowercased()
        }
        let result: String
        if let theInfix = infix {
            result = prefixKey + " - " + theInfix
        } else {
            result = prefixKey
        }
        return result
    }

    private static let callKindTimeIntervalFormatter: DateComponentsFormatter = {
        let result = DateComponentsFormatter()
        result.includesApproximationPhrase = true
        result.maximumUnitCount = 1
        result.unitsStyle = .full
        return result
    }()
}
