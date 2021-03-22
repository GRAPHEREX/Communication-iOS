//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc
class AppSettingsViewController: OWSTableViewController2 {

    @objc
    class func inModalNavigationController() -> OWSNavigationController {
        return OWSNavigationController(rootViewController: AppSettingsViewController())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("SETTINGS_NAV_BAR_TITLE", comment: "Title for settings activity")
//        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))

        defaultSeparatorInsetLeading = Self.cellHInnerMargin + 24 + OWSTableItem.iconSpacing

        updateTableContents()

        if let localAddress = tsAccountManager.localAddress {
            bulkProfileFetch.fetchProfile(address: localAddress)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localProfileDidChange),
            name: .localProfileDidChange,
            object: nil
        )
    }

    @objc
    func didTapDone() {
        dismiss(animated: true)
    }

    @objc
    func localProfileDidChange() {
        AssertIsOnMainThread()
        updateTableContents()
    }

    func updateTableContents() {
        let contents = OWSTableContents()

        let profileSection = OWSTableSection()
        profileSection.add(.init(
            customCellBlock: { self.profileCell() },
            actionBlock: { [weak self] in
                let vc = MyProfileViewController()
                vc.completionHandler = { completedVC in
                    completedVC.navigationController?.popViewController(animated: true)
                }
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        ))
        contents.addSection(profileSection)

//        let section1 = OWSTableSection()
//        section1.add(.disclosureItem(
//            icon: .settingsAccount,
//            name: NSLocalizedString("SETTINGS_ACCOUNT", comment: "Title for the 'account' link in settings."),
//            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "account"),
//            actionBlock: { [weak self] in
//                let vc = AccountSettingsViewController()
//                self?.push(viewController: vc)
//            }
//        ))
//        section1.add(.disclosureItem(
//            icon: .settingsLinkedDevices,
//            name: NSLocalizedString("LINKED_DEVICES_TITLE", comment: "Menu item and navbar title for the device manager"),
//            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "linked-devices"),
//            actionBlock: { [weak self] in
//                let vc = LinkedDevicesTableViewController()
//                self?.push(viewController: vc)
//            }
//        ))
//        contents.addSection(section1)

        let section2 = OWSTableSection()
        section2.add(.disclosureItem(
            icon: .settingsAppearance,
            name: NSLocalizedString("SETTINGS_APPEARANCE_TITLE", comment: "The title for the appearance settings."),
            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "appearance"),
            actionBlock: { [weak self] in
                let vc = AppearanceSettingsTableViewController()
                self?.push(viewController: vc)
            }
        ))
        section2.add(.disclosureItem(
            icon: .settingsChats,
            name: NSLocalizedString("SETTINGS_CHATS", comment: "Title for the 'chats' link in settings."),
            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "chats"),
            actionBlock: { [weak self] in
                let vc = ChatsSettingsViewController()
                self?.push(viewController: vc)
            }
        ))
        section2.add(.disclosureItem(
            icon: .settingsNotifications,
            name: NSLocalizedString("SETTINGS_NOTIFICATIONS", comment: "The title for the notification settings."),
            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "notifications"),
            actionBlock: { [weak self] in
                let vc = NotificationSettingsViewController()
                self?.push(viewController: vc)
            }
        ))
        section2.add(.disclosureItem(
            icon: .settingsPrivacy,
            name: NSLocalizedString("SETTINGS_PRIVACY_TITLE", comment: "The title for the privacy settings."),
            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "privacy"),
            actionBlock: { [weak self] in
                let vc = PrivacySettingsViewController()
                self?.push(viewController: vc)
            }
        ))
        section2.add(.disclosureItem(
            icon: .settingsDataUsage,
            name: NSLocalizedString("SETTINGS_DATA", comment: "Label for the 'data' section of the app settings."),
            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "data-usage"),
            actionBlock: { [weak self] in
                let vc = DataSettingsTableViewController()
                self?.push(viewController: vc)
            }
        ))
        contents.addSection(section2)

        let section3 = OWSTableSection()
        section3.add(.disclosureItem(
            icon: .settingsHelp,
            name: NSLocalizedString("SETTINGS_HELP", comment: "Title for support page in app settings."),
            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "help"),
            actionBlock: { [weak self] in
                let vc = HelpViewController()
                self?.push(viewController: vc)
            }
        ))
        contents.addSection(section3)

        let section4 = OWSTableSection()
        section4.add(.item(
            icon: .settingsInvite,
            name: NSLocalizedString("SETTINGS_INVITE_TITLE", comment: "Settings table view cell label"),
            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "invite"),
            actionBlock: { [weak self] in
                self?.showInviteFlow()
            }
        ))
