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
    func didFind(deprecation: Deprecator.Deprecation, isRequired: Bool, in deprecator: Deprecator)
    func didNotFindDeprecation(in deprecator: Deprecator)
    func didFail(with error: Deprecator.DataError, in deprecator: Deprecator)
}

// MARK: DeprecatorDataSource

public protocol DeprecatorDataSource: class
{
    func currentBuildNumber(for deprecator: Deprecator) -> Int
}

// MARK: Deprecator

public final class Deprecator
{
    // Public
    public weak var delegate: DeprecatorDelegate?
    
    // Private
    private weak var dataSource: DeprecatorDataSource?
    
    private let deprecationURL: URL
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // JSON Keys
    private let minimumUpdateKey = "minimum_update"
    private let preferredUpdateKey = "preferred_update"
    
    // MARK: Initialization
    
    public required init(deprecationURL: URL, dataSource: DeprecatorDataSource)
    {
        self.deprecationURL = deprecationURL
        self.dataSource = dataSource
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
            guard let weakSelf = self else { return }
            
            if let unwrappedError = error
            {
                let HTTPError = DataError.httpError(error: unwrappedError)
                weakSelf.delegate?.didFail(with: HTTPError, in: weakSelf)
                
                return
            }
            
            guard let unwrappedData = data else
            {
                weakSelf.delegate?.didFail(with: DataError.noDataReturned, in: weakSelf)
                return
            }
            
            // Let the delegate know whats going on
            let currentBuildNumber = weakSelf.dataSource!.currentBuildNumber(for: weakSelf)
            
            do
            {
                let deprecations = try weakSelf.buildDeprecations(with: unwrappedData)
                var deprecationFound = false
                
                if let minimumDeprecation = deprecations.minimumDeprecation, minimumDeprecation.buildNumber > currentBuildNumber
                {
                    weakSelf.delegate?.didFind(deprecation: minimumDeprecation, isRequired: true, in: weakSelf)
                    deprecationFound = true
                }
                
                // First check that there is a preferred deprecation.
                // If there is and a minumum deprecation then it takes priority
                if let preferredDeprecation = deprecations.preferredDeprecation, preferredDeprecation.buildNumber > currentBuildNumber && deprecationFound == false
                {
                    weakSelf.delegate?.didFind(deprecation: preferredDeprecation, isRequired: false, in: weakSelf)
                    deprecationFound = true
                }
                
                // No deprecations found
                if !deprecationFound
                {
                    weakSelf.delegate?.didNotFindDeprecation(in: weakSelf)
                }
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
        }) .resume()
    }
    
    private func buildDeprecations(with JSONData: Data) throws -> (minimumDeprecation: Deprecation?, preferredDeprecation: Deprecation?)
    {
        let JSON = try JSONSerialization.jsonObject(with: JSONData, options: [])
        
        // Minimum
        var minimumDeprecation: Deprecation?
        if let minimumJSON = (JSON as AnyObject).object(forKey: self.minimumUpdateKey) as? [String : AnyObject]
        {
        
            minimumDeprecation = try Deprecation(JSON: minimumJSON)
        }
        
        // Preferred
        var preferredDeprecation: Deprecation?
        if let preferredJSON = (JSON as AnyObject).object(forKey: self.preferredUpdateKey) as? [String : AnyObject]
        {
            preferredDeprecation = try Deprecation(JSON: preferredJSON)
        }
        
        return (minimumDeprecation, preferredDeprecation)
    }
}
