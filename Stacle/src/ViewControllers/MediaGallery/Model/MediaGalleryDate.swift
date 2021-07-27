//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation

public struct MediaGalleryDate: Hashable, Comparable, Equatable {
    let year: Int
    let month: Int

    init(message: TSMessage) {
        let date = message.receivedAtDate()

        self.year = Calendar.current.component(.year, from: date)
        self.month = Calendar.current.component(.month, from: date)
    }

    init(year: Int, month: Int) {
        assert(month >= 1 && month <= 12)

        self.year = year
        self.month = month
    }

    private var isThisMonth: Bool {
        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let month = Calendar.current.component(.month, from: now)
        let thisMonth = MediaGalleryDate(year: year, month: month)

        return self == thisMonth
    }

    public var date: Date {
        var components = DateComponents()
        components.month = self.month
        components.year = self.year

        return Calendar.current.date(from: components)!
    }

    private var isThisYear: Bool {
        let now = Date()
        let thisYear = Calendar.current.component(.year, from: now)

        return self.year == thisYear
    }

    static let thisYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"

        return formatter
    }()

    static let olderFormatter: DateFormatter = {
        let formatter = DateFormatter()

        // FIXME localize for RTL, or is there a built in way to do this?
        formatter.dateFormat = "MMMM yyyy"

        return formatter
    }()

    var localizedString: String {
        if isThisMonth {
            return NSLocalizedString("MEDIA_GALLERY_THIS_MONTH_HEADER", comment: "Section header in media gallery collection view")
        } else if isThisYear {
            return type(of: self).thisYearFormatter.string(from: self.date)
        } else {
            return type(of: self).olderFormatter.string(from: self.date)
        }
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(month)
        hasher.combine(year)
    }

    // MARK: Comparable

    public static func < (lhs: MediaGalleryDate, rhs: MediaGalleryDate) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        } else if lhs.month != rhs.month {
            return lhs.month < rhs.month
        } else {
            return false
        }
    }

    // MARK: Equatable

    public static func == (lhs: MediaGalleryDate, rhs: MediaGalleryDate) -> Bool {
        return lhs.month == rhs.month && lhs.year == rhs.year
    }
}
