import XCTest
@testable import BD

class BDTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(BD().text, "Hello, World!")
    }


    static var allTests : [(String, (BDTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
