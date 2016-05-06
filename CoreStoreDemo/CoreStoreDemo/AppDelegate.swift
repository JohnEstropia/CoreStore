//
//  AppDelegate.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/02.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreData
import CoreStore


// MARK: - AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UIApplicationDelegate
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        application.statusBarStyle = .LightContent
        
        
        print(CoreStoreError.MappingModelNotFound(localStoreURL: NSURL(string: "file://sample.db")!, targetModel: NSManagedObjectModel.mergedModelFromBundles(nil)!, targetModelVersion: "Sample-1.0.0"))
        CoreStore.defaultStack = DataStack(migrationChain: ["Sample-1.0.0": "Sample-1.0.2", "Sample-1.0.1": "Sample-1.0.2"])
        print(CoreStore.defaultStack)
        print(CoreStore.beginUnsafe())
        
        return true
    }
}

