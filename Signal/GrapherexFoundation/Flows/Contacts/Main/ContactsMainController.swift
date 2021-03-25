import UIKit

final class ContactsMainController: UIViewController, UISearchBarDelegate {
        
    private let emptyStateView = EmptyStateView()
    @IBOutlet private var tableViewHolder: UIView!
    private let tableViewController = OWSTableViewController()
    private let outboundCallInitiator = AppEnvironment.shared.outboundIndividualCallInitiator
    private let searchBar = OWSSearchBar()
    private var contacts: [SignalAccount] = [] { didSet {
        reloadTable()
    }}
    private var inviteFlow: InviteFlow!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = Theme.backgroundColor
        searchBar.delegate = self
        searchBar.sizeToFit()
        setupData()
        setupEmptyState()
        setupTableView()
        inviteFlow = InviteFlow(presentingViewController: self)
        searchBar.placeholder = NSLocalizedString("CONTACTLIST_VIEW_SEARCHBAR_PLACEHOLDER",
                                                  comment: "Placeholder text for search bar which filters conversations.");
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .ThemeDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Environment.shared.contactsManager.userRequestedSystemContactsRefresh()
        search()
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("CONTACTS_VIEW_TITLE", comment: "")
        navigationItem.rightBarButtonItems = [
            .init(image: UIImage(imageLiteralResourceName: "plus-24"),
                  style: .plain,
                  target: self,
                  action: #selector(didAddNewContactButtonTap)
            )
        ]
    }
    
    func searchBar(_: UISearchBar, textDidChange: String) {
        ensureSearchBarCancelButton()
        search()
    }
    
    func search() {
        var contacts = [SignalAccount]()
        databaseStorage.uiRead(block: { [weak self] transaction in
            contacts = self?.contactsViewHelper.signalAccounts(
                matchingSearch: self?.searchBar.text ?? "",
                transaction: transaction
                ).filter { !$0.isDeleted } ?? []
            })
        contacts.removeAll(where: { $0.recipientAddress.isMyAddress })
        self.contacts = contacts
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissSearchKeyboard()
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        ensureSearchBarCancelButton()
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        ensureSearchBarCancelButton()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = nil;
        setupData()
        dismissSearchKeyboard()
        ensureSearchBarCancelButton()
    }
}

