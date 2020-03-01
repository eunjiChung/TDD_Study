/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

@testable import DogPatch

import XCTest

class DogPatchClientTests: XCTestCase {
  
  var sut: DogPatchClient!
  var baseURL: URL!
  var mockSession: MockURLSession!
  
  var getDogsURL: URL {
    return URL(string: "dogs", relativeTo: baseURL)!
  }
  
  override func setUp() {
    super.setUp()
    baseURL = URL(string: "https://example.com/api/v1/")!
    mockSession = MockURLSession()
    sut = DogPatchClient(baseURL: baseURL, session: mockSession, responseQueue: nil)
  }
  
  override func tearDown() {
    baseURL = nil
    mockSession = nil
    sut = nil
    super.tearDown()
  }
  
  func whenGetDogs(statusCode: Int = 200,
                   data: Data? = nil,
                   error: Error? = nil) -> (calledCompletion: Bool, dogs: [Dog]?, error: Error?){
    let response = HTTPURLResponse(url: getDogsURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    
    var calledCompletion = false
    var receivedDogs: [Dog]? = nil
    var receivedError: Error? = nil
    let mockTask = sut.getDogs { (dogs, error) in
      calledCompletion = true
      receivedDogs = dogs
      receivedError = error
    } as! MockURLSessionDataTask
    mockTask.completionHandler(data, response, error)
    
    return (calledCompletion, receivedDogs, receivedError)
  }
  
  func verifyGetDogsDispatchedToMain(data: Data? = nil,
                                     statusCode: Int = 200,
                                     error: Error? = nil,
                                     line: UInt = #line) {
    // #line = 해당 라인의 literal...
    print("What is this????????? ", line) // > 호출한 줄의 line 번호가 들어간다
    // given
    mockSession.givenDispatchQueue()
    sut = DogPatchClient(baseURL: baseURL,
                         session: mockSession,
                         responseQueue: .main)
    let expect = self.expectation(description: "Completion wasn't called!")
    
    // when
    var thread: Thread!
    let mockTask = sut.getDogs { (dogs, error) in
      thread = Thread.current
      // 왜 completion은 호출되지 않았다고 하는지...?
      expect.fulfill()
    } as! MockURLSessionDataTask
    let repsonse = HTTPURLResponse(url: getDogsURL,
                                   statusCode: statusCode,
                                   httpVersion: nil,
                                   headerFields: nil)
    mockTask.completionHandler(data, repsonse, error)
    
    // then
    // waitForExpectation...?
    waitForExpectations(timeout: 0.2) { (_) in
      XCTAssertTrue(thread.isMainThread, line: line) // https://www.iosdev.recipes/xctest/custom-assertions-file-and-line/
    }
  }
  
  func test_init_sets_baseURL() {
    // then
    XCTAssertEqual(sut.baseURL, baseURL)
  }
  
  func test_init_sets_session() {
    // then
    XCTAssertEqual(sut.baseURL, baseURL)
    XCTAssertEqual(sut.session, mockSession)
  }
  
  func test_init_sets_responseQueue() {
    // then
    let queue = DispatchQueue.main
    // when
    sut = DogPatchClient(baseURL: baseURL, session: mockSession, responseQueue: queue)
    // then
    XCTAssertEqual(queue, sut.responseQueue)
  }
  
  func test_getDogs_callsExpectedURL() {
    // given
    // when
    let mockTask = sut.getDogs() { _, _ in } as! MockURLSessionDataTask
    // then
    XCTAssertEqual(getDogsURL, mockTask.url)
  }
  
  func test_getDogs_callsResumeOnTask() {
    // given
    // when
    let mockTask = sut.getDogs { (_, _) in } as! MockURLSessionDataTask
    // then
    XCTAssertTrue(mockTask.calledResume)
  }
  
  func test_getDogs_givenResponseStatusCode500_callsCompletion() {
    // when
    let result = whenGetDogs(statusCode: 500)
    
    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.dogs)
    XCTAssertNil(result.error)
  }
  
  func test_getDogs_givenError_callsCompletionWithError() throws {
    // given
    let expectedError = NSError(domain: "com.DogPatchTests", code: 42)
    // when
    let result = whenGetDogs(error: expectedError)
    
    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.dogs)
    let actualError = try XCTUnwrap(result.error as NSError?)
    XCTAssertEqual(actualError, expectedError)
  }
  
  func test_getDogs_givenValidJSON_callsCompletionWithDogs() throws {
    // given
    let data = try Data.fromJSON(fileName: "GET_Dogs_Response")
    let decoder = JSONDecoder()
    let dogs = try decoder.decode([Dog].self, from: data)
    
    // when
    let result = whenGetDogs(data: data)
    
    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertEqual(dogs, result.dogs)
    XCTAssertNil(result.error)
  }
  
  func test_getDogs_givenInvalidJSON_callsCompletionWithError() throws {
    // given
    let data = try Data.fromJSON(fileName: "GET_Dogs_MissingValuesResponse")
    let decoder = JSONDecoder()
    var expectedError: NSError!
    do {
      _ = try decoder.decode([Dog].self, from: data)
    } catch {
      expectedError = error as NSError
    }
    
    // when
    let result = whenGetDogs(data: data)
    
    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.dogs)
    let actualError = try XCTUnwrap(result.error as NSError?)
    XCTAssertEqual(actualError.domain, expectedError.domain)
    XCTAssertEqual(actualError.code, expectedError.code)
  }
  
  func test_getDogs_givenHTTPStatusError_dispatchedToResponseQueue() {
    // given
    verifyGetDogsDispatchedToMain(statusCode: 500)
  }
  
  func test_getDogs_givenError_dispatchesToResponseQueue() {
    // given
    let expectedError = NSError(domain: "com.DogPatchTests", code: 42)
    verifyGetDogsDispatchedToMain(error: expectedError)
  }
  
  func test_getDogs_givenValidJSON_dispatchesToResponseQueue() throws {
    // when
    let data = try Data.fromJSON(fileName: "GET_Dogs_Response")
    // then
    verifyGetDogsDispatchedToMain(data: data)
  }
  
  func test_getDog_givenInvalidJSON_dispathcesToResponseQueue() throws {
    // when
    let data = try Data.fromJSON(fileName: "GET_Dogs_MissingValuesResponse")
    // then
    verifyGetDogsDispatchedToMain(data: data)
  }
}

class MockURLSession: URLSession {
  
  // MockURLSession에서 쓰는 queue는 아래 givenDispatchQueue
  // DogPatchClient에서 쓰는 queue는 Main queue
  var queue: DispatchQueue? = nil
  
  func givenDispatchQueue() {
    // 특정 queue가 주어짐, IsNot Main queue
    queue = DispatchQueue(label: "com.DogPatchTests.MockSession")
  }
  
  override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    return MockURLSessionDataTask(completionHandler: completionHandler, url: url, queue: queue)
  }
}

class MockURLSessionDataTask: URLSessionDataTask {
  
  // URLResponse
  // HTTPURLResponse보다는 상위 클래스.
  // 어차피 URLSession을 통해 받는 response는 모두 HTTPURLResponse의 instance이다.
  // > 확장성을 위한 선택...?
  var completionHandler: (Data?, URLResponse?, Error?) -> Void
  var url: URL
  
  init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void,
       url: URL,
       queue: DispatchQueue?) {
    if let queue = queue {
      self.completionHandler = { data, response, error in
        queue.async {
          completionHandler(data, response, error)
        }
      }
    } else {
      self.completionHandler = completionHandler
    }
    self.url = url
    super.init()
  }
  
  var calledResume = false
  override func resume() {
    calledResume = true
  }
}
