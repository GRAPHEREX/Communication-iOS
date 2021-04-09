//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

final class MainHeaderView: NiblessView {
    
    // MARK: - Balance
    private let balanceTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 16)
        view.textColor = UIColor.wlt_secondaryLabelColor
        view.textAlignment = .left
        view.text = "Total balance".localized
        return view
    }()
    
    private let balanceValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 16)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .right
        return view
    }()
    
    private lazy var balanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [balanceTitleLabel, balanceValueLabel])
        stack.axis = .horizontal
        return stack
    }()
    
    // MARK: - Market Cap
    private let marketCapTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 13)
        view.textColor = UIColor.wlt_secondaryLabelColor
        view.textAlignment = .center
        view.text = "Market cap".localized
        return view
    }()
    
    private let marketCapValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 14)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var marketCapStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [marketCapTitleLabel, marketCapValueLabel])
        stack.axis = .vertical
        return stack
    }()
    
    // MARK: - Volume Trade
    private let volumeTradeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 13)
        view.textColor = UIColor.wlt_secondaryLabelColor
        view.textAlignment = .center
        view.text = "Volume trade 24h".localized
        return view
    }()
    
    private let volumeTradeValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 14)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var volumeTradeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [volumeTradeTitleLabel, volumeTradeValueLabel])
        stack.axis = .vertical
        return stack
    }()
    
    // MARK: - BTC Dominance
    private let btcDominanceTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 13)
        view.textColor = UIColor.wlt_secondaryLabelColor
        view.textAlignment = .center
        view.text = "BTC Dominance".localized
        return view
    }()
    
    private let btcDominanceValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 14)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var btcDominanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [btcDominanceTitleLabel, btcDominanceValueLabel])
        stack.axis = .vertical
        return stack
    }()
    
    struct Props {
        let balance: String
        let marketCap: String
        let volumeTrade: String
        let btcDominance: String
    }
    
    var props: Props? { didSet {
        render()
    }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
}

fileprivate extension MainHeaderView {
    
    func render() {
        guard let props = props else { return }
        balanceValueLabel.text = props.balance
        marketCapValueLabel.text = props.marketCap
        volumeTradeValueLabel.text = props.volumeTrade
        btcDominanceValueLabel.text = props.btcDominance
    }
    
    func setup() {
        backgroundColor = UIColor.wlt_primaryBackgroundColor
        self.layoutMargins = .zero
        
        let bottomDivider = UIView.spacer(withHeight: 6)
        bottomDivider.backgroundColor = UIColor.wlt_secondaryBackgroundColor
        addSubview(bottomDivider)
        bottomDivider.autoPinEdge(toSuperviewEdge: .leading)
        bottomDivider.autoPinEdge(toSuperviewEdge: .trailing)
        bottomDivider.autoPinEdge(toSuperviewEdge: .bottom)
    }
}

