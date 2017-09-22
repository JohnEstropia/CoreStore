//
//  CSMigrationType.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import CoreData


// MARK: - CSMigrationType

/**
 The `CSMigrationType` serves as the Objective-C bridging type for `MigrationType`.
 
 - SeeAlso: `MigrationType`
 */
@objc
public final class CSMigrationType: NSObject, CoreStoreObjectiveCType {
    
    /**
     Returns `YES` if the `CSMigrationType`'s `sourceVersion` and `destinationVersion` do not match. Returns `NO` otherwise.
     */
    @objc
    public var needsMigration: Bool {
        
        return self.bridgeToSwift.hasMigration
    }
    
    /**
     Returns the source model version for the migration type. If no migration is required, `sourceVersion` will be equal to the `destinationVersion`.
     */
    @objc
    public var sourceVersion: String {
        
        return self.bridgeToSwift.sourceVersion
    }
    
    /**
     Returns the destination model version for the migration type. If no migration is required, `destinationVersion` will be equal to the `sourceVersion`.
     */
    @objc
    public var destinationVersion: String {
        
        return self.bridgeToSwift.destinationVersion
    }
    
    /**
     Returns `YES` if the `CSMigrationType` is a lightweight migration. Used as syntactic sugar.
     */
    @objc
    public var isLightweightMigration: Bool {
        
        return self.bridgeToSwift.isLightweightMigration
    }
    
    /**
     Returns `YES` if the `CSMigrationType` is a heavyweight migration. Used as syntactic sugar.
     */
    @objc
    public var isHeavyweightMigration: Bool {
        
        return self.bridgeToSwift.isHeavyweightMigration
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSMigrationType else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: MigrationType
    
    public required init(_ swiftValue: MigrationType) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - MigrationType

extension MigrationType: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSMigrationType {
        
        return CSMigrationType(self)
    }
}
