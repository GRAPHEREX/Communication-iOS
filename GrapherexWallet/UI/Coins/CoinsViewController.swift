//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

protocol CoinsView: class {
    func onInfoLoaded(info: CoinsInfo)
}

class CoinsViewController: NiblessViewController {
    
    //MARK: - Properties
    private let headerView: CoinsHeaderView = {
        let view = CoinsHeaderView()
        return view
    }()

    private let tableViewController: WLTTableViewController = {
        let tableViewController = WLTTableViewController()
        tableViewController.tableView.backgroundColor = Theme.primarybackgroundColor
        return tableViewController
    }()
    
    private let tableHeaderView: CoinsTableHeaderView = {
        let view = CoinsTableHeaderView()
        return view
    }()
    
    private let mainLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    private var props: [CoinDataItem]? {
        didSet {
            render()
        }
    }
    
    private let presenter: CoinsPresenter
    
    // MARK: - Methods
    init(presenter: CoinsPresenter) {
        self.presenter = presenter
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        view.backgroundColor = Theme.primarybackgroundColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onThemeChanged), name: Notification.themeChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.fetchData()
    }
    
    override func setup() {
        setupHeaderView()
        setupTableView()
        setupPullToRefresh()
        mainLoadingIndicator.startAnimating()
    }
    
    private func setupHeaderView() {
        view.addSubview(headerView)
        headerView.autoPinEdge(toSuperviewEdge: .leading)
        headerView.autoPinEdge(toSuperviewSafeArea: .top)
        headerView.autoPinEdge(toSuperviewEdge: .trailing)
    }
    
    private func setupTableView() {
        view.addSubview(tableViewController.view)
        tableViewController.view.autoPinEdge(toSuperviewEdge: .leading)
        tableViewController.view.autoPinEdge(toSuperviewEdge: .trailing)
        tableViewController.view.autoPinEdge(toSuperviewSafeArea: .bottom)
        tableViewController.view.autoPinEdge(.top, to: .bottom, of: headerView)
        
        tableViewController.tableView.addSubview(mainLoadingIndicator)
        mainLoadingIndicator.autoCenterInSuperview()
        mainLoadingIndicator.bringSubviewToFront(tableViewController.tableView)
        
        let contents: WLTTableContents = .init()
        let headerSection = makeHeaderSection()
        contents.addSection(headerSection)
        
        tableViewController.contents = contents
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Wallet".localized
    }
    
    private func setupPullToRefresh() {
        let pullToRefreshView = UIRefreshControl()
        pullToRefreshView.tintColor = Theme.secondaryTextAndIconColor
        pullToRefreshView.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableViewController.tableView.refreshControl = pullToRefreshView
    }
    
    @objc
    private func refresh(refreshControl: UIRefreshControl) {
        presenter.fetchData {
            refreshControl.endRefreshing()
        }
    }
    
    private func makeHeaderSection() -> WLTTableSection {
        let headerSection = WLTTableSection()
        let headerCell = WLTTableItem.newCell()
        headerCell.selectionStyle = .none
        headerCell.contentView.addSubview(tableHeaderView)
        tableHeaderView.autoPinEdgesToSuperviewEdges()
        
        let tableItem = WLTTableItem(
            customCellBlock: { return headerCell },
            customRowHeight: 40,
            actionBlock: nil
        )
        headerSection.add(tableItem)
        return headerSection
    }
    
    private func setNoDataState() {
        mainLoadingIndicator.isHidden = true
        mainLoadingIndicator.stopAnimating()
        
        let contents: WLTTableContents = .init()
        let mainSection = WLTTableSection()
        
        // MARK: - SINGAL DEPENDENCY – reimplement
        //        if TSAccountManager.shared().isDeregistered() {
        //            let remindersSection = WLTTableSection()
        //            remindersSection.add(setupReminders())
        //            contents.addSection(remindersSection)
        //
        //            emptyItemHeight += Constant.remindersHeight
        //        }
        
        let emptyItem = WLTTableItem(
            customCellBlock: {
                let cell = WLTTableItem.newCell()
                let emptyView = SecondaryEmptyStateView()
                emptyView.set(
                    image: UIImage.loadFromWalletBundle(named: "wallet"),
                    title: "No data".localized
                )
                cell.contentView.addSubview(emptyView)
                emptyView.autoCenterInSuperviewMargins()
                emptyView.autoPinEdgesToSuperviewMargins(with: UIEdgeInsets(hMargin: 10, vMargin: 10))
                return cell
            },
            customRowHeight: UITableView.automaticDimension,
            actionBlock: nil
        )
        
        mainSection.add(emptyItem)
        contents.addSection(mainSection)
        
        tableViewController.contents = contents
    }
    
    func render() {
        guard let props = props,
              !props.isEmpty else {
            setNoDataState()
            return
        }
        let contents: WLTTableContents = .init()
        let mainSection = WLTTableSection()
        let headerSection = makeHeaderSection()
        
        mainSection.add(items: props.map {
                                let cell = WLTTableItem.newCell()
                                cell.selectionStyle = .none
                                cell.layoutMargins = .zero
                                let walletItem = CoinCell()
                                walletItem.currencyItem = $0
                                cell.contentView.addSubview(walletItem)
                                walletItem.autoPinEdgesToSuperviewEdges()
                                return .init(
                                    customCell: cell,
                                    customRowHeight: UITableView.automaticDimension,
                                    actionBlock: {
                                    }
                                )
                        })
            
        
        contents.addSection(headerSection)
        contents.addSection(mainSection)
        mainLoadingIndicator.isHidden = true
        mainLoadingIndicator.stopAnimating()
        tableViewController.contents = contents
    }
    
    // MARK: - Theme
    @objc private func onThemeChanged() {
        view.backgroundColor = Theme.primarybackgroundColor
        tableViewController.tableView.backgroundColor = Theme.primarybackgroundColor
    }
}

extension CoinsViewController: CoinsView {
    func onInfoLoaded(info: CoinsInfo) {
        self.props = info.items
        let headerProps = CoinsHeaderView.Props(balance: info.totalBalance,
                                                marketCap: info.marketCap,
                                                volumeTrade: info.volumeTrade,
                                                btcDominance: info.btcDominance,
                                                spendValue: info.spendValue,
                                                incomeValue: info.incomeValue,
                                                spendIncomeProportion: info.spendIncomeProportion)
        headerView.props = headerProps
    }
}
