//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

protocol CoinDetailsView: class {
    func onInfoLoaded(info: CoinsInfo)
}

class CoinDetailsViewController: NiblessViewController {
    
    //MARK: - Properties
    private enum Constants {
        static let tabsTitlesHeight: CGFloat = 40.0
    }
    
    private let headerView: CoinDetailsHeaderView = {
        let view = CoinDetailsHeaderView()
        return view
    }()
    
    private let actionsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 5
        view.distribution = .fillEqually
        return view
    }()
    
    private let segmentControl: TZSegmentedControl = {
        let segmentControl = TZSegmentedControl(sectionTitles: ["Wallets", "Transactions"])
        //segmentControl.segmentWidthStyle = .fixed
        //segmentControl.borderType = .none
        //segmentControl.selectionStyle = .fullWidth
        segmentControl.selectionIndicatorLocation = .down
        segmentControl.selectionIndicatorHeight = 2.0
        
        return segmentControl
    }()
    
    private let containerScrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private let containerContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let walletsVC: WalletsViewController
    
    private var props: CoinInfo? {
        didSet {
            render()
        }
    }
    
    private let presenter: CoinDetailsPresenter
    
    // MARK: - Methods
    init(presenter: CoinDetailsPresenter, coinInfo: CoinInfo?, walletsFactory: () -> WalletsViewController) {
        self.presenter = presenter
        self.props = coinInfo
        self.walletsVC = walletsFactory()
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onThemeChanged), name: Notification.themeChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //presenter.fetchData()
        render()
    }
    
    override func setup() {
        setupNavigationBar()
        setupContentView()
        setupActions()
        setupTabs()
        setupStyle()
        
//        setupTableView()
//        setupPullToRefresh()
//        mainLoadingIndicator.startAnimating()
    }
    
    private func setupContentView() {
        view.addSubview(containerScrollView)
        containerScrollView.addSubview(containerContentView)
        
        containerScrollView.autoPinEdgesToSuperviewSafeArea()
        containerContentView.autoPinEdgesToSuperviewEdges()
        containerContentView.autoPinWidth(toWidthOf: view)
        
        containerContentView.addSubview(headerView)
        headerView.autoPinEdge(toSuperviewEdge: .leading)
        headerView.autoPinEdge(toSuperviewSafeArea: .top)
        headerView.autoPinEdge(toSuperviewEdge: .trailing)
        
        containerContentView.addSubview(actionsStackView)
        actionsStackView.wltAutoHCenterInSuperview()
        actionsStackView.autoPinEdge(.top, to: .bottom, of: headerView, withOffset: 10)
        
        containerContentView.addSubview(segmentControl)
        segmentControl.autoSetDimension(.height, toSize: Constants.tabsTitlesHeight)
        segmentControl.autoPinEdge(.top, to: .bottom, of: actionsStackView, withOffset: 10)
        segmentControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentControl.autoPinEdge(toSuperviewEdge: .trailing)
        
        addChild(walletsVC)
        containerContentView.addSubview(walletsVC.view)
        walletsVC.didMove(toParent: self)
        
        walletsVC.view.autoPinEdge(.top, to: .bottom, of: segmentControl)
        walletsVC.view.autoPinEdge(toSuperviewEdge: .leading)
        walletsVC.view.autoPinEdge(toSuperviewEdge: .trailing)
        walletsVC.view.autoPinEdge(toSuperviewSafeArea: .bottom)
    }
    
    private func setupActions() {
        let sendAction = WalletActionView(option: .send, action: { [weak self] in
            self?.sendPressed()
        })
        
        let receiveAction = WalletActionView(option: .receive, action: { [weak self] in
            self?.receivePressed()
        })
        
        let newWalletAction = WalletActionView(option: .newWallet, action: { [weak self] in
            self?.newWalletPressed()
        })
        
        let actionViews = [sendAction, receiveAction, newWalletAction]
        actionsStackView.addArrangedSubviews(actionViews)
    }
    
    private func setupTabs() {
        segmentControl.sectionTitles = ["Wallets", "Transactions"]
        segmentControl.indexChangeBlock = { [weak self] selectedIndex in
            self?.handleChangeIndex(selectedIndex)
        }
    }
    
//    private func setupTableView() {
//        view.addSubview(tableViewController.view)
//        tableViewController.view.autoPinEdge(toSuperviewEdge: .leading)
//        tableViewController.view.autoPinEdge(toSuperviewEdge: .trailing)
//        tableViewController.view.autoPinEdge(toSuperviewSafeArea: .bottom)
//        tableViewController.view.autoPinEdge(toSuperviewSafeArea: .top)
//
//        tableViewController.tableView.addSubview(mainLoadingIndicator)
//        mainLoadingIndicator.autoCenterInSuperview()
//        mainLoadingIndicator.bringSubviewToFront(tableViewController.tableView)
//
//        let contents: WLTTableContents = .init()
//        let headerSection = makeHeaderSection()
//        contents.addSection(headerSection)
//
//        tableViewController.contents = contents
//    }
    
    private func setupNavigationBar() {
        navigationItem.title = ""
    }
    
//    private func setupPullToRefresh() {
//        let pullToRefreshView = UIRefreshControl()
//        pullToRefreshView.tintColor = Theme.secondaryTextAndIconColor
//        pullToRefreshView.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        tableViewController.tableView.refreshControl = pullToRefreshView
//    }

    private func setupStyle() {
        view.backgroundColor = Theme.primarybackgroundColor
        segmentControl.backgroundColor = Theme.primarybackgroundColor
        view.backgroundColor = Theme.primarybackgroundColor
        segmentControl.selectionIndicatorColor = Theme.accentGreenColor
        segmentControl.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.secondaryTextAndIconColor,
            NSAttributedString.Key.font: UIFont.wlt_sfUiTextRegularFont(withSize: 14)
        ]
        segmentControl.selectedTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.primaryTextColor,
            NSAttributedString.Key.font: UIFont.wlt_sfUiTextRegularFont(withSize: 14)
        ]
    }
    
    func render() {
        guard let props = props else {
            return
        }
        
        headerView.props = CoinDetailsHeaderView.Props(coinInfo: props, marketCap: "$ 1.6 T", volumeTrade: "$ 700m")
        
    }
    
    // MARK: - Actions
    @objc private func refresh(refreshControl: UIRefreshControl) {
//        presenter.fetchData {
//            refreshControl.endRefreshing()
//        }
    }
    
    @objc private func handleChangeIndex(_ index: Int) {
        
    }
    
    @objc private func newWalletPressed() {
        
    }
    
    @objc private func sendPressed() {
        
    }
    
    @objc private func receivePressed() {
        
    }
    
    // MARK: - Theme
    @objc private func onThemeChanged() {
        setupStyle()
    }
}

extension CoinDetailsViewController: CoinDetailsView {
    func onInfoLoaded(info: CoinsInfo) {
//        self.props = info.items
//        let headerProps = CoinsHeaderView.Props(balance: info.totalBalance,
//                                                marketCap: info.marketCap,
//                                                volumeTrade: info.volumeTrade,
//                                                btcDominance: info.btcDominance,
//                                                spendValue: info.spendValue,
//                                                incomeValue: info.incomeValue,
//                                                spendIncomeProportion: info.spendIncomeProportion)
//        headerView.props = headerProps
    }
}

