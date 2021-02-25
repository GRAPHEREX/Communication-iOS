//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

public class GroupGridViewCell: UICollectionViewCell {
    
    private enum Constant {
        static let textMargin: CGFloat = 12
        static let avatarSize: CGFloat = 44
    }
    
    static let reuseIdentifier = "GroupGridViewCell"
    
    private let groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        label.textColor = Theme.primaryTextColor
        return label
    }()
    
    private let memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
        label.textColor = UIColor.st_neutralGray
        return label
    }()
    
    private(set) public var groupThread: TSGroupThread!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let contentStackView = UIStackView(arrangedSubviews: [groupNameLabel, memberCountLabel])
        contentStackView.autoSetDimension(.height, toSize: Constant.avatarSize)
        contentStackView.axis = .vertical
        
        self.contentView.addSubview(contentStackView)
        contentStackView.autoPinTrailingToSuperviewMargin(withInset: Constant.avatarSize + Constant.textMargin)
        contentStackView.autoPinTrailingToSuperviewMargin()
        contentStackView.autoCenterInSuperview()
        
        appendDivider(to: self.contentView)
    }
    
    public func configure(groupThread: TSGroupThread) {
        self.groupThread = groupThread
        groupNameLabel.text = groupThread.groupModel.groupName
        let formatString: String = NSLocalizedString("MEMBERS", comment: "")
        memberCountLabel.text = String.localizedStringWithFormat(formatString, groupThread.groupModel.groupMembers.count)
        let avatar = ConversationAvatarImageView(thread: groupThread,
                                                 diameter: UInt(Constant.avatarSize))
        
        self.contentView.addSubview(avatar)
        avatar.autoPinLeadingToSuperviewMargin()
        avatar.autoVCenterInSuperview()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.subviews
            .filter { $0 is ConversationAvatarImageView }
            .forEach { $0.removeFromSuperview() }
    }
    
    @available(*, unavailable, message: "Uniplmplemented")
    required public init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
    
}

fileprivate extension GroupGridViewCell {
    func appendDivider(to view: UIView) {
        let divider = UIView()
        view.addSubview(divider)
        divider.autoSetDimension(.height, toSize: 1)
        divider.backgroundColor = Theme.outlineColor;
        divider.autoPinEdge(.bottom, to: .bottom, of: view)
        divider.autoPinEdge(.leading, to: .leading, of: view)
        divider.autoPinEdge(.trailing, to: .trailing, of: view)
    }
}
