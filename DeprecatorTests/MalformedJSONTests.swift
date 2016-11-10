//
//  MalformedJSONTests.swift
//  Deprecator
//
//  Created by Red Davis on 07/07/2016.
//  Copyright © 2016 Togethera. All rights reserved.
//

import XCTest
import Mockingjay
@testable import Deprecator


internal class MalformedJSONTests: XCTestCase, DeprecatorDelegate, DeprecatorDataSource
{
    // Private
    private var deprecator: Deprecator!
    
    private var HTTPErrorExpectation: XCTestExpectation?
    private var missingBuildNumberExpectation: XCTestExpectation?
    private var missingURLExpectation: XCTestExpectation?
    private var invalidURLExpectation: XCTestExpectation?
    private var missingDefaultLanguageExpectation: XCTestExpectation?
    private var missingStringsExpectation: XCTestExpectation?
    private var defaultLanguageNotIncludedExpectation: XCTestExpectation?
    
    // MARK: Setup
    
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
        self.removeAllStubs()
    }
    
    // MARK: -
    
    func testHTTPError()
    {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        self.stub(everything, failure(error))
        
        let URL = Foundation.URL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.HTTPErrorExpectation = self.expectation(description: "no deprecation")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testMissingBuildNumberError()
    {
        let path = Bundle(for: type(of: self)).path(forResource: "missing_build_number", ofType: "json")!
        let data = try! Data(contentsOf: Foundation.URL(fileURLWithPath: path))
        
        self.stub(everything, jsonData(data))
        
        let URL = Foundation.URL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.missingBuildNumberExpectation = self.expectation(description: "no build number")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testMissingURLError()
    {
        let path = Bundle(for: type(of: self)).path(forResource: "missing_url", ofType: "json")!
        let data = try! Data(contentsOf: Foundation.URL(fileURLWithPath: path))
        
        self.stub(everything, jsonData(data))
        
        let URL = Foundation.URL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.missingURLExpectation = self.expectation(description: "no URL")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testInvalidURLError()
    {
        let path = Bundle(for: type(of: self)).path(forResource: "invalid_url", ofType: "json")!
        let data = try! Data(contentsOf: Foundation.URL(fileURLWithPath: path))
        
        self.stub(everything, jsonData(data))
        
        let URL = Foundation.URL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.invalidURLExpectation = self.expectation(description: "invalid URL")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testMissingDefaultLanguageError()
    {
        let path = Bundle(for: type(of: self)).path(forResource: "missing_default_language", ofType: "json")!
        let data = try! Data(contentsOf: Foundation.URL(fileURLWithPath: path))
        
        self.stub(everything, jsonData(data))
        
        let URL = Foundation.URL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.missingDefaultLanguageExpectation = self.expectation(description: "missing default language")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testMissingStringsError()
    {
        let path = Bundle(for: type(of: self)).path(forResource: "missing_strings", ofType: "json")!
        let data = try! Data(contentsOf: Foundation.URL(fileURLWithPath: path))
        
        self.stub(everything, jsonData(data))
        
        let URL = Foundation.URL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.missingStringsExpectation = self.expectation(description: "missing strings")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testDefaultLanguageNotIncludedError()
    {
        let path = Bundle(for: type(of: self)).path(forResource: "default_language_not_included", ofType: "json")!
        let data = try! Data(contentsOf: Foundation.URL(fileURLWithPath: path))
        
        self.stub(everything, jsonData(data))
        
        let URL = Foundation.URL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.defaultLanguageNotIncludedExpectation = self.expectation(description: "default language not included")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    // MARK: DeprecatorDelegate
    
    func didFail(with error: Deprecator.DataError, in deprecator: Deprecator)
    {
        switch error
        {
        case .httpError(_):
            self.HTTPErrorExpectation?.fulfill()
        case let .missingAttribute(attribute, _):
            print(attribute)
            
            if let expectation = self.missingBuildNumberExpectation
            {
                XCTAssertEqual(attribute, "build_number")
                expectation.fulfill()
            }
            
            if let expectation = self.missingURLExpectation
            {
                XCTAssertEqual(attribute, "url")
                expectation.fulfill()
            }
            
            if let expectation = self.missingDefaultLanguageExpectation
            {
                XCTAssertEqual(attribute, "default_language")
                expectation.fulfill()
            }
            
            if let expectation = self.missingStringsExpectation
            {
                XCTAssertEqual(attribute, "strings")
                expectation.fulfill()
            }
        case .invalidURL(_):
            self.invalidURLExpectation?.fulfill()
        case .missingDefaultLanguageStrings:
            self.defaultLanguageNotIncludedExpectation?.fulfill()
        default:()
            
        }
    }
    
    func didFind(deprecation: Deprecator.Deprecation, isRequired: Bool, in deprecator: Deprecator)
    {
        XCTFail("shouldn't be called")
    }
    
    func didNotFindDeprecation(in deprecator: Deprecator)
    {
        XCTFail("shouldn't be called")
    }
    
    // MARK: DeprecatorDataSource
    
    func currentBuildNumber(for deprecator: Deprecator) -> Int
    {
        return 0
    }
}
