//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

enum MessagePushType {
    case none
    case push
    case voipAudio
    case voipVideo
    
    var typeForQuery: String {
        switch self {
        case .none:
            return "NONE"
        case .push:
            return "PUSH"
        case .voipAudio:
            return "VOIP_SOUND"
        case .voipVideo:
            return "VOIP_VIDEO"
        }
    }
}
