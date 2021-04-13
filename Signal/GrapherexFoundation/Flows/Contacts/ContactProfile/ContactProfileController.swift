//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class ContactProfileController: OWSTableViewController2 {
    
    private let outboundCallInitiator = AppEnvironment.shared.outboundIndividualCallInitiator
    private var thread: TSThread!
    private var threadViewModel: ThreadViewModel?
    public var address: SignalServiceAddress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("MAIN_PROFILE", comment: "")
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
        
        let mainSection = OWSTableSection()
        
        let header = makeProfileHeader()
        header.backgroundColor = .clear
        mainSection.customHeaderView = header
        
//        if let mobile = address.phoneNumber {
//            mainSection.add(makeInfoCell(for: NSLocalizedString("MAIN_MOBILE", comment: ""),
//                                         value: mobile))
//        }
        if canVerification() {
            mainSection.add(makeUserIdCell())
        }
        
        mainSection.add(makeInfoCell(for: NSLocalizedString("MAIN_DISPLAY_NAME", comment: ""),
                                     value: contactsManager.displayName(for: address)))
        
        contents.addSection(mainSection)
        contents.addSection(buildBlocSection())
        
        self.contents = contents
    }
    
    func makeProfileHeader() -> UIView {
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
        
        options.append(
            ProfileOptionView(option: .send, action: { [weak self] in
                guard let self = self else { return }
                self.showSendFromChat(recipientAddress: self.address)
            }
        ))
        
        headerView.setup(
            fullName: contactsManager.displayName(for: address),
            subtitle: "",
            image: getAvatar(),
            options: options
        )
        
        return headerView
    }
    
    func showMessage() {
        guard let threadViewModel = self.threadViewModel else { return }
        let controller = ConversationViewController(threadViewModel: threadViewModel,
                                                    action: .none,
                                                    focusMessageId: nil)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func makeUserIdCell() -> OWSTableItem {
        return OWSTableItem(customCellBlock: { [weak self] in
            guard let self = self else {
                owsFailDebug("Missing self")
                return OWSTableItem.newCell()
            }
            
            return OWSTableItem.buildDisclosureCell(name: "User Id",
                                                    icon: .userId,
                                                    accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "user_id"))
        },
        actionBlock: { [weak self] in
            guard let self = self else {
                owsFailDebug("Missing self")
                return
            }
            if self.contactsManagerImpl.supportsContactEditing {
                self.showUserIdInfo()
            }
        })
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
    
    func buildBlocSection() -> OWSTableSection {
        let section = OWSTableSection()
        
        section.footerTitle = NSLocalizedString("CONVERSATION_SETTINGS_BLOCK_AND_LEAVE_SECTION_CONTACT_FOOTER",
                                                comment: "Footer text for the 'block and leave' section of contact conversation settings view.")
        
        let isCurrentlyBlocked = blockingManager.isThreadBlocked(thread)

        section.add(OWSTableItem(customCellBlock: { [weak self] in
            guard let self = self else {
                owsFailDebug("Missing self")
                return OWSTableItem.newCell()
            }
            
            let cellTitle: String
            var customColor: UIColor?
            if isCurrentlyBlocked {
                cellTitle =
                    (self.thread.isGroupThread
                        ? NSLocalizedString("CONVERSATION_SETTINGS_UNBLOCK_GROUP",
                                            comment: "Label for 'unblock group' action in conversation settings view.")
                        : NSLocalizedString("CONVERSATION_SETTINGS_UNBLOCK_USER",
                                            comment: "Label for 'unblock user' action in conversation settings view."))
            } else {
                cellTitle =
                    (self.thread.isGroupThread
                        ? NSLocalizedString("CONVERSATION_SETTINGS_BLOCK_GROUP",
                                            comment: "Label for 'block group' action in conversation settings view.")
                        : NSLocalizedString("CONVERSATION_SETTINGS_BLOCK_USER",
                                            comment: "Label for 'block user' action in conversation settings view."))
                customColor = UIColor.ows_accentRed
            }
            let cell = OWSTableItem.buildIconNameCell(icon: .settingsBlock,
                                                      itemName: cellTitle,
                                                      customColor: customColor,
                                                      accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "block"))
            return cell
        },
        actionBlock: { [weak self] in
            self?.didBlockTap(address: self?.address)
        }))

        return section
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
