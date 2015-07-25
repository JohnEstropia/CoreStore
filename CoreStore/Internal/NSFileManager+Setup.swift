//
//  NSFileManager+Setup.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2015/07/19.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import Foundation


// MARK: - NSFileManager

internal extension NSFileManager {
    
    // MARK: Internal
    
    internal func removeSQLiteStoreAtURL(fileURL: NSURL) {
        
        do {
            
            try self.removeItemAtURL(fileURL)
        }
        catch _ { }
        
        do {
            
            try self.removeItemAtPath(fileURL.path!.stringByAppendingString("-shm"))
        }
        catch _ { }
        
        do {
            
            try self.removeItemAtPath(fileURL.path!.stringByAppendingString("-wal"))
        }
        catch _ { }
    }
}