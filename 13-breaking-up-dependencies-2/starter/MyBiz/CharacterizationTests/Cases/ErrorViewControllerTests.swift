//
//  ErrorViewControllerTests.swift
//  CharacterizationTests
//
//  Created by CHUNGEUNJI on 18/02/2020.
//  Copyright © 2020 Razeware. All rights reserved.
//

import XCTest

@testable import MyBiz

class ErrorViewControllerTests: XCTestCase {
  
  var sut: ErrorViewController!
  
  override func setUp() {
    super.setUp()
    sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "error") as? ErrorViewController
    // 미리 로드해놓는 뷰가 아니다!
    // 액션을 하면 생기는 뷰 -> 팝업창도 동일하게 테스트하면 될듯?!
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
  
  // 로그인할 때 에러가 날 경우!
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
  
  // 다른 이유로 에러가 났을때!
  func testViewController_whenDefault_secondaryButtonIsHidden() {
    // when
    whenDefault()
    // then
    XCTAssertNil(sut.secondaryButton.superview) // 그냥 표현에 익숙해지기
  }
  
}
