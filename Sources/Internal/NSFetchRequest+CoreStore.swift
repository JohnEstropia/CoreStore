//
//  NSFetchRequest+CoreStore.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2016/07/20.
//  Copyright © 2016 John Rommel Estropia. All rights reserved.
//

import CoreData

internal extension NSFetchRequest {
    
    // MARK: Internal
    
    @nonobjc
    internal func cs_dynamicCast<U: NSFetchRequestResult>() -> NSFetchRequest<U> {
        
        return unsafeBitCast(self, to: NSFetchRequest<U>.self)
    }
}
