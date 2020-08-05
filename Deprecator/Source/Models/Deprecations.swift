//
//  Deprecations.swift
//  Deprecator
//
//  Created by Red Davis on 04/08/2020.
//  Copyright © 2020 Plum Fintech LTD. All rights reserved.
//

import Foundation


internal extension Deprecator
{
    struct Deprecations: Decodable
    {
        // Internal
        internal let minimum: Deprecator.Deprecation?
        internal let preferred: Deprecator.Deprecation?
    }
}

// MARK: Coding keys

private extension Deprecator.Deprecations
{
    private enum CodingKeys: String, CodingKey
    {
        case minimum = "minimum_update"
        case preferred = "preferred_update"
    }
}
