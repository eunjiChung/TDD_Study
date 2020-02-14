//
//  ErrorViewControllerTests.swift
//  CharacterizationTests
//
//  Created by CHUNGEUNJI on 15/02/2020.
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
  
  func whenDefault() {
    sut.loadViewIfNeeded()
  }
  
  func whenSetToLogin() {
    sut.secondaryAction = .init(title: "Try Again", action: {})
    sut.loadViewIfNeeded()
  }
  
  func testViewController_whenSetToLogin_primaryButtonIsOK() {
    // when
    whenSetToLogin()
    // then
    XCTAssertEqual(sut.okButton.currentTitle, "OK")
  }
  
  func testViewController_whenSetToLogin_showsTryAgainButton() {
   // when
    whenSetToLogin()
    // then
    XCTAssertFalse(sut.secondaryButton.isHidden)
    XCTAssertEqual(sut.secondaryButton.currentTitle, "Try Again")
  }
  
  func testViewController_whenDefault_secondaryButtonIsHidden() {
    // when
    whenDefault()
    // then
    XCTAssertNil(sut.secondaryButton.superview)
  }
  
}
