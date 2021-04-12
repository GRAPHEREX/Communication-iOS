//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc public class GrapherexWalletService: NSObject {
    //MARK: - Public Properties
    public static let shared = GrapherexWalletService()
    //MARK: - Private Properties
    private var coordinator: MainCoordinator!
    private var apiService: APIService!
    
    //MARK: - Public Methods
    public func start(withConfig config: WalletConfig) {
        apiService = APIService(config: config)
        coordinator = MainCoordinator(navigationController: UINavigationController(), apiService: apiService)
    }
    
    public func reset() {
        //TODO:
    }
    
    @objc public func createWalletController() -> UINavigationController {
        coordinator.start()
        return coordinator.navigationController
    }
    
    //MARK: - Private Methods
    private override init() {}
}
