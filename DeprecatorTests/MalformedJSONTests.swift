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


class MalformedJSONTests: XCTestCase, DeprecatorDelegate, DeprecatorDataSource
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
    
    // MARK: -
    
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
        self.stub(everything, builder: failure(error))
        
        let URL = NSURL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.HTTPErrorExpectation = self.expectationWithDescription("no deprecation")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testMissingBuildNumberError()
    {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("missing_build_number", ofType: "json")!
        let data = NSData(contentsOfFile: path)!
        
        self.stub(everything, builder: jsonData(data))
        
        let URL = NSURL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.missingBuildNumberExpectation = self.expectationWithDescription("no build number")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testMissingURLError()
    {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("missing_url", ofType: "json")!
        let data = NSData(contentsOfFile: path)!
        
        self.stub(everything, builder: jsonData(data))
        
        let URL = NSURL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.missingURLExpectation = self.expectationWithDescription("no URL")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testInvalidURLError()
    {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("invalid_url", ofType: "json")!
        let data = NSData(contentsOfFile: path)!
        
        self.stub(everything, builder: jsonData(data))
        
        let URL = NSURL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.invalidURLExpectation = self.expectationWithDescription("invalid URL")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testMissingDefaultLanguageError()
    {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("missing_default_language", ofType: "json")!
        let data = NSData(contentsOfFile: path)!
        
        self.stub(everything, builder: jsonData(data))
        
        let URL = NSURL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.missingDefaultLanguageExpectation = self.expectationWithDescription("missing default language")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testMissingStringsError()
    {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("missing_strings", ofType: "json")!
        let data = NSData(contentsOfFile: path)!
        
        self.stub(everything, builder: jsonData(data))
        
        let URL = NSURL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.missingStringsExpectation = self.expectationWithDescription("missing strings")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testDefaultLanguageNotIncludedError()
    {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("default_language_not_included", ofType: "json")!
        let data = NSData(contentsOfFile: path)!
        
        self.stub(everything, builder: jsonData(data))
        
        let URL = NSURL(string: "http://red.to")!
        self.deprecator = Deprecator(deprecationURL: URL, dataSource: self)
        self.deprecator.delegate = self
        
        self.defaultLanguageNotIncludedExpectation = self.expectationWithDescription("default language not included")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    // MARK: DeprecatorDelegate
    
    func deprecator(deprecator: Deprecator, didFindRequiredDeprecation deprecation: Deprecator.Deprecation)
    {
        XCTAssertTrue(false, "shouldn't be called")
    }
    
    func deprecator(deprecator: Deprecator, didFindPreferredDeprecation deprecation: Deprecator.Deprecation)
    {
        XCTAssertTrue(false, "shouldn't be called")
    }
    
    func deprecatorDidNotFindDeprecation(deprecator: Deprecator)
    {
        XCTAssertTrue(false, "shouldn't be called")
    }
    
    func deprecator(deprecator: Deprecator, didFailWithError error: Deprecator.Error)
    {
        switch error
        {
        case .HTTPError(_):
            self.HTTPErrorExpectation?.fulfill()
        case let .missingAttribute(attribute, _):
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
    
    // MARK: DeprecatorDataSource
    
    func currentBuildNumber(deprecator: Deprecator) -> Int
    {
        return 0
    }
}