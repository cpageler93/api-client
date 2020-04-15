import XCTest

import api_clientTests

var tests = [XCTestCaseEntry]()
tests += api_clientTests.allTests()
XCTMain(tests)
