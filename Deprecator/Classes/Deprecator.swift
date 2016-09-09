//
//  Deprecator.swift
//  Deprecator
//
//  Created by Red Davis on 04/07/2016.
//  Copyright © 2016 Togethera. All rights reserved.
//

import UIKit


public protocol DeprecatorDelegate
{
    func deprecator(deprecator: Deprecator, didFindRequiredDeprecation deprecation: Deprecator.Deprecation)
    func deprecator(deprecator: Deprecator, didFindPreferredDeprecation deprecation: Deprecator.Deprecation)
    func deprecatorDidNotFindDeprecation(deprecator: Deprecator)
    func deprecator(deprecator: Deprecator, didFailWithError error: Deprecator.Error)
}


public protocol DeprecatorDataSource
{
    func currentBuildNumber(deprecator: Deprecator) -> Int
}


public final class Deprecator
{
    // Public
    public var delegate: DeprecatorDelegate?
    
    // Private
    private let dataSource: DeprecatorDataSource
    
    private let deprecationURL: NSURL
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    // JSON Keys
    private let minimumUpdateKey = "minimum_update"
    private let preferredUpdateKey = "preferred_update"
    
    
    // MARK: Initialization
    
    public required init(deprecationURL: NSURL, dataSource: DeprecatorDataSource)
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
        self.session.dataTaskWithURL(self.deprecationURL) { [weak self] (data, response, error) in
            guard let weakSelf = self else { return }
            
            if let unwrappedError = error
            {
                let HTTPError = Error.HTTPError(error: unwrappedError)
                weakSelf.delegate?.deprecator(weakSelf, didFailWithError: HTTPError)
                
                return
            }
            
            guard let unwrappedData = data else
            {
                weakSelf.delegate?.deprecator(weakSelf, didFailWithError: Error.noDataReturned)
                return
            }
            
            // Let the delegate know whats going on
            let currentBuildNumber = weakSelf.dataSource.currentBuildNumber(weakSelf)
            
            do
            {
                let deprecations = try weakSelf.buildDeprecations(unwrappedData)
                var deprecationFound = false
                
                if let minimumDeprecation = deprecations.minimumDeprecation where minimumDeprecation.buildNumber > currentBuildNumber
                {
                    weakSelf.delegate?.deprecator(weakSelf, didFindRequiredDeprecation: minimumDeprecation)
                    deprecationFound = true
                }
                
                // First check that there is a preferred deprecation.
                // If there is and a minumum deprecation then it takes priority
                if let preferredDeprecation = deprecations.preferredDeprecation where preferredDeprecation.buildNumber > currentBuildNumber && deprecationFound == false
                {
                    weakSelf.delegate?.deprecator(weakSelf, didFindPreferredDeprecation: preferredDeprecation)
                    deprecationFound = true
                }
                
                // No deprecations found
                if !deprecationFound
                {
                    weakSelf.delegate?.deprecatorDidNotFindDeprecation(weakSelf)
                }
            }
            catch let JSONError as Error
            {
                weakSelf.delegate?.deprecator(weakSelf, didFailWithError: JSONError)
            }
            catch
            {
                
            }
        }.resume()
    }
    
    private func buildDeprecations(JSONData: NSData) throws -> (minimumDeprecation: Deprecation?, preferredDeprecation: Deprecation?)
    {
        do
        {
            let JSON = try NSJSONSerialization.JSONObjectWithData(JSONData, options: [])
            
            // Minimum
            var minimumDeprecation: Deprecation?
            if let minimumJSON = JSON.objectForKey(self.minimumUpdateKey) as? [String : AnyObject]
            {
            
                minimumDeprecation = try Deprecation(JSON: minimumJSON)
            }
            
            // Preferred
            var preferredDeprecation: Deprecation?
            if let preferredJSON = JSON.objectForKey(self.preferredUpdateKey) as? [String : AnyObject]
            {
                preferredDeprecation = try Deprecation(JSON: preferredJSON)
            }
            
            return (minimumDeprecation, preferredDeprecation)
        }
        catch let JSONError as Error
        {
            throw JSONError
        }
        catch
        {
            return (nil, nil)
        }
    }
}

