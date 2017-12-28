//
//  CSWhere.swift
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


// MARK: - CSWhere

/**
 The `CSWhere` serves as the Objective-C bridging type for `Where`.
 
 - SeeAlso: `Where`
 */
@objc
public final class CSWhere: NSObject, CSFetchClause, CSQueryClause, CSDeleteClause {
    
    /**
     The internal `NSPredicate` instance for the `Where` clause
     */
    @objc
    public var predicate: NSPredicate {
        
        return self.bridgeToSwift.predicate
    }

    /**
     Initializes a `CSWhere` clause with a predicate that always evaluates to the specified boolean value
     ```
     MyPersonEntity *people = [transaction
        fetchAllFrom:CSFromClass([MyPersonEntity class])
        fetchClauses:@[CSWhereValue(YES)]]];
     ```
     - parameter value: the boolean value for the predicate
     */
    @objc
    public convenience init(value: Bool) {
        
        self.init(Where(value))
    }
    
    /**
     Initializes a `CSWhere` clause with a predicate using the specified string format and arguments
     ```
     NSPredicate *predicate = // ...
     MyPersonEntity *people = [transaction
        fetchAllFrom:CSFromClass([MyPersonEntity class])
        fetchClauses:@[CSWherePredicate(predicate)]];
     ```
     - parameter format: the format string for the predicate
     - parameter argumentArray: the arguments for `format`
     */
    @objc
    public convenience init(format: String, argumentArray: [NSObject]?) {
        
        self.init(Where(format, argumentArray: argumentArray))
    }
    
    /**
     Initializes a `CSWhere` clause that compares equality
     
     - parameter keyPath: the keyPath to compare with
     - parameter value: the arguments for the `==` operator
     */
    @objc
    public convenience init(keyPath: KeyPathString, isEqualTo value: CoreDataNativeType?) {
        
        self.init(value == nil || value is NSNull
            ? Where("\(keyPath) == nil")
            : Where("\(keyPath) == %@", value!))
    }
    
    /**
     Initializes a `CSWhere` clause that compares membership
     
     - parameter keyPath: the keyPath to compare with
     - parameter list: the array to check membership of
     */
    @objc
    public convenience init(keyPath: KeyPathString, isMemberOf list: [CoreDataNativeType]) {
        
        self.init(Where("\(keyPath) IN %@", list as NSArray))
    }
    
    /**
     Initializes a `CSWhere` clause with an `NSPredicate`
     
     - parameter predicate: the `NSPredicate` for the fetch or query
     */
    @objc
    public convenience init(predicate: NSPredicate) {
        
        self.init(Where(predicate))
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSWhere else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CSFetchClause, CSQueryClause, CSDeleteClause
    
    @objc
    public func applyToFetchRequest(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        
        self.bridgeToSwift.applyToFetchRequest(fetchRequest)
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: Where<NSManagedObject>
    
    public init<D: NSManagedObject>(_ swiftValue: Where<D>) {
        
        self.bridgeToSwift = swiftValue.downcast()
        super.init()
    }
}


// MARK: - Where

extension Where where D: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSWhere {
        
        return CSWhere(self)
    }
    
    
    // MARK: FilePrivate
    
    fileprivate func downcast() -> Where<NSManagedObject> {
        
        return Where<NSManagedObject>(self.predicate)
    }
}
