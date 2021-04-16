//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol CoinsPresenter: class {
    var view: CoinsView? { get set }
    func fetchData(completion: (() -> Void)?)
}

extension CoinsPresenter {
    func fetchData() {
        fetchData(completion: nil)
    }
}

class CoinsPresenterImpl: CoinsPresenter {
    
    // MARK: - Properties
    weak var view: CoinsView?
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    // MARK: - CoinsPresenter
    func fetchData(completion: (() -> Void)?) {
        apiService.initWallets { [weak self](result) in
            guard let strong = self else { return }
            switch result {
            case .failure(_):
                strong.view?.onInfoLoaded(info: CoinsInfo.noInfo)
            case .success(let response):
                let wallets = response.0.wallets
                let groupedWallets = Dictionary(grouping: wallets, by: {$0.currency})
                var currencyItems = [CoinInfo]()
                var totalBalance: Double = 0
                var nextBaseCurrency: String = ""
                
                for (nextCurrency, nextWallets) in groupedWallets {
                    let nextBalCurSum = nextWallets.reduce(0, { $0 + $1.balance })
                    let nextFiatCurSum = nextWallets.reduce(0, { $0 + $1.fiatBalance })
                    totalBalance += nextFiatCurSum
                    
                    let nextBalStr = nextBalCurSum.format(f: ".5") + nextCurrency.symbol
                    nextBaseCurrency = nextWallets.first?.fiatCurrency ?? ""
                    let nextCurStr = nextFiatCurSum.format(f: ".0") + nextBaseCurrency
                    
                    //TODO: replace static info when new API is available
                    let priceChangeStr = Int.random(in: 0...1) == 0 ? "1.7%" : "2.1%"
                    let priceChangeDirection: CoinPriceChangeDirection = Int.random(in: 0...1) == 0 ? .positive : .negative
                    let currencyPrice = String(Int.random(in: 5000...9000))
                    
                    let nextCurItem = CoinInfo(
                        currency: nextCurrency,
                        balance: nextBalStr,
                        currencyBalance: nextCurStr,
                        stockPrice: currencyPrice.appendingLeadingCurrencySymbol(forCode: nextBaseCurrency, divider: ""),
                        priceChange: priceChangeStr,
                        priceChangeType: priceChangeDirection,
                        wallets: nextWallets)
                    currencyItems.append(nextCurItem)
                }
                
                //TODO: replace static info when new API is available
                let info = CoinsInfo(
                    totalBalance: totalBalance.format(f: ".2").appendingLeadingCurrencySymbol(forCode: nextBaseCurrency),
                    marketCap: "1.6 T".appendingLeadingCurrencySymbol(forCode: nextBaseCurrency),
                    volumeTrade: "700m".appendingLeadingCurrencySymbol(forCode: nextBaseCurrency),
                    btcDominance: "65%",
                    spendValue: "25.3k".appendingLeadingCurrencySymbol(forCode: nextBaseCurrency),
                    incomeValue: "100,00".appendingLeadingCurrencySymbol(forCode: nextBaseCurrency),
                    spendIncomeProportion: 0.75,
                    items: currencyItems)
                strong.view?.onInfoLoaded(info: info)
            }
            completion?()
        }
    }
}

