//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol MainPresenter: class {
    func fetchData(completion: (() -> Void)?)
}

extension MainPresenter {
    func fetchData() {
        fetchData(completion: nil)
    }
}

class MainPresenterImpl: MainPresenter {
    
    // MARK: - Properties
    weak var view: MainView?
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    // MARK: - MainPresenter
    func fetchData(completion: (() -> Void)?) {
        apiService.initWallets { [weak self](result) in
            guard let strong = self else { return }
            switch result {
            case .failure(_):
                strong.view?.onInfoLoaded(info: WalletsInfo.noInfo)
            case .success(let response):
                let wallets = response.0.wallets
                let groupedWallets = Dictionary(grouping: wallets, by: {$0.currency})
                var currencyItems = [WalletCurrencyItem]()
                var totalBalance: Double = 0
                var nextBaseCurrency: String = ""
                
                for (nextCurrency, nextWallets) in groupedWallets {
                    let nextBalCurSum = nextWallets.reduce(0, { $0 + $1.balance })
                    let nextFiatCurSum = nextWallets.reduce(0, { $0 + $1.fiatBalance })
                    totalBalance += nextFiatCurSum
                    
                    let nextBalStr = nextBalCurSum.format(f: ".5") + nextCurrency.symbol
                    nextBaseCurrency = nextWallets.first?.fiatCurrency ?? ""
                    let nextCurStr = nextFiatCurSum.format(f: ".0") + nextBaseCurrency
                    
                    let nextCurItem = WalletCurrencyItem(coinTitle: nextCurrency.symbol,
                                                         currency: nextCurrency,
                                                         currencyIcon: nextCurrency.icon,
                                                         balance: nextBalStr,
                                                         currencyBalance: nextCurStr,
                                                         stockPrice: "9000USD",
                                                         wallets: nextWallets)
                    currencyItems.append(nextCurItem)
                }
                
                //TODO: replace static info when new API is available
                let info = WalletsInfo(totalBalance: String.getSymbolForCurrencyCode(code: nextBaseCurrency) + totalBalance.format(f: ".2"),
                                       marketCap: "1.6 T USD",
                                       volumeTrade: "700m USD",
                                       btcDominance: "65%",
                                       items: currencyItems)
                strong.view?.onInfoLoaded(info: info)
            }
            completion?()
        }
    }
}

