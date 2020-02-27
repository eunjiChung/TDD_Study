//
//  LoginViewControllerTests.swift
//  MyBizTests
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
    sut.api = UIApplication.appDelegate.api
    sut.loadViewIfNeeded()
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
}
