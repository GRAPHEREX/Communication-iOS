//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class CurrencyPickerView: BaseView {
    typealias FinishHandler = (Currency) -> Void
    
    var finish: FinishHandler?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.primaryTextColor
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
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
        imageView.autoVCenterInSuperview()
        imageView.autoPinLeading(toEdgeOf: self)
        
        nameLabel.autoVCenterInSuperview()
        nameLabel.autoPinLeading(toTrailingEdgeOf: imageView, offset: 8)
        nameLabel.autoPinTrailingToSuperviewMargin()

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
