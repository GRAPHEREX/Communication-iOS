//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class WalletDetailController: OWSViewController {
    
    private lazy var tableViewController =  OWSTableViewController()
    private let headerView = WalletHeaderView()
    private let noDataView = SecondaryEmptyStateView()
    private let emptyTransactionsView = SecondaryEmptyStateView()
    private let throttler = Throttler(minimumDelay: 0.5)
    
    var selectedSortBy: FilterTransactionController.SortBy = .time
    var selectedTransactionType: TransactionView.TransactionType = .all
    private var transactionOffset: Int = 0
    
    var walletId: String! { didSet {
        self.wallet = walletModel.getWalletById(id: walletId)
    }}
    
    private(set) var wallet: Wallet!

    private let walletModel: WalletModel = {
        return WalletModel.shared
    }()
    
    private let transactionPaginationSize: Int = 50
    private let transactionHeaderView = UIView()
    private let paginationLoadingIndicator = UIActivityIndicatorView()
    private let mainLoadingIndicator = UIActivityIndicatorView()
    private let refreshControl = UIRefreshControl()
    
    private var isLoadedAll: Bool = false
    private var needLoadNextPage: Bool = false { willSet {
        guard newValue != needLoadNextPage && isLoadedAll == false else { return }
        if newValue {
            throttler.throttle { [weak self] in
                self?.loadNextPage()
            }
        }
    }}
    
    private var data: [TransactionView.Props] = []
    
    override func setup() {
        super.setup()
        setupTransactionHeader()
        title = wallet.currency.name
        setupTableView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateWallet),
            name: WalletModel.walletCredentionalsDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(applyTheme),
            name: .ThemeDidChange, object: nil)
        
        loadData()
        mainLoadingIndicator.startAnimating()
    }
    
    func setNoDataState() {
        mainLoadingIndicator.isHidden = true
        mainLoadingIndicator.stopAnimating()
        
        navigationItem.rightBarButtonItem = nil

        let contents: OWSTableContents = .init()
        let mainSection = OWSTableSection()
                        
        let emptyItem = OWSTableItem(
            customCellBlock: {
                let cell = OWSTableItem.newCell()
                let emptyView = SecondaryEmptyStateView()
                emptyView.set(
                    image: UIImage(named: "Wallet"),
                    title: "No data"
                )
                cell.contentView.addSubview(emptyView)
                emptyView.autoCenterInSuperviewMargins()
                return cell
        },
            actionBlock: nil
        )
        emptyItem.customRowHeight = NSNumber(nonretainedObject: tableViewController.tableView.frame.height)
        
        mainSection.add(emptyItem)
        contents.addSection(mainSection)
        
        tableViewController.contents = contents
    }
}

