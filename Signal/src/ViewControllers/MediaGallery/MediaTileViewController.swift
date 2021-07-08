//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit
import SafariServices
import QuickLook

@objc
public class MediaTileViewController: OWSViewController, OWSAudioPlayerDelegate {
    
    var owsAudioPlayer: OWSAudioPlayer?
    var currentVoiceCell: VoiceGridViewCell?
    
    public var audioPlaybackState = AudioPlaybackState.stopped { didSet {
        ensureButtonState()
    }}
    
    public func setAudioProgress(_ progress: TimeInterval, duration: TimeInterval) {}

    private func ensureButtonState() {
        guard let cell = currentVoiceCell else { return }
        cell.changeState(audioPlaybackState)
    }
    
    private var tabs: TZSegmentedControl?

    // MARK: - Dependencies
    
    private var thread: TSThread!
    private lazy var mediaGallery: MediaGallery = {
        let kMediaTileViewLoadBatchSize: UInt = 200
        let mediaGallery = MediaGallery(thread: thread)
        return mediaGallery
    }()
        
    public lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: mediaTileViewLayout)
        view.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        view.backgroundColor = Theme.backgroundColor
        return view
    }()
    
    fileprivate var mediaTileViewLayout: MediaTileViewLayout = {
        let layout = MediaTileViewLayout()

        if #available(iOS 11, *) {
            layout.sectionInsetReference = .fromSafeArea
        }
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionHeadersPinToVisibleBounds = true

        return layout
    }()
        
    private var types: [GalleryType] = []
    private var currentType: GalleryType = .media
    private var currentAttachmentStream: TSAttachmentStream?
    
    deinit {
        owsAudioPlayer?.stop()
        owsAudioPlayer = nil
    }
    
    // MARK: View Lifecycle Overrides

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.title = MediaStrings.allMedia
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        collectionView.backgroundColor = Theme.backgroundColor
        collectionView.register(PhotoGridViewCell.self, forCellWithReuseIdentifier: PhotoGridViewCell.reuseIdentifier)
        collectionView.register(FileGridViewCell.self, forCellWithReuseIdentifier: FileGridViewCell.reuseIdentifier)
        collectionView.register(VoiceGridViewCell.self, forCellWithReuseIdentifier: VoiceGridViewCell.reuseIdentifier)
        collectionView.register(GroupGridViewCell.self, forCellWithReuseIdentifier: GroupGridViewCell.reuseIdentifier)
        collectionView.register(LinkGridViewCell.self, forCellWithReuseIdentifier: LinkGridViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self

        self.mediaTileViewLayout.invalidateLayout()

        applyTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .ThemeDidChange, object: nil)
    }
    
    @objc func applyTheme() {
        collectionView.backgroundColor = Theme.backgroundColor
    }
        
    func configure(
        types: [GalleryType],
        thread: TSThread
    ) {
        self.thread = thread
        self.types = types
        
        let segmentControl = TZSegmentedControl(sectionTitles: types.map({ $0.rawValue }))
        segmentControl.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 40)
        segmentControl.segmentWidthStyle = .fixed
        segmentControl.backgroundColor = Theme.backgroundColor
        segmentControl.borderType = .none
        segmentControl.selectionStyle = .fullWidth
        segmentControl.selectionIndicatorLocation = .down
        segmentControl.selectionIndicatorColor = UIColor.st_accentGreen
        segmentControl.selectionIndicatorHeight = 2.0
        segmentControl.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.st_neutralGray,
            NSAttributedString.Key.font: UIFont.st_sfUiTextRegularFont(withSize: 14)
        ]
        segmentControl.selectedTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.primaryTextColor,
            NSAttributedString.Key.font: UIFont.st_sfUiTextRegularFont(withSize: 14)
        ]
        
        tabs = segmentControl
        tabs?.indexChangeBlock = { [weak self] selectedIndex in
            self?.handleChangeIndex(selectedIndex)
        }
        
        view.addSubview(segmentControl)
        view.addSubview(collectionView)
        
        segmentControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentControl.autoPinEdge(toSuperviewEdge: .trailing)
        segmentControl.autoPinEdge(toSuperviewSafeArea: .top)
        segmentControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        collectionView.autoPinEdge(.top, to: .bottom, of: segmentControl)
        collectionView.autoPinEdge(toSuperviewEdge: .leading)
        collectionView.autoPinEdge(toSuperviewEdge: .trailing)
        collectionView.autoPinEdge(toSuperviewEdge: .bottom)
                
        let index = types.lastIndex(where: { $0 == currentType })
        segmentControl.selectedSegmentIndex = index ?? 0
        updateData(for: currentType)
    }

    private func handleChangeIndex(_ index: Int) {
        guard let mediaType = types[safe: index] else { return }
        currentType = mediaType
        updateData(for: mediaType)
        mediaGallery.currentFetchType = mediaType
    }
    
    private func updateData(for mediaType: GalleryType) {
        mediaTileViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
}

