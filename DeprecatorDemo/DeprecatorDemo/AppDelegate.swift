//
//  AppDelegate.swift
//  DeprecatorDemo
//
//  Created by Red Davis on 11/07/2016.
//  Copyright © 2016 Togethera. All rights reserved.
//

import UIKit
import Deprecator


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    // Private
    private var deprecator: Deprecator!
    
    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        let deprecationURL = URL(string: "https://gist.githubusercontent.com/reddavis/5a9ec23add5fd9f0a154a05d207320c5/raw/8483aa57ddcdbd33b0b8632b5c3e769aa2916112/deprecator.json")!
        self.deprecator = Deprecator(deprecationURL: deprecationURL, dataSource: self)
        self.deprecator.delegate = self
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        self.deprecator.checkForDeprecations()
    }
}


extension AppDelegate: DeprecatorDataSource
{
    func currentBuildNumber(for deprecator: Deprecator) -> Int
    {
        guard let bundleVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as? String,
              let buildVersionNumber = Int(bundleVersion) else
        {
            fatalError("Build number probably isnt an integer")
        }
        
        return buildVersionNumber
    }
}


extension AppDelegate: DeprecatorDelegate
{
    func didFind(deprecation: Deprecator.Deprecation, isRequired: Bool, in deprecator: Deprecator)
    {
        guard let rootViewController = self.window?.rootViewController else
        {
            return
        }
        
        DispatchQueue.main.async {
            deprecation.present(in: rootViewController)
        }
    }
    
    func didFail(with error: Deprecator.DataError, in deprecator: Deprecator)
    {
        print("Error! \(error)")
    }
    
    func didNotFindDeprecation(in deprecator: Deprecator)
    {
        print("didnt find anything")
    }
}
