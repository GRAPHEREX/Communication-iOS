//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation

class MediaGalleryAlbum {

    private var originalItems: [MediaGalleryItem]
    var items: [MediaGalleryItem] {
        get {
            guard let _ = self.mediaGallery else {
                owsFailDebug("mediaGallery was unexpectedly nil")
                return originalItems
            }

            return originalItems
        }
    }

    weak var mediaGallery: MediaGallery?

    init(items: [MediaGalleryItem]) {
        self.originalItems = items
    }

    func add(item: MediaGalleryItem) {
        guard !originalItems.contains(item) else {
            return
        }

        originalItems.append(item)
        originalItems.sort { (lhs, rhs) -> Bool in
            return lhs.albumIndex < rhs.albumIndex
        }
    }
}
