//
//  MigrationType.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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


// MARK: - MigrationType

/**
 The `MigrationType` specifies the type of migration required for a store.
 */
public enum MigrationType: BooleanType, Hashable {
    
    /**
     Indicates that the persistent store matches the latest model version and no migration is needed
     */
    case None(version: String)
    
    /**
     Indicates that the persistent store does not match the latest model version but Core Data can infer the mapping model, so a lightweight migration is needed
     */
    case Lightweight(sourceVersion: String, destinationVersion: String)
    
    /**
     Indicates that the persistent store does not match the latest model version and Core Data could not infer a mapping model, so a custom migration is needed
     */
    case Heavyweight(sourceVersion: String, destinationVersion: String)
    
    /**
     Returns the source model version for the migration type. If no migration is required, `sourceVersion` will be equal to the `destinationVersion`.
     */
    public var sourceVersion: String {
        
        switch self {
            
        case .None(let version):
            return version
            
        case .Lightweight(let sourceVersion, _):
            return sourceVersion
            
        case .Heavyweight(let sourceVersion, _):
            return sourceVersion
        }
    }
    
    /**
     Returns the destination model version for the migration type. If no migration is required, `destinationVersion` will be equal to the `sourceVersion`.
     */
    public var destinationVersion: String {
        
        switch self {
            
        case .None(let version):
            return version
            
        case .Lightweight(_, let destinationVersion):
            return destinationVersion
            
        case .Heavyweight(_, let destinationVersion):
            return destinationVersion
        }
    }
    
    /**
     Returns `true` if the `MigrationType` is a lightweight migration. Used as syntactic sugar.
     */
    public var isLightweightMigration: Bool {
        
        if case .Lightweight = self {
            
            return true
        }
        return false
    }
    
    /**
     Returns `true` if the `MigrationType` is a heavyweight migration. Used as syntactic sugar.
     */
    public var isHeavyweightMigration: Bool {
        
        if case .Heavyweight = self {
            
            return true
        }
        return false
    }
    
    
    // MARK: BooleanType
    
    public var boolValue: Bool {
        
        switch self {
            
        case .None:         return false
        case .Lightweight:  return true
        case .Heavyweight:  return true
        }
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        let preHash = self.boolValue.hashValue ^ self.isHeavyweightMigration.hashValue
        switch self {
            
        case .None(let version):
            return preHash ^ version.hashValue
            
        case .Lightweight(let sourceVersion, let destinationVersion):
            return preHash ^ sourceVersion.hashValue ^ destinationVersion.hashValue
            
        case .Heavyweight(let sourceVersion, let destinationVersion):
            return preHash ^ sourceVersion.hashValue ^ destinationVersion.hashValue
        }
    }
}


// MARK: - MigrationType: Equatable

@warn_unused_result
public func == (lhs: MigrationType, rhs: MigrationType) -> Bool {
    
    switch (lhs, rhs) {
        
    case (.None(let version1), .None(let version2)):
        return version1 == version2
        
    case (.Lightweight(let source1, let destination1), .Lightweight(let source2, let destination2)):
        return source1 == source2 && destination1 == destination2
        
    case (.Heavyweight(let source1, let destination1), .Heavyweight(let source2, let destination2)):
        return source1 == source2 && destination1 == destination2
        
    default:
        return false
    }
}
