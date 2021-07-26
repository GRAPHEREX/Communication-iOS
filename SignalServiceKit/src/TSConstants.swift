//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

private protocol TSConstantsProtocol: class {
    var textSecureWebSocketAPI: String { get }
    var textSecureServerURL: String { get }
    var walletServerURL: String { get }
    var walletSocketServerURL: String { get }
    var textSecureCDN0ServerURL: String { get }
    var textSecureCDN2ServerURL: String { get }
    var contactDiscoveryURL: String { get }
    var keyBackupURL: String { get }
    var storageServiceURL: String { get }
    var sfuURL: String { get }
    var kUDTrustRoot: String { get }

    var censorshipReflectorHost: String { get }

    var serviceCensorshipPrefix: String { get }
    var cdn0CensorshipPrefix: String { get }
    var cdn2CensorshipPrefix: String { get }
    var contactDiscoveryCensorshipPrefix: String { get }
    var keyBackupCensorshipPrefix: String { get }
    var storageServiceCensorshipPrefix: String { get }

    var contactDiscoveryEnclaveName: String { get }
    var contactDiscoveryMrEnclave: String { get }

    var keyBackupEnclave: KeyBackupEnclave { get }
    var keyBackupPreviousEnclaves: [KeyBackupEnclave] { get }

    var applicationGroup: String { get }

    var serverPublicParamsBase64: String { get }
    
    var sslPinningCertNames: [String] { get }
    
    var appsFlyerDevKey: String { get }
    var appsFlyerAppId: String { get }
}

public struct KeyBackupEnclave: Equatable {
    let name: String
    let mrenclave: String
    let serviceId: String
}

// MARK: -

@objc
public class TSConstants: NSObject {

    @objc
    public static let EnvironmentDidChange = Notification.Name("EnvironmentDidChange")

    // Never instantiate this class.
    private override init() {}

    @objc
    public static var textSecureWebSocketAPI: String { return shared.textSecureWebSocketAPI }
    @objc
    public static var textSecureServerURL: String { return shared.textSecureServerURL }
    @objc
    public static var walletServerURL: String { return shared.walletServerURL }
    @objc
    public static var walletSocketServerURL: String { return shared.walletSocketServerURL }
    @objc
    public static var textSecureCDN0ServerURL: String { return shared.textSecureCDN0ServerURL }
    @objc
    public static var textSecureCDN2ServerURL: String { return shared.textSecureCDN2ServerURL }
    @objc
    public static var contactDiscoveryURL: String { return shared.contactDiscoveryURL }
    @objc
    public static var keyBackupURL: String { return shared.keyBackupURL }
    @objc
    public static var storageServiceURL: String { return shared.storageServiceURL }
    @objc
    public static var sfuURL: String { return shared.sfuURL }
    @objc
    public static var kUDTrustRoot: String { return shared.kUDTrustRoot }

    @objc
    public static var censorshipReflectorHost: String { return shared.censorshipReflectorHost }

    @objc
    public static var serviceCensorshipPrefix: String { return shared.serviceCensorshipPrefix }
    @objc
    public static var cdn0CensorshipPrefix: String { return shared.cdn0CensorshipPrefix }
    @objc
    public static var cdn2CensorshipPrefix: String { return shared.cdn2CensorshipPrefix }
    @objc
    public static var contactDiscoveryCensorshipPrefix: String { return shared.contactDiscoveryCensorshipPrefix }
    @objc
    public static var keyBackupCensorshipPrefix: String { return shared.keyBackupCensorshipPrefix }
    @objc
    public static var storageServiceCensorshipPrefix: String { return shared.storageServiceCensorshipPrefix }

    @objc
    public static var contactDiscoveryEnclaveName: String { return shared.contactDiscoveryEnclaveName }
    @objc
    public static var contactDiscoveryMrEnclave: String { return shared.contactDiscoveryMrEnclave }

    static var keyBackupEnclave: KeyBackupEnclave { shared.keyBackupEnclave }
    static var keyBackupPreviousEnclaves: [KeyBackupEnclave] { shared.keyBackupPreviousEnclaves }

    @objc
    public static var applicationGroup: String { return shared.applicationGroup }

