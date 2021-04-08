//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

public class VoiceGridViewCell: UICollectionViewCell {

    var onPlayButtonTap:(() -> Void)?
    
    static let reuseIdentifier = "VoiceGridViewCell"
    private let playImage = UIImage(named: "attachment.share.play")
    private let pauseImage = UIImage(named: "attachment.share.pause")
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(playImage, for: .normal)
        return button
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
        return view
    }()
    
    var item: GalleryVoiceGridCellItem?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let contentView = UIView()
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = UIColor.st_neutralGrayMessege
        contentView.layer.masksToBounds = true

        let imageContainer = UIView()
        imageContainer.backgroundColor = UIColor.st_accentGreen
        
        addSubview(contentView)
        imageContainer.addSubview(playButton)
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

        playButton.autoPinEdgesToSuperviewEdges()
    }

    @available(*, unavailable, message: "Uniplmplemented")
    required public init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
    
    func configure(item: GalleryVoiceGridCellItem) {
        self.item = item

        var name: String = ""
        self.databaseStorage.uiRead { [weak self] transaction in
            switch(item.galleryItem.message.interactionType()) {
            case .incomingMessage:
                guard
                    let incomingMessage = item.galleryItem.message as? TSIncomingMessage
                else {
                    break
                }
                name = self?.contactsManager.displayName(for: incomingMessage.authorAddress) ?? ""
            case .outgoingMessage:
                name = OWSProfileManager.shared.localFullName() ?? ""
            default:
                break
            }
        }

        let timeDescription = OWSFormat.formatDurationSeconds(Int(item.galleryItem.attachmentStream.audioDurationSeconds()))
        let data = VoiceGridViewCell.fileGridDataFormatter.string(
            from: item.galleryItem.message.receivedAtDate()
        )
        
        self.titleLabel.text = name
        self.subtitleLabel.text = timeDescription + " " + data
        
        playButton.addTarget(self, action: #selector(playButtonTap), for: .touchUpInside)
    }
    
    private static let fileGridByteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()
    
    private static let fileGridDataFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy 'at' HH:mm"
        return formatter
    }()
    
    public func changeState(_ state: AudioPlaybackState) {
        switch state {
        case .playing:
            playButton.setImage(pauseImage, for: .normal)
        case .paused, .stopped:
            playButton.setImage(playImage, for: .normal)
        @unknown default:
            break
        }
    }
        
    @objc
    func playButtonTap() {
        onPlayButtonTap?()
    }
}
