//
//  LoginViewControllerTests.swift
//  CharacterizationTests
//
//  Created by eunji chung on 2020/02/18.
//  Copyright © 2020 Razeware. All rights reserved.
//

import XCTest
@testable import MyBiz

class LoginViewControllerTests: XCTestCase {
  
  var sut: LoginViewController!
  
  override func setUp() {
    super.setUp()
    sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "login") as? LoginViewController
    UIApplication.appDelegate.userId = nil // clears shared userId from AppDelegate, "being logged in" state proxy
    sut.api = UIApplication.appDelegate.api
    sut.loadViewIfNeeded()
  }
  
  override func tearDown() {
    sut = nil
    UIApplication.appDelegate.userId = nil // being logged out
    super.tearDown()
  }

  func testSignIn_withGoodCredentials_doesLogin() {
    // given
    sut.emailField.text = "agent@shield.org"
    sut.passwordField.text = "hailHydra"
    
    // when
    let exp = expectation(for: NSPredicate(block: { (vc, _) -> Bool in
      return UIApplication.appDelegate.userId != nil
    }), evaluatedWith: sut, handler: nil)
    sut.signIn(sut.signInButton!)
    
    // then
    wait(for: [exp], timeout: 2)
    XCTAssertNotNil(UIApplication.appDelegate.userId, "a successful login sets valid user id")
  }
  
  func testSignIn_withBadCredentials_showsError() {
    // given
    sut.emailField.text = "bad@credentials.ca"
    sut.passwordField.text = "Shazam!"
    
    // when
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
