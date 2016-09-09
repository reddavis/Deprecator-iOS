//
//  NoDeprecationFoundTests.swift
//  Deprecator
//
//  Created by Red Davis on 06/07/2016.
//  Copyright © 2016 Togethera. All rights reserved.
//

import XCTest
import Mockingjay
@testable import Deprecator
    
    
class NoDeprecationFoundTests: XCTestCase, DeprecatorDelegate, DeprecatorDataSource
{
    // Private
    private let requiredDeprecatorURL = NSURL(string: "http://red.to/required")!
    private var deprecator: Deprecator!
    
    private var noDeprecationFoundExpectation: XCTestExpectation?
    
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
    
    func testFindingNoDeprecation()
    {
        self.deprecator = Deprecator(deprecationURL: self.requiredDeprecatorURL, dataSource: self)
        self.deprecator.delegate = self
        
        self.noDeprecationFoundExpectation = self.expectationWithDescription("no deprecation")
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
        self.noDeprecationFoundExpectation?.fulfill()
    }
    
    func deprecator(deprecator: Deprecator, didFailWithError error: Deprecator.Error)
    {
        
    }
    
    // MARK: DeprecatorDataSource
    
    func currentBuildNumber(deprecator: Deprecator) -> Int
    {
        return 99999
    }
}
