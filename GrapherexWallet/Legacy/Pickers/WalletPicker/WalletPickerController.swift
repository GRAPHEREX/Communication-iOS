//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation
import PureLayout

// MARK: - SINGAL DEPENDENCY – reimplement
final class WalletPickerController: ActionSheetController {
   typealias FinishHandler = (Wallet) -> Void
    
    enum Constant {
        static let height: CGFloat = 64
    }
    
    var finish: FinishHandler?
    public var currencyFilter: Currency?
    
    private var wallets: [Wallet] {
        return WalletModel.shared.wallets.filter { $0.currency == currencyFilter || currencyFilter == nil }
    }
    
    private var filteredWallets: [Wallet] = [] { didSet {
//            setupContent()
        }}
    
//    private let searchBar = OWSSearchBar()
//
    private let tableViewController = WLTTableViewController()

    override func setup() {
        super.setup()
//        searchBar.delegate = self
//        searchBar.sizeToFit()
//        searchBar.placeholder = "Search"
        isCancelable = true
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        setupMargins(margin: 16)
        setupCenterHeader(title: "Choose wallet", close: #selector(close))
        stackView.addArrangedSubview(tableViewController.view)
        tableViewController.tableView.backgroundColor = .clear
//        tableViewController.tableView.tableHeaderView = searchBar
        tableViewController.tableView.keyboardDismissMode = .onDrag
        filteredWallets = wallets

        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nothing)))
    }
    
    @objc func nothing() {}
}


fileprivate extension WalletPickerController {
    func setupContent() {
        let content = WLTTableContents()
        let mainSection = WLTTableSection()
        filteredWallets.forEach {
            mainSection.add(self.createItem(wallet: $0))
        }
        content.addSection(mainSection)
        tableViewController.contents = content
    }

    func createItem(wallet: Wallet) -> WLTTableItem {
        let newCell = WLTTableItem.newCell()

        let view = WalletPickerView()
        view.wallet = wallet
        view.finish = { [weak self] wallet in
            self?.finish?(wallet)
            self?.close()
        }
        newCell.selectionStyle = .none
        newCell.contentView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges()

        return WLTTableItem(customCell: newCell,
                            customRowHeight: Constant.height,
                            actionBlock: nil)
    }

    @objc
    func close() {
        self.dismiss(animated: true, completion:  nil)
    }
    
}
// MARK: - Search
extension WalletPickerController: UISearchBarDelegate {
    
    func searchBar(_: UISearchBar, textDidChange: String) {
        ensureSearchBarCancelButton()
        search()
    }
    
    func search() {
//        guard let text = searchBar.text, !text.isEmpty else {
//            filteredWallets = wallets
//            return
//        }
//        filteredWallets = wallets.filter {
//            $0.currency.name.lowercased().contains(text.lowercased())
//        }
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
//        self.searchBar.text = nil;
        search()
        dismissSearchKeyboard()
        ensureSearchBarCancelButton()
    }
    
    func dismissSearchKeyboard() {
//        searchBar.resignFirstResponder()
    }
    
    func ensureSearchBarCancelButton() {
//        let shouldShowCancelButton: Bool = (searchBar.isFirstResponder || searchBar.text?.count ?? 0 > 0)
//        if searchBar.showsCancelButton == shouldShowCancelButton { return }
//        searchBar.setShowsCancelButton(shouldShowCancelButton, animated: self.isViewLoaded)
    }
    
    @objc func removeFocus() {
//        searchBar.endEditing(true)
    }
}
