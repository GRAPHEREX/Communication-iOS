//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

final class CoinsTableHeaderView: NiblessView {
    
    private struct Constants {
        static let contentHorizontalOffset: CGFloat = 14.0
    }
    
    // MARK: - TableHeaderView
    private let tableCurrencyLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoRegularFont(withSize: 12)
        view.textColor = UIColor.wlt_darkGray47Color
        view.textAlignment = .left
        view.text = "Currency".localized
        return view
    }()
    
    private let tableBalanceLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoRegularFont(withSize: 12)
        view.textColor = UIColor.wlt_darkGray47Color
        view.textAlignment = .left
        view.text = "Balance".localized
        return view
    }()
    
    private let tablePriceLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoRegularFont(withSize: 12)
        view.textColor = UIColor.wlt_darkGray47Color
        view.textAlignment = .left
        view.text = "Price".localized
        return view
    }()
    
    private lazy var tableHeaderStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tableCurrencyLabel, tableBalanceLabel, tablePriceLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        activateConstraints()
    }
    
    func setup() {
        addSubview(tableHeaderStack)
    }
    
    func activateConstraints() {
        tableHeaderStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: Constants.contentHorizontalOffset, bottom: 0, right: Constants.contentHorizontalOffset))
    }
}
