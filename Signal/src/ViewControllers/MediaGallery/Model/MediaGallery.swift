//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDB

public enum GalleryDirection {
    case before, after, around
}

public enum GalleryType: String, CaseIterable {
    case media = "Media"
    case files = "Files"
    case voice = "Voice"
    case groups = "Groups"
//    case links = "Links"
    case gifs = "GIFs"
}

protocol MediaGalleryDelegate: AnyObject {
    func mediaGallery(_ mediaGallery: MediaGallery, willDelete items: [MediaGalleryItem], initiatedBy: AnyObject)
    func mediaGallery(_ mediaGallery: MediaGallery, deletedSections: IndexSet, deletedItems: [IndexPath])
}

class MediaGallery {
    
    public var currentFetchType: GalleryType = .media

    private var databaseStorage: SDSDatabaseStorage {
        return SDSDatabaseStorage.shared
    }

    private let mediaGalleryFinder: AnyMediaGalleryFinder
//    private let messagesWithLinkFinder: AnyMessagesWithLinkFinder

    // we start with a small range size for quick loading.
    private let fetchRangeSize: UInt = 10
    private let loadRangeSize: Int = 20000

    @objc
    init(thread: TSThread) {
        self.mediaGalleryFinder = AnyMediaGalleryFinder(thread: thread)
//        self.messagesWithLinkFinder = AnyMessagesWithLinkFinder(thread: thread)
        loadData(thread: thread)
    }

    // MARK: -

    var mediaItems: [MediaGalleryItem] = []
    var fileItems: [MediaGalleryItem] = []
    var voiceItems: [MediaGalleryItem] = []
    var groupsItems: [TSGroupThread] = []
    var linkItems: [(URL, String)] = []
    var gifItems: [MediaGalleryItem] = []
    
    func buildGalleryItem(attachment: TSAttachment, transaction: SDSAnyReadTransaction) -> MediaGalleryItem? {
        guard let attachmentStream = attachment as? TSAttachmentStream else {
            owsFailDebug("gallery doesn't yet support showing undownloaded attachments")
            return nil
        }

        guard let message = attachmentStream.fetchAlbumMessage(transaction: transaction) else {
            owsFailDebug("message was unexpectedly nil")
            return nil
        }

        let galleryItem = MediaGalleryItem(message: message, attachmentStream: attachmentStream)
        galleryItem.album = getAlbum(item: galleryItem)

        return galleryItem
    }

    var galleryAlbums: [String: MediaGalleryAlbum] = [:]
    func getAlbum(item: MediaGalleryItem) -> MediaGalleryAlbum? {
        guard let albumMessageId = item.attachmentStream.albumMessageId else {
            return nil
        }

        guard let existingAlbum = galleryAlbums[albumMessageId] else {
            let newAlbum = MediaGalleryAlbum(items: [item])
            galleryAlbums[albumMessageId] = newAlbum
            newAlbum.mediaGallery = self
            return newAlbum
        }

        existingAlbum.add(item: item)
        return existingAlbum
    }

    // MARK: - Loading

    private func loadData(thread: TSThread) {
        loadLinks()
        loadAttachments(thread: thread)
    }
    
    private func loadAttachments(thread: TSThread) {
        do {
            try Bench(title: "fetching gallery items") {
                try self.databaseStorage.uiReadThrows { [weak self] transaction in
                    guard let self = self else { return }
                    let nsRange: NSRange = NSRange(location: 0, length: self.loadRangeSize)
                    self.mediaGalleryFinder.enumerateAllAttachments(range: nsRange, transaction: transaction) { (attachment: TSAttachment) in
                        if attachment.isVisualMedia || attachment.isVoiceMessage{
                            guard let item: MediaGalleryItem = self.buildGalleryItem(attachment: attachment, transaction: transaction) else { return }
                            if item.isVideo || item.isImage { self.mediaItems.append(item) }
                            if item.isAnimated { self.gifItems.append(item) }
                            if item.isVoice { self.voiceItems.append(item) } 
                        } else {
                            guard let item: MediaGalleryItem = self.buildGalleryItem(attachment: attachment, transaction: transaction) else { return }
                            self.fileItems.append(item)
                        }
                    }
                    guard thread.recipientAddresses.count == 1 else { return }
                    let groups = TSGroupThread.groupThreads(with: thread.recipientAddresses[0], transaction: transaction)
                    self.groupsItems = groups
                }
            }
        } catch { }
    }
    
    private func loadLinks() {
//        do {
//            try Bench(title: "fetching gallery items") {
//                try self.databaseStorage.uiReadThrows { [weak self] transaction in
//                    self?.messagesWithLinkFinder.enumerateAllMessagesWithLink(transaction: transaction) { interaction, stop in
//                        guard
//                            let body = interaction.body,
//                            let match = self?.dataDetector?.firstMatch(in: body, options: [], range: NSRange(location: 0, length: body.utf16.count)),
//                            let range = Range(match.range, in: body)
//                        else {
//                            return
//                        }
//                        var urlString = String(body[range])
//                        if !["http", "https"].contains(urlString.lowercased()) {
//                            urlString = "https://" + urlString
//                        }
//                        guard let url = URL(string: urlString) else { return }
//                        self?.linkItems.append((url, body))
//                    }
//                }
//            }
//        } catch { }
    }
    
    fileprivate var dataDetector: NSDataDetector? {
        return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }

    // MARK: -

    private var _delegates: [Weak<MediaGalleryDelegate>] = []

    var delegates: [MediaGalleryDelegate] {
        return _delegates.compactMap { $0.value }
    }

    func addDelegate(_ delegate: MediaGalleryDelegate) {
        _delegates = _delegates.filter({ $0.value != nil}) + [Weak(value: delegate)]
    }

    let kGallerySwipeLoadBatchSize: UInt = 5

    internal func galleryItem(after currentItem: MediaGalleryItem) -> MediaGalleryItem? {
        Logger.debug("")

        let items: [MediaGalleryItem]
        switch currentFetchType {
        case .media:
            items = mediaItems
        case .gifs:
            items = gifItems
        default:
            return nil
        }
        
        guard let currentIndex = items.firstIndex(of: currentItem) else {
            owsFailDebug("currentIndex was unexpectedly nil")
            return nil
        }

        let index: Int = items.index(after: currentIndex)
        guard let nextItem = items[safe: index] else {
            // already at last item
            return nil
        }

        return nextItem
    }

    internal func galleryItem(before currentItem: MediaGalleryItem) -> MediaGalleryItem? {
        Logger.debug("")

        let items: [MediaGalleryItem]
        switch currentFetchType {
        case .media:
            items = mediaItems
        case .gifs:
            items = gifItems
        default:
            return nil
        }
        
        guard let currentIndex = items.firstIndex(of: currentItem) else {
            owsFailDebug("currentIndex was unexpectedly nil")
            return nil
        }

        let index: Int = items.index(before: currentIndex)
        guard let previousItem = items[safe: index] else {
            // already at first item
            return nil
        }

        return previousItem
    }

    var galleryItemCount: Int {
        let count: UInt = databaseStorage.uiRead { transaction in
            return self.mediaGalleryFinder.mediaCount(transaction: transaction)
        }
        return Int(count)
    }
}
