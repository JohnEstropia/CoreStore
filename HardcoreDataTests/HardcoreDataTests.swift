//
//  HardcoreDataTests.swift
//  HardcoreDataTests
//
//  Created by John Rommel Estropia on 2014/09/14.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

import UIKit
import XCTest

class HardcoreDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        
        #if DEBUG
            let resetStoreOnMigrationFailure = true
            #else
            let resetStoreOnMigrationFailure = false
        #endif
        
        switch HardcoreData.defaultStack.addSQLiteStore(resetStoreOnMigrationFailure: resetStoreOnMigrationFailure) {
            
        case .Failure(let error):
            NSException(
                name: "CoreDataMigrationException",
                reason: error.localizedDescription,
                userInfo: error.userInfo).raise()
            
        default: break
        }
        
        HardcoreData.performTransaction { (transaction) -> () in
            
            let obj = transaction.context.findFirst(FlickrPhoto)
            transaction.commit { (result) -> () in
                
                switch result {
                    
                case .Success(let hasChanges):
                    JEDump(hasChanges, "hasChanges")
                case .Failure(let error):
                    JEDump(error, "error")
                }
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
