//
//  Deprecator.swift
//  Deprecator
//
//  Created by Red Davis on 04/07/2016.
//  Copyright © 2016 Togethera. All rights reserved.
//

import UIKit


// MARK: DeprecatorDelegate

public protocol DeprecatorDelegate: class
{
    func didFind(deprecation: Deprecation, isRequired: Bool, in deprecator: Deprecator)
    func didNotFindDeprecation(in deprecator: Deprecator)
    func didFail(with error: Deprecator.DataError, in deprecator: Deprecator)
}


// MARK: Deprecator

public final class Deprecator
{
    // Public
    public weak var delegate: DeprecatorDelegate?
    
    // Private
    private let currentBuildNumber: Int
    private let deprecationURL: URL
    private let session: URLSession
    
    // MARK: Initialization
    
    public required init(deprecationURL: URL, currentBuildNumber: Int, session: URLSession = URLSession(configuration: .default))
    {
        self.deprecationURL = deprecationURL
        self.currentBuildNumber = currentBuildNumber
        self.session = session
    }
    
    // MARK: -
    
    public func checkForDeprecations()
    {
        self.requestDeprecations()
    }
    
    // MARK: HTTP
    
    private func requestDeprecations()
    {
        self.session.dataTask(with: self.deprecationURL, completionHandler: { [weak self] (data, response, error) in
            guard let weakSelf = self else
            {
                return
            }
            
            if let unwrappedError = error
            {
                let httpError = DataError.httpError(error: unwrappedError)
                weakSelf.delegate?.didFail(with: httpError, in: weakSelf)
                
                return
            }
            
            guard let unwrappedData = data else
            {
                weakSelf.delegate?.didFail(with: DataError.noDataReturned, in: weakSelf)
                return
            }
            
            // Let the delegate know whats going on
            do
            {
                let decoder = JSONDecoder()
                let deprecations = try decoder.decode(Deprecations.self, from: unwrappedData)

                // First check that there is a minimum deprecation.
                // If there is one, then it takes priority.
                if let minimumDeprecation = deprecations.minimumDeprecation,
                       minimumDeprecation.buildNumber > weakSelf.currentBuildNumber
                {
                    weakSelf.delegate?.didFind(deprecation: minimumDeprecation, isRequired: true, in: weakSelf)
                    return
                }
                
                // Check if there is a preferred deprecation.
                // This will only be called if there is no minimum deprecation.
                if let preferredDeprecation = deprecations.preferredDeprecation,
                       preferredDeprecation.buildNumber > weakSelf.currentBuildNumber
                {
                    weakSelf.delegate?.didFind(deprecation: preferredDeprecation, isRequired: false, in: weakSelf)
                    return
                }
                
                // No deprecations found
                weakSelf.delegate?.didNotFindDeprecation(in: weakSelf)
            }
            catch let error as Deprecator.DataError
            {
                weakSelf.delegate?.didFail(with: error, in: weakSelf)
            }
            catch let error
            {
                let JSONError = Deprecator.DataError.JSONError(error: error)
                weakSelf.delegate?.didFail(with: JSONError, in: weakSelf)
            }
        }).resume()
    }
}