    @objc
    public static var serverPublicParamsBase64: String { return shared.serverPublicParamsBase64 }
    
    @objc
    public static var appsFlyerDevKey: String { return shared.appsFlyerDevKey }
    
    @objc
    public static var appsFlyerAppId: String { return shared.appsFlyerAppId }

    @objc
    public static var isUsingProductionService: Bool {
        return environment == .production
    }

    private enum Environment {
        case production, staging
    }

    private static let serialQueue = DispatchQueue(label: "TSConstants")
    private static var _forceEnvironment: Environment?
    private static var forceEnvironment: Environment? {
        get {
            return serialQueue.sync {
                return _forceEnvironment
            }
        }
        set {
            serialQueue.sync {
                _forceEnvironment = newValue
            }
        }
    }

    private static var environment: Environment {
        if let environment = forceEnvironment {
            return environment
        }
        return FeatureFlags.isUsingProductionService ? .production : .staging
    }

    @objc
    public class func forceStaging() {
        forceEnvironment = .staging
    }

    @objc
    public class func forceProduction() {
        forceEnvironment = .production
    }

    private static var shared: TSConstantsProtocol {
        switch environment {
        case .production:
            return TSConstantsProduction()
        case .staging:
            return TSConstantsStaging()
        }
    }
    
    @objc
    public static var sslPinningCertNames: [String] { return shared.sslPinningCertNames }
}

// MARK: -

private class TSConstantsProduction: TSConstantsProtocol {

    public let textSecureWebSocketAPI = "wss://api.grapherex.com/v1/websocket/"
    public let textSecureServerURL = "https://api.grapherex.com/"
    public let walletServerURL = "https://wcs.grapherex.com/"
    public let walletSocketServerURL = "wss://wcs.grapherex.com/api/crypto-backend/v2/ws"
    public let textSecureCDN0ServerURL = "https://cdn.grapherex.com"
    public let textSecureCDN2ServerURL = "https://cdn.grapherex.com"
    public let contactDiscoveryURL = "https://directory.grapherex.com"
    public let keyBackupURL = "https://backup.grapherex.com"
    public let storageServiceURL = "https://storage.grapherex.com"
    public let sfuURL = "https://sfu.voip.signal.org"
    public let kUDTrustRoot = "BX/Mjk0HarJmhgYrNuAbK5MkcWhq+Syv3cRVLlO2XbVI"

    public let censorshipReflectorHost = "europe-west1-signal-cdn-reflector.cloudfunctions.net"

    public let serviceCensorshipPrefix = "service"
    public let cdn0CensorshipPrefix = "cdn"
    public let cdn2CensorshipPrefix = "cdn"
    public let contactDiscoveryCensorshipPrefix = "directory"
    public let keyBackupCensorshipPrefix = "backup"
    public let storageServiceCensorshipPrefix = "storage"

    public let contactDiscoveryEnclaveName = "c98e00a4e3ff977a56afefe7362a27e4961e4f19e211febfbb19b897e6b80b15"
    public var contactDiscoveryMrEnclave: String {
        return contactDiscoveryEnclaveName
    }

    public let keyBackupEnclave = KeyBackupEnclave(
        name: "fe7c1bfae98f9b073d220366ea31163ee82f6d04bead774f71ca8e5c40847bfe",
        mrenclave: "a3baab19ef6ce6f34ab9ebb25ba722725ae44a8872dc0ff08ad6d83a9489de87",
        serviceId: "fe7c1bfae98f9b073d220366ea31163ee82f6d04bead774f71ca8e5c40847bfe"
    )

    // An array of previously used enclaves that we should try and restore
    // key material from during registration. These must be ordered from
    // newest to oldest, so we check the latest enclaves for backups before
    // checking earlier enclaves.
    public let keyBackupPreviousEnclaves = [KeyBackupEnclave]()

    public let applicationGroup = "group.app.grapherex"

