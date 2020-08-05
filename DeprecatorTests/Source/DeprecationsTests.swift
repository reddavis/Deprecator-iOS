//
//  DeprecationsTests.swift
//  DeprecatorTests
//
//  Created by Red Davis on 05/08/2020.
//  Copyright © 2020 Plum Fintech LTD. All rights reserved.
//

import XCTest
@testable import Deprecator


internal final class DeprecationsTests: XCTestCase
{
    internal func testInitialization() throws
    {
        let data = try self.loadMockData(filename: "Example1.json")
        let decoder = JSONDecoder()
        XCTAssertNoThrow(try decoder.decode(Deprecator.Deprecations.self, from: data))
    }
}
