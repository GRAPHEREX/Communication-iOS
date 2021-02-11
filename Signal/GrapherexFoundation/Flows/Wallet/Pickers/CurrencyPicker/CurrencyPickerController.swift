//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

final class CurrencyPickerController: ActionSheetController {
    typealias FinishHandler = (Currency) -> Void
    
    enum Constant {
        static let height: CGFloat = 64
    }
    
    var finish: FinishHandler?
    
    public var customCurrencyList: [Currency] = []
    
    private var currencies: [Currency] {
        if customCurrencyList.isEmpty { return WalletModel.shared.currencies }
        return customCurrencyList
    }
    
    private var filteredCurrencies: [Currency] = [] {
        didSet {
            setupContent()
        }
    }
    
    private let searchBar = OWSSearchBar()
    
    private let tableViewController = OWSTableViewController()
    
    override func setup() {
        super.setup()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        isCancelable = true
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        setupMargins(margin: 16)
        setupCenterHeader(title: "Choose currency", close: #selector(close))
        stackView.addArrangedSubview(tableViewController.view)
        tableViewController.tableView.backgroundColor = .clear
        tableViewController.tableView.tableHeaderView = searchBar
        tableViewController.tableView.keyboardDismissMode = .onDrag
        filteredCurrencies = currencies
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nothing)))
    }
    
    @objc func nothing() {}
}

fileprivate extension CurrencyPickerController {
    func setupContent() {
        let content = OWSTableContents()
        let mainSection = OWSTableSection()
        filteredCurrencies.forEach {
            mainSection.add(self.createCurrencyItem(currency: $0))
        }
        content.addSection(mainSection)
        tableViewController.contents = content
    }
    
    func createCurrencyItem(currency: Currency) -> OWSTableItem {
        let newCell = OWSTableItem.newCell()
        
        let view = CurrencyPickerView()
        view.currency = currency
        view.finish = { [weak self] currency in
            self?.finish?(currency)
            self?.close()
        }
        view.autoSetDimension(.height, toSize: Constant.height)
        newCell.selectionStyle = .none
        newCell.contentView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        
        return OWSTableItem(customCell: newCell,
                            customRowHeight: Constant.height,
                            actionBlock: nil)
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion:  nil)
    }
    
}
// MARK: - Search
extension CurrencyPickerController: UISearchBarDelegate {
    
    func searchBar(_: UISearchBar, textDidChange: String) {
        ensureSearchBarCancelButton()
        search()
    }
    
    func search() {
        guard let text = searchBar.text, !text.isEmpty else {
            filteredCurrencies = currencies
            return
        }
        filteredCurrencies = currencies.filter { $0.name.lowercased().contains(text.lowercased()) }
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
        search()
        dismissSearchKeyboard()
        ensureSearchBarCancelButton()
    }
    
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
    
}
