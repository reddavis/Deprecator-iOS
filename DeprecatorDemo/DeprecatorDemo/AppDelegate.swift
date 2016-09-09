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
class AppDelegate: UIResponder, UIApplicationDelegate, DeprecatorDataSource, DeprecatorDelegate
{
    var window: UIWindow?
    
    // Private
    private var deprecator: Deprecator!
    
    // MARK: UIApplicationDelegate

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        let deprecationURL = NSURL(string: "https://gist.githubusercontent.com/reddavis/5a9ec23add5fd9f0a154a05d207320c5/raw/8483aa57ddcdbd33b0b8632b5c3e769aa2916112/deprecator.json")!
        self.deprecator = Deprecator(deprecationURL: deprecationURL, dataSource: self)
        self.deprecator.delegate = self
        
        return true
    }

    func applicationWillResignActive(application: UIApplication)
    {
        
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        self.deprecator.checkForDeprecations()
    }

    func applicationWillTerminate(application: UIApplication)
    {
        
    }
    
    // MARK: DeprecatorDataSource
    
    func currentBuildNumber(deprecator: Deprecator) -> Int
    {
        guard let bundleVersion = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as? String,
              let buildVersionNumber = Int(bundleVersion) else
        {
            fatalError("Build number probably isnt an integer")
        }
        
        return buildVersionNumber
    }
    
    // MARK: DeprecatorDelegate
    
    func deprecator(deprecator: Deprecator, didFindRequiredDeprecation deprecation: Deprecator.Deprecation)
    {
        guard let rootViewController = self.window?.rootViewController else
        {
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            deprecation.present(in: rootViewController)
        })
    }
    
    func deprecator(deprecator: Deprecator, didFindPreferredDeprecation deprecation: Deprecator.Deprecation)
    {
        guard let rootViewController = self.window?.rootViewController else
        {
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            deprecation.present(in: rootViewController)
        })
    }
    
    func deprecatorDidNotFindDeprecation(deprecator: Deprecator)
    {
        print("didnt find anything")
    }
    
    func deprecator(deprecator: Deprecator, didFailWithError error: Deprecator.Error)
    {
        print("error \(error)")
    }
}
