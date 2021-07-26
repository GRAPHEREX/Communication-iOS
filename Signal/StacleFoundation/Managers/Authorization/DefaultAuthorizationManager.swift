import Combine
import KeychainAccess

// MARK: - DefaultAuthorizationManager

public typealias AuthCallback = (UserCredentials) -> Void

final class DefaultAuthorizationManager: CredentialsProvider {

    private enum Const {
        enum Keychain {
            static let serviceId = "GrapherixKit.Authorization.DefaultAuthorizationManager"
            static let refreshTokenKey = "Stacle.refreshToken"
            static let userNameKey = "Stacle.userName"
        }
    }

    // MARK: Protocol: AuthorizationManager
    let getSessionTokenOutput: AnyPublisher<Communication.GetSessionToken.Output, Never>
    let signUpOutput: AnyPublisher<Communication.SignUp.Output, Never>
    let state: AnyPublisher<AuthorizationManagerState, Never>

    // MARK: Protocol: CredentialsProvider
    let credentials: CurrentValuePublisher<UserCredentials?, Never>
    
    // MARK: Private properties
    private let _getSessionTokenOutput = PassthroughSubject<Communication.GetSessionToken.Output, Never>()
    private let _signUpOutput = PassthroughSubject<Communication.SignUp.Output, Never>()

    private let _credentials = CurrentValueSubject<UserCredentials?, Never>(nil)

    private let networkService: NetworkService
    private let keychain: Keychain
    private var cancellableSet: Set<AnyCancellable> = []

    private var userAuthModel = UserAuthModel.empty

    private let authCallback: AuthCallback
    
    // MARK: Lifecycle
    init(networkService: NetworkService,
         signUpCallback: @escaping AuthCallback) {
        self.getSessionTokenOutput = _getSessionTokenOutput.eraseToAnyPublisher()
        self.signUpOutput = _signUpOutput.eraseToAnyPublisher()

        self.credentials = _credentials.asPublisher()
        self.state = _credentials
            .dropFirst() // Do not publish initial value of CurrentValueSubject
            .map { $0 == nil ? .notAuthorized : .authorized }
            .eraseToAnyPublisher()

        self.networkService = networkService
        self.authCallback = signUpCallback
        self.keychain = Keychain(service: Const.Keychain.serviceId)
    }
}

// MARK: - AuthorizationManager

extension DefaultAuthorizationManager: AuthorizationManager {
    
    func invokeAuthCallback(withCredentials credentials: UserCredentials) {
        DispatchQueue.main.async { [weak self] in
            self?.authCallback(credentials)
        }
    }
    
    func getSessionToken(_ input: AnyPublisher<Communication.GetSessionToken.Input, Never>?) {

        // When automatic login is unavailable, wait for external auth information
        input?.sink { [weak self] (input: Communication.GetSessionToken.Input) in
            guard let strongSelf = self else { return }

            switch input {
            case let .auth(userName, password):
                strongSelf.signInWith(userName: userName, password: password)
            }
        }.store(in: &self.cancellableSet)
        
        // Already logged in - early exit
        if let credentials = _credentials.value {
            _credentials.send(credentials)
            _getSessionTokenOutput.send(.auth(.success(())))
            return
        }

        // Try to login with userName and refreshToken first
        if let refreshToken = keychain[Const.Keychain.refreshTokenKey] {
            self.performTokenRefresh(refreshToken)
            return
        }

        self._credentials.send(nil)
        self._getSessionTokenOutput.send(.unableToLoginAutomatically)
    }

    func signUp(_ input: AnyPublisher<Communication.SignUp.Input, Never>) {
        signUpOrSetPasswordFlow(input, isSignUp: true, userNameHandler: { [weak self] userName in
            guard let strongSelf = self else { return }
            strongSelf.userAuthModel.userName = userName
            strongSelf._signUpOutput.send(
                .userName(.success(()))
            )
        })
    }
    
//    func setPassword(_ input: AnyPublisher<Communication.SignUp.Input, Never>) {
//        signUpOrSetPasswordFlow(input, isSignUp: false, userNameHandler: { [weak self] userName in
//            guard let strongSelf = self else { return }
//            strongSelf.sendVerificationCodeTo(userName: userName)
//        })
//    }
    
    private func signUpOrSetPasswordFlow(_ input: AnyPublisher<Communication.SignUp.Input, Never>, isSignUp: Bool, userNameHandler: @escaping (String) -> Void) {
        input.sink { [weak self] (input: Communication.SignUp.Input) in
            guard let strongSelf = self else { return }

            switch input {
            case .userName(let userName):
                userNameHandler(userName)
                
            case .verificationCode(let verificationCode):
                guard let userName = strongSelf.userAuthModel.userName else {
                    strongSelf._signUpOutput.send(.verificationCode(.failure(.noUserId)))
                    return
                }
                strongSelf.verify(code: verificationCode, forUser: userName)

            case .password(let password):
                guard let verificationCode = strongSelf.userAuthModel.verificationCode else {
                    strongSelf._signUpOutput.send(.password(.failure(.noVerificationCode)))
                    return
                }
                strongSelf.setNew(password: password,
                                  verificationCode: verificationCode,
                                  isSignUp: isSignUp)
            }

        }.store(in: &self.cancellableSet)
    }

    func logout(_ completion: @escaping () -> Void) {
        try? keychain.remove(Const.Keychain.refreshTokenKey)
        try? keychain.remove(Const.Keychain.userNameKey)
        _credentials.send(nil)
        completion()
    }
}

// MARK: - Topic GetToken

