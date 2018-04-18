//
//  DeprecatorTests.swift
//  DeprecatorTests
//
//  Created by Red Davis on 17/04/2018.
//  Copyright © 2018 Red Davis. All rights reserved.
//

import XCTest
@testable import Deprecator


internal final class DeprecatorTests: XCTestCase
{
    // Private
    private var delegateAssertion: ((_ deprecation: Deprecation?, _ isRequired: Bool?, _ error: Deprecator.DataError?) -> ())?
    private var mockSession: MockSession!
    
    // MARK: Setup
    
    override func setUp()
    {
        super.setUp()
        
        self.mockSession = MockSession()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Successful responses
    
    internal func testMinimumDeprecation()
    {
        let url = URL(string: "http://red.to/deprecator")!
        let deprecator = Deprecator(deprecationURL: url, currentBuildNumber: 47, session: self.mockSession)
        deprecator.delegate = self
        
        // Mock http request
        let data = self.loadMockData(filename: "example1.json")
        let response = MockSession.Response(urlPattern: "deprecator", data: data, statusCode: 200, headers: nil)
        self.mockSession.mockResponses.append(response)
        
        // Assertion
        let expectation = self.expectation(description: "delegate call")
        
        self.delegateAssertion = { (deprecation, isRequired, error) in
            XCTAssertNil(error)
            XCTAssertEqualOptional(true, isRequired)
            XCTAssertEqualOptional(2, deprecation?.languages.count)
            XCTAssertEqualOptional(48, deprecation?.buildNumber)
            XCTAssertEqualOptional("englishTitle", deprecation?.defaultLanguageStrings.title)
            XCTAssertEqualOptional("englishUpdateTitle", deprecation?.defaultLanguageStrings.updateTitle)
            XCTAssertEqualOptional("englishMessage", deprecation?.defaultLanguageStrings.message)
            XCTAssertNil(deprecation?.defaultLanguageStrings.cancelTitle)
            
            expectation.fulfill()
        }
        
        // Request and wait
        deprecator.checkForDeprecations()
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    internal func testPreferredDeprecation()
    {
        let url = URL(string: "http://red.to/deprecator")!
        let deprecator = Deprecator(deprecationURL: url, currentBuildNumber: 60, session: self.mockSession)
        deprecator.delegate = self
        
        // Mock http request
        let data = self.loadMockData(filename: "example1.json")
        let response = MockSession.Response(urlPattern: "deprecator", data: data, statusCode: 200, headers: nil)
        self.mockSession.mockResponses.append(response)
        
        // Assertion
        let expectation = self.expectation(description: "delegate call")
        
        self.delegateAssertion = { (deprecation, isRequired, error) in
            XCTAssertNil(error)
            XCTAssertEqualOptional(false, isRequired)
            XCTAssertEqualOptional(3, deprecation?.languages.count)
            XCTAssertEqualOptional(61, deprecation?.buildNumber)
            XCTAssertEqualOptional("germanTitle", deprecation?.defaultLanguageStrings.title)
            XCTAssertEqualOptional("germanUpdateTitle", deprecation?.defaultLanguageStrings.updateTitle)
            XCTAssertEqualOptional("germanMessage", deprecation?.defaultLanguageStrings.message)
            XCTAssertEqualOptional("germanCancelTitle", deprecation?.defaultLanguageStrings.cancelTitle)
            
            expectation.fulfill()
        }
        
        // Request and wait
        deprecator.checkForDeprecations()
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    // MARK: Error response
    
    internal func testNoData()
    {
        let url = URL(string: "http://red.to/deprecator")!
        let deprecator = Deprecator(deprecationURL: url, currentBuildNumber: 60, session: self.mockSession)
        deprecator.delegate = self
        
        // Mock http request
        let response = MockSession.Response(urlPattern: "deprecator", data: nil, statusCode: 200, headers: nil)
        self.mockSession.mockResponses.append(response)
        
        // Assertion
        let expectation = self.expectation(description: "delegate call")
        
        self.delegateAssertion = { (deprecation, isRequired, error) in
            defer {
                expectation.fulfill()
            }
            
            guard let unwrappedError = error,
                  case Deprecator.DataError.noDataReturned = unwrappedError else
            {
                XCTFail("Incorrect error \(String(describing: error))")
                return
            }
            
            XCTAssertNil(deprecation)
            XCTAssertNil(isRequired)
        }
        
        // Request and wait
        deprecator.checkForDeprecations()
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    internal func testInvalidJSON()
    {
        let url = URL(string: "http://red.to/deprecator")!
        let deprecator = Deprecator(deprecationURL: url, currentBuildNumber: 60, session: self.mockSession)
        deprecator.delegate = self
        
        // Mock http request
        let data = try! JSONSerialization.data(withJSONObject: ["minimum_update" : [:]], options: [])
        let response = MockSession.Response(urlPattern: "deprecator", data: data, statusCode: 200, headers: nil)
        self.mockSession.mockResponses.append(response)
        
        // Assertion
        let expectation = self.expectation(description: "delegate call")
        
        self.delegateAssertion = { (deprecation, isRequired, error) in
            defer {
                expectation.fulfill()
            }
            
            guard let unwrappedError = error,
                  case Deprecator.DataError.JSONError = unwrappedError else
            {
                XCTFail("Incorrect error \(String(describing: error))")
                return
            }
            
            XCTAssertNil(deprecation)
            XCTAssertNil(isRequired)
        }
        
        // Request and wait
        deprecator.checkForDeprecations()
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
}

// MARK: DeprecatorDelegate

extension DeprecatorTests: DeprecatorDelegate
{
    func didFail(with error: Deprecator.DataError, in deprecator: Deprecator)
    {
        self.delegateAssertion?(nil, nil, error)
    }
    
    func didNotFindDeprecation(in deprecator: Deprecator)
    {
        self.delegateAssertion?(nil, nil, nil)
    }
    
    func didFind(deprecation: Deprecation, isRequired: Bool, in deprecator: Deprecator)
    {
        self.delegateAssertion?(deprecation, isRequired, nil)
    }
}
