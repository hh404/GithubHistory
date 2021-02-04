//
//  GithubAPIRequestViewModelTests.swift
//  GithubHistoryTests
//
//  Created by huangjianwu on 2021/2/4.
//

import XCTest
@testable import GithubHistory

class GithubAPIRequestViewModelTests: XCTestCase {
    let viewModel = GithubAPIRequestViewModel()
    let vc = MockAPIViewController()

    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStartRequest() throws {
        viewModel.delegate = vc
        viewModel.start()
        let expectation = self.expectation(description: "api view model request")
        vc.asyncExpectation = expectation
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertTrue(self.vc.requestCount > 0)
            XCTAssertTrue(self.vc.dataString.count > 0)
        }
        XCTAssertTrue(self.vc.requestCount > 0)
    }
}

class MockAPIViewController: ViewModelDelegate {
    var requestCount =  0
    var dataString = ""
    var asyncExpectation: XCTestExpectation?
    
    func requestDidStart(with model: Any?) {
        requestCount = model as? Int ?? 0
    }
    
    func requestDidFinishSuccess(with model: Any?) {
        let data: Data? = model as? Data
        let str = String(data: data ?? Data(), encoding: .utf8) ?? ""
        dataString = str
        asyncExpectation?.fulfill()
    }
    
    func requestDidFinishError(with error: Error) {
        
    }
    
    func modelDidLoad(with model: Any?) {
        requestCount = model as? Int ?? 0
    }
}
