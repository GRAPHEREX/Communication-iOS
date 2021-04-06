//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation

final class MoneyInputTextField: PastelessTextField {

    public var onAmountChange: ((String) -> Void)?
    public var additionalValidation: ((String) -> Bool)?
    
    public var maxDigitsCountAfterSeparator: Int? = 2 { didSet {
        guard let maxDigitsCount = maxDigitsCountAfterSeparator else {
            moneyDelegate.maxDigitsCountAfterSeparator = 2
            return }
        moneyDelegate.maxDigitsCountAfterSeparator = maxDigitsCount
        placeholder = moneyDelegate.emptyNumberString
        }}
    public var maxDigitsCountBeforeSeparator: Int? = 20 { didSet {
        guard let maxDigitsCount = maxDigitsCountBeforeSeparator else {
            moneyDelegate.maxDigitsCountBeforeSeparator = 20
            return }
        moneyDelegate.maxDigitsCountAfterSeparator = maxDigitsCount
        }}
    
    private let moneyDelegate = MoneyInputDelegate()
    
    var isNotEmpty: Bool {
        for index in 1...9 {
            if self.text?.contains(String(index)) == true { return true }
        }
        return false
    }
    
    public var textSize: CGFloat {
        return moneyDelegate.textSize
    }
    
    public var emptyNumberStringSize: CGFloat {
        return moneyDelegate.emptyNumberStringSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        keyboardType = .decimalPad
        self.delegate = moneyDelegate
        self.placeholder = moneyDelegate.emptyNumberString
        moneyDelegate.textField = self
        
        moneyDelegate.onAmountChange = { [weak self] text in
            self?.onAmountChange?(text)
        }
        moneyDelegate.additionalValidation = { [weak self] text in
            return self?.additionalValidation?(text) != false
        }
        
        // MARK: - SINGAL DEPENDENCY – reimplement
        font = .systemFont(ofSize: 16)
//        font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 16).wlt_semibold
//
//        NotificationCenter.default.addObserver(
//            self, selector: #selector(applyTheme),
//            name: .ThemeDidChange, object: nil)
    }
    
    public func amountForSending() -> String? {
        return self.text?.replacingOccurrences(of: moneyDelegate.groupSeparator, with: "")
            .withReplacedSeparators.withoutSpaces
    }
    
    public func validText(text: String) -> Bool {
        let isValidText = moneyDelegate.isValid(text: text)
        return isValidText
    }
    
    public func setNewValue(_ value: String?, handleOnAmountChange: Bool = true) {
        let safetyValue: String = value ?? self.moneyDelegate.emptyNumberString
    
        self.text = safetyValue
        moneyDelegate.updateTextSize(text: safetyValue)
        if handleOnAmountChange { onAmountChange?(safetyValue) }
    }
    
    public func setNewValue(_ value: String, multiplier: String) {
        let newValue = moneyDelegate.multiply(value1: value, value2: multiplier)
        self.setNewValue(newValue, handleOnAmountChange: false)
    }
    
    public func setNewValue(_ value: String, divider: String) {
        let newValue = moneyDelegate.divide(value1: value, value2: divider)
        self.setNewValue(newValue, handleOnAmountChange: false)
    }
    
    public func getSuitableSize() -> CGFloat {
        let additionalSpace: CGFloat = 8.0
        if self.text?.isEmpty != false {
            return emptyNumberStringSize + additionalSpace
        } else if !self.isNotEmpty {
            return max(emptyNumberStringSize, textSize) + additionalSpace
        }
        
        return textSize + additionalSpace
    }
    
    public func setEmptyState() {
        setNewValue(moneyDelegate.emptyNumberString)
    }
    
    @objc
    private func applyTheme() {
        // MARK: - SINGAL DEPENDENCY – reimplement
//        textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
    }
}

fileprivate final class MoneyInputDelegate: NSObject  {
    public var onAmountChange: ((String) -> Void)?
    public var additionalValidation: ((String) -> Bool)?
    
    public var maxDigitsCountAfterSeparator: Int = 2
    public var maxDigitsCountBeforeSeparator: Int = 20
    public var textSize: CGFloat = 0.0

    public var emptyNumberStringSize: CGFloat {
        return self.getEmptyStringSize()
    }
    
    public unowned var textField: MoneyInputTextField!
    
    override public init() {
        super.init()
    }
}

extension MoneyInputDelegate: UITextFieldDelegate {
    
    public var currentDecimalSeparator: String {
        return Locale.current.decimalSeparator ?? "."
    }
    
