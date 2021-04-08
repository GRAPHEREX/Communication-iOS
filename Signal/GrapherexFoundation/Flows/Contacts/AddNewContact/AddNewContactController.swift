import UIKit

final class AddNewContactController: UIViewController {
    
    @IBOutlet var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = NSLocalizedString("NEW_CONTACT_DESCRIPTION", comment: "")
            descriptionLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        }
    }
    @IBOutlet var inputForm: UIView! {
        didSet {
            inputForm.backgroundColor = .st_neutralGrayMessege
            inputForm.layer.cornerRadius = 10
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showKeyboard))
            inputForm.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet var orLabel: UILabel! {
        didSet {
            orLabel.text = NSLocalizedString("MAIN_OR", comment: "")
            orLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
            orLabel.textColor = .lightGray
        }
    }
    @IBOutlet var inputTextField: UITextField! {
        didSet {
            inputTextField.placeholder = NSLocalizedString("MAIN_USER_KEY", comment: "")
            inputTextField.autocorrectionType = .no
            inputTextField.textColor = .st_accentBlack
        }
    }
    @IBOutlet var descScanLabel: UILabel!{
        didSet {
            descScanLabel.text = NSLocalizedString("NEW_CONTACT_SCAN_INFO", comment: "")
            descScanLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
            descScanLabel.textColor = .lightGray
        }
    }
    @IBOutlet var scanView: UIView! {
        didSet {
            scanView.layer.cornerRadius = scanView.frame.height / 2
            scanView.backgroundColor = .st_neutralGrayMessege
            let imageView = UIImageView(image: UIImage(named: "icon.scan.qr"))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showQRScanner))
            scanView.addGestureRecognizer(tapGesture)
            imageView.contentMode = .center
            scanView.addSubview(imageView)
            imageView.autoPin(toEdgesOf: scanView)
        }
    }
    @IBOutlet var formViewCenterYConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.backgroundColor
        navigationItem.rightBarButtonItem = .init(title: NSLocalizedString("MAIN_ADD", comment: ""),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(addContact))
        navigationController?.navigationItem.backBarButtonItem?.title = NSLocalizedString("MAIN_BACK", comment: "")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func showQRScanner() {
        DispatchQueue.main.async {
            let controller = ScanQRController()
            controller.returnScreen = self
            controller.result = { [weak self] uuidString in
                self?.setUuidString(uuidString: uuidString)
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func setUuidString(uuidString: String) {
        inputTextField.text = uuidString
        navigationController?.popToViewController(
            self,
            animated: true,
            completion: { [weak self] in
                self?.addContact()
        })
        
    }
    
    @objc func showKeyboard() {
        inputTextField.becomeFirstResponder()
    }
    
    @objc func dismissKeyboard() {
      view.endEditing(true)
    }
    
    @objc
    private func addContact() {
        guard let text = inputTextField.text else { return }
        Logger.verbose("add contact with user key: \(text)")
        guard let uuid = UUID(uuidString: text) else {
            OWSActionSheets.showErrorAlert(message: NSLocalizedString("INCORRECT_UUID_ERROR_MESSAGE", comment: ""))
            return
        }
        
        if let contact = contactsManagerImpl.fetchSignalAccount(for: .init(uuid: uuid)) {
            if !contact.isDeleted {
                OWSActionSheets.showErrorAlert(message: NSLocalizedString("ADD_NEW_CONTACT_ERROR_CONTACT_ALREADY_EXIST", comment: ""))
                return
            }
        }

        if tsAccountManager.localUuid == uuid {
            OWSActionSheets.showErrorAlert(message: NSLocalizedString("ADD_NEW_CONTACT_ERROR_CONTACT_OWN_USERID", comment: ""))
            return
        }
    
        let controller = UIStoryboard.makeController(NewUserDisplayNameController.self)
        controller.uuid = uuid
        navigationController?.pushViewController(controller, animated: true)
    }
}
