//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation
import PromiseKit
import SafariServices

@objc(OWSSupportConstants)
@objcMembers class SupportConstants: NSObject {
    static let supportURL = URL(string: "https://support.grapherex.com/")!
    static let debugLogsInfoURL = URL(string: "https://support.grapherex.com")!
    static let supportEmail = "support@grapherex.com"
}

enum ContactSupportFilter: String, CaseIterable {
    case feature_request = "Feature Request"
    case question = "Question"
    case feedback = "Feedback"
    case something_not_working = "Something Not Working"
    case other = "Other"
    case payments = "Payments"

    var localizedString: String {
        switch self {
        case .feature_request:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_FEATURE_REQUEST",
                comment: "The localized representation of the 'feature request' support filter."
            )
        case .question:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_QUESTION",
                comment: "The localized representation of the 'question' support filter."
            )
        case .feedback:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_FEEDBACK",
                comment: "The localized representation of the 'feedback' support filter."
            )
        case .something_not_working:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_SOMETHING_NOT_WORKING",
                comment: "The localized representation of the 'something not working' support filter."
            )
        case .other:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_OTHER",
                comment: "The localized representation of the 'other' support filter."
            )
        case .payments:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_PAYMENTS",
                comment: "The localized representation of the 'payments' support filter."
            )
        }
    }

    var localizedShortString: String {
        switch self {
        case .feature_request:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_FEATURE_REQUEST_SHORT",
                comment: "A brief localized representation of the 'feature request' support filter."
            )
        case .question:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_QUESTION_SHORT",
                comment: "A brief localized representation of the 'question' support filter."
            )
        case .feedback:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_FEEDBACK_SHORT",
                comment: "A brief localized representation of the 'feedback' support filter."
            )
        case .something_not_working:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_SOMETHING_NOT_WORKING_SHORT",
                comment: "A brief localized representation of the 'something not working' support filter."
            )
        case .other:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_OTHER_SHORT",
                comment: "A brief localized representation of the 'other' support filter."
            )
        case .payments:
            return NSLocalizedString(
                "CONTACT_SUPPORT_FILTER_PAYMENTS_SHORT",
                comment: "A brief localized representation of the 'payments' support filter."
            )
        }
    }
}

@objc(OWSContactSupportViewController)
final class ContactSupportViewController: OWSTableViewController2 {

    var selectedFilter: ContactSupportFilter?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .interactive
        tableView.separatorInsetReference = .fromCellEdges
        tableView.separatorInset = .zero

        rebuildTableContents()
        setupNavigationBar()
        setupDataProviderViews()
        applyTheme()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameChange),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameChange),
                                               name: UIResponder.keyboardDidChangeFrameNotification,
                                               object: nil)
    }

    // MARK: - Data providers
    // Any views that provide model information are instantiated by the view controller directly
    // Views that are just chrome are put together in the `constructTableContents()` function

    private let descriptionField = SupportRequestTextView()
    private let debugSwitch = UISwitch()
    private let emojiPicker = EmojiMoodPickerView()

    func setupDataProviderViews() {
        descriptionField.delegate = self
        descriptionField.placeholderText = NSLocalizedString("SUPPORT_DESCRIPTION_PLACEHOLDER",
                                                             comment: "Placeholder string for support description")
        debugSwitch.isOn = true
    }

    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: CommonStrings.cancelButton,
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: CommonStrings.nextButton,
            style: .done,
            target: self,
            action: #selector(didTapNext)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func updateRightBarButton() {
        navigationItem.rightBarButtonItem?.isEnabled = (descriptionField.text.count > 10) && selectedFilter != nil
    }

    override func applyTheme() {
        super.applyTheme()

        navigationItem.rightBarButtonItem?.tintColor = Theme.accentBlueColor

        // Rebuild the contents to force them to update their theme
        rebuildTableContents()
    }

    func rebuildTableContents() {
        contents = constructContents()
    }

    // MARK: - View transitions

    @objc func keyboardFrameChange(_ notification: NSNotification) {
        guard let keyboardEndFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            owsFailDebug("Missing keyboard frame info")
            return
        }
        let tableViewSafeArea = tableView.bounds.inset(by: tableView.safeAreaInsets)
        let keyboardFrameInTableView = tableView.convert(keyboardEndFrame, from: nil)
        let intersectionHeight = keyboardFrameInTableView.intersection(tableViewSafeArea).height

        tableView.contentInset.bottom = intersectionHeight
        tableView.scrollIndicatorInsets.bottom = intersectionHeight
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_) in
            self.scrollToFocus(animated: true)
        }, completion: nil)
    }

    var showSpinnerOnNextButton = false {
        didSet {
            guard showSpinnerOnNextButton else {
                navigationItem.rightBarButtonItem?.customView = nil
                return
            }

            let indicatorStyle: UIActivityIndicatorView.Style
            if #available(iOS 13, *) {
                indicatorStyle = .medium
            } else {
                indicatorStyle = Theme.isDarkThemeEnabled ? .white : .gray
            }
            let spinner = UIActivityIndicatorView(style: indicatorStyle)
            spinner.startAnimating()

            let label = UILabel()
            label.text = NSLocalizedString("SUPPORT_LOG_UPLOAD_IN_PROGRESS",
                                           comment: "A string in the navigation bar indicating that the support request is uploading logs")
            label.textColor = Theme.secondaryTextAndIconColor

            let stackView = UIStackView(arrangedSubviews: [label, spinner])
            stackView.spacing = 4
            navigationItem.rightBarButtonItem?.customView = stackView
        }
    }

    // MARK: - Actions

    @objc func didTapCancel() {
        currentEmailComposeOperation?.cancel()
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    var currentEmailComposeOperation: ComposeSupportEmailOperation?
    @objc func didTapNext() {
        var emailRequest = SupportEmailModel()
        emailRequest.userDescription = descriptionField.text
        emailRequest.emojiMood = emojiPicker.selectedMood
        emailRequest.debugLogPolicy = debugSwitch.isOn ? .attemptUpload : .none
        if let selectedFilter = selectedFilter {
            emailRequest.supportFilter = "iOS \(selectedFilter.rawValue)"
        }
        let operation = ComposeSupportEmailOperation(model: emailRequest)
        currentEmailComposeOperation = operation
        showSpinnerOnNextButton = true

        firstly { () -> Promise<Void> in
            operation.perform(on: .sharedUserInitiated)

        }.done(on: .main) { _ in
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)

        }.catch(on: .main) { error in
            let alertTitle = error.localizedDescription
            let alertMessage = NSLocalizedString("SUPPORT_EMAIL_ERROR_ALERT_DESCRIPTION",
                                                 comment: "Message for alert dialog presented when a support email failed to send")
            OWSActionSheets.showActionSheet(title: alertTitle, message: alertMessage)

        }.finally(on: .main) {
            self.currentEmailComposeOperation = nil
            self.showSpinnerOnNextButton = false

        }
    }
}

