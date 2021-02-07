import Foundation

public struct PersonName: Equatable {
    private init(components: Components) {
        self.components = components
    }

    private let components: Components
}

extension PersonName {

    public init(
        namePrefix: String? = nil,
        givenName: String? = nil,
        middleName: String? = nil,
        familyName: String? = nil,
        nameSuffix: String? = nil,
        nickname: String? = nil,
        phoneticNamePrefix: String? = nil,
        phoneticGivenName: String? = nil,
        phoneticMiddleName: String? = nil,
        phoneticFamilyName: String? = nil,
        phoneticNameSuffix: String? = nil,
        phoneticNickname: String? = nil
    ) {
        var components = Components()
        components.namePrefix = namePrefix
        components.givenName = givenName
        components.middleName = middleName
        components.familyName = familyName
        components.nameSuffix = nameSuffix
        components.nickname = nickname
        var phoneticComponents = Components()
        phoneticComponents.namePrefix = phoneticNamePrefix
        phoneticComponents.givenName = phoneticGivenName
        phoneticComponents.middleName = phoneticMiddleName
        phoneticComponents.familyName = phoneticFamilyName
        phoneticComponents.nameSuffix = phoneticNameSuffix
        phoneticComponents.nickname = phoneticNickname
        components.phoneticRepresentation = phoneticComponents
        self.init(components: components)
    }

    ///
    public var namePrefix: String? {
        components.namePrefix
    }

    ///
    public var givenName: String? {
        components.givenName
    }

    ///
    public var middleName: String? {
        components.middleName
    }

    ///
    public var familyName: String? {
        components.familyName
    }

    ///
    public var nameSuffix: String? {
        components.nameSuffix
    }

    ///
    public var nickname: String? {
        components.nickname
    }

    ///
    public var phoneticNamePrefix: String? {
        components.namePrefix
    }

    ///
    public var phoneticGivenName: String? {
        components.givenName
    }

    ///
    public var phoneticMiddleName: String? {
        components.middleName
    }

    ///
    public var phoneticFamilyName: String? {
        components.familyName
    }

    ///
    public var phoneticNameSuffix: String? {
        components.nameSuffix
    }

    ///
    public var phoneticNickname: String? {
        components.nickname
    }

    ///
    public var abbreviation: String {
        Self.abbreviationFormatter.string(from: components)
    }

    private typealias Formatter = PersonNameComponentsFormatter
    private typealias Components = PersonNameComponents

    private static let descriptionFormatter: Formatter = {
        let formatter: Formatter
        formatter = .init()
        formatter.isPhonetic = false
        formatter.style = .long
        return formatter
    }()

    private static let abbreviationFormatter: Formatter = {
           let formatter: Formatter
           formatter = .init()
           formatter.isPhonetic = false
           formatter.style = .abbreviated
           return formatter
       }()
}
