//
//  Deprecation.swift
//  Deprecator
//
//  Created by Red Davis on 07/07/2016.
//  Copyright © 2016 Togethera. All rights reserved.
//

import Foundation


public extension Deprecator
{
    public struct Deprecation
    {
        public struct LanguageStrings
        {
            let title: String
            let message: String
            let updateTitle: String
            let cancelTitle: String?
            
            internal init?(dictionary: [String : String])
            {
                guard let title = dictionary["title"],
                    let message = dictionary["message"],
                    let updateTitle = dictionary["update_option"] else
                {
                    return nil
                }
                
                self.title = title
                self.message = message
                self.updateTitle = updateTitle
                self.cancelTitle = dictionary["cancel_option"]
            }
        }
        
        // Public
        public let buildNumber: Int
        public let URL: NSURL
        public let defaultLanguageStrings: LanguageStrings
        public private(set) var languages = [String : LanguageStrings]()
        
        // Private
        private let defaultLanguage: String
        
        // MARK: Initialization
        
        internal init(JSON: [String : AnyObject]) throws
        {
            guard let buildNumber = JSON["build_number"] as? Int else
            {
                throw Deprecator.Error.missingAttribute(attribute: "build_number", providedJSON: JSON)
            }
            
            guard let URLString = JSON["url"] as? String else
            {
                throw Deprecator.Error.missingAttribute(attribute: "url", providedJSON: JSON)
            }
            
            guard let URL = NSURL(string: URLString) where URL.scheme != "" else
            {
                throw Deprecator.Error.invalidURL(providedURL: URLString)
            }
            
            guard let defaultLanguage = JSON["default_language"] as? String else
            {
                throw Deprecator.Error.missingAttribute(attribute: "default_language", providedJSON: JSON)
            }
            
            guard let languageStringDictionaries = JSON["strings"] as? [String : [String : String]] else
            {
                throw Deprecator.Error.missingAttribute(attribute: "strings", providedJSON: JSON)
            }
            
            self.defaultLanguage = defaultLanguage
            self.buildNumber = buildNumber
            self.URL = URL
            
            // Language strings
            for (language, stringsDictionary) in languageStringDictionaries
            {
                if let languageStrings = LanguageStrings(dictionary: stringsDictionary)
                {
                    self.languages[language] = languageStrings
                }
            }
            
            // Default language strings
            guard let defaultLanguageStrings = self.languages[self.defaultLanguage] else
            {
                throw Deprecator.Error.missingDefaultLanguageStrings
            }
            
            self.defaultLanguageStrings = defaultLanguageStrings
        }
        
        // MARK: Alerts
        
        public func present(in viewController: UIViewController, language: String? = nil)
        {
            var languageStrings = self.defaultLanguageStrings
            if let unwrappedLanguage = language,
                let userLanguageStrings = self.languages[unwrappedLanguage]
            {
                languageStrings = userLanguageStrings
            }
            
            // Alert controller
            let alertController = UIAlertController(title: languageStrings.title, message: languageStrings.message, preferredStyle: .Alert)
            
            // Update action
            let updateAction = UIAlertAction(title: languageStrings.updateTitle, style: .Default) { (action) in
                UIApplication.sharedApplication().openURL(self.URL)
            }
            alertController.addAction(updateAction)
            
            // Cancel button
            if let cancelTitle = languageStrings.cancelTitle
            {
                let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel) { (action) in
                    
                }
                alertController.addAction(cancelAction)
            }
            
            // Present
            viewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
