//
//  CSUnsafeDataModelSchema.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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

import CoreData
import Foundation


// MARK: - CSUnsafeDataModelSchema

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public final class CSUnsafeDataModelSchema: NSObject, CSDynamicSchema, CoreStoreObjectiveCType {
    
    @objc
    public required init(modelName: ModelVersion, model: NSManagedObjectModel) {

        fatalError()
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {

        fatalError()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {

        fatalError()
    }
    
    public override var description: String {

        fatalError()
    }
    
    
    // MARK: CSDynamicSchema
    
    @objc
    public var modelVersion: ModelVersion {

        fatalError()
    }
    
    @objc
    public func rawModel() -> NSManagedObjectModel {

        fatalError()
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: UnsafeDataModelSchema
    
    public required init(_ swiftValue: UnsafeDataModelSchema) {

        fatalError()
    }
}


// MARK: - UnsafeDataModelSchema

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
extension UnsafeDataModelSchema: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSUnsafeDataModelSchema {

        fatalError()
    }
}
