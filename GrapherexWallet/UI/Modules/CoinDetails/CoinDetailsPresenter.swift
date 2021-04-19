//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol CoinDetailsPresenter {
    func fetchData(completion: (() -> Void)?)
}

extension CoinDetailsPresenter {
    func fetchData() {
        fetchData(completion: nil)
    }
}

class CoinDetailsPresenterImpl: CoinDetailsPresenter {
    // MARK: - Properties
    weak var view: CoinDetailsView!
    
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
                strong.view.onInfoLoaded(info: nil)
            case .success(let response):
                let fiatBalance = response.fiatTotalBalance.appendingLeadingCurrencySymbol(forCode: response.fiatCurrency)
                let coinBalance = response.wallets.totalCoinBalance().format(f: ".5") + strong.shownCurrency.symbol
                let walletsInfo = response.wallets.compactMap({ WalletInfo(coinName: $0.currency.symbol, coinIcon: $0.currency.icon, balance: $0.balance.format(f: ".5") + $0.currency.symbol, currencyBalance: $0.fiatBalance.format(f: ".2").appendingLeadingCurrencySymbol(forCode: $0.currency.symbol)) })
                let info = CoinWalletsInfo(coinName: strong.shownCurrency.symbol,
                                           coinIcon: strong.shownCurrency.icon,
                                           totalBalance: coinBalance,
                                           totalCurrencyBalance: fiatBalance,
                                           marketCap: "1.6 T".appendingLeadingCurrencySymbol(forCode: response.fiatCurrency),
                                           volumeTrade: "700m".appendingLeadingCurrencySymbol(forCode: response.fiatCurrency),
                                           price: "9000".appendingLeadingCurrencySymbol(forCode: response.fiatCurrency),
                                           wallets: walletsInfo)
                strong.view.onInfoLoaded(info: info)
            }
        }
    }
}
