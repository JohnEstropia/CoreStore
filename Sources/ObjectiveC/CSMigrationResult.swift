//
//  CSMigrationResult.swift
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


// MARK: - CSMigrationResult

/**
 The `CSMigrationResult` serves as the Objective-C bridging type for `MigrationResult`.
 
 - SeeAlso: `MigrationResult`
 */
@objc
public final class CSMigrationResult: NSObject, CoreStoreObjectiveCType {
    
    /**
     `YES` if the migration succeeded, `NO` otherwise
     */
    @objc
    public var isSuccess: Bool {
        
        return self.bridgeToSwift.boolValue
    }
    
    /**
     `YES` if the migration failed, `NO` otherwise
     */
    @objc
    public var isFailure: Bool {
        
        return !self.bridgeToSwift.boolValue
    }
    
    /**
     `YES` if the migration succeeded, `NO` otherwise
     */
    @objc
    public var migrationTypes: [CSMigrationType]? {
        
        guard case .Success(let migrationTypes) = self.bridgeToSwift else {
            
            return nil
        }
        return migrationTypes.map { $0.bridgeToObjectiveC }
    }
    
    /**
     The `NSError` for a failed migration, or `nil` if the migration succeeded
     */
    @objc
    public var error: NSError? {
        
        guard case .Failure(let error) = self.bridgeToSwift else {
            
            return nil
        }
        return error.bridgeToObjectiveC
    }
    
    /**
     If the result was a success, the `success` block is executed with an array of `CSMigrationType`s that indicates the migration steps completed. If the result was a failure, the `failure` block is executed with an `NSError` argument pertaining to the actual error.
     
     The blocks are executed immediately as `@noescape` and will not be retained.
     
     - parameter success: the block to execute on success. The block passes an array of `CSMigrationType`s that indicates the migration steps completed.
     - parameter failure: the block to execute on failure. The block passes an `NSError` argument that pertains to the actual error.
     */
    @objc
    public func handleSuccess(@noescape success: (migrationTypes: [CSMigrationType]) -> Void, @noescape failure: (error: NSError) -> Void) {
        
        switch self.bridgeToSwift {
            
        case .Success(let migrationTypes):
            success(migrationTypes: migrationTypes.map { $0.bridgeToObjectiveC })
            
        case .Failure(let error):
            failure(error: error.bridgeToObjectiveC)
        }
    }
    
    /**
     If the result was a success, the `success` block is executed with an array of `CSMigrationType`s that indicates the migration steps completed. If the result was a failure, this method does nothing.
     
     The block is executed immediately as `@noescape` and will not be retained.
     
     - parameter success: the block to execute on success. The block passes an array of `CSMigrationType`s that indicates the migration steps completed.
     */
    @objc
    public func handleSuccess(@noescape success: (migrationTypes: [CSMigrationType]) -> Void) {
        
        guard case .Success(let migrationTypes) = self.bridgeToSwift else {
            
            return
        }
        success(migrationTypes: migrationTypes.map { $0.bridgeToObjectiveC })
    }
    
    /**
     If the result was a failure, the `failure` block is executed with an `NSError` argument pertaining to the actual error. If the result was a success, this method does nothing.
     
     The block is executed immediately as `@noescape` and will not be retained.
     
     - parameter failure: the block to execute on failure. The block passes an `NSError` argument that pertains to the actual error.
     */
    @objc
    public func handleFailure(@noescape failure: (error: NSError) -> Void) {
        
        guard case .Failure(let error) = self.bridgeToSwift else {
            
            return
        }
        failure(error: error.bridgeToObjectiveC)
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSMigrationResult else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: self.dynamicType))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: MigrationResult
    
    public required init(_ swiftValue: MigrationResult) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - MigrationResult

extension MigrationResult: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public typealias ObjectiveCType = CSMigrationResult
}
