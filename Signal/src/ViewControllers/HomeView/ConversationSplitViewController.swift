//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation
import MultipeerConnectivity

@objc
class ConversationSplitViewController: OWSNavigationController, ConversationSplit {
    
    fileprivate var deviceTransferNavController: DeviceTransferNavigationController?

    private let conversationListVC = ConversationListViewController()

    @objc private(set) weak var selectedConversationViewController: ConversationViewController?

    weak var navigationTransitionDelegate: UINavigationControllerDelegate?

    /// The thread, if any, that is currently presented in the view hieararchy. It may be currently
    /// covered by a modal presentation or a pushed view controller.
    @objc var selectedThread: TSThread? {
        guard let selectedConversationViewController = selectedConversationViewController else { return nil }
        return selectedConversationViewController.thread
    }

    /// Returns the currently selected thread if it is visible on screen, otherwise
    /// returns nil.
    @objc var visibleThread: TSThread? {
        guard view.window?.isKeyWindow == true else { return nil }
        guard selectedConversationViewController?.isViewVisible == true else { return nil }
        return selectedThread
    }

    override init() {
        super.init()
        self.setViewControllers([conversationListVC], animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .ThemeDidChange, object: nil)
        applyTheme()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.isDarkThemeEnabled ? .lightContent : .default
    }

    @objc func applyTheme() {
        view.backgroundColor = Theme.secondaryBackgroundColor
        let owsNavBar = navigationBar as? OWSNavigationBar
        owsNavBar?.switchToStyle(.default)
    }

    

    @objc(closeSelectedConversationAnimated:)
    func closeSelectedConversation(animated: Bool) {
        guard let selectedConversationViewController = selectedConversationViewController else { return }

        if let selectedConversationIndex = viewControllers.firstIndex(of: selectedConversationViewController) {
            let targetViewController = viewControllers[max(0, selectedConversationIndex-1)]
            popToViewController(targetViewController, animated: animated)
        }
    }

    @objc
    func presentThread(_ thread: TSThread, action: ConversationViewAction, focusMessageId: String?, animated: Bool) {
        AssertIsOnMainThread()

        guard selectedThread?.uniqueId != thread.uniqueId else {
            // If this thread is already selected, pop to the thread if
            // anything else has been presented above the view.
            guard let selectedConversationVC = selectedConversationViewController else { return }
            popToViewController(selectedConversationVC, animated: animated)
            return
        }

        // Update the last viewed thread on the conversation list so it
        // can maintain its scroll position when navigating back.
        conversationListVC.lastViewedThread = thread

        let threadViewModel = databaseStorage.uiRead {
            return ThreadViewModel(thread: thread,
                                   forConversationList: false,
                                   transaction: $0)
        }
        let vc = ConversationViewController(threadViewModel: threadViewModel, action: action, focusMessageId: focusMessageId)
        vc.hidesBottomBarWhenPushed = true
        
        selectedConversationViewController = vc
        
        if animated {
            showDetailViewController(vc, sender: self)
        } else {
            UIView.performWithoutAnimation { showDetailViewController(vc, sender: self) }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let presentedViewController = presentedViewController {
            return presentedViewController.supportedInterfaceOrientations
        } else {
            return super.supportedInterfaceOrientations
        }
    }

    // The stock implementation of `showDetailViewController` will in some cases,
    // particularly when launching a conversation from another window, fail to
    // recognize the right context to present the view controller. When this happens,
    // it presents the view modally instead of within the split view controller.
    // We never want this to happen, so we implement a version that knows the
    // correct context is always the split view controller.
    private weak var currentRootViewController: UIViewController?
    override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        var viewControllersToDisplay = viewControllers
        // If we already have a detail VC displayed, we want to replace it.
        // The normal behavior of `showDetailViewController` pushes on
        // top of it in collapsed mode.
        if let currentDetailVC = currentRootViewController,
            let detailVCIndex = viewControllersToDisplay.firstIndex(of: currentDetailVC) {
            viewControllersToDisplay = Array(viewControllersToDisplay[0..<detailVCIndex])
        }
        viewControllersToDisplay.append(vc)
        setViewControllers(viewControllersToDisplay, animated: true)

        // If the detail VC is a nav controller, we want to keep track of
        // the root view controller. We use this to determine the start
        // point of the current detail view when replacing it while
        // collapsed. At that point, this nav controller's view controllers
        // will have been merged into the primary nav controller.
        if let vc = vc as? UINavigationController {
            currentRootViewController = vc.viewControllers.first
        } else {
            currentRootViewController = vc
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    @objc func showNewConversationView() {
        conversationListVC.showNewConversationView()
    }

    @objc func showNewGroupView() {
        conversationListVC.showNewGroupView()
    }

    @objc func showAppSettings() {
        conversationListVC.showAppSettings()
    }

    func showAppSettingsWithMode(_ mode: ShowAppSettingsMode) {
        conversationListVC.showAppSettings(mode: mode)
    }

    @objc func focusSearch() {
        conversationListVC.focusSearch()
    }

    @objc func selectPreviousConversation() {
        conversationListVC.selectPreviousConversation()
    }

    @objc func selectNextConversation(_ sender: UIKeyCommand) {
        conversationListVC.selectNextConversation()
    }

    @objc func archiveSelectedConversation() {
        conversationListVC.archiveSelectedConversation()
    }

    @objc func unarchiveSelectedConversation() {
        conversationListVC.unarchiveSelectedConversation()
    }

    @objc func openConversationSettings() {
        guard let selectedConversationViewController = selectedConversationViewController else {
            return owsFailDebug("unexpectedly missing selected conversation")
        }

        selectedConversationViewController.showConversationSettings()
    }

    @objc func focusInputToolbar() {
        guard let selectedConversationViewController = selectedConversationViewController else {
            return owsFailDebug("unexpectedly missing selected conversation")
        }

        selectedConversationViewController.focusInputToolbar()
    }

    @objc func openAllMedia() {
        guard let selectedConversationViewController = selectedConversationViewController else {
            return owsFailDebug("unexpectedly missing selected conversation")
        }

        selectedConversationViewController.openAllMedia()
    }

    @objc func openStickerKeyboard() {
        guard let selectedConversationViewController = selectedConversationViewController else {
            return owsFailDebug("unexpectedly missing selected conversation")
        }

        selectedConversationViewController.openStickerKeyboard()
    }

    @objc func openAttachmentKeyboard() {
        guard let selectedConversationViewController = selectedConversationViewController else {
            return owsFailDebug("unexpectedly missing selected conversation")
        }

        selectedConversationViewController.openAttachmentKeyboard()
    }

    @objc func openGifSearch() {
        guard let selectedConversationViewController = selectedConversationViewController else {
            return owsFailDebug("unexpectedly missing selected conversation")
        }

        selectedConversationViewController.openGifSearch()
    }
}

extension ConversationSplitViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // If we're collapsed and navigating to a list VC (either inbox or archive)
        // the current conversation is no longer selected.
        guard viewController is ConversationListViewController else { return }
        selectedConversationViewController = nil
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return navigationTransitionDelegate?.navigationController?(
            navigationController,
            interactionControllerFor: animationController
        )
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return navigationTransitionDelegate?.navigationController?(
            navigationController,
            animationControllerFor: operation,
            from: fromVC,
            to: toVC
        )
    }
}

