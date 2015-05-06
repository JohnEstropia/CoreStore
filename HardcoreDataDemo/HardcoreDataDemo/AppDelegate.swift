//
//  AppDelegate.swift
//  HardcoreDataDemo
//
//  Created by John Rommel Estropia on 2015/05/02.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import HardcoreData


let paletteList: ManagedObjectListController<Palette> = {
    
    HardcoreData.defaultStack.addSQLiteStore()
    return HardcoreData.observeObjectList(
        From(Palette),
        GroupBy("colorName"),
        SortedBy(.Ascending("hue"), .Ascending("dateAdded"))
    )
}()


// MARK: - AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UIApplicationDelegate
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        return true
    }
}