//        section4.add(.item(
//            icon: .settingsDonate,
//            name: NSLocalizedString("SETTINGS_DONATE", comment: "Title for the 'donate to signal' link in settings."),
//            accessoryImage: #imageLiteral(resourceName: "open-externally-14"),
//            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "donate"),
//            actionBlock: {
//                UIApplication.shared.open(URL(string: "https://signal.org/donate")!, options: [:], completionHandler: nil)
//            }
//        ))
//        contents.addSection(section4)

        if DebugFlags.internalSettings {
            let internalSection = OWSTableSection()
            internalSection.add(.disclosureItem(
                icon: .settingsAdvanced,
                name: "Internal",
                accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "internal"),
                actionBlock: { [weak self] in
                    let vc = InternalSettingsViewController()
                    self?.push(viewController: vc)
                }
            ))
            contents.addSection(internalSection)
        }
        
        let accountSection = OWSTableSection()
//        accountSection.headerTitle = NSLocalizedString("SETTINGS_ACCOUNT", comment: "Title for the 'account' link in settings.")

        if tsAccountManager.isDeregistered() {
            accountSection.add(.actionItem(
                withText: tsAccountManager.isPrimaryDevice
                    ? NSLocalizedString("SETTINGS_REREGISTER_BUTTON", comment: "Label for re-registration button.")
                    : NSLocalizedString("SETTINGS_RELINK_BUTTON", comment: "Label for re-link button."),
                textColor: .ows_accentBlue,
                accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "reregister"),
                actionBlock: { [weak self] in
                    self?.reregisterUser()
                }
            ))
            accountSection.add(.actionItem(
                withText: NSLocalizedString("SETTINGS_DELETE_DATA_BUTTON",
                                            comment: "Label for 'delete data' button."),
                textColor: .ows_accentRed,
                accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "delete_data"),
                actionBlock: { [weak self] in
                    self?.deleteUnregisterUserData()
                }
            ))
        } else if tsAccountManager.isRegisteredPrimaryDevice {
            accountSection.add(.actionItem(
                withText: NSLocalizedString("SETTINGS_DELETE_ACCOUNT_BUTTON", comment: ""),
                textColor: .ows_accentRed,
                accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "delete_account"),
                actionBlock: { [weak self] in
                    self?.unregisterUser()
                }
            ))
        } else {
            accountSection.add(.actionItem(
                withText: NSLocalizedString("SETTINGS_DELETE_DATA_BUTTON",
                                            comment: "Label for 'delete data' button."),
                textColor: .ows_accentRed,
                accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "delete_data"),
                actionBlock: { [weak self] in
                    self?.deleteLinkedData()
                }
            ))
        }

        contents.addSection(accountSection)

        self.contents = contents
    }
    
    // MARK: - Account

    private func reregisterUser() {
        RegistrationUtils.showReregistrationUI(from: self)
    }

    private func deleteLinkedData() {
        OWSActionSheets.showConfirmationAlert(
            title: NSLocalizedString("CONFIRM_DELETE_LINKED_DATA_TITLE", comment: ""),
            message: NSLocalizedString("CONFIRM_DELETE_LINKED_DATA_TEXT", comment: ""),
            proceedTitle: NSLocalizedString("PROCEED_BUTTON", comment: ""),
            proceedStyle: .destructive
        ) { _ in
            SignalApp.resetAppData()
        }
    }

    private func unregisterUser() {
        let vc = DeleteAccountConfirmationViewController()
        presentFormSheet(OWSNavigationController(rootViewController: vc), animated: true)
    }

    private func deleteUnregisterUserData() {
        OWSActionSheets.showConfirmationAlert(
            title: NSLocalizedString("CONFIRM_DELETE_DATA_TITLE", comment: ""),
            message: NSLocalizedString("CONFIRM_DELETE_DATA_TEXT", comment: ""),
            proceedTitle: NSLocalizedString("PROCEED_BUTTON", comment: ""),
            proceedStyle: .destructive
        ) { [weak self] _ in
            SignalApp.resetAppData()
        }
    }

    private var inviteFlow: InviteFlow?
    private func showInviteFlow() {
        let inviteFlow = InviteFlow(presentingViewController: self)
        self.inviteFlow = inviteFlow
        inviteFlow.present(isAnimated: true, completion: nil)
    }

    private func profileCell() -> UITableViewCell {
        let cell = OWSTableItem.newCell()
        cell.accessoryType = .disclosureIndicator

        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.spacing = 12

        cell.contentView.addSubview(hStackView)
        hStackView.autoPinEdgesToSuperviewMargins()

        let snapshot = profileManager.localProfileSnapshot(shouldIncludeAvatar: true)

        let avatarDiameter: CGFloat = 64
        let avatarImageView = AvatarImageView()
        avatarImageView.contentMode = .scaleAspectFit
        if let avatarData = snapshot.avatarData {
            avatarImageView.image = UIImage(data: avatarData)
        } else {
            avatarImageView.image = OWSContactAvatarBuilder(forLocalUserWithDiameter: UInt(avatarDiameter)).buildDefaultImage()
        }
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarDiameter / 2
        avatarImageView.autoSetDimensions(to: CGSize(square: avatarDiameter))

        let avatarContainer = UIView()
        avatarContainer.addSubview(avatarImageView)
        avatarImageView.autoPinWidthToSuperview()
        avatarImageView.autoVCenterInSuperview()
        avatarContainer.autoSetDimension(.height, toSize: avatarDiameter, relation: .greaterThanOrEqual)

        hStackView.addArrangedSubview(avatarContainer)

        let vStackView = UIStackView()
        vStackView.axis = .vertical
        vStackView.spacing = 0
        hStackView.addArrangedSubview(vStackView)

        let nameLabel = UILabel()
        vStackView.addArrangedSubview(nameLabel)
        nameLabel.font = UIFont.ows_dynamicTypeTitle2Clamped.ows_medium
        if let fullName = snapshot.fullName, !fullName.isEmpty {
            nameLabel.text = fullName
            nameLabel.textColor = Theme.primaryTextColor
        } else {
            nameLabel.text = NSLocalizedString(
                "APP_SETTINGS_EDIT_PROFILE_NAME_PROMPT",
                comment: "Text prompting user to edit their profile name."
            )
            nameLabel.textColor = Theme.accentBlueColor
        }

        func addSubtitleLabel(text: String?, isLast: Bool = false) {
            guard let text = text, !text.isEmpty else { return }

            let label = UILabel()
            label.font = .ows_dynamicTypeFootnoteClamped
            label.text = text
            label.textColor = Theme.secondaryTextAndIconColor

            let containerView = UIView()
            containerView.layoutMargins = UIEdgeInsets(top: 2, left: 0, bottom: isLast ? 0 : 2, right: 0)
            containerView.addSubview(label)
            label.autoPinEdgesToSuperviewMargins()

            vStackView.addArrangedSubview(containerView)
        }

//        addSubtitleLabel(text: OWSUserProfile.bioForDisplay(bio: snapshot.bio, bioEmoji: snapshot.bioEmoji))

        if let phoneNumber = tsAccountManager.localNumber {
            addSubtitleLabel(
                text: PhoneNumber.bestEffortFormatPartialUserSpecifiedText(toLookLikeAPhoneNumber: phoneNumber),
                isLast: true
            )
        } else {
            owsFailDebug("Missing local number")
        }

        let topSpacer = UIView.vStretchingSpacer()
        let bottomSpacer = UIView.vStretchingSpacer()
        vStackView.insertArrangedSubview(topSpacer, at: 0)
        vStackView.addArrangedSubview(bottomSpacer)
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)

        return cell
    }
}

extension AppSettingsViewController {
    private func push(viewController: UIViewController) {
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}
