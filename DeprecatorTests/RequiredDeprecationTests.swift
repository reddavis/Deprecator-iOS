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


class RequiredDeprecationTests: XCTestCase, DeprecatorDelegate, DeprecatorDataSource
{
    // Private
    fileprivate let requiredDeprecatorURL = URL(string: "http://red.to/required")!
    fileprivate var deprecator: Deprecator!
    
    fileprivate var requiredDeprecationExpectation: XCTestExpectation?
    
    // MARK: -
    
    override func setUp()
    {
        super.setUp()
        
        // Stub HTTP requests
        let requriedPath = Bundle(for: type(of: self)).path(forResource: "required_deprecation", ofType: "json")!
        let requiredData = try! Data(contentsOf: URL(fileURLWithPath: requriedPath))
        stub(uri("/required"), jsonData(requiredData))
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: -
    
    func testFindingRequiredDeprecation()
    {
        self.deprecator = Deprecator(deprecationURL: self.requiredDeprecatorURL, dataSource: self)
        self.deprecator.delegate = self
        
        self.requiredDeprecationExpectation = self.expectation(description: "required deprecation")
        self.deprecator.checkForDeprecations()
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    // MARK: DeprecatorDelegate
    
    func didFail(with error: Deprecator.DataError, in deprecator: Deprecator)
    {
        XCTFail("shouldn't be called")
    }
    
    func didFind(deprecation: Deprecator.Deprecation, isRequired: Bool, in deprecator: Deprecator)
    {
        if isRequired
        {
            XCTAssertEqual(deprecation.languages.count, 2)
            self.requiredDeprecationExpectation?.fulfill()
        }
        else
        {
            XCTFail("Deprecation found, but it should be required")
        }
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
