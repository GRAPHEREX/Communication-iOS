//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

protocol CoinsCoordinator: Coordinator {
    func showCoinDetails(withInfo coinInfo: CoinInfo)
}

class CoinsCoordinatorImpl: CoinsCoordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    //MARK: - Long lived dependencies
    private let apiService: APIService
    
    init(navigationController: UINavigationController, apiService: APIService) {
        self.navigationController = navigationController
        self.apiService = apiService
    }
    
    func start() {
        // TODO: Replace with DI
        let presenter = CoinsPresenterImpl(apiService: apiService)
        let vc = CoinsViewController(presenter: presenter)
        presenter.view = vc
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func showCoinDetails(withInfo coinInfo: CoinInfo)
    {
        // TODO: Replace with DI
        let presenter = CoinDetailsPresenterImpl(apiService: apiService, shownCurrency: coinInfo.currency)
        
        let walletsVCFactory = { () -> WalletsViewController in
            // TODO: Remove self
            let presenter = WalletsPresenterImpl(apiService: self.apiService, shownCurrency: coinInfo.currency)
            let vc = WalletsViewController(presenter: presenter)
            presenter.view = vc
            return vc
        }
        
        let vc = CoinDetailsViewController(presenter: presenter, walletsFactory: walletsVCFactory)
        presenter.view = vc
        
        navigationController.pushViewController(vc, animated: true)
    }
}
