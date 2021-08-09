//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import XCTest
@testable import Signal
@testable import SignalServiceKit

class DeserializationTest: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let dataMsgBase64 = "CjAKBUh4aHhqMiDSH1uDjOFGB60so6K3uWdiiKhhhYndir5/t0I1TN+FqziDkIbFsS8="
        let dataMsgBytes: [UInt8] = Array(dataMsgBase64.utf8)
        let dataMsg = Data(dataMsgBytes)
        
        do {
            let builder = try SSKProtoDataMessage(serializedData: dataMsg)
            print(builder)
        } catch {
            print("DATA MSG ERROR: \(error)")
        }
        
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
