//
//  AppDelegate.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/02.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


// MARK: - AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UIApplicationDelegate
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        application.statusBarStyle = .LightContent
        
        
        print(InMemoryStore())
        print(SQLiteStore())
        print(LocalStorageOptions.None)
        print([.AllowSynchronousLightweightMigration, .PreventProgressiveMigration] as LocalStorageOptions)
        
        return true
    }
}

