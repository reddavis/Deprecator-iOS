//
//  DeprecatorTests.swift
//  DeprecatorTests
//
//  Created by Red Davis on 04/08/2020.
//  Copyright © 2020 Plum Fintech LTD. All rights reserved.
//

import XCTest
@testable import Deprecator


internal final class DeprecatorTests: XCTestCase
{
    // Private
    private var session: MockURLSession!
    private let url = URL(string: "https://withplum.com/test")!
    
    // MARK: Setup
    
    override func setUpWithError() throws
    {
        self.session = MockURLSession()
    }
    
    // MARK: Tests

    internal func testFindingMinumumDeprecation() throws
    {
        // Mock http request
        let data = try self.loadMockData(filename: "Example1.json")
        let response = MockURLSession.Response(urlPattern: "test", data: data, statusCode: 200, headers: nil)
        self.session.mockResponses.append(response)
        
        // Deprecator
        let handlerExpectation = self.expectation(description: "onDeprecationFound called")
        
        let configuration = Deprecator.Configuration(url: self.url, currentBuild: 39, onDeprecationFound: { (deprecation, isRequired) in
            XCTAssertEqual(deprecation.build, 40)
            XCTAssertTrue(isRequired)
            XCTAssertEqual(deprecation.updateURL, URL(string: "https://apply.workable.com/withplum/"))
            
            handlerExpectation.fulfill()
        }, onNoDeprecationFound: {
            XCTFail("Deprecation should have been found")
        }) { (error) in
            XCTFail("Should not have failed -- \(error)")
        }
        
        let deprecator = Deprecator(configuration: configuration, session: self.session)
        deprecator.check()
        
        self.waitForExpectations(timeout: 2.0) { (_) in
            XCTAssertEqual(deprecator.deprecation?.build, 40)
        }
    }
    
    internal func testFindingPreferredDeprecation() throws
    {
        // Mock http request
        let data = try self.loadMockData(filename: "Example1.json")
        let response = MockURLSession.Response(urlPattern: "test", data: data, statusCode: 200, headers: nil)
        self.session.mockResponses.append(response)
        
        // Deprecator
        let handlerExpectation = self.expectation(description: "onDeprecationFound called")
        
        let configuration = Deprecator.Configuration(url: self.url, currentBuild: 59, onDeprecationFound: { (deprecation, isRequired) in
            XCTAssertEqual(deprecation.build, 60)
            XCTAssertFalse(isRequired)
            XCTAssertEqual(deprecation.updateURL, URL(string: "https://apply.workable.com/withplum/"))
            
            handlerExpectation.fulfill()
        }, onNoDeprecationFound: {
            XCTFail("Deprecation should have been found")
        }) { (error) in
            XCTFail("Should not have failed -- \(error)")
        }
        
        let deprecator = Deprecator(configuration: configuration, session: self.session)
        deprecator.check()
        
        self.waitForExpectations(timeout: 2.0) { (_) in
            XCTAssertEqual(deprecator.deprecation?.build, 60)
        }
    }
    
    internal func testNotFindingDeprecation() throws
    {
        // Mock http request
        let data = try self.loadMockData(filename: "Example1.json")
        let response = MockURLSession.Response(urlPattern: "test", data: data, statusCode: 200, headers: nil)
        self.session.mockResponses.append(response)
        
        // Deprecator
        let handlerExpectation = self.expectation(description: "onDeprecationFound called")
        
        let configuration = Deprecator.Configuration(url: self.url, currentBuild: 100, onDeprecationFound: { (_, _) in
            XCTFail("No deprecation should have been found")
        }, onNoDeprecationFound: {
            handlerExpectation.fulfill()
        }) { (error) in
            XCTFail("Should not have failed -- \(error)")
        }
        
        let deprecator = Deprecator(configuration: configuration, session: self.session)
        deprecator.check()
        
        self.waitForExpectations(timeout: 2.0) { (_) in
            XCTAssertNil(deprecator.deprecation)
        }
    }
    
    internal func testHandlingError() throws
    {
        // Mock http request
        let response = MockURLSession.Response(urlPattern: "test", data: nil, statusCode: 500, headers: nil)
        self.session.mockResponses.append(response)
        
        // Deprecator
        let handlerExpectation = self.expectation(description: "onDeprecationFound called")
        
        let configuration = Deprecator.Configuration(url: self.url, currentBuild: 100, onDeprecationFound: { (_, _) in
            XCTFail("No deprecation should have been found")
        }, onNoDeprecationFound: {
            XCTFail("Should have been called")
        }) { (error) in
            handlerExpectation.fulfill()
        }
        
        let deprecator = Deprecator(configuration: configuration, session: self.session)
        deprecator.check()
        
        self.waitForExpectations(timeout: 2.0) { (_) in
            XCTAssertNil(deprecator.deprecation)
        }
    }
}
