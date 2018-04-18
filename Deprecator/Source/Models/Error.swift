//
//  Error.swift
//  Deprecator
//
//  Created by Red Davis on 07/07/2016.
//  Copyright © 2016 Togethera. All rights reserved.
//

import Foundation


public extension Deprecator
{
    public enum DataError: Error
    {
        case noDataReturned
        case httpError(error: Error)
        case JSONError(error: Error)
        case missingDefaultLanguageStrings
    }
}
