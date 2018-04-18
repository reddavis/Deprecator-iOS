//
//  Deprecations.swift
//  Deprecator
//
//  Created by Red Davis on 18/04/2018.
//  Copyright © 2018 Red Davis. All rights reserved.
//

import Foundation


internal struct Deprecations: Decodable
{
    // Internal
    internal let minimumDeprecation: Deprecation?
    internal let preferredDeprecation: Deprecation?
}


// MARK: Coding keys

private extension Deprecations
{
    private enum CodingKeys: String, CodingKey
    {
        case minimumDeprecation = "minimum_update"
        case preferredDeprecation = "preferred_update"
    }
}
