//
//  CSGroupBy.swift
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


// MARK: - CSGroupBy

/**
 The `CSGroupBy` serves as the Objective-C bridging type for `GroupBy`.
 
 - SeeAlso: `GroupBy`
 */
@objc
public final class CSGroupBy: NSObject, CSQueryClause {
    
    /**
     The list of key path strings to group results with
     */
    @objc
    public var keyPaths: [KeyPathString] {
        
        return self.bridgeToSwift.keyPaths
    }
    
    /**
     Initializes a `CSGroupBy` clause with a key path string
     
     - parameter keyPath: a key path string to group results with
     */
    @objc
    public convenience init(keyPath: KeyPathString) {
        
        self.init(GroupBy(keyPath))
    }
    
    /**
     Initializes a `CSGroupBy` clause with a list of key path strings
     
     - parameter keyPaths: a list of key path strings to group results with
     */
    @objc
    public convenience init(keyPaths: [KeyPathString]) {
        
        self.init(GroupBy(keyPaths))
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSGroupBy else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CSQueryClause
    
    @objc
    public func applyToFetchRequest(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        
        self.bridgeToSwift.applyToFetchRequest(fetchRequest)
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: GroupBy<NSManagedObject>
    
    public init<D: NSManagedObject>(_ swiftValue: GroupBy<D>) {
        
        self.bridgeToSwift = swiftValue.downcast()
        super.init()
    }
}


// MARK: - GroupBy

extension GroupBy where D: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSGroupBy {
        
        return CSGroupBy(self)
    }
    
    
    // MARK: FilePrivate
    
    fileprivate func downcast() -> GroupBy<NSManagedObject> {
        
        return GroupBy<NSManagedObject>(self.keyPaths)
    }
}
