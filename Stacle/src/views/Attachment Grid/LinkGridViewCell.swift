//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

public class LinkGridViewCell: UICollectionViewCell {
    
    enum Constants {
        static let textLeadingConstant: CGFloat = 66
        static let textTrailingConstant: CGFloat = 8
    }
   
    static let reuseIdentifier = "LinkGridViewCell"

    public let charLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        view.textColor = UIColor.white
        return view
    }()
        
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        view.textColor = UIColor.st_accentBlack
        return view
    }()
    private let subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.st_sfUiTextRegularFont(withSize: 12)
        view.textColor = UIColor.st_neutralGray
        view.numberOfLines = 3
        return view
    }()
    private let urlLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.st_sfUiTextRegularFont(withSize: 12)
        view.textColor = UIColor.st_otherBlueLink
        return view
    }()

    var item: GalleryLinkGridCellItem?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let contentView = UIView()
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = UIColor.st_neutralGrayMessege
        contentView.layer.masksToBounds = true

        let imageContainer = UIView()
        imageContainer.backgroundColor = UIColor.st_otherBlue
        
        addSubview(contentView)
        imageContainer.addSubview(charLabel)
        contentView.addSubview(imageContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(urlLabel)
        
        contentView.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
        contentView.autoPinEdge(toSuperviewEdge: .top, withInset: 4)
        contentView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        contentView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        
        imageContainer.autoPinEdge(toSuperviewEdge: .leading, withInset: 0)
        imageContainer.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
        imageContainer.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)

        NSLayoutConstraint.activate([
            imageContainer.widthAnchor.constraint(equalToConstant: 50),
            titleLabel.heightAnchor.constraint(equalToConstant: 19),
            subtitleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 56),
            urlLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: Constants.textLeadingConstant)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: Constants.textTrailingConstant)

        subtitleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: Constants.textLeadingConstant)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 4)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: Constants.textTrailingConstant)

        urlLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: Constants.textLeadingConstant)
        urlLabel.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: 4)
        urlLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: Constants.textTrailingConstant)
        urlLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        
        charLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 18)
        charLabel.autoHCenterInSuperview()
    }

    @available(*, unavailable, message: "Unimplemented")
    required public init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
    
    func configure(item: GalleryLinkGridCellItem) {
        self.item = item

        self.charLabel.text = item.url.host?.first?.description.capitalized
        self.titleLabel.text = item.url.host
        self.subtitleLabel.text = item.body
        self.urlLabel.text = item.url.absoluteString
    }
}
