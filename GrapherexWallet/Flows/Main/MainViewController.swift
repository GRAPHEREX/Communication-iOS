//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

protocol MainView: class {
    func onItemsRetrieval(items: [WalletCurrencyItem])
}

class MainViewController: NiblessViewController {
    
    //MARK: - Properties
    private struct Constant {
        static let headerHeight: CGFloat = 120
    }
    
    private let headerView: MainHeaderView = {
        let view = MainHeaderView()
        view.backgroundColor = .wlt_primaryBackgroundColor
        return view
    }()

    private let tableViewController: WLTTableViewController = {
        let tableViewController = WLTTableViewController()
        tableViewController.tableView.backgroundColor = .clear
        return tableViewController
    }()
    
    private let mainLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    private var props: [WalletCurrencyItem]? {
        didSet {
            render()
        }
    }
    
    private let presenter: MainPresenter
    
    // MARK: - Methods
    init(presenter: MainPresenter) {
        self.presenter = presenter
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let props = MainHeaderView.Props(balance: "$20.00", marketCap: "1.6 T USD", volumeTrade: "700m USD", btcDominance: "65%")
        headerView.props = props
        presenter.fetchData()
    }
    
    override func setup() {
        setupHeaderView()
        setupTableView()
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
        
        let contents: WLTTableContents = .init()
        tableViewController.contents = contents
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Wallet".localized
    }
    
    private func setNoDataState() {
        mainLoadingIndicator.isHidden = true
        mainLoadingIndicator.stopAnimating()
        
        let contents: WLTTableContents = .init()
        let mainSection = WLTTableSection()
        
        var emptyItemHeight: CGFloat = 0
        
        emptyItemHeight += Constant.headerHeight
        
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
                    image: UIImage.image(named: "wallet"),
                    title: "No data".localized
                )
                cell.contentView.addSubview(emptyView)
                emptyView.autoCenterInSuperviewMargins()
                return cell
            },
            customRowHeight: tableViewController.tableView.frame.height - emptyItemHeight,
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
        
        mainSection.add(items: props.map {
                                let cell = WLTTableItem.newCell()
                                cell.selectionStyle = .none
                                cell.layoutMargins.top = 16
                                cell.layoutMargins.bottom = 16
                                cell.layoutMargins.right = cell.layoutMargins.left
                                let walletItem = WalletItemCell()
                                walletItem.currencyItem = $0
                                cell.contentView.addSubview(walletItem)
                                walletItem.autoPinEdgesToSuperviewMargins()
                                return .init(
                                    customCell: cell,
                                    customRowHeight: UITableView.automaticDimension,
                                    actionBlock: { [weak self] in
                                        
                                    }
                                )
                        })
            
        
        contents.addSection(mainSection)
        mainLoadingIndicator.isHidden = true
        mainLoadingIndicator.stopAnimating()
        tableViewController.contents = contents
    }
}

extension MainViewController: MainView {
    func onItemsRetrieval(items: [WalletCurrencyItem]) {
        self.props = items
    }
}