    public var groupSeparator: String {
        return Locale.current.groupingSeparator ?? " "
    }
    
    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = self.groupSeparator
        formatter.currencyDecimalSeparator = self.currentDecimalSeparator
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = self.maxDigitsCountAfterSeparator
        formatter.allowsFloats = true
        return formatter
    }
    
    private var partAfterSeparator: String {
        return maxDigitsCountAfterSeparator == 1 ? "0" : "00"
    }
    
    public var emptyNumberString: String {
        return isInteger ? "0" : "0\(currentDecimalSeparator)\(partAfterSeparator)"
    }
    
    private var isInteger: Bool {
        return maxDigitsCountAfterSeparator == 0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newUnformattedText = ((textField.text ?? "") as NSString)
            .replacingCharacters(in: range, with: string).withoutSpaces
            .replacingOccurrences(of: groupSeparator, with: "")
        
        let additionalValidationResult: Bool = additionalValidation?(newUnformattedText) != false
        guard additionalValidationResult,
            let moneyTextField = textField as? MoneyInputTextField,
            newUnformattedText.hasOnlyOneSymbolOrLess(symbol: currentDecimalSeparator)
            else { return false }
        
        let newFormattedText = format(number: newUnformattedText)

        if newFormattedText.hasSuffix(currentDecimalSeparator) {
            moneyTextField.setNewValue(newFormattedText)
            return false
        }
        
        if newUnformattedText.isEmpty {
            moneyTextField.setNewValue(newUnformattedText)
        } else if newUnformattedText.isNumeric && isValid(text: newUnformattedText) {
            moneyTextField.setNewValue(newFormattedText)
        }
        
        return false
    }
    
    func getTextComponents(text: String) -> (integerPart: String, floatPart: String) {
        let components = text.withoutSpaces.replacingOccurrences(of: groupSeparator, with: "")
            .components(separatedBy: currentDecimalSeparator)
        
        if components.count == 1 {
            return (components[0], "")
        } else {
            return (components[0], components[1])
        }
    }
    
    func getNumberComponentsCounts(text: String) -> (beforeDigits: Int, afterDigits: Int) {
        let components = getTextComponents(text: text)
        return (components.integerPart.count, components.floatPart.count)
    }
    
    func isValid(text: String) -> Bool {
        let componentsCounts = getNumberComponentsCounts(text: text)
        let isSecondPartValid: Bool = componentsCounts.afterDigits <= maxDigitsCountAfterSeparator
        let isFirstPartValid: Bool = componentsCounts.beforeDigits <= maxDigitsCountBeforeSeparator
        return isFirstPartValid && isSecondPartValid
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard var text = textField.text,
            let moneyTextField = textField as? MoneyInputTextField
            else { return }
        if text == emptyNumberString {
            moneyTextField.text = nil
        } else if text.hasSuffix(emptyNumberString.dropFirst) && !isInteger {
            text.removeLast(emptyNumberString.count - 1)
            moneyTextField.setNewValue(text)
        } else {
            moneyTextField.setNewValue(text)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var text = textField.text,
            let moneyTextField = textField as? MoneyInputTextField
            else { return }
        
        while text.hasPrefix("0") && !text.hasPrefix("0\(currentDecimalSeparator)") && !text.isEmpty {
            text = text.dropFirst
        }

        if text.isEmpty || !moneyTextField.isNotEmpty {
            moneyTextField.setNewValue(emptyNumberString)
        } else if !text.contains(currentDecimalSeparator) && !isInteger {
            moneyTextField.setNewValue("\(text)\(emptyNumberString.dropFirst)")
        } else if text.hasSuffix(currentDecimalSeparator) {
             moneyTextField.setNewValue(isInteger ? text.dropLast : "\(text)\(partAfterSeparator)")
        } else { moneyTextField.setNewValue(text) }
    }

}

fileprivate extension MoneyInputDelegate {
    func format(number value: String) -> String {
        let components = getTextComponents(text: value)
        updateFormatter()
        let newIntegerPart: String = formatter.string(from: NSNumber(value: components.integerPart.withReplacedSeparators.doubleValue)) ?? "0"
        let newFormattedText = newIntegerPart
            + (value.contains(currentDecimalSeparator) ? (currentDecimalSeparator + components.floatPart) : "")
        
        return newFormattedText
    }
    
    func multiply(value1: String, value2: String) -> String? {
        let newValue1 = value1
            .floatFormat(decimalSeparator: value1.contains(",") ? "," : ".")
            .withReplacedSeparators
            .doubleValue
        let newValue2 = value2
            .floatFormat(decimalSeparator: value2.contains(",") ? "," : ".")
            .withReplacedSeparators
            .doubleValue
        
        let answer: Double = newValue1 * newValue2
        
        return string(from: answer)
    }
    
    func divide(value1: String, value2: String) -> String? {
        let newValue1 = value1
            .floatFormat(decimalSeparator: value1.contains(",") ? "," : ".")
            .withReplacedSeparators
            .doubleValue
        let newValue2 = value2
            .floatFormat(decimalSeparator: value2.contains(",") ? "," : ".")
            .withReplacedSeparators
            .doubleValue
        
        let answer: Double = newValue1 / newValue2
        
        return string(from: answer)
    }
    
    func string(from double: Double) -> String? {
        updateFormatter()
        return formatter.string(from: double)
    }
    
    func updateFormatter() {
        formatter.alwaysShowsDecimalSeparator = false
        formatter.groupingSeparator = self.groupSeparator
        formatter.currencyDecimalSeparator = self.currentDecimalSeparator
        formatter.maximumFractionDigits = self.maxDigitsCountAfterSeparator
    }
}

// MARK: - Text Sizes
fileprivate extension MoneyInputDelegate {
    func updateTextSize(text: String) {
        let attributedText = NSAttributedString(
            string: text,
            attributes: self.textField.defaultTextAttributes)
        self.textSize = attributedText.size().width
    }
    
    func getEmptyStringSize() -> CGFloat {
        let attributedText = NSAttributedString(
            string: self.emptyNumberString,
            attributes: textField.defaultTextAttributes)
        return attributedText.size().width
    }
}
