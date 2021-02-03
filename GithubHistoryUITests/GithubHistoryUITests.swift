//
//  GithubHistoryUITests.swift
//  GithubHistoryUITests
//
//  Created by huangjianwu on 2021/1/29.
//

import XCTest
@testable import GithubHistory

class GithubHistoryUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    
    func testAPIPageResponseTextView() {
        let app = XCUIApplication()
        app.launch()
        let textView = app.textViews["git.api.response.text.view"]
        XCTAssert(textView.exists)
    }
    
    func testAPIPageResponseTimesLabel() {
        let app = XCUIApplication()
        app.launch()
        let historyBtn = app.buttons["git.api.goto.history.btn"]
        historyBtn.tap()
    }
    
    func testAPIHistroyBack() {
        let app = XCUIApplication()
        app.launch()
        let historyBtn = app.buttons["git.api.goto.history.btn"]
        historyBtn.tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testHistoryTable() {
        let app = XCUIApplication()
        app.launch()
        let historyBtn = app.buttons["git.api.goto.history.btn"]
        historyBtn.tap()
        let talbeView = app.tables["git.api.history.tableview"]
        self.waitForElementToAppear(element: talbeView, timeout: 5)
        XCTAssert(talbeView.exists)
        let fullScreenshot = XCUIScreen.main.screenshot()
        let image = fullScreenshot.image
        self.saveImage(image: image, name: "testHistoryTable.jpeg")
    }
    
    private func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
            }
        }
    }
    
    private func saveImage(image: UIImage, name: String) {
        // get the documents directory url
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = name
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = image.jpegData(compressionQuality:  1.0)
          //!FileManager.default.fileExists(atPath: fileURL.path)
           {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
}
