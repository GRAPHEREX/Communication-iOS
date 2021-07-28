//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import XCTest
@testable import Signal
@testable import AppMessaging

class DisplayableTextTest: SignalBaseTest {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDisplayableText() {
        // show plain text
        let boringText = "boring text"
        XCTAssertEqual(boringText, boringText.filterStringForDisplay())

        // show high byte emojis
        let emojiText = "🇹🇹🌼🇹🇹🌼🇹🇹"
        XCTAssertEqual(emojiText, emojiText.filterStringForDisplay())

        // show normal diacritic usage
        let diacriticalText = "Příliš žluťoučký kůň úpěl ďábelské ódy."
        XCTAssertEqual(diacriticalText, diacriticalText.filterStringForDisplay())

        // filter excessive diacritics
        XCTAssertEqual("HAVING TROUBLE READING TEXT?", "H҉̸̧͘͠A͢͞V̛̛I̴̸N͏̕͏G҉̵͜͏͢ ̧̧́T̶̛͘͡R̸̵̨̢̀O̷̡U͡҉B̶̛͢͞L̸̸͘͢͟É̸ ̸̛͘͏R͟È͠͞A̸͝Ḑ̕͘͜I̵͘҉͜͞N̷̡̢͠G̴͘͠ ͟͞T͏̢́͡È̀X̕҉̢̀T̢͠?̕͏̢͘͢".filterStringForDisplay() )

        XCTAssertEqual("LGO!", "L̷̳͔̲͝Ģ̵̮̯̤̩̙͍̬̟͉̹̘̹͍͈̮̦̰̣͟͝O̶̴̮̻̮̗͘͡!̴̷̟͓͓".filterStringForDisplay())
    }

    func testGlyphCount() {
        // Plain text
        XCTAssertEqual("boring text".glyphCount, 11)

        // Emojis
        XCTAssertEqual("🇹🇹🌼🇹🇹🌼🇹🇹".glyphCount, 5)
        XCTAssertEqual("🇹🇹".glyphCount, 1)
        XCTAssertEqual("🇹🇹 ".glyphCount, 2)
        XCTAssertEqual("👌🏽👌🏾👌🏿".glyphCount, 3)
        XCTAssertEqual("😍".glyphCount, 1)
        XCTAssertEqual("👩🏽".glyphCount, 1)
        XCTAssertEqual("👾🙇💁🙅🙆🙋🙎🙍".glyphCount, 8)
        XCTAssertEqual("🐵🙈🙉🙊".glyphCount, 4)
        XCTAssertEqual("❤️💔💌💕💞💓💗💖💘💝💟💜💛💚💙".glyphCount, 15)
        XCTAssertEqual("✋🏿💪🏿👐🏿🙌🏿👏🏿🙏🏿".glyphCount, 6)
        XCTAssertEqual("🚾🆒🆓🆕🆖🆗🆙🏧".glyphCount, 8)
        XCTAssertEqual("0️⃣1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣🔟".glyphCount, 11)
        XCTAssertEqual("🇺🇸🇷🇺🇦🇫🇦🇲".glyphCount, 4)
        XCTAssertEqual("🇺🇸🇷🇺🇸 🇦🇫🇦🇲🇸".glyphCount, 7)
        XCTAssertEqual("🇺🇸🇷🇺🇸🇦🇫🇦🇲".glyphCount, 5)
        XCTAssertEqual("🇺🇸🇷🇺🇸🇦".glyphCount, 3)
        XCTAssertEqual("１２３".glyphCount, 3)

        // Normal diacritic usage
        XCTAssertEqual("Příliš žluťoučký kůň úpěl ďábelské ódy.".glyphCount, 39)

        // Excessive diacritics

        XCTAssertEqual("H҉̸̧͘͠A͢͞V̛̛I̴̸N͏̕͏G҉̵͜͏͢ ̧̧́T̶̛͘͡R̸̵̨̢̀O̷̡U͡҉B̶̛͢͞L̸̸͘͢͟É̸ ̸̛͘͏R͟È͠͞A̸͝Ḑ̕͘͜I̵͘҉͜͞N̷̡̢͠G̴͘͠ ͟͞T͏̢́͡È̀X̕҉̢̀T̢͠?̕͏̢͘͢".glyphCount, 115)

        XCTAssertEqual("L̷̳͔̲͝Ģ̵̮̯̤̩̙͍̬̟͉̹̘̹͍͈̮̦̰̣͟͝O̶̴̮̻̮̗͘͡!̴̷̟͓͓".glyphCount, 43)
    }

