//
//  XCTest+Extension.swift
//  DeprecatorTests
//
//  Created by Red Davis on 05/08/2020.
//  Copyright © 2020 Plum Fintech LTD. All rights reserved.
//

import XCTest


internal extension XCTest
{
    func loadMockData(filename: String) throws -> Data
    {
        let fileURL = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "")!
        return try Data(contentsOf: fileURL)
    }
}