private extension DefaultAuthorizationManager {
    private func signInWith(userName: String, password: String) {
        let operation = GetAccessTokenOperation.self
        let request = operation.Request(userName: userName, password: password)
        let httpTransport = networkService.httpTransport(
            coder: operation.init(),
            request: request, completion: { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                case .success(let response):
                    let userName = request.userName
                    let sessionToken = response.accessToken
                    let refreshToken = response.refreshToken
                    let expirationDate = Date().addingTimeInterval(response.expiresIn)
                    strongSelf.keychain[Const.Keychain.userNameKey] = userName
                    strongSelf.keychain[Const.Keychain.refreshTokenKey] = refreshToken
                    let creds = UserCredentials(userId: userName, sessionToken: sessionToken, refreshToken: refreshToken, expirationDate: expirationDate)
                    strongSelf.invokeAuthCallback(withCredentials: creds)
                    strongSelf._credentials.send(creds)
                    strongSelf._getSessionTokenOutput.send(.auth(.success(())))
                    
                case .failure:
                    self?._credentials.send(nil)
                    self?._getSessionTokenOutput.send(.auth(.failure(.unknown)))
                }
        })
        httpTransport.isRunning = true
    }
}

// MARK: - Refresh Token

extension DefaultAuthorizationManager {
    func performTokenRefresh(_ refreshToken: String, completion: ((UserCredentials?) -> Void)? = nil) {
        let operation = RefreshAccessTokenOperation.self
        let request = operation.Request(refreshToken: refreshToken)
        let httpTransport = networkService.httpTransport(
            coder: operation.init(),
            request: request,
            completion: { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                case .success(let response):
                    let sessionToken = response.accessToken
                    let refreshToken = response.refreshToken
                    let expirationDate = Date().addingTimeInterval(response.expiresIn)
                    strongSelf.keychain[Const.Keychain.refreshTokenKey] = refreshToken
                    let userName = strongSelf.keychain[Const.Keychain.userNameKey] ?? ""
                    let credentials = UserCredentials(userId: userName, sessionToken: sessionToken, refreshToken: refreshToken, expirationDate: expirationDate)
                    strongSelf._credentials.send(credentials)
                    strongSelf._getSessionTokenOutput.send(.auth(.success(())))
                    strongSelf.invokeAuthCallback(withCredentials: credentials)
                    completion?(credentials)
                case .failure(_):
                    strongSelf.keychain[Const.Keychain.userNameKey] = nil
                    strongSelf.keychain[Const.Keychain.refreshTokenKey] = nil

                    // TODO: Handle error internally
                    strongSelf._credentials.send(nil)
                    strongSelf._getSessionTokenOutput.send(.unableToLoginAutomatically)
                    
                    completion?(nil)
                }
        })
        httpTransport.isRunning = true
    }
}

// MARK: - Topic: SetPassword

private extension DefaultAuthorizationManager {

    /// Holds data needed for `signUp` and `setPassword` sequence
    struct UserAuthModel {
        var userName: String?
        var verificationCode: String?

        static var empty: UserAuthModel = {
            return UserAuthModel(userName: nil, verificationCode: nil)
        }()
    }

//    private func sendVerificationCodeTo(userName: String) {
//
//        let operation = StacleService.Operation.DispatchVerificationCode.self
//        let request = operation.Request(userName: userName)
//        let httpTransport = self.stacleService.httpTransport(coder: operation.init(), request: request) { [weak self] result in
//            guard let strongSelf = self else { return }
//
//            switch result {
//                case .success(_):
//                    strongSelf.userAuthModel.userName = userName
//                    strongSelf._signUpOutput.send(
//                        .userName(.success(()))
//                    )
//
//                case .failure:
//                    strongSelf._signUpOutput.send(.userName(.failure(.unknown)))
//            }
//        }
//        httpTransport.isRunning = true
//    }
//
    private func verify(code: String, forUser userName: String) {
        let operation = VerifyCodeOperation.self
        let request = operation.Request.init(userName: userName, verificationCode: code)
        let httpTransport = networkService.httpTransport(
            coder: operation.init(),
            request: request,
            completion: { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                case .success(let response):
                    strongSelf.userAuthModel.verificationCode = response.accessToken
                    strongSelf._signUpOutput.send(.verificationCode(.success(())))

                case .failure:
                    strongSelf._signUpOutput.send(.verificationCode(.failure(.unknown)))
                }
        })
        httpTransport.isRunning = true
    }

    private func setNew(password: String,
                        verificationCode: String,
                        isSignUp: Bool) {

        guard isSignUp else { return }
        
        let operation = SetPasswordOperation.self
        let request = operation.Request(password: password, verificationToken: verificationCode)
        let httpTransport = networkService.httpTransport(
            coder: operation.init(),
            request: request,
            completion: { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                case .success(let response):
                    guard let userName = strongSelf.userAuthModel.userName else {
                        strongSelf._signUpOutput.send(.password(.failure(.noUserId)))
                        return
                    }

                    let sessionToken = response.accessToken
                    let refreshToken = response.refreshToken
                    let expirationDate = Date().addingTimeInterval(response.expiresIn)
                    strongSelf.keychain[Const.Keychain.userNameKey] = userName
                    strongSelf.keychain[Const.Keychain.refreshTokenKey] = refreshToken
                    let creds = UserCredentials(userId: userName, sessionToken: sessionToken, refreshToken: refreshToken, expirationDate: expirationDate)
                    strongSelf.invokeAuthCallback(withCredentials: creds)
                    strongSelf._credentials.send(creds)
                    strongSelf.userAuthModel = .empty

                    strongSelf._signUpOutput.send(.password(.success(())))

                case .failure:
                    strongSelf._signUpOutput.send(.password(.failure(.unknown)))
                }
        })
        httpTransport.isRunning = true
    }
}
