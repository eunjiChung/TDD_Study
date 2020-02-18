//
//  APITests.swift
//  MyBizTests
//
//  Created by eunji chung on 2020/02/18.
//  Copyright © 2020 Razeware. All rights reserved.
//

import XCTest
@testable import MyBiz

class APITests: XCTestCase {

  var sut: API!

  override func setUp() {
    super.setUp()
    sut = MockAPI()
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  func givenLoggedIn() {
    sut.token = Token(token: "Nobody", userID: UUID())
  }
  
  func testAPI_whenLogout_generatesANotification() {
    // given
    givenLoggedIn()
    let exp = expectation(forNotification: UserLoggedOutNotification, object: nil)
    
    // when
    sut.logout()
    
    // then
    wait(for: [exp], timeout: 2)
    XCTAssertNil(sut.token)
  }
  
  func testAPI_whenLogin_generatesANotification() {
    // given
    var userInfo: [AnyHashable: Any]?
    let exp = expectation(forNotification: UserLoggedInNotification, object: nil) { (note) -> Bool in
      userInfo = note.userInfo
      return true
    }
    
    // when
    sut.login(username: "test", password: "test")
    
    // then
    wait(for: [exp], timeout: 2)
    let userId = userInfo?[UserNotificationKey.userId]
    XCTAssertNotNil(userId, "the login notification should also have a user id")
  }
}