// MARK: - <SupportRequestTextViewDelegate>

extension ContactSupportViewController: SupportRequestTextViewDelegate {

    func textViewDidUpdateSelection(_ textView: SupportRequestTextView) {
        scrollToFocus(animated: true)
    }

    func textViewDidUpdateText(_ textView: SupportRequestTextView) {
        updateRightBarButton()

        // Disable interactive presentation if the user has entered text
        if #available(iOS 13, *) {
            isModalInPresentation = (textView.text.count > 0)
        }

        // Kick the tableview so it recalculates sizes
        UIView.performWithoutAnimation {
            tableView.performBatchUpdates(nil) { (_) in
                // And when the size changes have finished, make sure we're scrolled
                // to the focused line
                self.scrollToFocus(animated: false)
            }
        }
    }

    /// Ensures the currently focused area is scrolled into the visible content inset
    /// If it's already visible, this will do nothing
    func scrollToFocus(animated: Bool) {
        let visibleRect = tableView.bounds.inset(by: tableView.adjustedContentInset)
        let rawCursorFocusRect = descriptionField.getUpdatedFocusLine()
        let cursorFocusRect = tableView.convert(rawCursorFocusRect, from: descriptionField)
        let paddedCursorRect = cursorFocusRect.insetBy(dx: 0, dy: -6)

        let entireContentFits = tableView.contentSize.height <= visibleRect.height
        let focusRect = entireContentFits ? visibleRect : paddedCursorRect

        // If we have a null rect, there's nowhere to scroll to
        // If the focusRect is already visible, there's no need to scroll
        guard !focusRect.isNull else { return }
        guard !visibleRect.contains(focusRect) else { return }

        let targetYOffset: CGFloat
        if focusRect.minY < visibleRect.minY {
            targetYOffset = focusRect.minY - tableView.adjustedContentInset.top
        } else {
            let bottomEdgeOffset = tableView.height - tableView.adjustedContentInset.bottom
            targetYOffset = focusRect.maxY - bottomEdgeOffset
        }
        tableView.setContentOffset(CGPoint(x: 0, y: targetYOffset), animated: animated)
    }
}

// MARK: - Table view content builders

