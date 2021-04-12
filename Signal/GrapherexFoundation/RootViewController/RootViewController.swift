import Foundation
import UIKit
import GrapherexWallet

public enum MainTab: Hashable, CaseIterable {
    case contactList
    case callList
    case chatList
    case walletList
    case settingList
}

final class RootViewController: UITabBarController {

    let contactListContentController: OWSNavigationController = OWSNavigationController(rootViewController: UIStoryboard.makeController(ContactsMainController.self))
    let callListContentController: OWSNavigationController = OWSNavigationController(rootViewController: UIStoryboard.makeController(CallsMainController.self))
    let chatListContentController: ConversationSplitViewController = ConversationSplitViewController()
    var walletListContentController: UINavigationController = GrapherexWalletService.shared.createWalletController()
    let settingListContentController: OWSNavigationController = AppSettingsViewController.inModalNavigationController()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.backgroundColor
        UITableView.appearance().separatorStyle = .none

        var contentControllerList: [UIViewController] = .init()
        contentControllerList.reserveCapacity(MainTab.allCases.count)
        for tab in MainTab.allCases {
            let contentController = self.content(forTab: tab)
            let tabItem = UITabBarItem(
                title: nil,
                image: icon(of: tab, as: .regular),
                selectedImage: icon(of: tab, as: .selected)
            )
            tabItem.imageInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
            contentController.tabBarItem = tabItem
            contentControllerList.append(contentController)
        }
        tabBar.tintColor = .gray
        viewControllers = contentControllerList
        selectedTab = .chatList
        tabBar.items.map { $0.forEach { $0.title = nil } }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTheme),
                                               name: .ThemeDidChange, object: nil)
    }
    
    @objc func applyTheme() {
        view.backgroundColor = Theme.backgroundColor
        viewControllers?.forEach({
            guard let tab = tab(forContent: $0) else { return }
            $0.tabBarItem.selectedImage =  icon(of: tab, as: .selected)
        })
    }
    
    private var isChangingSelection = false
}

extension RootViewController {

    private var selectedTab: MainTab {
        get {
            guard let result = tab(forIndex: selectedIndex) else { return .chatList }
            return result
        }
        set(selectedTab) { selectedIndex = index(forTab: selectedTab) }
    }

    private func content(forTab tab: MainTab) -> UINavigationController {
        switch tab {
            case .contactList:
                return contactListContentController
            case .callList:
                return callListContentController
            case .chatList:
                return chatListContentController
            case .walletList:
                return walletListContentController
            case .settingList:
                return settingListContentController
        }
    }

    private func tab(forContent viewController: UIViewController) -> MainTab? {
        switch viewController {
            case contactListContentController:
                return .contactList
            case callListContentController:
                return .callList
            case chatListContentController:
                return .chatList
            case walletListContentController:
                return .walletList
            case settingListContentController:
                return .settingList
            default:
                return nil
        }
    }

    private func tab(forIndex index: Int) -> MainTab? {
        switch index {
            case 0:
                return .contactList
            case 1:
                return .callList
            case 2:
                return .chatList
            case 3:
                return .walletList
            case 4:
                return .settingList
            default:
                return nil
        }
    }

    private func index(forTab tab: MainTab) -> Int {
        switch tab {
            case .contactList:
                return 0
            case .callList:
                return 1
            case .chatList:
                return 2
            case .walletList:
                return 3
            case .settingList:
                return 4
        }
    }
    
    private func icon(of mainTab: MainTab, as variant: IconVariant) -> UIImage? {
        let variantName: String
        switch variant {
            case .regular:   variantName = "regular"
            case .selected:  variantName = "selected"
        }
        let baseName: String
        switch mainTab {
            case .contactList:  baseName = "contactList"
            case .callList:     baseName = "callList"
            case .chatList:     baseName = "chatList"
            case .walletList:   baseName = "walletList"
            case .settingList:  baseName = "settingList"
        }
        
        if #available(iOS 12.0, *) {
            return UIImage(named: "mainTab.\(baseName).icon.\(variantName)", in: nil, compatibleWith: .init(userInterfaceStyle: Theme.isDarkThemeEnabled ? .dark : .light))
        } else {
            return UIImage(named: "mainTab.\(baseName).icon.\(variantName)")
        }
    }
}

extension RootViewController: RootViewControllerProtocol {
    @objc
    var conversationSplitViewController: ConversationSplitViewController {
        return chatListContentController
    }
    
    var selectedController: UINavigationController {
        return content(forTab: selectedTab)
    }
}

extension RootViewController: ConversationSplit {
    @objc var visibleThread: TSThread? {
        return selectedTab == .chatList ? chatListContentController.selectedThread : nil
    }
}

extension RootViewController {
    @objc func openConversationsList() {
        selectedTab = .chatList
    }
}
