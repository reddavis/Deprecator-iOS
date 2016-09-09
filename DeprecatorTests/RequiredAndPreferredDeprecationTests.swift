//
//  DeprecatorTests.swift
//  DeprecatorTests
//
//  Created by Red Davis on 04/07/2016.
//  Copyright © 2016 Togethera. All rights reserved.
//

import XCTest
import Mockingjay
@testable import Deprecator


class RequiredAndPreferredDeprecationTests: XCTestCase, DeprecatorDelegate, DeprecatorDataSource
{
    // Private
    private let requiredDeprecatorURL = NSURL(string: "http://red.to/required")!
    private var deprecator: Deprecator!
    
    private var requiredDeprecationExpectation: XCTestExpectation?
    private var preferredDeprecationExpectation: XCTestExpectation?
    
    // MARK: -
    
    override func setUp()
    {
        super.setUp()
        
        // Stub HTTP requests
        let requriedPath = NSBundle(forClass: self.dynamicType).pathForResource("required_deprecation", ofType: "json")!
        let requiredData = NSData(contentsOfFile: requriedPath)!
        stub(uri("/required"), builder: jsonData(requiredData))
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: -
    
    func testFindingDeprecation()
    {
        self.deprecator = Deprecator(deprecationURL: self.requiredDeprecatorURL, dataSource: self)
        self.deprecator.delegate = self
        
        self.requiredDeprecationExpectation = self.expectationWithDescription("required deprecation")
        self.preferredDeprecationExpectation = self.expectationWithDescription("preferred deprecation")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    // MARK: DeprecatorDelegate
    
    func deprecator(deprecator: Deprecator, didFindRequiredDeprecation deprecation: Deprecator.Deprecation)
    {
        XCTAssertEqual(deprecation.languages.count, 2)
        
        self.requiredDeprecationExpectation?.fulfill()
    }
    
    func deprecator(deprecator: Deprecator, didFindPreferredDeprecation deprecation: Deprecator.Deprecation)
    {
        XCTAssertEqual(deprecation.languages.count, 2)
        
        self.preferredDeprecationExpectation?.fulfill()
    }
    
    func deprecatorDidNotFindDeprecation(deprecator: Deprecator)
    {
        
    }
    
    func deprecator(deprecator: Deprecator, didFailWithError error: Deprecator.Error)
    {
        
    }
    
    // MARK: DeprecatorDataSource
    
    func currentBuildNumber(deprecator: Deprecator) -> Int
    {
        return 0
    }
}
