//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation
import PureLayout

final class SendFromChatView: BaseView {
    typealias VoidHandler = () -> Void
    public var action: VoidHandler?
    
    private let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 14)
        return label
    }()
    
    private let primaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 16).wlt_semibold
        return label
    }()
    
    private let secondaryLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 14)
        return label
    }()
    
    struct Props {
        let iconPath: String?
        let image: UIImage?
        let title: String
        let primaryText: String
        let secondaryText: String?
        
        init(
            iconPath: String? = nil,
            image: UIImage? = nil,
            title: String,
            primaryText: String,
            secondaryText: String? = nil
        ) {
            self.iconPath = iconPath
            self.image = image
            self.title = title
            self.primaryText = primaryText
            self.secondaryText = secondaryText
        }
    }
    
    public var props: Props? { didSet {
        render()
        }}
    
    override func setup() {
        backgroundColor = .clear
        addSubview(titleLabel)
        self.layoutMargins = .zero
//        titleLabel.wltAutoPinTopToSuperviewMargin()
//        titleLabel.wltAutoPinLeadingAndTrailingToSuperviewMargin()
        
        let textStack = UIStackView(arrangedSubviews: [
            primaryLabel,
            secondaryLabel
        ])
        textStack.autoSetDimension(.height, toSize: 40)
        textStack.axis = .vertical
        
        let contentStack = UIStackView(arrangedSubviews: [
            mainImageView,
            textStack
        ])
        contentStack.spacing = 8
        
        addSubview(contentStack)
        contentStack.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 4)
//        contentStack.wltAutoPinBottomToSuperviewMargin()
//        contentStack.wltAutoPinLeadingAndTrailingToSuperviewMargin()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        
        mainImageView.autoSetDimension(.width, toSize: 40, relation: .lessThanOrEqual)
    }
}

fileprivate extension SendFromChatView {
    func render() {
        guard let props = self.props else { return }
        if props.iconPath != nil {
            mainImageView.sd_setImage(with: URL(string: props.iconPath!), completed: nil)
        } else {
            mainImageView.image = props.image
            mainImageView.isHidden = props.image == nil
        }
        
        mainImageView.layer.cornerRadius = mainImageView.frame.size.width / 2
        titleLabel.text = props.title
        primaryLabel.text = props.primaryText
        secondaryLabel.text = props.secondaryText
        secondaryLabel.isHidden = props.secondaryText == nil
        
        self.layoutSubviews()
    }
    
    @objc
    func tap() {
        action?()
    }
}