fileprivate extension ContactsMainController {
    
    func dismissSearchKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func ensureSearchBarCancelButton() {
        let shouldShowCancelButton: Bool = (searchBar.isFirstResponder || searchBar.text?.count ?? 0 > 0)
        if searchBar.showsCancelButton == shouldShowCancelButton { return }
        searchBar.setShowsCancelButton(shouldShowCancelButton, animated: self.isViewLoaded)
    }
    
    @objc func removeFocus() {
        searchBar.endEditing(true)
    }
    
    @objc func applyTheme() {
        view.backgroundColor = Theme.backgroundColor
        reloadTable()
    }
    
    func setupData() {
        contactsViewHelper.addObserver(self)
        search()
    }
    
    func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.set(
            image: UIImage(imageLiteralResourceName: "Contacts"),
            title: NSLocalizedString("CONTACTS_VIEW_EMPTY_TITLE", comment: ""),
            subtitle: NSLocalizedString("CONTACTS_VIEW_EMPTY_SUBTITLE", comment: ""),
            buttonTitle: NSLocalizedString("CONTACTS_VIEW_EMPTY_BUTTON_TITLE", comment: ""),
            action: { [weak self] in
                self?.inviteFriends()
            }
        )
        emptyStateView.autoPin(toEdgesOf: tableViewHolder)
        emptyStateView.isHidden = true
    }
    
    func setupTableView() {
        tableViewHolder.addSubview(tableViewController.view)
        tableViewController.view.autoPinEdgesToSuperviewEdges()
        tableViewController.tableView.backgroundColor = .clear
        tableViewController.tableView.tableHeaderView = searchBar
        tableViewController.tableView.keyboardDismissMode = .onDrag
        tableViewController.swipeActionsConfigurationDelegate = self
        reloadTable()
    }
    
    func reloadTable() {
        if contacts.isEmpty && !isSearching() {
            emptyStateView.isHidden = false
            searchBar.isHidden = true
        } else {
            emptyStateView.isHidden = true
            searchBar.isHidden = false
        }
        let contents: OWSTableContents = .init()
        let mainSection = OWSTableSection()

        mainSection.add(items: contacts.map({ return makeCell(account: $0)}))
        contents.addSection(mainSection)
        tableViewController.contents = contents
    }
    
    func makeCell(account: SignalAccount) -> OWSTableItem {
        let cell = OWSTableItem.newCell()

        let contactView = ContactCellView()
        contactView.shouldShowStatus = false
        databaseStorage.uiRead { transaction in
            contactView.configure(withRecipientAddress: account.recipientAddress, transaction: transaction)
        }

        cell.contentView.addSubview(contactView)
        contactView.autoPinEdge(.top, to: .top, of: cell)
        contactView.autoPinEdge(toSuperviewMargin: .leading)
        contactView.autoPinEdge(toSuperviewMargin: .trailing)
        contactView.autoPinEdge(.bottom, to: .bottom, of: cell)
        contactView.configureCallAction({ [weak self] address in
                guard let self = self else { return }
                self.outboundCallInitiator.initiateCall(address: address)
        })

        return .init(customCell: cell,
                     customRowHeight: 60,
                     actionBlock: { [weak self] in
                        self?.showContactDetail(account: account)
        })
    }
    
    @objc func didAddNewContactButtonTap() {
        let presentAddNewContactControllerAction = ActionSheetAction(title: NSLocalizedString("Insert ID-Key", comment: ""), style: .default) { [weak self] _ in
            self?.presentAddNewContactController()
        }
        
        let presentScanQRControllerAction = ActionSheetAction(title: NSLocalizedString("Scan QR-Code", comment: ""), style: .default) { [weak self] _ in
            self?.presentScanQRController()
        }
        
        let presentInviteFriendsControllerAction = ActionSheetAction(title: NSLocalizedString("INVITE_FRIENDS_CONTACT_TABLE_BUTTON", comment: ""), style: .default) { [weak self] _ in
            self?.inviteFriends()
        }
        
        let actions = [presentAddNewContactControllerAction, presentScanQRControllerAction, presentInviteFriendsControllerAction]
        let actionSheetController = ActionSheetController(title: nil, message: nil)
        actionSheetController.addAction(OWSActionSheets.dismissAction)
        for action in actions {
            actionSheetController.addAction(action)
        }
        present(actionSheetController, animated: true)
    }
    
    private func presentAddNewContactController() {
        let controller = UIStoryboard.makeController(AddNewContactController.self)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func presentScanQRController() {
        let addNewContactController = UIStoryboard.makeController(AddNewContactController.self)
        addNewContactController.loadView()
        addNewContactController.viewDidLoad()
        addNewContactController.hidesBottomBarWhenPushed = true
        
        let scanQRController = ScanQRController()
        scanQRController.hidesBottomBarWhenPushed = true
        scanQRController.returnScreen = addNewContactController
        scanQRController.result = { [weak addNewContactController] uuidString in
            addNewContactController?.setUuidString(uuidString: uuidString)
        }
        navigationController?.pushViewController(scanQRController, animated: true) { [weak self] in
            var vcs = self?.navigationController?.viewControllers
            vcs?.insert(addNewContactController, at: 1)
            self?.navigationController?.viewControllers = vcs ?? []
        }
    }
    
    func showContactDetail(account: SignalAccount) {
        dismissSearchKeyboard()
        let controller = ContactProfileController()
        controller.address = account.recipientAddress
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func inviteFriends() {
        inviteFlow.present(isAnimated: true, completion: nil)
    }
    
    private func isSearching() -> Bool {
        guard let text = searchBar.text else { return false }
        return !text.ows_stripped().isEmpty
    }
}

extension ContactsMainController: OWSTableViewControllerSwipeActionsConfigurationDelegate {
    func canEditRow(at indexPath: IndexPath) -> Bool {
        return true
    }
    
    func leadingSwipeActionsConfigurationForRow(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let title = "Send money"
        
        let sendAction = UIContextualAction(
            style: .normal, title: title,
            handler: { (action, view, completionHandler) in
                completionHandler(true)
                self.sendMoney(at: indexPath)
        })
         sendAction.backgroundColor = .st_accentGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [sendAction])
        return configuration
    }
    
    func trailingSwipeActionsConfigurationForRow(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let title = "Delete"
        
        let deleteAction = UIContextualAction(
            style: .destructive, title: title,
            handler: { (action, view, completionHandler) in
                completionHandler(true)
                self.handleDeleteAction(at: indexPath)
        })
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    private func handleDeleteAction(at indexPath: IndexPath) {
        let alert = ActionSheetController(
            title: NSLocalizedString(
                "CONTACT_DELETE_CONFIRMATION_ALERT_TITLE",
                comment: "Title for the 'contact delete confirmation' alert."
            ),
            message: NSLocalizedString(
                "CONTACT_DELETE_CONFIRMATION_ALERT_MESSAGE",
                comment: "Message for the 'contact delete confirmation' alert."
            )
        )
        alert.addAction(.init(
            title: CommonStrings.deleteButton,
            style: .destructive,
            handler: { [weak self] action in
                self?.removeContact(at: indexPath)
            }
        ))
        
        alert.addAction(OWSActionSheets.cancelAction)
        presentActionSheet(alert)
    }
    
    private func removeContact(at indexPath: IndexPath) {
        contactsManager.deleteSignalAccount(contacts[indexPath.row])
        contacts.remove(at: indexPath.row)
        reloadTable()
    }
    
    private func sendMoney(at indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        
        self.showSendFromChat(recipientAddress: contact.recipientAddress)
    }
}

extension ContactsMainController: ContactsViewHelperObserver {
    func contactsViewHelperDidUpdateContacts() {
        if isSearching() { reloadTable() }
        else { setupData() }
    }
}