extension MediaTileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch currentType {
        case .media, .gifs:
            guard let gridCell = collectionView.cellForItem(at: indexPath) as? PhotoGridViewCell else { return }
            guard let galleryItem = (gridCell.item as? GalleryMediaGridCellItem)?.galleryItem else { return }
            showMediaAttachment(mediaGallery, attachment: galleryItem.attachmentStream)
        case .files:
            guard let gridCell = collectionView.cellForItem(at: indexPath) as? FileGridViewCell else { return }
            guard let galleryItem = gridCell.item?.galleryItem else { return }
            
            if let url = galleryItem.attachmentStream.originalMediaURL, QLPreviewController.canPreview(url as NSURL) {
                currentAttachmentStream = galleryItem.attachmentStream
                let previewController = QLPreviewController()
                previewController.dataSource = self
                present(previewController, animated: true)
            }
            else {
                showMediaAttachment(mediaGallery, attachment: galleryItem.attachmentStream)
            }
            
        case .voice:
            guard let gridCell = collectionView.cellForItem(at: indexPath) as? VoiceGridViewCell else { return }
            guard let galleryItem = gridCell.item?.galleryItem else { return }
            didTapVoiceItem(galleryItem, cell: gridCell)
        case .groups:
            guard let gridCell = collectionView.cellForItem(at: indexPath) as? GroupGridViewCell else { return }
            showGroup(gridCell.groupThread)
//        case .links:
//            guard
//                let gridCell = self.collectionView(collectionView, cellForItemAt: indexPath) as? LinkGridViewCell,
//                let url = gridCell.item?.url
//            else {
//                return
//            }
//            showLink(url)
        }
    }
    
    private func showMediaAttachment(_ mediaGallery: MediaGallery, attachment: TSAttachmentStream) {
        let multiSelectionAllowed: Bool
        switch currentType {
        case .media, .gifs:
            multiSelectionAllowed = false
        default:
            multiSelectionAllowed = true
        }
        let pageVC = MediaPageViewController(
            initialMediaAttachment: attachment,
            mediaGallery: mediaGallery,
            showingSingleMessage: multiSelectionAllowed
        )
        present(pageVC, animated: true)
    }
    
    private func showGroup(_ thread: TSGroupThread) {
        let threadViewModel: ThreadViewModel = self.databaseStorage.uiRead {
            return ThreadViewModel(thread: thread, forConversationList: false, transaction: $0)
        }
        let controller = ConversationViewController(threadViewModel: threadViewModel,
                                                    action: .none,
                                                    focusMessageId: nil)
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func showLink(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection sectionIdx: Int) -> Int {
        let count: Int
        
        switch currentType {
        case .media:
            count = mediaGallery.mediaItems.count
        case .files:
            count = mediaGallery.fileItems.count
        case .gifs:
            count = mediaGallery.gifItems.count
        case .voice:
            count = mediaGallery.voiceItems.count
        case .groups:
            count = mediaGallery.groupsItems.count
//        case .links:
//            count = mediaGallery.linkItems.count
        }
        
        if count == 0 {
            let emptyView = SecondaryEmptyStateView()
            emptyView.set(
                image: UIImage(named: "attachment.icon.gallery"),
                title: "No \(currentType.rawValue.lowercased()) here yet..."
            )
            collectionView.backgroundView = emptyView
        } else {
            self.collectionView.backgroundView = nil
        }
        
        return count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch currentType {
        case .media, .gifs:
            guard let cell = self.collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoGridViewCell.reuseIdentifier,
                for: indexPath
            ) as? PhotoGridViewCell else {
                owsFailDebug("unexpected cell for indexPath: \(indexPath)")
                return UICollectionViewCell()
            }
            guard let galleryItem = galleryItem(at: indexPath) as? MediaGalleryItem else { return UICollectionViewCell() }
            let item = GalleryMediaGridCellItem(galleryItem: galleryItem)
            cell.allowsSelection = false
            cell.configure(item: item)
            return cell
        case .files:
            guard let cell = self.collectionView.dequeueReusableCell(
                withReuseIdentifier: FileGridViewCell.reuseIdentifier,
                for: indexPath
            ) as? FileGridViewCell else {
                owsFailDebug("unexpected cell for indexPath: \(indexPath)")
                return UICollectionViewCell()
            }
            guard let galleryItem = galleryItem(at: indexPath) as? MediaGalleryItem else { return UICollectionViewCell() }
            let item = GalleryFileGridCellItem(galleryItem: galleryItem)
            cell.configure(item: item)
            return cell
        case .voice:
            guard let cell = self.collectionView.dequeueReusableCell(
                withReuseIdentifier: VoiceGridViewCell.reuseIdentifier,
                for: indexPath
            ) as? VoiceGridViewCell else {
                owsFailDebug("unexpected cell for indexPath: \(indexPath)")
                return UICollectionViewCell()
            }
            guard let galleryItem = galleryItem(at: indexPath) as? MediaGalleryItem else { return UICollectionViewCell() }
            let item = GalleryVoiceGridCellItem(galleryItem: galleryItem)
            cell.onPlayButtonTap = { [weak self] in
                self?.didTapVoiceItem(galleryItem, cell: cell)
            }
            cell.configure(item: item)
            return cell
        case .groups:
            guard let cell = self.collectionView.dequeueReusableCell(
                withReuseIdentifier: GroupGridViewCell.reuseIdentifier,
                for: indexPath
            ) as? GroupGridViewCell else {
                owsFailDebug("unexpected cell for indexPath: \(indexPath)")
                return UICollectionViewCell()
            }
            guard let galleryItem = galleryItem(at: indexPath) as? TSGroupThread else { return UICollectionViewCell() }
            cell.configure(groupThread: galleryItem)
            return cell
//        case .links:
//            guard let cell = self.collectionView.dequeueReusableCell(
//                withReuseIdentifier: LinkGridViewCell.reuseIdentifier,
//                for: indexPath
//            ) as? LinkGridViewCell else {
//                owsFailDebug("unexpected cell for indexPath: \(indexPath)")
//                return UICollectionViewCell()
//            }
//            guard let (url, body) = galleryItem(at: indexPath) as? (URL, String) else { return UICollectionViewCell() }
//            let item = GalleryLinkGridCellItem(url: url, body: body)
//            cell.configure(item: item)
//            return cell
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch currentType {
        case .media, .gifs:
            let size = floor(collectionView.frame.width / 3 - 4)
            return CGSize(width: size, height: size)
        case .files, .voice, .groups:
            return CGSize(width: collectionView.frame.width, height: 64)
//        case .links:
//            guard let (url, body) = galleryItem(at: indexPath) as? (URL, String) else { return .zero }
//            var boundingHeight: CGFloat = 0
//            if url.absoluteString != body {
//                let constraintRect = CGSize(
//                    width: collectionView.width - LinkGridViewCell.Constants.textLeadingConstant - LinkGridViewCell.Constants.textTrailingConstant - 16,
//                    height: .greatestFiniteMagnitude
//                )
//                boundingHeight = body.boundingRect(
//                    with: constraintRect,
//                    options: .usesLineFragmentOrigin,
//                    attributes: [.font: UIFont.st_sfUiTextSemiboldFont(withSize: 16)],
//                    context: nil
//                ).height
//            }
//            let height: CGFloat = boundingHeight > 56 ? 56 : ceil(boundingHeight)
//            return CGSize(width: collectionView.frame.width, height: height + 70)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }

    func galleryItem(at indexPath: IndexPath) -> Any? {
        switch currentType {
        case .media:
            return mediaGallery.mediaItems[safe: indexPath.row]
        case .files:
            return mediaGallery.fileItems[safe: indexPath.row]
        case .gifs:
            return mediaGallery.gifItems[safe: indexPath.row]
        case .voice:
            return mediaGallery.voiceItems[safe: indexPath.row]
        case .groups:
            return mediaGallery.groupsItems[indexPath.row]
//        case .links:
//            return mediaGallery.linkItems[safe: indexPath.row]
        }
    }
}

// MARK: - Private Helper Classes

private class MediaTileViewLayout: UICollectionViewFlowLayout {

    fileprivate var isInsertingCellsToTop: Bool = false
    fileprivate var contentSizeBeforeInsertingToTop: CGSize?

    override public func prepare() {
        super.prepare()

        if isInsertingCellsToTop {
            if let collectionView = collectionView, let oldContentSize = contentSizeBeforeInsertingToTop {
                let newContentSize = collectionViewContentSize
                let contentOffsetY = collectionView.contentOffset.y + (newContentSize.height - oldContentSize.height)
                let newOffset = CGPoint(x: collectionView.contentOffset.x, y: contentOffsetY)
                collectionView.setContentOffset(newOffset, animated: false)
            }
            contentSizeBeforeInsertingToTop = nil
            isInsertingCellsToTop = false
        }
    }
}

class GalleryMediaGridCellItem: PhotoGridItem {
    let galleryItem: MediaGalleryItem

    init(galleryItem: MediaGalleryItem) {
        self.galleryItem = galleryItem
    }

    var type: PhotoGridItemType {
        if galleryItem.isVideo {
            return .video
        } else if galleryItem.isAnimated {
            return .animated
        } else {
            return .photo
        }
    }

    func asyncThumbnail(completion: @escaping (UIImage?) -> Void) -> UIImage? {
        return galleryItem.thumbnailImage(async: completion)
    }
}

struct GalleryFileGridCellItem {
    let galleryItem: MediaGalleryItem
}

struct GalleryVoiceGridCellItem {
    let galleryItem: MediaGalleryItem
}

struct GalleryLinkGridCellItem {
    let url: URL
    let body: String
}

extension MediaTileViewController {
    
    func indexPath(galleryItem: MediaGalleryItem) -> IndexPath? {
        switch currentType {
        case .media:
            guard let row = mediaGallery.mediaItems.firstIndex(of: galleryItem) else { return nil }
            return IndexPath(row: row, section: 0)
        case .files:
            guard let row = mediaGallery.fileItems.firstIndex(of: galleryItem) else { return nil }
            return IndexPath(row: row, section: 0)
        case .gifs:
            guard let row = mediaGallery.gifItems.firstIndex(of: galleryItem) else { return nil }
            return IndexPath(row: row, section: 0)
        case .voice:
            guard let row = mediaGallery.voiceItems.firstIndex(of: galleryItem) else { return nil }
            return IndexPath(row: row, section: 0)
        case .groups:
            return nil
//        case .links:
//            return nil
        }
    }
}


extension MediaTileViewController {
    
    func didTapVoiceItem(_ item: MediaGalleryItem, cell: VoiceGridViewCell) {
        if cell != currentVoiceCell {
            owsAudioPlayer?.stop()
            currentVoiceCell = cell
        }
        
        prepareAudioPlayer(for: item, attachmentStream: item.attachmentStream)
        owsAudioPlayer?.setCurrentTime(item.attachmentStream.audioDurationSeconds())
        owsAudioPlayer?.togglePlayState()
    }
    
    // MARK: - Audio Setup

    private func prepareAudioPlayer(for item: MediaGalleryItem, attachmentStream: TSAttachmentStream) {
        AssertIsOnMainThread()

        guard let mediaURL = attachmentStream.originalMediaURL else {
            owsFailDebug("mediaURL was unexpectedly nil for attachment: \(attachmentStream)")
            return
        }

        guard FileManager.default.fileExists(atPath: mediaURL.path) else {
            owsFailDebug("audio file missing at path: \(mediaURL)")
            return
        }

        if let audioPlayer = self.owsAudioPlayer {
            // Is this player associated with this media adapter?
            if audioPlayer.owner?.isEqual(item.message.uniqueId) == true {
                return
            }
            audioPlayer.stop()
            self.owsAudioPlayer = nil
        }

        let audioPlayer = OWSAudioPlayer(mediaUrl: mediaURL, audioBehavior: .audioMessagePlayback)
        audioPlayer.delegate = self
        self.owsAudioPlayer = audioPlayer

        // Associate the player with this media adapter.
        self.owsAudioPlayer?.owner = item.message.uniqueId as AnyObject

        self.owsAudioPlayer?.setupAudioPlayer()
    }
}

extension MediaTileViewController: MediaPresentationContextProvider {
    func mediaPresentationContext(item: Media, in coordinateSpace: UICoordinateSpace) -> MediaPresentationContext? {
        // First time presentation can occur before layout.
        view.layoutIfNeeded()

        guard case let .gallery(galleryItem) = item else {
            owsFailDebug("Unexpected media type")
            return nil
        }

        guard let indexPath = indexPath(galleryItem: galleryItem) else {
            owsFailDebug("galleryItemIndexPath was unexpectedly nil")
            return nil
        }

        guard let visibleIndex = collectionView.indexPathsForVisibleItems.firstIndex(of: indexPath) else {
            Logger.debug("visibleIndex was nil, swiped to offscreen gallery item")
            return nil
        }

        guard let cell = collectionView.visibleCells[safe: visibleIndex] as? PhotoGridViewCell else {
            owsFailDebug("cell was unexpectedly nil")
            return nil
        }

        let mediaView = cell.imageView

        guard let mediaSuperview = mediaView.superview else {
            owsFailDebug("mediaSuperview was unexpectedly nil")
            return nil
        }

        let presentationFrame = coordinateSpace.convert(mediaView.frame, from: mediaSuperview)

        return MediaPresentationContext(mediaView: mediaView, presentationFrame: presentationFrame, cornerRadius: 0)
    }

    func snapshotOverlayView(in coordinateSpace: UICoordinateSpace) -> (UIView, CGRect)? {
        return nil
    }
}


extension MediaTileViewController: QLPreviewControllerDataSource {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        owsAssertDebug(index == 0)
        return (currentAttachmentStream?.originalMediaURL as QLPreviewItem?) ?? UnavailableItem()
    }

    private class UnavailableItem: NSObject, QLPreviewItem {
        var previewItemURL: URL? { nil }
    }
}
