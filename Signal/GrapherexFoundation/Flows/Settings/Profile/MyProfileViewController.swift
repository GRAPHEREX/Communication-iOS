//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation
import PromiseKit

final class MyProfileViewController: OWSViewController {
    typealias CompletionHandler = (MyProfileViewController) -> Void
    @objc public var completionHandler: CompletionHandler?
    
    private let kProfileView_LastPresentedDate = "kProfileView_LastPresentedDate";
    private let tableViewController = OWSTableViewController()
    private let headerView = HeaderMyProfileView()
    private var displayNameTextField: UITextField!

    private var isEditMode: Bool = false
    private var hasUnsavedChanges: Bool = false
    
    var keyValueStore: SDSKeyValueStore = SDSKeyValueStore(collection: "kProfileView_Collection")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.viewController = self
        headerView.avatarChanged = { [weak self] in self?.hasUnsavedChanges = true }
        view.backgroundColor = Theme.backgroundColor
        title = NSLocalizedString("MAIN_PROFILE", comment: "")
        
        SDSDatabaseStorage.shared.write(block: { [weak self] transaction in
            guard let self = self else { return }
            self.keyValueStore.setDate(Date(), key: self.kProfileView_LastPresentedDate, transaction: transaction)
        })
        
        setupTextField()
        setupTableView()
        makeCells()
        updateMode()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTheme),
                                               name: .ThemeDidChange, object: nil)
    }
    
    @objc
    private func applyTheme() {
        makeCells()
        tableViewController.view.backgroundColor = Theme.backgroundColor
        view.backgroundColor = Theme.backgroundColor
    }
}