@objc extension ConversationListViewController {
    var conversationSplitViewController: ConversationSplitViewController? {
        return SignalApp.shared().rootViewController?.chatListContentController
    }
}

@objc extension ConversationViewController {
    var conversationSplitViewController: ConversationSplitViewController? {
        return SignalApp.shared().rootViewController?.chatListContentController
    }
}

private class NoSelectedConversationViewController: OWSViewController {
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let logoImageView = UIImageView()

    override func loadView() {
        view = UIView()

        let logoContainer = UIView.container()
        logoImageView.image = #imageLiteral(resourceName: "signal-logo-128").withRenderingMode(.alwaysTemplate)
        logoImageView.contentMode = .scaleAspectFit
        logoContainer.addSubview(logoImageView)
        logoImageView.autoPinTopToSuperviewMargin()
        logoImageView.autoPinBottomToSuperviewMargin(withInset: 8)
        logoImageView.autoHCenterInSuperview()
        logoImageView.autoSetDimension(.height, toSize: 72)

        titleLabel.font = UIFont.ows_dynamicTypeBody.ows_semibold
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.text = NSLocalizedString("NO_SELECTED_CONVERSATION_TITLE", comment: "Title welcoming to the app")

        bodyLabel.font = .ows_dynamicTypeBody
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.text = NSLocalizedString("NO_SELECTED_CONVERSATION_DESCRIPTION", comment: "Explanation of how to see a conversation.")

        let centerStackView = UIStackView(arrangedSubviews: [logoContainer, titleLabel, bodyLabel])
        centerStackView.axis = .vertical
        centerStackView.spacing = 4
        view.addSubview(centerStackView)
        // Slightly offset from center to better optically center
        centerStackView.autoAlignAxis(.horizontal, toSameAxisOf: view, withMultiplier: 0.88)
        centerStackView.autoPinWidthToSuperview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.applyTheme), name: .ThemeDidChange, object: nil)

        applyTheme()
    }

    @objc
    override func applyTheme() {
        view.backgroundColor = Theme.backgroundColor
        titleLabel.textColor = Theme.primaryTextColor
        bodyLabel.textColor = Theme.secondaryTextAndIconColor
        logoImageView.tintColor = Theme.isDarkThemeEnabled ? .ows_gray05 : .ows_gray65
    }
}

extension ConversationSplitViewController: DeviceTransferServiceObserver {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        deviceTransferService.addObserver(self)
        deviceTransferService.startListeningForNewDevices()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        deviceTransferService.removeObserver(self)
        deviceTransferService.stopListeningForNewDevices()
    }

    func deviceTransferServiceDiscoveredNewDevice(peerId: MCPeerID, discoveryInfo: [String: String]?) {
        guard deviceTransferNavController?.presentingViewController == nil else { return }
        let navController = DeviceTransferNavigationController()
        deviceTransferNavController = navController
        navController.present(fromViewController: self)
    }

    func deviceTransferServiceDidStartTransfer(progress: Progress) {}

    func deviceTransferServiceDidEndTransfer(error: DeviceTransferService.Error?) {}
}
