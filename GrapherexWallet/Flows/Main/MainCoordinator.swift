//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    //MARK: - Long lived dependencies
    private let apiService: APIService
    
    init(navigationController: UINavigationController, apiService: APIService) {
        self.navigationController = navigationController
        self.apiService = apiService
    }
    
    func start() {
        let presenter = MainPresenterImpl(apiService: apiService)
        let vc = MainViewController(presenter: presenter)
        presenter.view = vc
        navigationController.pushViewController(vc, animated: false)
    }
}
