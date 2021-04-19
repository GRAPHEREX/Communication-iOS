//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

protocol CoinDetailsView: class {
    func onInfoLoaded(info: CoinWalletsInfo?)
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
        view.spacing = 0
        view.distribution = .fillEqually
        return view
    }()

    private var tabs: TZSegmentedControl?
    
//    private let containerScrollView: UIScrollView = {
//        let view = UIScrollView()
//        return view
//    }()
    
    private let containerContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let tabContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let walletsVC: WalletsViewController
    
    private var props: CoinWalletsInfo? {
        didSet {
            render()
        }
    }
    private var embeddedViewController: UIViewController?
    
    private let presenter: CoinDetailsPresenter
    
    // MARK: - Methods
    init(presenter: CoinDetailsPresenter, walletsFactory: () -> WalletsViewController) {
        self.presenter = presenter
        self.walletsVC = walletsFactory()
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onThemeChanged), name: Notification.themeChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.fetchData()
        render()
    }
    
    override func setup() {
        setupNavigationBar()
        setupContentView()
        setupActions()
        setupStyle()
        
//        setupPullToRefresh()
//        mainLoadingIndicator.startAnimating()
        embed(viewController: walletsVC)
    }
    
    private func setupContentView() {
//        view.addSubview(containerScrollView)
//        containerScrollView.addSubview(containerContentView)
//
//        containerScrollView.autoPinEdgesToSuperviewSafeArea()
        view.addSubview(containerContentView)
        containerContentView.autoPinEdgesToSuperviewEdges()
        containerContentView.autoPinWidth(toWidthOf: view)
        
        containerContentView.addSubview(headerView)
        headerView.autoPinEdge(toSuperviewEdge: .leading)
        headerView.autoPinEdge(toSuperviewSafeArea: .top)
        headerView.autoPinEdge(toSuperviewEdge: .trailing)
        
        containerContentView.addSubview(actionsStackView)
        actionsStackView.wltAutoHCenterInSuperview()
        actionsStackView.autoPinEdge(.top, to: .bottom, of: headerView, withOffset: 10)
        
        let segmentControl = TZSegmentedControl(sectionTitles: ["Wallets", "Transactions"])
        segmentControl.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40)
        segmentControl.segmentWidthStyle = .fixed
        segmentControl.borderType = .none
        segmentControl.selectionStyle = .fullWidth
        segmentControl.selectionIndicatorLocation = .down
        segmentControl.selectionIndicatorHeight = 2.0
        
        containerContentView.addSubview(segmentControl)
        segmentControl.autoSetDimension(.height, toSize: Constants.tabsTitlesHeight)
        segmentControl.autoPinEdge(.top, to: .bottom, of: actionsStackView, withOffset: 10)
        segmentControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentControl.autoPinEdge(toSuperviewEdge: .trailing)
        
        tabs = segmentControl
        
        containerContentView.addSubview(tabContentView)
        tabContentView.autoPinEdge(.top, to: .bottom, of: segmentControl)
        tabContentView.autoPinEdge(toSuperviewEdge: .leading)
        tabContentView.autoPinEdge(toSuperviewEdge: .trailing)
        tabContentView.autoPinEdge(toSuperviewSafeArea: .bottom)
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
        tabs?.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.secondaryTextAndIconColor,
            NSAttributedString.Key.font: UIFont.wlt_sfUiTextRegularFont(withSize: 14)
        ]
        tabs?.selectedTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.primaryTextColor,
            NSAttributedString.Key.font: UIFont.wlt_sfUiTextRegularFont(withSize: 14)
        ]
        tabs?.backgroundColor = Theme.primarybackgroundColor
        tabs?.selectionIndicatorColor = Theme.accentGreenColor
    }
    
    private func embed(viewController: UIViewController) {
        if let currentVc = embeddedViewController {
            // remove prev vc
            currentVc.view.removeFromSuperview()
            currentVc.removeFromParent()
        }
        
        addChild(viewController)
        tabContentView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.view.autoPinEdgesToSuperviewEdges()
        embeddedViewController = viewController
    }
    
    func render() {
        guard let props = props else {
            return
        }
        
        headerView.props = CoinDetailsHeaderView.Props(info: props)
        //(coinInfo: props, marketCap: "$ 1.6 T", volumeTrade: "$ 700m")
        
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
    func onInfoLoaded(info: CoinWalletsInfo?) {
        self.props = info
        render()
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

