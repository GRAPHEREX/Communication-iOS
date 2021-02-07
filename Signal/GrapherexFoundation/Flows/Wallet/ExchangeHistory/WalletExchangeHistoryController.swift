//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

final class WalletExchangeHistoryController: OWSViewController {
    
    enum TransactionType {
        case all, pending, closed
    }
    
    private lazy var tableViewController =  OWSTableViewController()
    private let emptyView = SecondaryEmptyStateView()

    private let segmentControl = UISegmentedControl(items: ["All", "Pending", "Closed"])
    var wallet: Wallet!
        
    private var data: [ExchangeHistoryView.Props] = []
    
    
    private var filteredData: [ExchangeHistoryView.Props] = [ ] { didSet {
        setupContent()
    }}
    
    override func setup() {
        super.setup()
        title = NSLocalizedString("WALLET_EXCHANGE_MY_ORDERS_TITLE", comment: "")
        setupView()
        setupTableView()
        setupContent()
        filteredData = data
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTheme),
                                               name: .ThemeDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupEmptyView()
    }
    
    @objc
    private func applyTheme() {
        view.backgroundColor = Theme.backgroundColor
        setupContent()
    }
}

fileprivate extension WalletExchangeHistoryController {
    func setupView() {
        view.addSubview(segmentControl)
        segmentControl.addTarget(self, action: #selector(filter), for: .valueChanged)
        segmentControl.autoPinEdge(.top, to: .top, of: view)
        segmentControl.autoHCenterInSuperview()
        segmentControl.selectedSegmentIndex = 0
    }
    
    func setupTableView() {
        view.backgroundColor = Theme.backgroundColor
        tableViewController.tableViewStyle = .plain
        view.addSubview(tableViewController.view)
        tableViewController.view.backgroundColor = .clear
        tableViewController.tableView.backgroundColor = .clear
        
        tableViewController.view.autoPinEdge(.top, to: .bottom, of: segmentControl, withOffset: 8)
        tableViewController.view.autoPinEdge(.leading, to: .leading, of: view)
        tableViewController.view.autoPinEdge(.trailing, to: .trailing, of: view)
        tableViewController.view.autoPinEdge(.bottom, to: .bottom, of: view)
        
        self.definesPresentationContext = false
        
        setupPullToRefresh()
    }
    
    func setupEmptyView() {
        emptyView.set(image: #imageLiteral(resourceName: "SignNumber"), title: NSLocalizedString("WALLET_ORDERS_EMPTY_STATE_TITLE", comment: ""))
        view.addSubview(emptyView)
        emptyView.autoPinEdge(.top, to: .top, of: tableViewController.view)
        emptyView.autoPinBottomToSuperviewMargin()
        emptyView.autoPinEdge(.trailing, to: .trailing, of: tableViewController.view)
        emptyView.autoPinEdge(.leading, to: .leading, of: tableViewController.view)
        view.bringSubviewToFront(tableViewController.view)
    }
    
    func setupContent() {
        let contents: OWSTableContents = .init()
        let mainSection = OWSTableSection()
                
        filteredData.forEach {
            mainSection.add(makeExchangeHistoryView(props: $0))
        }
        
        makeEmptyState(isEmpty: filteredData.isEmpty)
        contents.addSection(mainSection)
        tableViewController.contents = contents
    }
    
    func setupPullToRefresh() {
        let pullToRefreshView = UIRefreshControl()
        pullToRefreshView.tintColor = Theme.secondaryTextAndIconColor
        pullToRefreshView.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableViewController.tableView.refreshControl = pullToRefreshView
    }
    
    @objc
    func filter() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            filteredData = data
        case 1:
            filteredData = data.filter { $0.status == .pending }
        case 2:
            filteredData = data.filter { $0.status == .closed }
        default:
            break
        }
    }
        
    func makeEmptyState(isEmpty: Bool) {
        emptyView.isHidden = !isEmpty
        tableViewController.view.isHidden = isEmpty
    }
    
    func makeExchangeHistoryView(props: ExchangeHistoryView.Props) -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        let view = ExchangeHistoryView()
        view.props = props
        cell.contentView.layoutMargins = .zero
        cell.contentView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        return OWSTableItem(customCell: cell, customRowHeight: 64, actionBlock: nil)
    }
    
    @objc
    func refresh(refreshControl: UIRefreshControl) {
        print("refresh")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            refreshControl.endRefreshing()
        }
    }
}
