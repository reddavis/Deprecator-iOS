//
//  Deprecation.swift
//  Deprecator
//
//  Created by Red Davis on 04/08/2020.
//  Copyright © 2020 Plum Fintech LTD. All rights reserved.
//

import Foundation


public extension Deprecator
{
    struct Deprecation: Decodable
    {
        // Public
        public let build: Int
        public let updateURL: URL
    }
}

// MARK: Coding keys

private extension Deprecator.Deprecation
{
    private enum CodingKeys: String, CodingKey
    {
        case build = "build_number"
        case updateURL = "url"
    }
}
