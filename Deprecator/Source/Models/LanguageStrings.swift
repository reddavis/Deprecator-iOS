//
//  LanguageStrings.swift
//  Deprecator
//
//  Created by Red Davis on 18/04/2018.
//  Copyright © 2018 Red Davis. All rights reserved.
//

import Foundation


public extension Deprecation
{
    public struct LanguageStrings: Decodable
    {
        // Public
        public let title: String
        public let message: String
        public let updateTitle: String
        public let cancelTitle: String?
    }
}


// MARK: Coding keys

private extension Deprecation.LanguageStrings
{
    private enum CodingKeys: String, CodingKey
    {
        case title
        case message
        case updateTitle = "update_action_title"
        case cancelTitle = "cancel_action_title"
    }
}
