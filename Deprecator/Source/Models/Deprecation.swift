//
//  Deprecation.swift
//  Deprecator
//
//  Created by Red Davis on 07/07/2016.
//  Copyright © 2016 Togethera. All rights reserved.
//

import Foundation


public struct Deprecation: Decodable
{
    // Public
    public let buildNumber: Int
    public let appStoreURL: URL
    public let defaultLanguageStrings: LanguageStrings
    public let languages: [String : LanguageStrings]
    
    // MARK: Initialization
    
    public init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.buildNumber = try values.decode(Int.self, forKey: .buildNumber)
        self.appStoreURL = try values.decode(URL.self, forKey: .appStoreURL)
        
        // Language strings
        let defaultLanguage = try values.decode(String.self, forKey: .defaultLanguage)
        self.languages = try values.decode([String : LanguageStrings].self, forKey: .strings)
        
        // Default language strings
        guard let defaultLanguageStrings = self.languages[defaultLanguage] else
        {
            throw Deprecator.DataError.missingDefaultLanguageStrings
        }
        
        self.defaultLanguageStrings = defaultLanguageStrings
    }
    
    // MARK: Alerts
    
    public func present(in viewController: UIViewController, language: String? = nil, completion: (() -> Void)? = nil)
    {
        var languageStrings = self.defaultLanguageStrings
        if let unwrappedLanguage = language,
           let userLanguageStrings = self.languages[unwrappedLanguage]
        {
            languageStrings = userLanguageStrings
        }
        
        // Alert controller
        let alertController = UIAlertController(title: languageStrings.title, message: languageStrings.message, preferredStyle: .alert)
        
        // Update action
        let updateAction = UIAlertAction(title: languageStrings.updateTitle, style: .default) { (action) in
            UIApplication.shared.open(self.appStoreURL, options: [:], completionHandler: nil)
        }
        alertController.addAction(updateAction)
        
        // Cancel button
        if let cancelTitle = languageStrings.cancelTitle
        {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        }
        
        // Present
        viewController.present(alertController, animated: true, completion: completion)
    }
}


// MARK: Coding keys

private extension Deprecation
{
    private enum CodingKeys: String, CodingKey
    {
        case buildNumber = "build_number"
        case appStoreURL = "url"
        case defaultLanguage = "default_language"
        case strings
    }
}
