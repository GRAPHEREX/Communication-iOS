//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc public class GrapherexWallet: NSObject {
    //MARK: - Private Properties
    private var coordinator: Coordinator!
    private var apiService: APIService!
    
    private var firstAppStart = true
    
    //MARK: - Public Methods
    /**
        Performs initial wallet module setup
        - Attention: This should be called prior to any other module methods
     */
    /// - Tag: setup
    public func setup(withConfig config: WalletConfig) {
        apiService = APIService(config: config)
        coordinator = CoinsCoordinator(navigationController: RootNavigationController(), apiService: apiService)
        
        if firstAppStart {
            firstAppStart = false
            FontManager.registerCustomFonts()
        }
    }
    
    public func reset() {
        coordinator.start()
        coordinator = nil
        apiService = nil
    }
    
    /**
        Creates initial wallet controller.
        - Attention: This should be called only after [setup(withConfig:)](x-source-tag://setup) is called
     */
    @objc public func createInitialController() -> UINavigationController {
        wltAssertDebug(coordinator != nil)
        wltAssertDebug(apiService != nil)
            
        coordinator.start()
        return coordinator.navigationController
    }
}
