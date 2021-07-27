//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import KeychainAccess

public struct Device {

    // MARK: Confidential

    private let keychain: Keychain
    private let keychainDeviceIdKey = "deviceId"
    private init() {
        self.keychain = Keychain(service: "StacleKit.Device")
    }
}

extension Device {

    // MARK: Essential

    public static let current: Device = Device()

    public var id: String {
        let id: String
        if let existing = self.keychain[keychainDeviceIdKey] {
            id = existing
        } else {
            id = "IOS \(UUID())"
            self.keychain[keychainDeviceIdKey] = id
        }
        return id
    }
    
    public func removeId() {
        do {
            try keychain.remove(keychainDeviceIdKey)
        }
        catch {
            print("Failed to erase device ID")
        }
    }
}
