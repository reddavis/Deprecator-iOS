//
//  Deprecator.swift
//  Deprecator
//
//  Created by Red Davis on 04/08/2020.
//  Copyright © 2020 Plum Fintech LTD. All rights reserved.
//

import Foundation


public final class Deprecator
{
    // Public
    
    /// The current deprecation
    public private(set) var deprecation: Deprecation?
    
    // Private
    private let configuration: Configuration
    private let session: URLSession
    
    // MARK: Initialization
    
    /// Initializes a new `Deprecator` instance.
    /// - Parameters:
    ///   - configuration: A `Deprecator.Configuration` instance.
    ///   - session: A `URLSession` instance.
    public required init(configuration: Configuration, session: URLSession = URLSession(configuration: .default))
    {
        self.configuration = configuration
        self.session = session
    }
    
    // MARK: API
    
    /// Performs a request to the `Deprecator.Configuration#url` to check whether there
    /// is a new version.
    public func check()
    {
        self.session.dataTask(with: self.configuration.url, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            var currentDeprecation: Deprecation?
            defer { self.deprecation = currentDeprecation }
            
            if let error = error
            {
                self.configuration.onError(.httpError(error: error))
                return
            }
            
            guard let data = data else { self.configuration.onError(.noData); return } // No data error
            
            // Parse
            do
            {
                let decoder = JSONDecoder()
                let deprecations = try decoder.decode(Deprecations.self, from: data)
                
                // First check that there is a minimum deprecation.
                if let minimum = deprecations.minimum,
                    minimum.build > self.configuration.currentBuild
                {
                    currentDeprecation = minimum
                    self.configuration.onDeprecationFound(minimum)
                    return
                }
                
                
                if let preferred = deprecations.preferred,
                       preferred.build > self.configuration.currentBuild
                {
                    currentDeprecation = preferred
                    self.configuration.onDeprecationFound(preferred)
                    return
                }
                
                // No deprecations found
                self.configuration.onNoDeprecationFound()
            }
            catch
            {
                self.configuration.onError(.invalidJSON(error: error))
            }
        }).resume()
    }
}
