//
//  APITests.swift
//  MyBizTests
//
//  Created by CHUNGEUNJI on 15/02/2020.
//  Copyright © 2020 Razeware. All rights reserved.
//

import XCTest

@testable import MyBiz

class APITests: XCTestCase {
  
  var sut: API!
  
  // 1
  override func setUp() {
    super.setUp()
    sut = MockAPI()
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  // 2
  // Sets a fake token to simulate the "logged in" state for SUT
  func givenLoggedIn() {
    sut.token = Token(token: "Nobody", userID: UUID())
  }
  
  // 3
  // call logout(), and wait for Notification
  // NotificationCenter is the simplest way for sending asynchronous events
  func testAPI_whenLogout_generatesANotification() {
    // given
    givenLoggedIn()
    let exp = expectation(forNotification: UserLoggedOutNotification, object: nil)
    
    // when
    sut.logout()
    
    // then
    wait(for: [exp], timeout: 2)
    // if logout, token set to nil
    XCTAssertNil(sut.token)
  }
  
  func testAPI_whenLogin_generatesANotification() {
    // given
    var userInfo: [AnyHashable: Any]?
    let exp = expectation(forNotification: UserLoggedNotification, object: nil) { (note) -> Bool in
      userInfo = note.userInfo
      return true
    }
    
    // when
    sut.login(username: "test", password: "test")
    
    // then
    wait(for: [exp], timeout: 1)
    let userId = userInfo?[UserNotificationKey.userId]
    XCTAssertNotNil(userId, "the login notification should also have a userId")
  }
}
