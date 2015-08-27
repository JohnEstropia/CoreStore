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
        
        _ = try? self.removeItemAtURL(fileURL)
        
        let filePath = fileURL.path!
        _ = try? self.removeItemAtPath(filePath.stringByAppendingString("-shm"))
        _ = try? self.removeItemAtPath(filePath.stringByAppendingString("-wal"))
    }
}