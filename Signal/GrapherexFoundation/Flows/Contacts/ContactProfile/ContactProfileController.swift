//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class ContactProfileController: OWSViewController {
    
    private let tableViewController = OWSTableViewController()
    private let outboundCallInitiator = AppEnvironment.shared.outboundIndividualCallInitiator
    private var thread: TSThread!
    private var threadViewModel: ThreadViewModel?
    public var address: SignalServiceAddress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.backgroundColor
        title = NSLocalizedString("MAIN_PROFILE", comment: "")
        setupTableView()
        makeCells()
        navigationItem.leftBarButtonItem = createOWSBackButton()
        navigationItem.leftBarButtonItem?.imageInsets.left = -8
        updateRighBarButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(identityStateDidChange), name: .identityStateDidChange, object: nil)
    }
    
    @objc func identityStateDidChange() {
        updateRighBarButton()
    }
    
    private func updateRighBarButton() {
        if canVerification() {
            let icon: UIImage
            if OWSIdentityManager.shared.verificationState(for: address) == .verified {
                icon = Theme.iconImage(.verificationActive, alwaysTemplate: false).withRenderingMode(.alwaysOriginal)
            }
            else {
                icon = Theme.iconImage(.verificationNonActive, alwaysTemplate: false).withRenderingMode(.alwaysOriginal)
            }
            navigationItem.rightBarButtonItem = .init(
                image: icon,
                style: .plain,
                target: self,
                action: #selector(showVerificationView))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}

fileprivate extension ContactProfileController {
    func canVerification() -> Bool {
        return address.uuid != nil && OWSIdentityManager.shared.identityKey(for: address) != nil
    }
    
    func setupTableView() {
        view.addSubview(tableViewController.view)
        tableViewController.view.autoPinEdgesToSuperviewSafeArea()
        tableViewController.tableView.backgroundColor = Theme.backgroundColor
        tableViewController.tableView.separatorStyle = .none
        self.definesPresentationContext = false
    }
    
    @objc func showVerificationView() {
        guard let contactThread = thread as? TSContactThread else {
            owsFailDebug("Invalid thread.")
            return
        }
        let contactAddress = contactThread.contactAddress
        assert(contactAddress.isValid)
        FingerprintViewController.present(from: self, address: contactAddress)
    }
    
    func makeCells() {
        let contents = OWSTableContents()
        
        let headerSection = OWSTableSection()
        headerSection.add(makeProfileHeaderCell())
        
        let mainSection = OWSTableSection()
//        if let mobile = address.phoneNumber {
//            mainSection.add(makeInfoCell(for: NSLocalizedString("MAIN_MOBILE", comment: ""),
//                                         value: mobile))
//        }
        mainSection.add(makeInfoCell(for: NSLocalizedString("MAIN_DISPLAY_NAME", comment: ""),
                                     value: contactsManager.displayName(for: address)))
        
        let blockSection = OWSTableSection()
        blockSection.add(makeBlockCell())
        
        contents.addSection(headerSection)
        contents.addSection(mainSection)
        contents.addSection(blockSection)
        
        tableViewController.contents = contents
    }
    
    func makeProfileHeaderCell() -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        let headerView = HeaderContactProfileView()
        thread = TSContactThread.getOrCreateThread(contactAddress: address)
        var options: [ProfileOptionView] = [ProfileOptionView(option: .message, action: { [weak self] in
            guard let self = self else { return }
            self.threadViewModel = self.databaseStorage.uiRead {
                return ThreadViewModel(thread: self.thread, forConversationList: false, transaction: $0)
            }
            self.showMessage()
        })]
        
        if !(thread.isNoteToSelf) {
            options.append(contentsOf: [
                ProfileOptionView(option: .call, action: { [weak self] in
                    guard let self = self else { return }
                    self.didCallTap()
                }),
                ProfileOptionView(option: .video, action: { [weak self] in
                    guard let self = self else { return }
                    self.didCallTap(isVideo: true)
                })
            ])
        }
        
        if canVerification() {
            options.append(
                ProfileOptionView(option: .userId, action: { [weak self] in
                    self?.showUserIdInfo()
                    }
            ))
        }
        
        headerView.setup(
            fullName: contactsManager.displayName(for: address),
            subtitle: "",
            image: getAvatar(),
            options: options
        )
        
        cell.contentView.addSubview(headerView)
        cell.selectionStyle = .none
        headerView.autoPinEdge(.trailing, to: .trailing, of: cell.contentView)
        headerView.autoPinEdge(.leading, to: .leading, of: cell.contentView)
        cell.backgroundColor = .st_neutralGrayBackground
        headerView.autoPinEdge(.top, to: .top, of: cell.contentView)
        headerView.autoPinEdge(.bottom, to: .bottom, of: cell.contentView)
        
        appendDivider(to: cell.contentView)
        return .init(customCell: cell,
                     customRowHeight: HeaderContactProfileView.Constact.height)
    }
    
    func showMessage() {
        guard let threadViewModel = self.threadViewModel else { return }
        let controller = ConversationViewController(threadViewModel: threadViewModel,
                                                    action: .none,
                                                    focusMessageId: nil)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func makeInfoCell(for parameterName: String, value: String) -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none
        let parameterLabel = UILabel()
        parameterLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        parameterLabel.text = parameterName
        parameterLabel.textColor = .st_neutralGray
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
        valueLabel.textColor = Theme.primaryTextColor
        valueLabel.text = value
        
        cell.contentView.addSubview(parameterLabel)
        cell.contentView.addSubview(valueLabel)
        cell.contentView.layoutMargins = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        parameterLabel.autoPinLeadingToSuperviewMargin()
        parameterLabel.autoPinTopToSuperviewMargin()
        parameterLabel.autoPinTrailingToSuperviewMargin()
        
        valueLabel.autoPinEdge(.bottom, to: .bottom, of: cell.contentView, withOffset: -8)
        valueLabel.autoPinLeadingToSuperviewMargin()
        valueLabel.autoPinTrailingToSuperviewMargin()
        
        appendMarginDivider(to: cell.contentView)
        return .init(customCell: cell,
                     customRowHeight: 56)
    }
    
    func makeDisclosureCell(title: String, action: @escaping () -> Void) -> OWSTableItem {
       let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
        titleLabel.text = title
        titleLabel.textColor = UIColor.st_neutralGray
        
        cell.contentView.layoutMargins = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        cell.contentView.addSubview(titleLabel)
        titleLabel.autoVCenterInSuperview()
        titleLabel.autoPinLeadingToSuperviewMargin()
        
        let disclosureImage = UIImage(imageLiteralResourceName: CurrentAppContext().isRTL ? "NavBarBack" : "NavBarBackRTL")
        let disclosureButton = UIImageView(image: disclosureImage.withRenderingMode(.alwaysTemplate))
        disclosureButton.tintColor = UIColor(rgbHex: 0xCCCCCC)
        cell.contentView.addSubview(disclosureButton)
        disclosureButton.autoSetDimensions(to: CGSize(width: 11, height: 14))
        disclosureButton.autoVCenterInSuperview()
        disclosureButton.autoPinTrailingToSuperviewMargin()
        disclosureButton.autoPinLeading(toTrailingEdgeOf: titleLabel, offset: 16)
        disclosureButton.setContentCompressionResistancePriority((.defaultHigh + 1), for: .horizontal)
      
        appendMarginDivider(to: cell)
        return .init(customCell: cell,
                     customRowHeight: 56,
                     actionBlock: action)
    }
    
    func showUserIdInfo() {
        let controller = UserIDViewController()
        controller.address = address
        let modal = OWSNavigationController(rootViewController: controller)
        navigationController?.present(modal, animated: true, completion: nil)
    }
    
    func makeBlockCell() -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        let blockLabel = UILabel()

        blockLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
        blockLabel.text = NSLocalizedString(blockingManager.isAddressBlocked(address) ? "MAIN_UNBLOCK" : "MAIN_BLOCK_USER" , comment: "")
        blockLabel.textColor = blockingManager.isAddressBlocked(address) ? Theme.primaryTextColor : .st_otherRed

        cell.contentView.addSubview(blockLabel)
        
        blockLabel.autoPinEdge(.leading, to: .leading, of: cell.contentView, withOffset: 16)
        blockLabel.autoVCenterInSuperview()
        blockLabel.autoPinEdge(.trailing, to: .trailing, of: cell.contentView, withOffset: -16)
        
        appendDivider(to: cell.contentView)
        return .init(
            customCell: cell,
            customRowHeight: 56,
            actionBlock: { [weak self] in
                self?.didBlockTap(address: self?.address)
            }
        )
    }
    
    func didBlockTap(address: SignalServiceAddress?) {
        guard let address = address else { return }
        let isCurrentlyBlocked = blockingManager.isAddressBlocked(address)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if isCurrentlyBlocked {
                BlockListUIUtils.showUnblockAddressActionSheet(address, from: self) { _ in
                    self.makeCells()
                }
            } else {
                BlockListUIUtils.showBlockAddressActionSheet(address, from: self) { _ in
                    self.makeCells()
                }
            }
        }
    }
    
    func getAvatar() -> UIImage? {
        guard address?.isValid == true else { return nil }
    
        let colorName: ConversationColorName? = thread != nil
            ? thread?.conversationColorName
            : TSThread.stableColorNameForNewConversation(with: address?.stringForDisplay ?? "")

        guard let colorName_ = colorName else { return nil }
        
        let avatarBuilder = OWSContactAvatarBuilder(
            address: address,
            colorName: colorName_,
            diameter: UInt(80)
        )
        return avatarBuilder.build()
    }
    
    func didCallTap(isVideo: Bool = false) {
        outboundCallInitiator.initiateCall(address: address, isVideo: isVideo)
    }
    
    func appendDivider(to view: UIView) {
        let divider = UIView()
        view.addSubview(divider)
        divider.autoSetDimension(.height, toSize: 1)
        divider.backgroundColor = Theme.outlineColor;
        divider.autoPinEdge(.bottom, to: .bottom, of: view)
        divider.autoPinEdge(.leading, to: .leading, of: view)
        divider.autoPinEdge(.trailing, to: .trailing, of: view)
    }
    
    func appendMarginDivider(to view: UIView) {
        let divider = UIView()
        view.addSubview(divider)
        divider.autoSetDimension(.height, toSize: 1)
        divider.backgroundColor = Theme.outlineColor;
        divider.autoPinLeadingToSuperviewMargin()
        divider.autoPinEdge(.trailing, to: .trailing, of: view)
        divider.autoPinEdge(.bottom, to: .bottom, of: view)
    }

}
