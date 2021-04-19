//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

//protocol TransactionsView: class {
//    func onTransactionsLoaded(transactionInfo: [TransactionInfo])
//}
//
//class TransactionsViewController: NiblessViewController {
//    // MARK: - Properties
//    private let tableViewController: WLTTableViewController = {
//        let tableViewController = WLTTableViewController()
//        tableViewController.tableView.backgroundColor = Theme.primarybackgroundColor
//        return tableViewController
//    }()
//
//    private let presenter: TransactionsPresenter
//
//    private var transactions = [TransactionInfo]()
//
//    // MARK: - Methods
//    init(presenter: TransactionsPresenter) {
//        self.presenter = presenter
//        super.init()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupStyle()
//        NotificationCenter.default.addObserver(self, selector: #selector(self.onThemeChanged), name: Notification.themeChanged, object: nil)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        presenter.fetchData()
//    }
//
//    override func setup() {
//        view.addSubview(tableViewController.view)
//        tableViewController.view.autoPinEdgesToSuperviewEdges()
//
//        //        tableViewController.tableView.addSubview(mainLoadingIndicator)
//        //        mainLoadingIndicator.autoCenterInSuperview()
//        //        mainLoadingIndicator.bringSubviewToFront(tableViewController.tableView)
//
//        let contents: WLTTableContents = .init()
//        tableViewController.contents = contents
//    }
//
//    @objc private func onThemeChanged() {
//        setupStyle()
//    }
//
//    private func setupStyle() {
//        view.backgroundColor = Theme.primarybackgroundColor
//    }
//
//    private func setNoDataState() {
//        //        mainLoadingIndicator.isHidden = true
//        //        mainLoadingIndicator.stopAnimating()
//
//        let contents: WLTTableContents = .init()
//        let mainSection = WLTTableSection()
//
//        let emptyItem = WLTTableItem(
//            customCellBlock: {
//                let cell = WLTTableItem.newCell()
//                let emptyView = SecondaryEmptyStateView()
//                emptyView.set(
//                    image: UIImage.loadFromWalletBundle(named: "wallet"),
//                    title: "No data".localized
//                )
//                cell.contentView.addSubview(emptyView)
//                emptyView.autoCenterInSuperviewMargins()
//                emptyView.autoPinEdgesToSuperviewEdges()
//                return cell
//            },
//            customRowHeight: UITableView.automaticDimension,
//            actionBlock: nil
//        )
//
//        mainSection.add(emptyItem)
//        contents.addSection(mainSection)
//
//        tableViewController.contents = contents
//    }
//
//    private func render() {
//        guard !transactions.isEmpty else {
//            setNoDataState()
//            return
//        }
//        let contents: WLTTableContents = .init()
//        let mainSection = WLTTableSection()
//
//        mainSection.add(items: transactions.map {
//            let cell = WLTTableItem.newCell()
//            cell.selectionStyle = .none
//            cell.layoutMargins = .zero
//            let walletItem = WalletDetailCell()
//            walletItem.walletInfo = WalletInfo(coinName: $0.currency.symbol,
//                                               coinIcon: $0.currency.icon,
//                                               balance: $0.balanceStr + $0.currency.symbol,
//                                               currencyBalance: $0.fiatBalanceStr.appendingLeadingCurrencySymbol(forCode: $0.fiatCurrency))
//            cell.contentView.addSubview(walletItem)
//            walletItem.autoPinEdgesToSuperviewEdges()
//            return .init(
//                customCell: cell,
//                customRowHeight: UITableView.automaticDimension,
//                actionBlock: {
//                }
//            )
//        })
//
//
//        contents.addSection(mainSection)
//        //        mainLoadingIndicator.isHidden = true
//        //        mainLoadingIndicator.stopAnimating()
//        tableViewController.contents = contents
//    }
//}
//
//extension WalletsViewController: WalletsView {
//    func onWalletsLoaded(wallets: [Wallet]) {
//        self.wallets = wallets
//        render()
//    }
//}
//
