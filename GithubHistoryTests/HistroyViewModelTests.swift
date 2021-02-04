//
//  HistroyViewModelTests.swift
//  GithubHistoryTests
//
//  Created by huangjianwu on 2021/2/4.
//

import XCTest
@testable import GithubHistory

class HistroyViewModelTests: XCTestCase {
    let viewModel = HistroyViewModel(historys: ["testKey"])
    let vc = MockHistoryViewController()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadData() throws {
        let expectation = self.expectation(description: "history view model request")
        vc.asyncExpectation = expectation
        viewModel.delegate = vc
        viewModel.onViewWillAppear()
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertTrue(self.vc.isReady)
            XCTAssertTrue(self.viewModel.githubAPIs.count >= 1 )
        }
    }

}

class MockHistoryViewController: HistoryViewModelDelegate {
    var asyncExpectation: XCTestExpectation?
    var isReady = false
    
    func didReceiveNewAPI() {
        
    }
    
    func requestDidStart(with model: Any?) {
        
    }
    
    func requestDidFinishSuccess(with model: Any?) {
        
    }
    
    func requestDidFinishError(with error: Error) {
        
    }
    
    func modelDidLoad(with model: Any?) {
        isReady = true
        asyncExpectation?.fulfill()
    }
}