fileprivate extension WalletDetailController {
    
    func loadData(completion: ( () -> Void)? = nil) {
        self.walletModel.walletInfo(wallet) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let wallet):
                self.wallet = wallet
                self.data = []
                self.isLoadedAll = false
                self.transactionOffset = 0
                self.setupContent()
                self.loadNextPage()
                self.updateContent(allowedShowEmptyTransaction: false)
            case .failure(let error):
                self.setNoDataState()
                OWSActionSheets.showErrorAlert(message: error.localizedDescription)
            }
        }
        completion?()
    }
    
    @objc
    func updateWallet() {
        self.wallet = walletModel.getWalletById(id: walletId)
    }
    
    func setupTableView() {
        view.backgroundColor = Theme.backgroundColor
        tableViewController.tableViewStyle = .plain
        view.addSubview(tableViewController.view)
        tableViewController.view.backgroundColor = .clear
        tableViewController.willDisplayDelegate = self
        tableViewController.tableView.backgroundView?.backgroundColor = .clear
        tableViewController.tableView.backgroundColor = .clear
        tableViewController.tableView.showsVerticalScrollIndicator = false
        tableViewController.view.autoPinEdgesToSuperviewEdges()
        self.definesPresentationContext = false
        setupPullToRefresh()
        
        tableViewController.tableView.addSubview(mainLoadingIndicator)
        mainLoadingIndicator.autoCenterInSuperview()
    }
    
    func setupContent() {
        mainLoadingIndicator.isHidden = true
        mainLoadingIndicator.stopAnimating()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "icon.dots"),
            style: .plain,
            target: self,
            action: #selector(showMenu)
        )
        
        let contents: OWSTableContents = .init()
        let headerSection = OWSTableSection()
        let mainSection = OWSTableSection()
        let loaderSection = OWSTableSection()
        headerSection.add(setupHeader())
        mainSection.customHeaderView = transactionHeaderView
        mainSection.customHeaderHeight = 40

        contents.addSection(headerSection)
        contents.addSection(mainSection)
        contents.addSection(loaderSection)
        tableViewController.contents = contents
    }
    
    func updateContent(allowedShowEmptyTransaction: Bool) {
        let contents: OWSTableContents = .init()
        let headerSection = OWSTableSection()
        let mainSection = OWSTableSection()
        let loaderSection = OWSTableSection()
        headerSection.add(setupHeader())
        mainSection.customHeaderView = transactionHeaderView
        mainSection.customHeaderHeight = 40
        
        if data.isEmpty && allowedShowEmptyTransaction {
             mainSection.add(makeEmptyState())
        } else {
            data.forEach {
                mainSection.add(makeTransactionView(props: $0))
            }
            loaderSection.add(setupLoading())
        }

        contents.addSection(headerSection)
        contents.addSection(mainSection)
        contents.addSection(loaderSection)
        tableViewController.contents = contents
    }
    
    func setupHeader() -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none
        cell.contentView.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges()
        headerView.setup(
            currency: wallet.currency,
            amount: wallet.balance + " " + wallet.currency.symbol,
            currencyAmount: wallet.fiatCurrency + " " + wallet.fiatBalance,
            options: [
                ProfileOptionView(option: .send,
                                  action: { [weak self] in self?.send() }),
                ProfileOptionView(option: .receive,
                                  action: { [weak self] in self?.receive() }),
                ProfileOptionView(option: .info,
                                  action: { [weak self] in self?.showInfo() })
            ])
        
        return OWSTableItem(customCell: cell,
                            customRowHeight: WalletHeaderView.Constact.height,
                            actionBlock: nil)
    }
    
    func setupLoading() -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none
        cell.contentView.addSubview(paginationLoadingIndicator)
        paginationLoadingIndicator.autoCenterInSuperview()
        
        return OWSTableItem(customCell: cell,
                            customRowHeight: 64,
                            actionBlock: nil)
    }
    
    func setupTransactionHeader() {
        let label = UILabel()
        transactionHeaderView.subviews.forEach { $0.removeFromSuperview() }
        transactionHeaderView.backgroundColor = Theme.backgroundColor
        label.textColor = Theme.primaryTextColor
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        label.text = NSLocalizedString("WALLET_TRANSACTION_TITLE", comment: "")
        
        transactionHeaderView.addSubview(label)
        label.autoPinEdge(.top, to: .top, of: transactionHeaderView)
        label.autoPinEdge(.bottom, to: .bottom, of: transactionHeaderView)
        label.autoPinEdge(.trailing, to: .trailing, of: transactionHeaderView)
        label.autoPinEdge(.leading, to: .leading, of: transactionHeaderView, withOffset: 16)
        
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "icon.filter").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = Theme.secondaryTextAndIconColor
        button.addTarget(self, action: #selector(showFilter), for: .touchUpInside)
        
        transactionHeaderView.addSubview(button)
        button.autoPinEdge(.top, to: .top, of: transactionHeaderView)
        button.autoPinEdge(.bottom, to: .bottom, of: transactionHeaderView)
        button.autoPinEdge(.trailing, to: .trailing, of: transactionHeaderView, withOffset: -16)
        button.autoSetDimension(.width, toSize: 40)
    }
    
    @objc
    func showFilter() {
        let controller = FilterTransactionController()
        controller.selectedSortBy = selectedSortBy
        controller.selectedTransactionType = selectedTransactionType
        controller.finish = { [weak self] transactionType, sortBy in
            guard let self = self else { return }
            self.data = []
            self.transactionOffset = 0
            self.isLoadedAll = false
            self.selectedSortBy = sortBy
            self.selectedTransactionType = transactionType
            self.loadNextPage()
        }
        self.presentActionSheet(controller, animated: true)
    }
    
    @objc
    func showMenu() {
        let action = ActionSheetController()
        let hasPin: Bool = (wallet.credentials?.pin != nil)
        action.addAction(.init(title: hasPin ? "Edit pin" : "Set pin", style: .default, handler: { [weak self] actionSheet in
            guard let self = self else { return }
            let setPinController = SetPinController()
            setPinController.walletId = self.wallet.id
            
            if hasPin {
                let enterController = EnterPinController()
                enterController.walletId = self.wallet.id
                enterController.finish = { [weak self] isSuccess in
                    guard let self = self else { return }
                    if isSuccess {
                        enterController.dismiss(animated: true, completion: {
                            DispatchQueue.main.async {                                
                                self.presentActionSheet(setPinController)
                            }
                        })
                    }
                }
                self.presentActionSheet(enterController)
            } else {
                self.presentActionSheet(setPinController)
            }
        }))
        
        action.addAction(.init(title: "Edit password", style: .default, handler: { [weak self] actionSheet in
            guard let self = self else { return }
            let controller = PasswordController()
            controller.walletId = self.walletId
            controller.mode = .changePassword
            self.presentActionSheet(controller)
        }))
        
        let isHiddenWallet = wallet.credentials?.isHidden == true
        let title = isHiddenWallet ? "Show wallet at main list" : "Hide wallet from main list"
        action.addAction(.init(title: title, style: .default, handler: { [weak self] actionSheet in
            guard let self = self else { return }
            _ = WalletCredentialsManager.update(isHidden: !isHiddenWallet, walletId: self.walletId)
            self.updateWallet()
        }))
        
        if hasPin {
            action.addAction(.init(title: "Cancel pin", style: .destructive, handler: { [weak self] actionSheet in
                guard let self = self else { return }
                let controller = CancelPinController()
                controller.walletId = self.wallet.id
                self.presentActionSheet(controller)
            }))
        }
        
        action.addAction(.init(title: "Restore password", style: .destructive, handler: { [weak self] actionSheet in
            guard let self = self else { return }
            let controller = RestorePasswordController()
            controller.walletId = self.walletId
            self.presentActionSheet(controller)
        }))
        action.isCancelable = true
        self.presentActionSheet(action, animated: true)
    }
    
    @objc
    func showInfo() {
        let controller = InfoCurrencyController()
        controller.wallet = wallet
        self.presentActionSheet(controller, animated: true)
    }
    
    func makeEmptyState() -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none
        cell.contentView.addSubview(emptyTransactionsView)
        emptyTransactionsView.autoPinEdgesToSuperviewEdges()
        emptyTransactionsView.set(image: #imageLiteral(resourceName: "SignNumber"), title: NSLocalizedString("WALLET_TRANSACTION_EMPTY_STATE_TITLE", comment: ""))
        
        return OWSTableItem(customCell: cell,
                            customRowHeight: tableViewController.view.frame.height - WalletHeaderView.Constact.height - 64,
                            actionBlock: nil)
    }
    
    func setupPullToRefresh() {
        refreshControl.tintColor = Theme.secondaryTextAndIconColor
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableViewController.tableView.refreshControl = refreshControl
    }
    
    @objc
    func refresh(refreshControl: UIRefreshControl) {
        loadData() {
            refreshControl.endRefreshing()
        }
    }
    
    func makeTransactionView(props: TransactionView.Props) -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none
        let view = TransactionView()
        view.props = props
        cell.contentView.layoutMargins = .zero
        cell.contentView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        return OWSTableItem(
            customCell: cell,
            customRowHeight: TransactionView.Constant.height,
            actionBlock: { [weak self] in
                let controller = TransactionInfoController()
                controller.config = TransactionInfoController.Config(
                    isRecieved: props.type == .received,
                    address: props.address,
                    amount: props.amount,
                    currency: props.currency,
                    date: props.date.mainFormat(),
                    hash: props.hash)
                self?.presentFormSheet(controller, animated: true)
            }
        )
    }
    
    @objc func applyTheme() {
        setupTransactionHeader()
        self.updateContent(allowedShowEmptyTransaction: true)
    }
}

