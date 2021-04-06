//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation


final class FilterTransactionController: ActionSheetController {
    typealias FinishHandler = (_ type: TransactionView.TransactionType, _ sortBy: SortBy) -> Void
    var finish: FinishHandler?
    
    enum SortBy {
        case time, amount
        
        var title: String {
            switch self {
            case .time:
                return NSLocalizedString("MAIN_TIME", comment: "")
            case .amount:
                return NSLocalizedString("MAIN_AMOUNT", comment: "")
            }
        }
        
        var fieldName: String {
            switch self {
            case .time:
                return "created_at"
            case .amount:
                return "amount"
            }
        }
        
        var ascending: Bool {
            switch self {
            case .time:
                return false
            case .amount:
                return true
            }
        }
    }
    
    private let applyButton = STPrimaryButton()
    
    var selectedSortBy: SortBy = .time
    var selectedTransactionType: TransactionView.TransactionType = .all
    
    private let transactionTypes: [TransactionView.TransactionType] = [.all, .sent, .received]
    private let sortBy: [SortBy] = [.time, .amount]
    
    private let transactionTypeFilter = UISegmentedControl()
    private let sortByFilter = UISegmentedControl()
    
    override func setup() {
        super.setup()
        isCancelable = true
        setupCenterHeader(title: NSLocalizedString("FILTER_TITLE", comment: ""), close: #selector(close))
        
        transactionTypes.enumerated().forEach {
            transactionTypeFilter.insertSegment(withTitle: $0.element.title, at: $0.offset, animated: false)
            if selectedTransactionType == $0.element { transactionTypeFilter.selectedSegmentIndex = $0.offset }
        }
    
        sortBy.enumerated().forEach {
            sortByFilter.insertSegment(withTitle: $0.element.title, at: $0.offset, animated: false)
            if selectedSortBy == $0.element { sortByFilter.selectedSegmentIndex = $0.offset }
        }
        
        setupMargins(margin: 16)
        stackView.spacing = 16

        makeFilter(title: NSLocalizedString("FILTER_TRANSACTION_TYPE_TITLE", comment: ""), filterOption: transactionTypeFilter)
        makeFilter(title: NSLocalizedString("FILTER_SORT_BY_TITLE", comment: ""), filterOption: sortByFilter)
        
        setupButton()
    }
}

fileprivate extension FilterTransactionController {
    
    func setupButton() {
        applyButton.icon = .ok
        stackView.addArrangedSubview(applyButton)
        applyButton.setTitle(NSLocalizedString("MAIN_APPLY", comment: ""), for: .normal)
        applyButton.addTarget(self, action: #selector(apply), for: .touchUpInside)
    }
    
    func makeFilter(title: String, filterOption: UISegmentedControl) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
        filterOption.tintColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryIconColor
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        titleLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 14)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .left
        titleLabel.text = title
        
        backgroundView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .top, of: backgroundView, withOffset: 4)
        titleLabel.autoPinEdge(.leading, to: .leading, of: backgroundView)
        
        backgroundView.addSubview(filterOption)
        filterOption.autoPinEdge(.bottom, to: .bottom, of: backgroundView, withOffset: -4)
        filterOption.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16)
        filterOption.autoPinEdge(.leading, to: .leading, of: backgroundView)
        
        stackView.addArrangedSubview(backgroundView)
    }
    
    @objc
    func apply() {
        let transactionIndex = transactionTypeFilter.selectedSegmentIndex
        let sortByIndex = sortByFilter.selectedSegmentIndex
        finish?(transactionTypes[transactionIndex], sortBy[sortByIndex])
        self.dismiss(animated: true, completion:  nil)
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion:  nil)
    }
}
