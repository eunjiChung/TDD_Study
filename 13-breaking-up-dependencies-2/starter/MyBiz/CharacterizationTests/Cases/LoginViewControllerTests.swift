//
//  LoginViewControllerTests.swift
//  CharacterizationTests
//
//  Created by CHUNGEUNJI on 15/02/2020.
//  Copyright © 2020 Razeware. All rights reserved.
//

import XCTest

@testable import MyBiz

class LoginViewControllerTests: XCTestCase {

  var sut: LoginViewController!
  
  override func setUp() {
    super.setUp()
    sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "login") as? LoginViewController
    // a proxy for "being logged in" state
    UIApplication.appDelegate.userId = nil
    sut.api = UIApplication.appDelegate.api // mock 말고 실제 api 통신 확인? 왜냐면 beaking dependency했기 때문
    sut.loadViewIfNeeded()
  }
  
  override func tearDown() {
    sut = nil
    UIApplication.appDelegate.userId = nil
    super.tearDown()
  }
  
  func testSignIn_WithGoodCredentials_doesLogin() {
    // given
    sut.emailField.text = "agent@shield.org"
    sut.passwordField.text = "hailHydra"
    
    // when
    // this predicate expectation waits for userId state to be set
    // in order to fulfill the expectation
    let exp = expectation(for: NSPredicate(block: { vc,_ -> Bool in
      return UIApplication.appDelegate.userId != nil
    }), evaluatedWith: sut, handler: nil)
    sut.signIn(sut.signInButton!)
    
    // then
    // remember to start the backend before running this test
    wait(for: [exp], timeout: 3)
    XCTAssertNotNil(UIApplication.appDelegate.userId, "a successful login sets valid user id")
  }
  
  func testSignIn_withBadCredentials_showsError() {
    // given
    sut.emailField.text = "bad@credentials.ca"
    sut.passwordField.text = "Shazam!"
    
    // when
    // waits modal view to be shown
    let exp = expectation(for: NSPredicate(block: { (vc, _) -> Bool in
      return UIApplication.appDelegate.window?.rootViewController?.presentedViewController != nil
    }), evaluatedWith: sut, handler: nil)
    sut.signIn(sut.signInButton!)
    
    // then
    wait(for: [exp], timeout: 2)
    let presentedController = UIApplication.appDelegate.window?.rootViewController?.presentedViewController as? ErrorViewController
    XCTAssertNotNil(presentedController, "should be showing an error controller")
    XCTAssertEqual(presentedController?.alertTitle, "Login Failed")
    XCTAssertEqual(presentedController?.subtitle, "User has not been authenticated.")
  }

}