// MARK: - Pagination

extension WalletDetailController: OWSTableViewControllerWillDisplayDelegate {
    
    func loadNextPage() {
        paginationLoadingIndicator.startAnimating()
        loadMore { [weak self] result in
            switch result {
            case .success(let data):
                if !data.isEmpty {
                    self?.data.append(contentsOf: data)
                    self?.transactionOffset += data.count
                } else {
                    self?.isLoadedAll = true
                }
            case .failure:
                break
            }
            self?.updateContent(allowedShowEmptyTransaction: true)
            self?.paginationLoadingIndicator.stopAnimating()
        }
    }
    
    func loadMore(completion: ((Result<[TransactionView.Props], Error>) -> Void)? = nil) {
        walletModel.getTransactions(
            wallet: wallet,
            limit: transactionPaginationSize,
            offset: transactionOffset,
            tx_direction: selectedTransactionType.fieldName,
            sortBy: selectedSortBy.fieldName,
            ascending: selectedSortBy.ascending
        ) { response in
            switch response {
            case .success(let transactions):
                let data = transactions.compactMap { transaction in
                    return TransactionView.Props(
                        currency: transaction.currency,
                        amount: transaction.amount,
                        transactionName: transaction.hash,
                        date: Date.getDate(timestamp: transaction.createdAt),
                        type: transaction.direction == .out ? .sent : .received,
                        hash: transaction.hash,
                        address: transaction.direction == .out ? transaction.recipient : transaction.sender)
                }
                completion?(.success(data))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    func willDisplay(_ cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        needLoadNextPage = cell.contentView.subviews.contains(paginationLoadingIndicator)
    }
}

// MARK: - Profile Option Action

fileprivate extension WalletDetailController {
    func send() {
        let controller = SendCurrencyFromWalletController()
        controller.wallet = wallet
        navigationController?.pushViewController(controller, animated: true)
    }

    func receive() {
        let controller = ReceiveCurrencyController()
        controller.wallet = wallet
        self.presentActionSheet(controller)
    }
}
