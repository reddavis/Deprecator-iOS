//
//  Error.swift
//  Deprecator
//
//  Created by Red Davis on 04/08/2020.
//  Copyright © 2020 Plum Fintech LTD. All rights reserved.
//

import Foundation


public extension Deprecator
{
    enum APIError: Error
    {
        /// No data returned.
        case noData
        
        /// HTTP error encountered.
        case httpError(error: Error)
        
        /// Invalid JSON returned.
        case invalidJSON(error: Error)
    }
}
