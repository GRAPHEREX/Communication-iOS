//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation
import PureLayout

final class CurrencyPickerView: BaseView {
    typealias FinishHandler = (Currency) -> Void
    
    var finish: FinishHandler?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
        return label
    }()
    
    private let imageView = UIImageView()
    
    var currency: Currency! { didSet {
        render()
    }}
    
    override func setup() {
        super.setup()
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        addSubview(nameLabel)
        imageView.autoSetDimensions(to: .init(width: 32, height: 32))
        // MARK: - SINGAL DEPENDENCY – reimplement
//        imageView.wltAutoVCenterInSuperview()
//        imageView.wltAutoPinLeading(toEdgeOf: self)
        
//        nameLabel.wltAutoVCenterInSuperview()
//        nameLabel.wltAutoPinLeading(toTrailingEdgeOf: imageView, offset: 8)
//        nameLabel.wltAutoPinTrailingToSuperviewMargin()

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
}

fileprivate extension CurrencyPickerView {
    func render() {
        nameLabel.text = currency.name
        imageView.sd_setImage(with: URL(string: currency.icon), completed: nil)
    }
    
    @objc
    func tap() {
        finish?(currency)
    }
}
