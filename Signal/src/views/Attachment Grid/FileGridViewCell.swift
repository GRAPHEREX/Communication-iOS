//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

public class FileGridViewCell: UICollectionViewCell {

    static let reuseIdentifier = "FileGridViewCell"

    public let imageView: UIImageView = UIImageView(image: UIImage(named: "attachment.share.file"))
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
        return view
    }()

    var item: GalleryFileGridCellItem?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let contentView = UIView()
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = UIColor.st_neutralGrayMessege
        contentView.layer.masksToBounds = true

        let imageContainer = UIView()
        imageContainer.backgroundColor = UIColor.st_otherYellowIcon
        
        addSubview(contentView)
        imageContainer.addSubview(imageView)
        contentView.addSubview(imageContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
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
            subtitleLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 66)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)

        subtitleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 66)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 4)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        
        imageView.autoCenterInSuperview()
    }

    @available(*, unavailable, message: "Unimplemented")
    required public init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
    
    func configure(item: GalleryFileGridCellItem) {
        self.item = item
        
        let sizeDescription = FileGridViewCell.fileGridByteCountFormatter.string(
            fromByteCount: Int64(item.galleryItem.attachmentStream.byteCount)
        )
        
        let data = FileGridViewCell.fileGridDataFormatter.string(
            from: item.galleryItem.galleryDate.date
        )
        
        self.titleLabel.text = item.galleryItem.captionForDisplay
        self.subtitleLabel.text = sizeDescription + " " + data
    }
    
    private static let fileGridByteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()
    
    private static let fileGridDataFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy at HH.mm"
        return formatter
    }()
}
