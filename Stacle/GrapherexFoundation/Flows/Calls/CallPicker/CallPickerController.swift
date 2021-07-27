//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation
import PromiseKit

@objc
class CallPickerController: OWSViewController {
    let recipientPicker = RecipientPickerViewController()
    
    private let outboundCallInitiator = AppEnvironment.shared.outboundIndividualCallInitiator
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("CALL_PICKER_MAIN_TITLE", comment: "")

        view.backgroundColor = Theme.backgroundColor

        recipientPicker.allowsSelectingUnregisteredPhoneNumbers = false
        recipientPicker.shouldShowNewGroup = false
        recipientPicker.shouldShowInvites = false
        recipientPicker.shouldShowCreateGroup = false
        recipientPicker.delegate = self
        addChild(recipientPicker)
        view.addSubview(recipientPicker.view)
        recipientPicker.view.autoPin(toTopLayoutGuideOf: self, withInset: 0)
        recipientPicker.view.autoPinEdge(toSuperviewEdge: .leading)
        recipientPicker.view.autoPinEdge(toSuperviewEdge: .trailing)
        recipientPicker.view.autoPinEdge(toSuperviewEdge: .bottom)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissPressed))
    }

    @objc func dismissPressed() {
        dismiss(animated: true)
    }

    func newCall(address: SignalServiceAddress) {
        assert(address.isValid)
        outboundCallInitiator.initiateCall(address: address)
        presentingViewController?.dismiss(animated: true)
    }
}

extension CallPickerController: RecipientPickerDelegate {
    func recipientPickerShowSelection() -> Bool {
        return false
    }
    
    func recipientPicker(
        _ recipientPickerViewController: RecipientPickerViewController,
        canSelectRecipient recipient: PickedRecipient
    ) -> RecipientPickerRecipientState {
        return recipient.isGroup ? .unknownError : .canBeSelected
    }

    func recipientPicker(
        _ recipientPickerViewController: RecipientPickerViewController,
        didSelectRecipient recipient: PickedRecipient
    ) {
        switch recipient.identifier {
        case .address(let address):
            newCall(address: address)
        case .group(_):
            break
        }
    }

    func recipientPicker(_ recipientPickerViewController: RecipientPickerViewController,
                         willRenderRecipient recipient: PickedRecipient) {
        // Do nothing.
    }

    func recipientPicker(_ recipientPickerViewController: RecipientPickerViewController,
                         prepareToSelectRecipient recipient: PickedRecipient) -> AnyPromise {
        owsFailDebug("This method should not called.")
        return AnyPromise(Promise.value(()))
    }

    func recipientPicker(_ recipientPickerViewController: RecipientPickerViewController,
                         showInvalidRecipientAlert recipient: PickedRecipient) {
        owsFailDebug("Unexpected error.")
    }

    func recipientPicker(
        _ recipientPickerViewController: RecipientPickerViewController,
        didDeselectRecipient recipient: PickedRecipient
    ) {}

    func recipientPicker(
        _ recipientPickerViewController: RecipientPickerViewController,
        accessoryMessageForRecipient recipient: PickedRecipient
    ) -> String? {
        switch recipient.identifier {
        case .address(let address):
            guard recipientPicker.contactsViewHelper.isSignalServiceAddressBlocked(address) else { return nil }
            return MessageStrings.conversationIsBlocked
        case .group(let thread):
            guard recipientPicker.contactsViewHelper.isThreadBlocked(thread) else { return nil }
            return MessageStrings.conversationIsBlocked
        }
    }

    func recipientPicker(_ recipientPickerViewController: RecipientPickerViewController,
                         accessoryViewForRecipient recipient: PickedRecipient) -> UIView? {
        return nil
    }

    func recipientPickerTableViewWillBeginDragging(_ recipientPickerViewController: RecipientPickerViewController) {}

    func recipientPickerNewGroupButtonWasPressed() {}

    func recipientPickerCustomHeaderViews() -> [UIView] { return [] }
}