    func testContainsOnlyEmoji() {
        // Plain text
        XCTAssertFalse("boring text".containsOnlyEmoji)

        // Emojis
        XCTAssertTrue("🇹🇹🌼🇹🇹🌼🇹🇹".containsOnlyEmoji)
        XCTAssertTrue("🇹🇹".containsOnlyEmoji)
        XCTAssertFalse("🇹🇹 ".containsOnlyEmoji)
        XCTAssertTrue("👌🏽👌🏾👌🏿".containsOnlyEmoji)
        XCTAssertTrue("😍".containsOnlyEmoji)
        XCTAssertTrue("👩🏽".containsOnlyEmoji)
        XCTAssertTrue("👾🙇💁🙅🙆🙋🙎🙍".containsOnlyEmoji)
        XCTAssertTrue("🐵🙈🙉🙊".containsOnlyEmoji)
        XCTAssertTrue("❤️💔💌💕💞💓💗💖💘💝💟💜💛💚💙".containsOnlyEmoji)
        XCTAssertTrue("✋🏿💪🏿👐🏿🙌🏿👏🏿🙏🏿".containsOnlyEmoji)
        XCTAssertTrue("🚾🆒🆓🆕🆖🆗🆙🏧".containsOnlyEmoji)
        XCTAssertFalse("0️⃣1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣🔟".containsOnlyEmoji)
        XCTAssertTrue("🇺🇸🇷🇺🇦🇫🇦🇲".containsOnlyEmoji)
        XCTAssertFalse("🇺🇸🇷🇺🇸 🇦🇫🇦🇲🇸".containsOnlyEmoji)
        XCTAssertTrue("🇺🇸🇷🇺🇸🇦🇫🇦🇲".containsOnlyEmoji)
        XCTAssertTrue("🇺🇸🇷🇺🇸🇦".containsOnlyEmoji)
        // Unicode standard doesn't consider these to be Emoji.
        XCTAssertFalse("１２３".containsOnlyEmoji)

        // Normal diacritic usage
        XCTAssertFalse("Příliš žluťoučký kůň úpěl ďábelské ódy.".containsOnlyEmoji)

        // Excessive diacritics
        XCTAssertFalse("H҉̸̧͘͠A͢͞V̛̛I̴̸N͏̕͏G҉̵͜͏͢ ̧̧́T̶̛͘͡R̸̵̨̢̀O̷̡U͡҉B̶̛͢͞L̸̸͘͢͟É̸ ̸̛͘͏R͟È͠͞A̸͝Ḑ̕͘͜I̵͘҉͜͞N̷̡̢͠G̴͘͠ ͟͞T͏̢́͡È̀X̕҉̢̀T̢͠?̕͏̢͘͢".containsOnlyEmoji)
        XCTAssertFalse("L̷̳͔̲͝Ģ̵̮̯̤̩̙͍̬̟͉̹̘̹͍͈̮̦̰̣͟͝O̶̴̮̻̮̗͘͡!̴̷̟͓͓".containsOnlyEmoji)
    }

    func test_shouldAllowLinkification() {
        func assertLinkifies(_ text: String, file: StaticString = #file, line: UInt = #line) {
            let displayableText = DisplayableText.displayableTextForTests(text)
            XCTAssert(displayableText.shouldAllowLinkification, "was not linkifiable text: \(text)", file: file, line: line)
        }

        func assertNotLinkifies(_ text: String, file: StaticString = #file, line: UInt = #line) {
            let displayableText = DisplayableText.displayableTextForTests(text)
            XCTAssertFalse(displayableText.shouldAllowLinkification, "was linkifiable text: \(text)", file: file, line: line)
        }

        // some basic happy paths
        assertLinkifies("foo google.com")
        assertLinkifies("google.com/foo")
        assertLinkifies("blah google.com/foo")
        assertLinkifies("foo http://google.com")
        assertLinkifies("foo https://google.com")

        // cyrillic host with ascii tld
        assertNotLinkifies("foo http://asĸ.com")
        assertNotLinkifies("http://asĸ.com")
        assertNotLinkifies("asĸ.com")

        // Mixed latin and cyrillic text, but it's not a link
        // (nothing to linkify, but there's nothing illegal here)
        assertLinkifies("asĸ")

        // Cyrillic host with cyrillic TLD
        assertLinkifies("http://кц.рф")
        assertLinkifies("https://кц.рф")
        assertLinkifies("кц.рф")
        assertLinkifies("https://кц.рф/foo")
        assertLinkifies("https://кц.рф/кц")
        assertLinkifies("https://кц.рф/кцfoo")

        // ascii text outside of the link, with cyrillic host + cyrillic domain
        assertLinkifies("some text: кц.рф")

        // Mixed ascii/cyrillic text outside of the link, with cyrillic host + cyrillic domain
        assertLinkifies("asĸ кц.рф")

        assertLinkifies("google.com")
        assertLinkifies("foo.google.com")
        assertLinkifies("https://foo.google.com")
        assertLinkifies("https://foo.google.com/some/path.html")

        assertNotLinkifies("asĸ.com")
        assertNotLinkifies("https://кц.cфm")
        assertNotLinkifies("https://google.cфm")

        assertLinkifies("кц.рф")
        assertLinkifies("кц.рф/some/path")
        assertLinkifies("https://кц.рф/some/path")
        assertNotLinkifies("http://foo.кц.рф")
    }
}
