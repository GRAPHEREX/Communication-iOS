import UIKit
import PromiseKit

private protocol OnboardingCodeViewTextFieldDelegate: AnyObject {
    func textFieldDidDeletePrevious()
}

// MARK: -

// Editing a code should feel seamless, as even though
// the UITextField only lets you edit a single digit at
// a time.  For deletes to work properly, we need to
// detect delete events that would affect the _previous_
// digit.
private class OnboardingCodeViewTextField: UITextField {

    fileprivate weak var codeDelegate: OnboardingCodeViewTextFieldDelegate?

    override func deleteBackward() {
        var isDeletePrevious = false
        if let selectedTextRange = selectedTextRange {
            let cursorPosition = offset(from: beginningOfDocument, to: selectedTextRange.start)
            if cursorPosition == 0 {
                isDeletePrevious = true
            }
        }

        super.deleteBackward()

        if isDeletePrevious {
            codeDelegate?.textFieldDidDeletePrevious()
        }
    }

}

// MARK: -

// The OnboardingCodeView is a special "verification code"
// editor that should feel like editing a single piece
// of text (ala UITextField) even though the individual
// digits of the code are visually separated.
//
// We use a separate UILabel for each digit, and move
// around a single UITextfield to let the user edit the
// last/next digit.
final class OnboardingCodeView_Grapherex: UIView {

    weak var delegate: OnboardingCodeViewDelegate?

    public init() {
        super.init(frame: .zero)
        
        createSubviews()
        backgroundColor = .st_neutralGrayMessege
        layer.cornerRadius = 10
        updateViewState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        createSubviews()
        backgroundColor = .st_neutralGrayMessege
        layer.cornerRadius = 10
        updateViewState()
    }

    private let digitCount = 6
    private var digitLabels = [UILabel]()
    private var digitStrokes = [UIView]()

    // We use a single text field to edit the "current" digit.
    // The "current" digit is usually the "last"
    fileprivate let textfield = OnboardingCodeViewTextField()
    private var currentDigitIndex = 0
    private var textfieldConstraints = [NSLayoutConstraint]()

    // The current complete text - the "model" for this view.
    private var digitText = ""

    var isComplete: Bool {
        return digitText.count == digitCount
    }
    var verificationCode: String {
        return digitText
    }

    private func createSubviews() {
        textfield.textAlignment = .left
        textfield.delegate = self
        textfield.keyboardType = .numberPad
        textfield.textColor = Theme.lightThemePrimaryColor
        textfield.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        textfield.codeDelegate = self

        var digitViews = [UIView]()
        (0..<digitCount).forEach { (_) in
            let (digitView, digitLabel, digitStroke) = makeCellView(text: "", hasStroke: true)

            digitLabels.append(digitLabel)
            digitStrokes.append(digitStroke)
            digitViews.append(digitView)
        }

        let stackView = UIStackView(arrangedSubviews: digitViews)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        addSubview(stackView)
        stackView.autoCenterInSuperview()

        self.addSubview(textfield)
        
        let tap =  UITapGestureRecognizer(target: self, action: #selector(focus))
        addGestureRecognizer(tap)
    }

    private func makeCellView(text: String, hasStroke: Bool) -> (UIView, UILabel, UIView) {
        let digitView = UIView()

        let digitLabel = UILabel()
        digitLabel.text = text
        digitLabel.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        digitLabel.textColor = Theme.lightThemePrimaryColor
        digitLabel.textAlignment = .center
        digitView.addSubview(digitLabel)
        digitLabel.autoCenterInSuperview()

        let strokeColor = (hasStroke ? Theme.lightThemePrimaryColor : UIColor.clear)
        let strokeView = digitView.addBottomStroke(color: strokeColor, strokeWidth: 1)

        let vMargin: CGFloat = 4
        let cellHeight: CGFloat = digitLabel.font.lineHeight + vMargin * 2
        let cellWidth: CGFloat = cellHeight * 2 / 3
        digitView.autoSetDimensions(to: CGSize(width: cellWidth, height: cellHeight))

        return (digitView, digitLabel, strokeView)
    }

    private func digit(at index: Int) -> String {
        guard index < digitText.count else {
            return ""
        }
        return digitText.substring(from: index).substring(to: 1)
    }

    // Ensure that all labels are displaying the correct
    // digit (if any) and that the UITextField has replaced
    // the "current" digit.
    private func updateViewState() {
        currentDigitIndex = min(digitCount - 1,
                                digitText.count)

        (0..<digitCount).forEach { (index) in
            let digitLabel = digitLabels[index]
            digitLabel.text = digit(at: index)
            digitLabel.isHidden = index == currentDigitIndex
        }

        NSLayoutConstraint.deactivate(textfieldConstraints)
        textfieldConstraints.removeAll()

        let digitLabelToReplace = digitLabels[currentDigitIndex]
        textfield.text = digit(at: currentDigitIndex)
        textfieldConstraints.append(textfield.autoAlignAxis(.horizontal, toSameAxisOf: digitLabelToReplace))
        textfieldConstraints.append(textfield.autoAlignAxis(.vertical, toSameAxisOf: digitLabelToReplace))

        // Move cursor to end of text.
        let newPosition = textfield.endOfDocument
        textfield.selectedTextRange = textfield.textRange(from: newPosition, to: newPosition)
    }

    public override func becomeFirstResponder() -> Bool {
        return textfield.becomeFirstResponder()
    }
    
    @objc private func focus() {
        textfield.becomeFirstResponder()
    }

    func setHasError(_ hasError: Bool) {
        let backgroundColor = (hasError ? UIColor.ows_accentRed : Theme.lightThemePrimaryColor)
        for digitStroke in digitStrokes {
            digitStroke.backgroundColor = backgroundColor
        }
        addBorder(with: hasError ? .red : .clear)
    }

     func set(verificationCode: String) {
        digitText = verificationCode

        updateViewState()

        self.delegate?.codeViewDidChange()
    }
}

// MARK: -

extension OnboardingCodeView_Grapherex: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString newString: String) -> Bool {
        var oldText = ""
        if let textFieldText = textField.text {
            oldText = textFieldText
        }
        let left = oldText.substring(to: range.location)
        let right = oldText.substring(from: range.location + range.length)
        let unfiltered = left + newString + right
        let characterSet = CharacterSet(charactersIn: "0123456789")
        let filtered = unfiltered.components(separatedBy: characterSet.inverted).joined()
        let filteredAndTrimmed = filtered.substring(to: 1)
        textField.text = filteredAndTrimmed

        digitText = digitText.substring(to: currentDigitIndex) + filteredAndTrimmed

        updateViewState()

        self.delegate?.codeViewDidChange()

        // Inform our caller that we took care of performing the change.
        return false
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.codeViewDidChange()

        return false
    }
}

// MARK: -

extension OnboardingCodeView_Grapherex: OnboardingCodeViewTextFieldDelegate {
    public func textFieldDidDeletePrevious() {
        guard digitText.count > 0 else {
            return
        }
        digitText = digitText.substring(to: currentDigitIndex - 1)

        updateViewState()
    }
}
