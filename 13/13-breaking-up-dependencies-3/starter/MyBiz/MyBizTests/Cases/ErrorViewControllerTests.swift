//
//  ErrorViewControllerTests.swift
//  MyBizTests
//
//  Created by eunji chung on 2020/02/18.
//  Copyright © 2020 Razeware. All rights reserved.
//

import XCTest
@testable import MyBiz

class ErrorViewControllerTests: XCTestCase {

  var sut: ErrorViewController!
  
  override func setUp() {
    super.setUp()
    sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "error") as? ErrorViewController
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  func testSecondaryButton_whenActionSet_hasCorrectTitle() {
    // given
    let action = ErrorViewController.SecondaryAction(title: "title") {}
    sut.secondaryAction = action
    // when
    sut.loadViewIfNeeded()
    // then
    XCTAssertEqual(sut.secondaryButton.currentTitle, "title")
  }
  
  func testSecondaryAction_whenButtonTapped_isInvoked() {
    // given
    let exp = expectation(description: "secondary action")
    var actionHappened = false
    let action = ErrorViewController.SecondaryAction(title: "action") {
      actionHappened = true
      exp.fulfill()
    }
    sut.secondaryAction = action
    sut.loadViewIfNeeded()
    // when
    sut.secondaryAction(())
    // then
    wait(for: [exp], timeout: 1)
    XCTAssertTrue(actionHappened)
  }

}