extension ContactSupportViewController {
    fileprivate func constructContents() -> OWSTableContents {

        let titleText = NSLocalizedString("HELP_CONTACT_US",
                                          comment: "Help item allowing the user to file a support request")
        let contactHeaderText = NSLocalizedString("SUPPORT_CONTACT_US_HEADER",
                                                  comment: "Header of support description field")
        let emojiHeaderText = NSLocalizedString("SUPPORT_EMOJI_PROMPT",
                                                comment: "Header for emoji mood selection")
        let faqPromptText = NSLocalizedString("SUPPORT_FAQ_PROMPT",
                                              comment: "Label in support request informing user about Signal FAQ")

        return OWSTableContents(title: titleText, sections: [

            OWSTableSection(title: contactHeaderText, items: [

                // Filter selection
                OWSTableItem(customCell: OWSTableItem.buildIconNameCell(
                    itemName: NSLocalizedString(
                        "CONTACT_SUPPORT_FILTER_PROMPT",
                        comment: "Prompt telling the user to select a filter for their support request."
                    ),
                    accessoryText: self.selectedFilter?.localizedShortString ?? NSLocalizedString(
                        "CONTACT_SUPPORT_SELECT_A_FILTER",
                        comment: "Placeholder telling user they must select a filter."
                    ),
                    accessoryTextColor: self.selectedFilter == nil ? Theme.placeholderColor : nil
                ),
                actionBlock: { [weak self] in
                    self?.showFilterPicker()
                }),

                // Description field
                OWSTableItem(customCellBlock: { [weak self] in
                    let cell = OWSTableItem.newCell()
                    guard let self = self else { return cell }
                    cell.contentView.addSubview(self.descriptionField)
                    self.descriptionField.autoPinEdgesToSuperviewMargins()
                    self.descriptionField.autoSetDimension(.height, toSize: 125, relation: .greaterThanOrEqual)
                    return cell
                }),

                // Debug log switch
                OWSTableItem(customCell: createDebugLogCell(), customRowHeight: UITableView.automaticDimension),

                // FAQ prompt
                OWSTableItem(customCellBlock: {
                    let cell = OWSTableItem.newCell()
                    cell.textLabel?.font = UIFont.ows_dynamicTypeBody
                    cell.textLabel?.adjustsFontForContentSizeCategory = true
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.text = faqPromptText
                    cell.textLabel?.textColor = Theme.accentBlueColor
                    return cell
                },
                   actionBlock: { [weak self] in
                    let vc = SFSafariViewController(url: SupportConstants.supportURL)
                    self?.present(vc, animated: true)
                })
            ]),

            // The emoji picker is placed in the section footer to avoid tableview separators
            // As far as I can tell, there's no way for a grouped UITableView to not add separators
            // between the header and the first row without messing in the UITableViewCell's hierarchy
            //
            // UITableViewCell.separatorInset looks like it would work, but it only applies to separators
            // between cells, not between the header and the footer

            OWSTableSection(title: emojiHeaderText, footer: createEmojiFooterView())
        ])
    }

    func createDebugLogCell() -> UITableViewCell {
        let cell = OWSTableItem.newCell()

        let label = UILabel()
        label.text = NSLocalizedString("SUPPORT_INCLUDE_DEBUG_LOG",
                                       comment: "Label describing support switch to attach debug logs")
        label.font = UIFont.ows_dynamicTypeBody
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = Theme.primaryTextColor

        let infoButton = OWSButton(imageName: "help-outline-24", tintColor: Theme.secondaryTextAndIconColor) { [weak self] in
            let vc = SFSafariViewController(url: SupportConstants.debugLogsInfoURL)
            self?.present(vc, animated: true)
        }
        infoButton.accessibilityLabel = NSLocalizedString("DEBUG_LOG_INFO_BUTTON",
                                                          comment: "Accessibility label for the ? vector asset used to get info about debug logs")

        cell.contentView.addSubview(label)
        cell.contentView.addSubview(infoButton)
        cell.accessoryView = debugSwitch

        label.autoPinEdges(toSuperviewMarginsExcludingEdge: .trailing)
        label.setCompressionResistanceHigh()

        infoButton.autoPinHeightToSuperviewMargins()
        infoButton.autoPinLeading(toTrailingEdgeOf: label, offset: 6)
        infoButton.autoPinEdge(toSuperviewMargin: .trailing, relation: .greaterThanOrEqual)

        return cell
    }

    func createEmojiFooterView() -> UIView {
        let containerView = UIView()

        // These constants were pulled from OWSTableViewController to get things to line up right
        let horizontalEdgeInset: CGFloat = UIDevice.current.isPlusSizePhone ? 20 : 16
        containerView.directionalLayoutMargins.leading = horizontalEdgeInset
        containerView.directionalLayoutMargins.trailing = horizontalEdgeInset

        containerView.addSubview(emojiPicker)
        emojiPicker.autoPinEdges(toSuperviewMarginsExcludingEdge: .trailing)
        return containerView
    }

    func showFilterPicker() {
        let actionSheet = ActionSheetController(title: NSLocalizedString(
            "CONTACT_SUPPORT_FILTER_PROMPT",
            comment: "Prompt telling the user to select a filter for their support request."
        ))
        actionSheet.addAction(OWSActionSheets.cancelAction)

        for filter in ContactSupportFilter.allCases {
            let action = ActionSheetAction(title: filter.localizedString) { [weak self] _ in
                self?.selectedFilter = filter
                self?.updateRightBarButton()
                self?.rebuildTableContents()
            }
            if selectedFilter == filter { action.trailingIcon = .checkCircle }
            actionSheet.addAction(action)
        }

        presentActionSheet(actionSheet)
    }
}
