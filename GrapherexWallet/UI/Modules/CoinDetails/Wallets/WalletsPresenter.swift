//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol WalletsPresenter {
    func fetchData(completion: (() -> Void)?)
}

extension WalletsPresenter {
    func fetchData() {
        fetchData(completion: nil)
    }
}

class WalletsPresenterImpl: WalletsPresenter {
    // MARK: - Properties
    weak var view: WalletsView!
    
    private let apiService: APIService
    private let shownCurrency: Currency
    
    // MARK: - Methods
    init(apiService: APIService, shownCurrency: Currency) {
        self.apiService = apiService
        self.shownCurrency = shownCurrency
    }
    
    func fetchData(completion: (() -> Void)?) {
        apiService.getWallets([shownCurrency]) { [weak self](result) in
            guard let strong = self else { return }
            switch result {
            case .failure(_):
                strong.view.onWalletsLoaded(walletsInfo: [])
            case .success(let response):
                let walletInfos = response.wallets.compactMap({ WalletInfo(coinName: $0.currency.symbol,
                                                                           coinIcon: $0.currency.icon,
                                                                           balance: $0.balanceStr + $0.currency.symbol,
                                                                           currencyBalance: $0.fiatBalanceStr.appendingLeadingCurrencySymbol(forCode: $0.fiatCurrency)) })
                strong.view.onWalletsLoaded(walletsInfo: walletInfos)
            }
        }
    }
}
