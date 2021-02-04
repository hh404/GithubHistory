//
//  GithubHistoryTests.swift
//  GithubHistoryTests
//
//  Created by huangjianwu on 2021/1/29.
//

import XCTest
@testable import GithubHistory

class GithubHistoryTests: XCTestCase {
    let gitAPIVC = GitHubAPIViewController()
    var window: UIWindow!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        window = UIWindow()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func loadView()
      {
        window.addSubview(gitAPIVC.view)
        RunLoop.current.run(until: Date())
      }
    
    func testGitAPIRequest()  {
        let e = expectation(description: "Alamofire")
        self.loadView()
        gitAPIVC.beginAppearanceTransition(true, animated: true)
        gitAPIVC.endAppearanceTransition()
        e.fulfill()
        waitForExpectations(timeout: 15.0, handler: nil)
    }

}
