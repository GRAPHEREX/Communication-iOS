//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

final class CoinCell: NiblessView {
    
    private let coinImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let coinLabel: UILabel = {
        let view = UILabel()
        view.font = .wlt_robotoFont(withSize: 14)
        view.textColor = .wlt_primaryLabelColor
        return view
    }()
    
    private lazy var coinStack: UIStackView = {
       let stack = UIStackView(arrangedSubviews: [coinImage, coinLabel])
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    
    private let balanceLabel: UILabel = {
        let view = UILabel()
        view.textColor = .wlt_primaryLabelColor
        view.font = .wlt_robotoFont(withSize: 14)
        view.textAlignment = .right
        return view
    }()
    
    private let currencyBalanceLabel: UILabel = {
        let view = UILabel()
        view.textColor = .wlt_secondaryLabelColor
        view.font = .wlt_robotoFont(withSize: 12)
        view.textAlignment = .right
        return view
    }()
    
    private lazy var balanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [balanceLabel, currencyBalanceLabel])
        stack.axis = .vertical
        return stack
    }()
    
    private let priceLabel: UILabel = {
        let view = UILabel()
        view.textColor = .wlt_darkGray63Color
        view.font = .wlt_robotoFont(withSize: 14)
        view.textAlignment = .right
        return view
    }()
    
    private lazy var containerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [coinStack, balanceStack, priceLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    var currencyItem: CoinDataItem? {
        didSet {
            render()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
}

fileprivate extension CoinCell {
    
    func render() {
        guard let currencyItem = currencyItem else { return }
        coinImage.sd_setImage(with: URL(string: currencyItem.currencyIcon))
        coinLabel.text = currencyItem.coinTitle
        balanceLabel.text = currencyItem.balance
        currencyBalanceLabel.text = currencyItem.currencyBalance
        priceLabel.text = currencyItem.stockPrice
    }
    
    func setup() {
        backgroundColor = .wlt_primaryBackgroundColor
        self.layoutMargins = .zero
        
        coinImage.wltSetContentHuggingHorizontalLow()
        coinImage.autoSetDimension(.height, toSize: 32)
        coinImage.autoMatch(.height, to: .width, of: coinImage)
        coinLabel.wltSetContentHuggingHorizontalHigh()
        addSubview(containerStack)
        containerStack.autoPinEdgesToSuperviewEdges()
    }
}

