import UIKit
import PureLayout

final public class WalletMainController: UIViewController {

    @IBOutlet var tableViewHolder: UIView!
    private let tableViewController = WLTTableViewController()
    private let mainLoadingIndicator = UIActivityIndicatorView()
    
    enum Constant {
        static let remindersHeight: CGFloat = 102
        static let headerHeight: CGFloat = 120
    }
    
    // MARK: - Dependencies
    
    private var model: WalletModel {
        return WalletModel.shared
    }
    
    private var showOnlyHidden: Bool = false {
        didSet {
            self.setupNavigationBar()
            filteredWallets = props.wallets.filter { $0.isHidden == showOnlyHidden }
        }
    }
    
    struct Props {
        let wallets: [WalletCell.Props]
        let totalCurrency: String
        
        static let initial = Props(wallets: [], totalCurrency: "")
    }
    
    private var props: Props = .initial { didSet {
        filteredWallets = props.wallets.filter { $0.isHidden == showOnlyHidden }
    }}
    
    private var filteredWallets: [WalletCell.Props] = [] { didSet {
            render()
        }}
    private let credentialsManager: CredentialsManager = WalletCredentialsManager()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
        setupTableView()
        setupNavigationBar()
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(themeDidChange),
//            name: .ThemeDidChange,
//            object: nil
//        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateWallet),
            name: WalletModel.walletCredentionalsDidChange,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateWalletsFired),
            name: WalletModel.walletsNeedUpdate,
            object: nil
        )
        
        mainLoadingIndicator.startAnimating()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if props.wallets.isEmpty {
            self.showOnlyHidden = false
            loadData()
        }
    }
}

