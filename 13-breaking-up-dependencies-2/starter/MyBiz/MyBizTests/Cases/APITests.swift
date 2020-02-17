//
//  APITests.swift
//  MyBizTests
//
//  Created by CHUNGEUNJI on 17/02/2020.
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
    // expect notification
    let exp = expectation(forNotification: UserLoggedOutNotification, object: nil)
    
    // when
    sut.logout()
    
    // then
    wait(for: [exp], timeout: 3)
    XCTAssertNil(sut.token)
  }
  
  func testAPI_whenLogin_generatesANotification() {
    // given
    // AnyHashable을 왜쓰지... -> mixed type keys를 쓸때 쓴대
    var userInfo: [AnyHashable: Any]?
    // ????
    let exp = expectation(forNotification: UserLoggedInNotification, object: nil) { note -> Bool in
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
