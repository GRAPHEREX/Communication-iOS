//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

public enum PhotoGridItemType {
    case photo, animated, video
}

public protocol PhotoGridItem: class {
    var type: PhotoGridItemType { get }
    func asyncThumbnail(completion: @escaping (UIImage?) -> Void) -> UIImage?
}

public class PhotoGridViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PhotoGridViewCell"
    
    private let unselectedBadgeView: UIView = {
        let view = CircleView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.white.cgColor
        view.isHidden = true
        return view
    }()
    
    private let selectedBadgeView: UIImageView = {
        let view = UIImageView()
        view.image = PhotoGridViewCell.selectedBadgeImage
        view.isHidden = true
        view.tintColor = .white
        return view
    }()
    
    override public var isSelected: Bool { didSet {
        updateSelectionState()
    }}
    
    public var allowsMultipleSelection: Bool = false { didSet {
        updateSelectionState()
    }}
    
    public var allowsSelection: Bool = true { didSet {
        updateSelectionState()
    }}
    
    func updateSelectionState() {
        guard allowsSelection == true else { return }
        if isSelected {
            unselectedBadgeView.isHidden = true
            selectedBadgeView.isHidden = false
            selectedMaskView.isHidden = false
        } else if allowsMultipleSelection {
            unselectedBadgeView.isHidden = false
            selectedBadgeView.isHidden = true
            selectedMaskView.isHidden = true
        } else {
            unselectedBadgeView.isHidden = true
            selectedBadgeView.isHidden = true
            selectedMaskView.isHidden = true
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            self.highlightedMaskView.isHidden = !self.isHighlighted
        }
    }
    
    public let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let contentTypeBadgeView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        return view
    }()
    private let highlightedMaskView: UIView = {
        let view = UIView()
        view.alpha = 0.2
        view.backgroundColor = Theme.darkThemePrimaryColor
        view.isHidden = true
        return view
    }()
    private let selectedMaskView: UIView = {
        let view = UIView()
        view.alpha = 0.3
        view.backgroundColor = Theme.darkThemeBackgroundColor
        view.isHidden = true
        return view
    }()
    
    var item: PhotoGridItem?
    
    private static let videoBadgeImage = #imageLiteral(resourceName: "ic_gallery_badge_video")
    private static let animatedBadgeImage = #imageLiteral(resourceName: "ic_gallery_badge_gif")
    private static let selectedBadgeImage = #imageLiteral(resourceName: "image_editor_checkmark_full").withRenderingMode(.alwaysTemplate)
    public var loadingColor = Theme.washColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(contentTypeBadgeView)
        self.contentView.addSubview(highlightedMaskView)
        self.contentView.addSubview(selectedMaskView)
        self.contentView.addSubview(unselectedBadgeView)
        self.contentView.addSubview(selectedBadgeView)
        
        imageView.autoPinEdgesToSuperviewEdges()
        highlightedMaskView.autoPinEdgesToSuperviewEdges()
        selectedMaskView.autoPinEdgesToSuperviewEdges()
        
        let kUnselectedBadgeSize = CGSize(square: 22)
        unselectedBadgeView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 4)
        unselectedBadgeView.autoPinEdge(toSuperviewEdge: .top, withInset: 4)
        unselectedBadgeView.autoSetDimensions(to: kUnselectedBadgeSize)
        
        let kSelectedBadgeSize = CGSize(square: 22)
        selectedBadgeView.autoSetDimensions(to: kSelectedBadgeSize)
        selectedBadgeView.autoAlignAxis(.vertical, toSameAxisOf: unselectedBadgeView)
        selectedBadgeView.autoAlignAxis(.horizontal, toSameAxisOf: unselectedBadgeView)
        
        // Note assets were rendered to match exactly. We don't want to re-size with
        // content mode lest they become less legible.
        let kContentTypeBadgeSize = CGSize(square: 12)
        contentTypeBadgeView.autoPinEdge(toSuperviewEdge: .leading, withInset: 3)
        contentTypeBadgeView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 3)
        contentTypeBadgeView.autoSetDimensions(to: kContentTypeBadgeSize)
    }
    
    @available(*, unavailable, message: "Unimplemented")
    required public init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
    
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.backgroundColor = newValue == nil ? loadingColor : .clear
        }
    }
    
    var contentTypeBadgeImage: UIImage? {
        get { return contentTypeBadgeView.image }
        set {
            contentTypeBadgeView.image = newValue
            contentTypeBadgeView.isHidden = newValue == nil
        }
    }
    
    public func configure(item: PhotoGridItem) {
        self.item = item
        
        // PHCachingImageManager returns multiple progressively better
        // thumbnails in the async block. We want to avoid calling
        // `configure(item:)` multiple times because the high-quality image eventually applied
        // last time it was called will be momentarily replaced by a progression of lower
        // quality images.
        image = item.asyncThumbnail { [weak self] image in
            guard let self = self else { return }
            
            guard let currentItem = self.item else {
                return
            }
            
            guard currentItem === item else {
                return
            }
            
            if image == nil {
                Logger.debug("image == nil")
            }
            self.image = image
        }
        
        switch item.type {
        case .video:
            self.contentTypeBadgeImage = PhotoGridViewCell.videoBadgeImage
        case .animated:
            self.contentTypeBadgeImage = PhotoGridViewCell.animatedBadgeImage
        case .photo:
            self.contentTypeBadgeImage = nil
        }
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        item = nil
        imageView.image = nil
        contentTypeBadgeView.isHidden = true
        highlightedMaskView.isHidden = true
        selectedMaskView.isHidden = true
        selectedBadgeView.isHidden = true
        unselectedBadgeView.isHidden = true
    }
}
