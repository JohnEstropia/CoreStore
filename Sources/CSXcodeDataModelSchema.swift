//
//  CSXcodeDataModelSchema.swift
//  CoreStore
//
//  Copyright © 2017 John Rommel Estropia
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


// MARK: - CSXcodeDataModelSchema

/**
 The `CSXcodeDataModelSchema` serves as the Objective-C bridging type for `XcodeDataModelSchema`.
 
 - SeeAlso: `XcodeDataModelSchema`
 */
@objc
public final class CSXcodeDataModelSchema: NSObject, CSDynamicSchema, CoreStoreObjectiveCType {
    
    /**
     Initializes an `CSXcodeDataModelSchema` from an *.xcdatamodeld file URL.
     
     - parameter modelName: the model version, typically the file name of an *.xcdatamodeld file (without the file extension)
     - parameter modelVersionFileURL: the file URL that points to the .xcdatamodeld's "momd" file.
     */
    @objc
    public required init(modelName: ModelVersion, modelVersionFileURL: URL) {
        
        self.bridgeToSwift = XcodeDataModelSchema(
            modelName: modelName,
            modelVersionFileURL: modelVersionFileURL
        )
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.bridgeToSwift).hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSXcodeDataModelSchema else {
            
            return false
        }
        return self.bridgeToSwift === object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CSDynamicSchema
    
    @objc
    public var modelVersion: ModelVersion {
        
        return self.bridgeToSwift.modelVersion
    }
    
    @objc
    public func rawModel() -> NSManagedObjectModel {
        
        return self.bridgeToSwift.rawModel()
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: XcodeDataModelSchema
    
    public required init(_ swiftValue: XcodeDataModelSchema) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - XcodeDataModelSchema

extension XcodeDataModelSchema: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSXcodeDataModelSchema {
        
        return CSXcodeDataModelSchema(self)
    }
}
