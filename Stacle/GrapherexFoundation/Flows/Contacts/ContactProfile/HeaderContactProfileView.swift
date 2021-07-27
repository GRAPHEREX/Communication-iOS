//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

class HeaderContactProfileView: BaseView {
    
    enum Constact {
        static let imageSize: CGFloat = 80
        static let height: CGFloat = 258
    }
    
    private let mainContentStack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        return stack
    }()
    
    private let optionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 40
        return stack
    }()
    
    internal let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    internal let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        return label
    }()
    
    internal let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        // TODO: add Color from palette
        label.textColor = .st_neutralGray
        return label
    }()
    
    struct Props {
        let fullName: String
        let subtitle: String
        let image: UIImage?
        let options: [ProfileOptionView]
        
        init(fullName: String,
         subtitle: String,
         image: UIImage?,
         options: [ProfileOptionView]) {
            self.fullName = fullName
            self.subtitle = subtitle
            self.image = image
            self.options = options
        }
    }
    
    private (set) var props: Props?
    
    override func setup() {
        render()
        applyTheme()
        addSubview(mainContentStack)
        mainContentStack.autoPinEdge(.trailing, to: .trailing, of: self)
        mainContentStack.autoPinEdge(.leading, to: .leading, of: self)
        mainContentStack.autoPinEdge(.top, to: .top, of: self, withOffset: 24)
        mainContentStack.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -24)
        imageView.autoSetDimensions(to: .init(square: Constact.imageSize))
        imageView.layer.cornerRadius = Constact.imageSize / 2
        
        mainContentStack.addArrangedSubview(imageView)
        mainContentStack.setCustomSpacing(8, after: imageView)
        mainContentStack.addArrangedSubview(nameLabel)
        mainContentStack.addArrangedSubview(subtitleLabel)
        mainContentStack.setCustomSpacing(16, after: subtitleLabel)
        mainContentStack.addArrangedSubview(optionStack)
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .ThemeDidChange, object: nil)
    }
    
    func setup(fullName: String,
               subtitle: String,
               image: UIImage?,
               options: [ProfileOptionView]) {
        props = .init(fullName: fullName, subtitle: subtitle, image: image, options: options)
        render()
    }
}

internal extension HeaderContactProfileView {
    @objc func applyTheme() {
//        backgroundColor = Theme.backgroundColor
    }
    
    @objc
    func render() {
        guard let props = props else { return }
        imageView.image = props.image
        nameLabel.text = props.fullName
        subtitleLabel.text = props.subtitle
        optionStack.arrangedSubviews
            .forEach({ $0.removeFromSuperview() })
        for option in props.options {
            optionStack.addArrangedSubview(option)
        }
    }
}
