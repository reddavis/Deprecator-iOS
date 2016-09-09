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
    public enum Error: ErrorType
    {
        case noDataReturned
        case HTTPError(error: NSError)
        case missingAttribute(attribute: String, providedJSON: [String : AnyObject])
        case invalidURL(providedURL: String)
        case missingDefaultLanguageStrings
    }
}