fileprivate extension WalletMainController {
    @objc
    func updateWallet() {
        let wallets = model.wallets
        
        props = .init(
            wallets: wallets.map { wallet in
                return WalletCell.Props(
                    title: wallet.currency.name,
                    walletId: wallet.id,
                    currency: wallet.currency,
                    currencyIcon: self.model.getCurrencyIconUrl(wallet.currency) ?? "",
                    balance: wallet.balanceStr + " " + wallet.currency.symbol.lowercased(),
                    currencyBalance: wallet.fiatCurrency + " " + wallet.fiatBalanceStr,
                    hasPin: wallet.credentials?.pin != nil,
                    needPassword: wallet.needPassword,
                    isHidden: wallet.credentials?.isHidden == true
                )
            },
            totalCurrency: props.totalCurrency
        )
    }
    
    // MARK: - SINGAL DEPENDENCY – reimplement
//    func setupReminders() -> WLTTableItem {
//        let cell = WLTTableItem.newCell()
//        let deregisteredView = ReminderView.nag(
//            text: TSAccountManager.shared().isPrimaryDevice
//                ? NSLocalizedString("DEREGISTRATION_WARNING", comment: "Label warning the user that they have been de-registered.")
//                : NSLocalizedString(
//                    "UNLINKED_WARNING", comment: "Label warning the user that they have been unlinked from their primary device."), tapAction: {
////                        RegistrationUtils.showReregistrationUI(from: self)
//        })
//
//
//        cell.selectionStyle = .none
//        cell.contentView.addSubview(deregisteredView)
//        deregisteredView.autoPinEdgesToSuperviewEdges()
//
//        return WLTTableItem(
//            customCellBlock: { return cell },
//            customRowHeight: Constant.remindersHeight,
//            actionBlock: {
//                RegistrationUtils.showReregistrationUI(from: self)
//        })
//    }

    func setupTableView() {
        tableViewHolder.addSubview(tableViewController.view)
        tableViewController.view.autoPinEdgesToSuperviewEdges()
        tableViewController.tableView.backgroundColor = .clear
        tableViewController.editActionDelegate = self
        tableViewController.swipeActionsConfigurationDelegate = self
        setupPullToRefresh()
        
        tableViewController.tableView.addSubview(mainLoadingIndicator)
        mainLoadingIndicator.autoCenterInSuperview()
        mainLoadingIndicator.bringSubviewToFront(tableViewController.tableView)
        
        let contents: WLTTableContents = .init()
        let headerSection = WLTTableSection()
        
        let headerCell = WLTTableItem.newCell()
        headerCell.selectionStyle = .none
        let walletMainHeader = WalletMainHeaderCell()
        walletMainHeader.props = .init(balance: "USD 0.00")
        headerCell.contentView.addSubview(walletMainHeader)
        walletMainHeader.autoPinEdgesToSuperviewEdges()
        
        let owsItem = WLTTableItem(
            customCellBlock: { return headerCell },
            customRowHeight: 80,
            actionBlock: nil
        )
        headerSection.add(owsItem)
        
        contents.addSection(headerSection)
        
        tableViewController.contents = contents
    }
    
    func setNoDataState() {
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
                    title: "No data"
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
        let contents: WLTTableContents = .init()
        let headerSection = WLTTableSection()
        let mainSection = WLTTableSection()

        if !showOnlyHidden {
            let headerCell = WLTTableItem.newCell()
            headerCell.selectionStyle = .none
            let walletMainHeader = WalletMainHeaderCell()
            walletMainHeader.props = .init(balance: props.totalCurrency)
            headerCell.contentView.addSubview(walletMainHeader)
            walletMainHeader.autoPinEdgesToSuperviewEdges()
            
            let owsItem = WLTTableItem(
                customCellBlock: { return headerCell },
                customRowHeight: 80,
                actionBlock: nil
            )
            headerSection.add(owsItem)
        }
        
        if props.wallets.isEmpty {
            let customRowHeight = tableViewController.tableView.frame.height - Constant.headerHeight
            guard customRowHeight > 0 else { return }
            headerSection.add(WLTTableItem(
                customCellBlock: {
                    let cell = WLTTableItem.newCell()
                    let emptyView = SecondaryEmptyStateView()
                    emptyView.set(
                        image: UIImage.image(named: "wallet"),
                        title: "No wallets"
                    )
                    cell.contentView.addSubview(emptyView)
                    emptyView.autoCenterInSuperviewMargins()
                    return cell
            },
                customRowHeight: tableViewController.tableView.frame.height - Constant.headerHeight,
                actionBlock: nil
            ))
        } else {
            if filteredWallets.isEmpty {
                headerSection.add(WLTTableItem(
                    customCellBlock: {
                        let cell = WLTTableItem.newCell()
                        let emptyView = SecondaryEmptyStateView()
                        emptyView.set(
                            image: UIImage.image(named: "wallet"),
                            title: "All wallets are hidden"
                        )
                        cell.contentView.addSubview(emptyView)
                        emptyView.autoCenterInSuperviewMargins()
                        return cell
                },
                    customRowHeight: tableViewController.tableView.frame.height - Constant.headerHeight,
                    actionBlock: nil
                ))
            } else {
                mainSection.add(items: 
                    filteredWallets.map {
                        let cell = WLTTableItem.newCell()
                        cell.selectionStyle = .none
                        cell.layoutMargins.top = 16
                        cell.layoutMargins.bottom = 16
                        cell.layoutMargins.right = cell.layoutMargins.left
                        let walletItem = WalletCell()
                        let props = $0
                        walletItem.props = props
                        cell.contentView.addSubview(walletItem)
                        walletItem.autoPinEdgesToSuperviewMargins()
                        return .init(
                            customCell: cell,
                            customRowHeight: UITableView.automaticDimension,
                            actionBlock: { [weak self] in
                                self?.tap(
                                    walletId: props.walletId,
                                    hasPin: props.hasPin,
                                    needPassword: props.needPassword
                                )
                            }
                        )
                })
            }
        }
        contents.addSection(headerSection)
        contents.addSection(mainSection)
        mainLoadingIndicator.isHidden = true
        mainLoadingIndicator.stopAnimating()
        
        tableViewController.contents = contents
        
        if !model.currencies.isEmpty {
            //        Hide until implementation
            //
//            navigationItem.leftBarButtonItem = UIBarButtonItem(
//                image: #imageLiteral(resourceName: "icon.swap.h"),
//                style: .plain,
//                target: self,
//                action: #selector(exchangeButtonPressed)
//            )
              
            // MARK: - SINGAL DEPENDENCY – reimplement
//            if !TSAccountManager.shared().isDeregistered() {
//                navigationItem.rightBarButtonItem = UIBarButtonItem(
//                    image: UIImage(named: "icon.dots"),
//                    style: .plain,
//                    target: self,
//                    action: #selector(showMenu)
//                )
//            }
        }
    }
    
    func tap(walletId: String, hasPin: Bool, needPassword: Bool) {
        if needPassword {
            let controller = PasswordController()
            controller.walletId = walletId
            controller.mode = .setFirstPassword
            controller.completion = { [weak self] in
                self?.showTransactions(walletId: walletId, hasPin: hasPin)
            }
            self.presentActionSheet(controller, animated: true)
        } else {
            showTransactions(walletId: walletId, hasPin: hasPin)
        }
    }
    
    func showTransactions(walletId: String, hasPin: Bool) {
        if !hasPin {
            showTransactionList(walletId: walletId)
            return 
        }
        let pin = EnterPinController()
        pin.walletId = walletId
        pin.finish = { [weak self] isSuccess in
            if isSuccess {
                self?.showTransactionList(walletId: walletId)
            }
        }
        self.presentActionSheet(pin)
    }
    
    func showTransactionList(walletId: String) {
        let controller = WalletDetailController()
        controller.walletId = walletId
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func setupPullToRefresh() {
        let pullToRefreshView = UIRefreshControl()
        pullToRefreshView.tintColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        pullToRefreshView.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableViewController.tableView.refreshControl = pullToRefreshView
    }
    
    func loadData(completion: (() -> Void)? = nil) {
        model.initWallets { [weak self] result in
            switch result {
            case .success(let data):
                self?.tableViewController.tableView.backgroundView?.isHidden = true
                self?.props = .init(
                    wallets: data.wallets.map { wallet in
                        return WalletCell.Props(
                            title: wallet.currency.name,
                            walletId: wallet.id,
                            currency: wallet.currency,
                            currencyIcon: self?.model.getCurrencyIconUrl(wallet.currency) ?? "",
                            balance: wallet.balanceStr + " " + wallet.currency.symbol.lowercased(),
                            currencyBalance: wallet.fiatCurrency + " " + wallet.fiatBalanceStr,
                            hasPin: wallet.credentials?.pin != nil,
                            needPassword: wallet.needPassword,
                            isHidden: wallet.credentials?.isHidden == true
                        )
                    },
                    totalCurrency: data.fiatCurrency + " " + data.fiatTotalBalance
                )
            case .failure(_):
                if self?.props.wallets.isEmpty == true {
                    self?.setNoDataState()
                }
            }
            completion?()
        }
    }
    
    @objc
    func updateWalletsFired(_ notification: NSNotification) {
        loadData()
    }
    
    @objc
    func refresh(refreshControl: UIRefreshControl) {
        loadData() {
            refreshControl.endRefreshing()
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = showOnlyHidden ? "Hidden wallets" : "Wallets"
    }
    
    @objc func exchangeButtonPressed() {
        let controller = WalletExchangeController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func plusButtonPressed() {
        let controller = NewWalletController()
        self.presentActionSheet(controller)
    }
    
    @objc func showMenu() {
        let action = ActionSheetController()
        
        action.addAction(.init(title: "Create new wallet", style: .default, handler: { [weak self] action in
            self?.plusButtonPressed()
        }))
        
        if !props.wallets.filter({ $0.isHidden == true }).isEmpty {
            let title = showOnlyHidden ? "Show main wallets" : "Show hidden wallets"
            action.addAction(.init(title: title, style: .default, handler: { [weak self] action in
                self?.showOnlyHidden.toggle()
                self?.render()
            }))
        }
        
        action.isCancelable = true
        self.presentActionSheet(action, animated: true)
    }
    
    @objc func themeDidChange() {
        view.backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
        render()
    }
}

extension WalletMainController: WLTTableViewControllerEditActionDelegate, WLTTableViewControllerSwipeActionsConfigurationDelegate {
    
    public func leadingSwipeActionsConfigurationForRow(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let title = filteredWallets[indexPath.row].isHidden ? "Show" : "Hide"
        
        let hideAction = UIContextualAction(
            style: .normal, title: title,
            handler: { (action, view, completionHandler) in
                completionHandler(true)
                self.handleHideAction(on: indexPath)
        })
        hideAction.backgroundColor = .stwlt_otherBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [hideAction])
        return configuration
    }
    
    public func trailingSwipeActionsConfigurationForRow(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        guard let wallet = model.getWalletById(id: filteredWallets[indexPath.row].walletId)
            else { return UISwipeActionsConfiguration(actions: [ ]) }
        
        let sendAction = UIContextualAction(
            style: .normal, title: NSLocalizedString("MAIN_SEND", comment: ""),
            handler: { (action, view, completionHandler) in
                completionHandler(true)
                self.send(wallet: wallet)
        })
        sendAction.backgroundColor = .stwlt_accentGreen
        
        let recieveAction = UIContextualAction(
            style: .normal, title: NSLocalizedString("MAIN_RECEIVE", comment: ""),
            handler: { (action, view, completionHandler) in
                completionHandler(true)
                self.receive(wallet: wallet)
        })
        recieveAction.backgroundColor = .stwlt_accentGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [sendAction, recieveAction])
        return configuration
    }
    
    public func canEditRow(at indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    public func editActionsForRow(at indexPath: IndexPath) -> [Any] { return [ ] }
    
    private func handleHideAction(on indexPath: IndexPath) {
        let message = filteredWallets[indexPath.row].isHidden
        ? "Do you want to show this wallet at main list?"
        : "Do you want to hide this wallet from main list?"
        
        let alert = ActionSheetController(
            title: "Attention",
            message: message
        )
        
        alert.addAction(.init(
            title: "Yes",
            style: .destructive,
            handler: { [weak self] action in
                guard let self = self else { return }
                self.credentialsManager.setHidden(forWalletWithId: self.filteredWallets[indexPath.row].walletId,
                                                  isHidden: !self.filteredWallets[indexPath.row].isHidden) { [weak self](_) in
                    guard let self = self else { return }
                    if self.filteredWallets.count < 1 && self.showOnlyHidden {
                        self.showOnlyHidden = false
                        self.render()
                    }

                }
            }
        ))
        
        // MARK: - SINGAL DEPENDENCY – reimplement
//        alert.addAction(OWSActionSheets.cancelAction)
        presentActionSheet(alert)
    }
}

fileprivate extension WalletMainController {
    func send(wallet: Wallet) {
        let controller = SendCurrencyFromWalletController()
        controller.wallet = wallet
        controller.hidesBottomBarWhenPushed = true
        
        if wallet.credentials?.pin != nil {
            let pin = EnterPinController()
            pin.walletId = wallet.id
            pin.finish = { [weak self] isSuccess in
                if isSuccess {
                    self?.navigationController?.pushViewController(controller, animated: true)
                }
            }
            self.presentActionSheet(pin)
        } else {
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    func receive(wallet: Wallet) {
        let controller = ReceiveCurrencyController()
        controller.wallet = wallet
        self.presentActionSheet(controller)
    }
}