fileprivate extension MyProfileViewController {
    func setupTextField() {
        if UIDevice.current.isIPhone5OrShorter {
            displayNameTextField = DismissableTextField()
        } else {
            displayNameTextField = OWSTextField()
        }
        
        displayNameTextField.returnKeyType = .next
        displayNameTextField.autocorrectionType = .no
        displayNameTextField.spellCheckingType = .no
        displayNameTextField.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
        displayNameTextField.textColor = Theme.primaryTextColor
        displayNameTextField.placeholder = NSLocalizedString(
            "PROFILE_VIEW_GIVEN_NAME_DEFAULT_TEXT", comment: "Default text for the given name field of the profile view.");
        displayNameTextField.delegate = self
        displayNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        displayNameTextField.text = OWSProfileManager.shared.localGivenName()
    }
    
    func navigationButtonTitle() -> String {
        return NSLocalizedString(isEditMode ? "PROFILE_VIEW_SAVE_BUTTON" : "PROFILE_VIEW_EDIT_BUTTON", comment: "")
    }
    
    func updateMode() {
        if isEditMode {
            displayNameTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        
        displayNameTextField.isUserInteractionEnabled = isEditMode
        headerView.isEditMode = isEditMode
        navigationItem.rightBarButtonItem = .init(
            title: navigationButtonTitle(),
            style: .plain,
            target: self,
            action: isEditMode ? #selector(saveButtonTapped) : #selector(editButtonTapped)
        )
        
        isEditMode.toggle()
    }
    
    func save() {
        if !hasUnsavedChanges { return }
        let normalizedDisplayName: String = displayNameTextField.text?.ows_stripped() ?? ""
        
        if normalizedDisplayName.isEmpty {
            OWSActionSheets.showErrorAlert(message:
                NSLocalizedString("PROFILE_VIEW_ERROR_GIVEN_NAME_REQUIRED", comment: ""))
            return
        }
        
        if OWSProfileManager.shared.isProfileNameTooLong(normalizedDisplayName) {
            OWSActionSheets.showErrorAlert(message:
                NSLocalizedString("PROFILE_VIEW_ERROR_GIVEN_NAME_TOO_LONG", comment: ""))
            return
        }
        
        if (!reachabilityManager.isReachable) {
            OWSActionSheets.showErrorAlert(message:
                NSLocalizedString("PROFILE_VIEW_NO_CONNECTION", comment: ""))
            return
        }
        
        headerView.updateDispayNameLabel(newName: normalizedDisplayName)
        // Show an activity indicator to block the UI during the profile upload.
        
        ModalActivityIndicatorViewController.present( fromViewController: self, canCancel: false) { [weak self] modalActivityIndicator in
            
            OWSProfileManager.updateLocalProfilePromise(profileGivenName: normalizedDisplayName,
                                                        profileFamilyName: "",
                                                        profileBio: nil,
                                                        profileBioEmoji: nil,
                                                        profileAvatarData: self?.headerView.getAvatarData() )
                .then { () -> Promise<Void> in
                    modalActivityIndicator.dismiss(completion: {
                        self?.updateProfileCompleted()
//                        SDSDatabaseStorage.shared.asyncWrite(block: { transaction in
//                            ExperienceUpgradeManager.clearProfileNameReminder(transaction: transaction.unwrapGrdbWrite)
//                        })
                    } )
                    return Promise()
            }
            .catch { (error) in
                modalActivityIndicator.dismiss(completion: { [weak self] in
                    self?.updateProfileCompleted()
                })
            }
        }
    }
    
    func updateProfileCompleted() {
        profileCompleted()
    }
    
    func profileCompleted() {
        completionHandler?(self)
    }
    
    @objc func saveButtonTapped() {
        save()
        updateMode()
    }
    
    @objc func editButtonTapped() {
        if tsAccountManager.isPrimaryDevice {
            updateMode()
        } else {
            OWSActionSheets.showActionSheet(
                title: NSLocalizedString("MAIN_ATTENTION", comment: ""),
                message: NSLocalizedString("DEREGISTRATION_WARNING", comment: "Label warning the user that they have been de-registered."),
                buttonTitle:  NSLocalizedString("SETTINGS_REREGISTER_BUTTON", comment: ""),
                buttonAction: { [weak self] _ in
                    guard let self = self else { return }
                    RegistrationUtils.showReregistrationUI(from: self)
                }
            )
        }
    }
    
    func setupTableView() {
        view.addSubview(tableViewController.view)
        tableViewController.view.backgroundColor = Theme.backgroundColor
        tableViewController.view.autoPinEdgesToSuperviewSafeArea()
        tableViewController.tableView.backgroundColor = Theme.backgroundColor
        tableViewController.tableView.keyboardDismissMode = .onDrag
        tableViewController.tableView.separatorStyle = .none
        self.definesPresentationContext = false
    }
    
    func makeCells() {
        let contents = OWSTableContents()
        
        let headerSection = OWSTableSection()
        headerSection.add(makeProfileHeaderCell())
        
        let mainSection = OWSTableSection()
        if let mobile = TSAccountManager.localAddress?.phoneNumber {
            mainSection.add(makeInfoCell(for: NSLocalizedString("MAIN_MOBILE", comment: ""),
                                         value: mobile))
        }
        mainSection.add(makeDisplayNameCell())
        contents.addSection(headerSection)
        contents.addSection(mainSection)
        
        tableViewController.contents = contents
    }
    
    func makeProfileHeaderCell() -> OWSTableItem {
        let cell = OWSTableItem.newCell()
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
    
    func makeDisplayNameCell() -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none
        let parameterLabel = UILabel()
        parameterLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        parameterLabel.text = NSLocalizedString("MAIN_DISPLAY_NAME", comment: "")
        parameterLabel.textColor = .st_neutralGray
        
        displayNameTextField.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
        displayNameTextField.textColor = Theme.primaryTextColor
        
        cell.contentView.addSubview(parameterLabel)
        cell.contentView.addSubview(displayNameTextField)
        cell.contentView.layoutMargins = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        parameterLabel.autoPinLeadingToSuperviewMargin()
        parameterLabel.autoPinTopToSuperviewMargin()
        parameterLabel.autoPinTrailingToSuperviewMargin()
        
        displayNameTextField.autoPinEdge(.bottom, to: .bottom, of: cell.contentView, withOffset: -8)
        displayNameTextField.autoPinLeadingToSuperviewMargin()
        displayNameTextField.autoPinTrailingToSuperviewMargin()
        
        appendMarginDivider(to: cell.contentView)
        return .init(customCell: cell,
                     customRowHeight: 56)
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
    
    func leaveViewCheckingForUnsavedChanges() {
        displayNameTextField.resignFirstResponder()
        
        if !hasUnsavedChanges {
            profileCompleted()
            return
        }
        
        OWSActionSheets.showPendingChangesActionSheet(discardAction: { [weak self] in
            self?.profileCompleted()
        })
    }
}

extension MyProfileViewController: OWSNavigationView {
    func shouldCancelNavigationBack() -> Bool {
        let result = hasUnsavedChanges
        if result {
            leaveViewCheckingForUnsavedChanges()
        }
        return result
    }
}

extension MyProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return TextFieldHelper.textField(textField,
                                         shouldChangeCharactersInRange: range,
                                         replacementString: string,
                                         maxByteCount: kOWSProfileManager_NameDataLength)
    }
    
    @objc func textFieldDidChange() {
        self.hasUnsavedChanges = true
    }
}
