//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation
import ContactsUI

final class NewUserDisplayNameController: UIViewController, UITextFieldDelegate, ContactsViewHelperObserver {
    
    @IBOutlet var avatarView: AvatarImageView!
    @IBOutlet var displayNameContainer: UIView!
    @IBOutlet var displayNameTextField: UITextField!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var saveButton: STPrimaryButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    var uuid: UUID!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func  setup() {
        contactsViewHelper.addObserver(self)
    }

    func contactsViewHelperDidUpdateContacts() {}

    override func loadView() {
        super.loadView()

        self.title = NSLocalizedString("NEW_USER_NAME_TITLE", comment: "Title for the profile view.");

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        configureViews()
        setupKeyboardNotifications()
    }

    func configureViews() {
        self.view.backgroundColor = Theme.backgroundColor;
        
        descriptionLabel.text = NSLocalizedString("NEW_USER_NAME_DESCRIPTION_TEXT", comment:"")
        displayNameContainer.backgroundColor = UIColor.st_neutralGrayMessege
        descriptionLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
        displayNameContainer.layer.cornerRadius = 10
        descriptionLabel.textAlignment = .center
        
        // Avatar
        avatarView.backgroundColor = UIColor.st_accentGreen;
        avatarView.layer.cornerRadius = avatarSize() / 2;
        avatarView.contentMode = .center
        avatarView.image = #imageLiteral(resourceName: "profile_camera_large")
        
        // Given Name
        self.displayNameTextField.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(displayNameRowTapped(sender:)))
        )
        
        displayNameTextField.borderStyle = .none;
        displayNameTextField.backgroundColor = .clear
        displayNameTextField.returnKeyType = .next
        displayNameTextField.autocorrectionType = .no
        displayNameTextField.spellCheckingType = .no
        displayNameTextField.font = UIFont.ows_dynamicTypeBodyClamped
        displayNameTextField.textColor = UIColor.st_accentBlack
        displayNameTextField.tintColor = .st_accentGreen
        displayNameTextField.placeholder = NSLocalizedString(
            "PROFILE_VIEW_GIVEN_NAME_DEFAULT_TEXT", comment: "Default text for the given name field of the profile view.");
        displayNameTextField.delegate = self
        changeStyle(isFilled: displayNameTextField.text?.count ?? 0 > 0)
        // Big Button
        saveButton.setTitle(NSLocalizedString("MAIN_ADD", comment: ""), for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.displayNameTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let normalizedGivenName = self.normalizedGivenName()
        
        if normalizedGivenName.count <= 0 {
            OWSActionSheets.showErrorAlert(
                message: NSLocalizedString("PROFILE_VIEW_ERROR_GIVEN_NAME_REQUIRED",
                                           comment: "Error message shown when user tries to update profile without a given name")
            )
            return
        }
        
        if OWSProfileManager.shared.isProfileNameTooLong(normalizedGivenName) {
            OWSActionSheets.showErrorAlert(
                message: NSLocalizedString("PROFILE_VIEW_ERROR_GIVEN_NAME_TOO_LONG",
                                           comment: "Error message shown when user tries to update profile with a given name that is too long.")
            )
            return
        }
        
        databaseStorage.write(block: { [weak self] transaction in
            guard let self = self
                else { return }
            if let signalAccount = self.contactsViewHelper.fetchSignalAccount(for: .init(uuid: self.uuid)) {
                if signalAccount.isDeleted {
                    signalAccount.anyUpdate(transaction: transaction, block: { signalAcc in
                        signalAcc.isDeleted = false
                    })
                    self.contactsManagerImpl.update(signalAccount)
                } else { }
            } else {
                let signalAccount = SignalAccount(address: .init(uuid: self.uuid))
                let contact = Contact(
                    uniqueId: self.uuid.uuidString,
                    cnContactId: nil,
                    firstName: nil,
                    lastName: nil,
                    nickname: nil,
                    fullName: normalizedGivenName,
                    userTextPhoneNumbers: [],
                    phoneNumberNameMap: [:],
                    parsedPhoneNumbers: [],
                    emails: [],
                    imageDataToHash: nil)
                signalAccount.contact = contact
                signalAccount.anyInsert(transaction: transaction)
                self.contactsManagerImpl.update(signalAccount)
            }
        })
        contactsManagerImpl.userRequestedSystemContactsRefresh()
        navigationController?.popToRootViewController(animated: true)
    }
    
    func normalizedGivenName() -> String {
        return (displayNameTextField.text?.ows_stripped()) ?? ""
    }

    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardNotification),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardNotification),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc
    func handleKeyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
        let keyboardEndFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        
        let keyboardEndFrame = keyboardEndFrameValue.cgRectValue
        let keyboardEndFrameConverted = view.convert(keyboardEndFrame, from: nil)
        
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    
        if (isKeyboardShowing) {
             bottomConstraint.isActive = false
            bottomConstraint.constant = keyboardEndFrameConverted.size.height - bottomPadding + 16;
            bottomConstraint.isActive = true
        } else {
            bottomConstraint.isActive = false
            bottomConstraint.constant = 16
            bottomConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    func changeStyle(isFilled: Bool) {
        saveButton.handleEnabled(isFilled)
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as String

        changeStyle(isFilled: newString.count > 0)
        
        return TextFieldHelper.textField(textField,
                                         shouldChangeCharactersInRange: range,
                                         replacementString: string,
                                         maxByteCount: kOWSProfileManager_NameDataLength)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func avatarSize() -> CGFloat {
        return 96.0
    }


    @objc
    func displayNameRowTapped(sender: UIGestureRecognizer) {
        if sender.state == .recognized {
            displayNameTextField.becomeFirstResponder()
        }
    }

    @objc
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
