//
//  XCTestCase+Extensions.swift
//  Red Davis
//
//  Created by Red Davis on 22/02/2018.
//  Copyright © 2018 Red Davis. All rights reserved.
//

import XCTest


internal func XCTAssertEqualOptional<T: Any, Q: Any>(_ expectedValue: @autoclosure () -> T?, _ expression2: @autoclosure () -> Q?, _ message: String = "", file: StaticString = #file, line: UInt = #line) where T: Equatable
{
    switch (expectedValue(), expression2())
    {
    case (nil, nil):
        XCTAssert(true)
    case (let a?, nil):
        XCTFail("Expression1: \(a) - Expression2: nil", file: file, line: line)
    case (nil, let b?):
        XCTFail("Expression1: nil - Expression2: \(b)", file: file, line: line)
    case (let a?, let b?):
        guard let castB = b as? T else
        {
            XCTFail("Expression1: \(a) - Expression2: \(b)", file: file, line: line)
            return
        }
        
        XCTAssertEqual(a, castB, message, file: file, line: line)
    }
}
