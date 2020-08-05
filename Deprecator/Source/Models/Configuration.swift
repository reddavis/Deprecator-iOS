//
//  Configuration.swift
//  Deprecator
//
//  Created by Red Davis on 05/08/2020.
//  Copyright © 2020 Plum Fintech LTD. All rights reserved.
//

import Foundation


public extension Deprecator
{
    struct Configuration
    {
        // Public
        
        /// The `URL` of where the deprecation JSON is requested from.
        public let url: URL
        
        /// The app's current build number.
        public let currentBuild: Int
        
        /// Handler for when a deprecation is found.
        public let onDeprecationFound: DeprecationFoundClosure
        public typealias DeprecationFoundClosure = (_ deprecation: Deprecator.Deprecation) -> Void
        
        /// Handler for when no deprecation is found.
        public let onNoDeprecationFound: NoDeprecationFoundClosure
        public typealias NoDeprecationFoundClosure = () -> Void
        
        /// Handler for when `Deprecator` encounters an error.
        public let onError: ErrorClosure
        public typealias ErrorClosure = (_ error: Deprecator.APIError) -> Void
        
        // MARK: Initialization
        
        public init(url: URL, currentBuild: Int, onDeprecationFound: @escaping DeprecationFoundClosure, onNoDeprecationFound: @escaping NoDeprecationFoundClosure, onError: @escaping ErrorClosure)
        {
            self.url = url
            self.currentBuild = currentBuild
            self.onDeprecationFound = onDeprecationFound
            self.onNoDeprecationFound = onNoDeprecationFound
            self.onError = onError
        }
    }
}
