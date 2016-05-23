//
//  BaseTestCase.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2016/05/08.
//  Copyright © 2016 John Rommel Estropia. All rights reserved.
//

import XCTest

@testable
import CoreStore


// MARK: - BaseTestCase

class BaseTestCase: XCTestCase {
    
    // MARK: XCTestCase
    
    override func setUp() {
        
        super.setUp()
        self.deleteStores()
    }
    
    override func tearDown() {
        
        self.deleteStores()
        super.tearDown()
    }
    
    
    // MARK: Private
    
    private func deleteStores() {
        
        _ = try? NSFileManager.defaultManager().removeItemAtURL(SQLiteStore.defaultRootDirectory)
    }
}
