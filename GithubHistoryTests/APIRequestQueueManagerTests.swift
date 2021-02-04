//
//  APIRequestQueueManagerTests.swift
//  GithubHistoryTests
//
//  Created by huangjianwu on 2021/2/4.
//

import XCTest
@testable import GithubHistory

class APIRequestQueueManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRequest() throws {
        let expectation = self.expectation(description: "github api request succeeds")
        APIRequestQueueManager.default.requestGitAPI(URLRequest(url: URL(string: "https://api.github.com/")!), cacheKey: "testKey", receiptID: UUID().uuidString) { response in
            XCTAssertNotNil(response)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}