    // We need to discard all profile key credentials if these values ever change.
    // See: GroupsV2Impl.verifyServerPublicParams(...)
    public let serverPublicParamsBase64 = "AJ5s6oYLJTKMeGXCIZB52Vh3+aTvM/ulexj2X0OM3uM1Sg0QbMOfWLnGiQwzZEBOXHyjIAOWtfqWkJE8kysABwHe8ODl0xul0NnsQjpTxG6S4RpiRk5STFHPHtRJ/I9UIh7I36P/D3FzqoiUCaU1BkpAhTS05VeXJTwyTWPn2Eh6sE0Fkw12/dKZTBm0ImTiUTs9bd1P0LZjacfmM4kZZi4=="
    
    public let sslPinningCertNames = ["grapherex_prod_2020", "grapherex_prod_2021"]
    
    public let appsFlyerDevKey: String = "rhC4t7R59SLbh8cdAmfSDZ"
    public let appsFlyerAppId: String = "1542360019"
}

// MARK: -

private class TSConstantsStaging: TSConstantsProtocol {

    public let textSecureWebSocketAPI = "wss://api.grapherextests.com/v1/websocket/"
    public let textSecureServerURL = "https://api.grapherextests.com/"
    public let walletServerURL = "https://crypto.grapherextests.com/"
    public let walletSocketServerURL = "wss://crypto.grapherextests.com/api/crypto-backend/v2/ws"
    public let textSecureCDN0ServerURL = "https://cdn.grapherextests.com"
    public let textSecureCDN2ServerURL = "https://cdn.grapherextests.com"
    public let contactDiscoveryURL = "https://directory.grapherex.com"
    public let keyBackupURL = "https://backup.grapherex.com"
    public let storageServiceURL = "https://storage.grapherex.com"
    public let sfuURL = "https://sfu.voip.signal.org"
    public let kUDTrustRoot = "BTdIuRPrgRf3GnJXgjjqddSrLng6VkZTZNDR7qXjmrlz"

    public let censorshipReflectorHost = "europe-west1-signal-cdn-reflector.cloudfunctions.net"

    public let serviceCensorshipPrefix = "service"
    public let cdn0CensorshipPrefix = "cdn"
    public let cdn2CensorshipPrefix = "cdn"
    public let contactDiscoveryCensorshipPrefix = "directory"
    public let keyBackupCensorshipPrefix = "backup"
    public let storageServiceCensorshipPrefix = "storage"

    public let contactDiscoveryEnclaveName = "cd6cfc342937b23b1bdd3bbf9721aa5615ac9ff50a75c5527d441cd3276826c9"
    public var contactDiscoveryMrEnclave: String {
        return contactDiscoveryEnclaveName
    }

    public let keyBackupEnclave = KeyBackupEnclave(
        name: "fe7c1bfae98f9b073d220366ea31163ee82f6d04bead774f71ca8e5c40847bfe",
        mrenclave: "a3baab19ef6ce6f34ab9ebb25ba722725ae44a8872dc0ff08ad6d83a9489de87",
        serviceId: "fe7c1bfae98f9b073d220366ea31163ee82f6d04bead774f71ca8e5c40847bfe"
    )

    // An array of previously used enclaves that we should try and restore
    // key material from during registration. These must be ordered from
    // newest to oldest, so we check the latest enclaves for backups before
    // checking earlier enclaves.
    public let keyBackupPreviousEnclaves = [KeyBackupEnclave]()

    public let applicationGroup = "group.app.grapherex"

    // We need to discard all profile key credentials if these values ever change.
    // See: GroupsV2Impl.verifyServerPublicParams(...)
    public let serverPublicParamsBase64 = "ALRbOPkWOmalFte5ILZa4zeCyxE0e3IlPpKOWPgR3dMrRLeXssRKNsvUg/m+IugL1skJqi8WPQE9Nfk8ujsSWDOcSn5+444FYgHJ7ofg7P4QRDPkEtC0fsSGlyCfnus2Unp+qDmfd4lHTBBmpXdl4gSMpwS8cXGfwII6iY7JObE+tuVY5R4MeH0IHRw5DYiH9t1EZs9oNeqk7EEN2bM5InU=="
    
    public let sslPinningCertNames = ["grapherex_dev_2020", "grapherex_dev_2021"]
    
    public let appsFlyerDevKey: String = "rhC4t7R59SLbh8cdAmfSDZ"
    public let appsFlyerAppId: String = "1542360019"
}
