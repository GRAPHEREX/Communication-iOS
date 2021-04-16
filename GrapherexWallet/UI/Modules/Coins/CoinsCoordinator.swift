//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

class CoinsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    //MARK: - Long lived dependencies
    private let apiService: APIService
    
    init(navigationController: UINavigationController, apiService: APIService) {
        self.navigationController = navigationController
        self.apiService = apiService
    }
    
    func start() {
        let presenter = CoinsPresenterImpl(apiService: apiService)
        let vc = CoinsViewController(presenter: presenter)
        presenter.view = vc
        navigationController.setViewControllers([vc], animated: true)
    }
}
