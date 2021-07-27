import Combine


// MARK: - AuthorizationManager

public protocol AuthorizationManager: CredentialsProvider {
    typealias Communication = AuthorizationManagerCommunication

    var state: AnyPublisher<AuthorizationManagerState, Never> { get }

    // TODO: Replace `PassthroughPublisher` with `associatedtype: Publisher`
    var getSessionTokenOutput: AnyPublisher<Communication.GetSessionToken.Output, Never> { get }
    var signUpOutput: AnyPublisher<Communication.SignUp.Output, Never> { get }

    /// Start `getSessionToken` sequence at the end of which user is logged in automatically or through manual sign in
    func getSessionToken(_ input: AnyPublisher<Communication.GetSessionToken.Input, Never>?)
    /// Start `signUp` sequence at the end of which user is registered and logged in
    /// Manager  waits input data in this succession: userName > verificationCode > password
    func signUp(_ input: AnyPublisher<Communication.SignUp.Input, Never>)
    /// Start `setPassword` sequence at the end of which user is registered and logged in
    /// Manager  waits input data in this succession: userName > verificationCode > password
//    func setPassword(_ input: AnyPublisher<Communication.SignUp.Input, Never>)

    func logout(_ completion: @escaping () -> Void)
    
    func performTokenRefresh(_ refreshToken: String, completion: ((UserCredentials?) -> Void)?)
}

// MARK: - AuthorizationManagerState

public enum AuthorizationManagerState {
    case authorized
    case notAuthorized
}

// MARK: - CredentialsProvider
public struct UserCredentials {
    public let userId: String
    public let sessionToken: String
    public let refreshToken: String
    public let expirationDate: Date
}
public protocol CredentialsProvider {
    var credentials: CurrentValuePublisher<UserCredentials?, Never> { get }
}


// MARK: - Communication

public enum AuthorizationManagerCommunication {

    public enum GetSessionToken {
        public enum Input {
            case auth(userName: String, password: String)
        }
        public enum Output {
            case unableToLoginAutomatically
            case auth(Result<Void, AuthorizationError>)
        }
    }

    public enum SignUp {
        public enum Input {
            case userName(String)
            case verificationCode(String)
            case password(String)
        }
        public enum Output {
            case userName(Result<Void, AuthorizationError>)
            case verificationCode(Result<Void, AuthorizationError>)
            case password(Result<Void, AuthorizationError>)
        }
    }
}
