//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

//protocol TransactionsPresenter {
//    func fetchData(completion: (() -> Void)?)
//}
//
//extension TransactionsPresenter {
//    func fetchData() {
//        fetchData(completion: nil)
//    }
//}
//
//class TransactionsPresenterImpl: TransactionsPresenter {
//    // MARK: - Properties
//    var shownCurrencies = [Currency]() {
//        didSet {
//            fetchData()
//        }
//    }
//
//    weak var view: WalletsView!
//    
//    private let apiService: APIService
//
//    // MARK: - Methods
//    init(apiService: APIService) {
//        self.apiService = apiService
//    }
//
//    func fetchData(completion: (() -> Void)?) {
//        apiService.getWallets(shownCurrencies) { [weak self](result) in
//            guard let strong = self else { return }
//            switch result {
//            case .failure(_):
//                strong.view.onWalletsLoaded(wallets: [])
//            case .success(let response):
//                strong.view.onWalletsLoaded(wallets: response.wallets)
//            }
//        }
//    }
//}
