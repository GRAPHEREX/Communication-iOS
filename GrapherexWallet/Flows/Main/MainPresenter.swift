//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol MainPresenter: class {
    func fetchData()
}

class MainPresenterImpl: MainPresenter {
    
    // MARK: - Properties
    weak var view: MainView?
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    // MARK: - MainPresenter
    func fetchData() {
        apiService.initWallets { [weak self](result) in
            guard let strong = self else { return }
            switch result {
            case .failure(_):
                strong.view?.onItemsRetrieval(items: [])
            case .success(let response):
                let wallets = response.0.wallets
                let groupedWallets = Dictionary(grouping: wallets, by: {$0.currency})
                var currencyItems = [WalletCurrencyItem]()
                for (nextCurrency, nextWallets) in groupedWallets {
                    let nextBalCurSum = nextWallets.reduce(0, { $0 + $1.balance })
                    let nextFiatCurSum = nextWallets.reduce(0, { $0 + $1.fiatBalance })
                    let nextBalStr = String(nextBalCurSum) + nextCurrency.symbol
                    let nextBaseCurrency = nextWallets.first?.fiatCurrency ?? ""
                    let nextCurStr = String(nextFiatCurSum) + nextBaseCurrency
                    let nextCurItem = WalletCurrencyItem(coinTitle: nextCurrency.symbol,
                                                         currency: nextCurrency,
                                                         currencyIcon: nextCurrency.icon,
                                                         balance: nextBalStr,
                                                         currencyBalance: nextCurStr,
                                                         stockPrice: "9000USD",
                                                         wallets: nextWallets)
                    currencyItems.append(nextCurItem)
                }
                
                strong.view?.onItemsRetrieval(items: currencyItems)
            }
        }
    }
}

