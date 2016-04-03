//
//  CSSelect.swift
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


// MARK: - CSSelectTerm

/**
 The `CSSelectTerm` serves as the Objective-C bridging type for `SelectTerm`.
 */
@objc
public final class CSSelectTerm: NSObject, CoreStoreObjectiveCType {
    
    /**
     Provides a `CSSelectTerm` to a `CSSelect` clause for querying an entity attribute.
     ```
     NSString *fullName = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect stringForTerm:[CSSelectTerm attribute:@"fullName"]]
         fetchClauses:@[[CSWhere keyPath:@"employeeID" isEqualTo: @1111]]];
     ```
     - parameter keyPath: the attribute name
     - returns: a `CSSelectTerm` to a `CSSelect` clause for querying an entity attribute
     */
    public static func attribute(keyPath: KeyPath) -> CSSelectTerm {

        return self.init(.Attribute(keyPath))
    }

    /**
     Provides a `CSSelectTerm` to a `CSSelect` clause for querying the average value of an attribute.
     ```
     NSNumber *averageAge = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect numberForTerm:[CSSelectTerm average:@"age" as:nil]]];
     ```
     - parameter keyPath: the attribute name
     - parameter `as`: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "average(<attributeName>)" is used
     - returns: a `CSSelectTerm` to a `CSSelect` clause for querying the average value of an attribute
     */
    public static func average(keyPath: KeyPath, `as` alias: KeyPath?) -> CSSelectTerm {
        
        return self.init(.Average(keyPath, As: alias))
    }

    /**
     Provides a `CSSelectTerm` to a `CSSelect` clause for a count query.
     ```
     NSNumber *numberOfEmployees = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect numberForTerm:[CSSelectTerm count:@"employeeID" as:nil]]];
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "count(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for a count query
     */
    public static func count(keyPath: KeyPath, `as` alias: KeyPath?) -> CSSelectTerm {
        
        return self.init(.Count(keyPath, As: alias))
    }

    /**
     Provides a `CSSelectTerm` to a `CSSelect` clause for querying the maximum value for an attribute.
     ```
     NSNumber *maximumAge = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect numberForTerm:[CSSelectTerm maximum:@"age" as:nil]]];
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "max(<attributeName>)" is used
     - returns: a `CSSelectTerm` to a `CSSelect` clause for querying the maximum value for an attribute
     */
    public static func maximum(keyPath: KeyPath, `as` alias: KeyPath?) -> CSSelectTerm {
        
        return self.init(.Maximum(keyPath, As: alias))
    }

    /**
     Provides a `CSSelectTerm` to a `CSSelect` clause for querying the minimum value for an attribute.
     ```
     NSNumber *minimumAge = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect numberForTerm:[CSSelectTerm minimum:@"age" as:nil]]];
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "min(<attributeName>)" is used
     - returns: a `CSSelectTerm` to a `CSSelect` clause for querying the minimum value for an attribute
     */
    public static func minimum(keyPath: KeyPath, `as` alias: KeyPath?) -> CSSelectTerm {
        
        return self.init(.Minimum(keyPath, As: alias))
    }

    /**
     Provides a `CSSelectTerm` to a `CSSelect` clause for querying the sum value for an attribute.
     ```
     NSNumber *totalAge = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect numberForTerm:[CSSelectTerm sum:@"age" as:nil]]];
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "sum(<attributeName>)" is used
     - returns: a `CSSelectTerm` to a `CSSelect` clause for querying the sum value for an attribute
     */
    public static func sum(keyPath: KeyPath, `as` alias: KeyPath?) -> CSSelectTerm {
        
        return self.init(.Sum(keyPath, As: alias))
    }
    
    /**
     Provides a `CSSelectTerm` to a `CSSelect` clause for querying the `NSManagedObjectID`.
     ```
     NSManagedObjectID *objectID = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect objectIDForTerm:[CSSelectTerm objectIDAs:nil]]
         fetchClauses:@[[CSWhere keyPath:@"employeeID" isEqualTo: @1111]]];
     
     let objectID = CoreStore.queryValue(
     From(MyPersonEntity),
     Select<NSManagedObjectID>(.ObjectID()),
     Where("employeeID", isEqualTo: 1111)
     )
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "objecID" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func objectIDAs(alias: KeyPath? = nil) -> SelectTerm {
        
        return ._Identity(
            alias: alias ?? "objectID",
            nativeType: .ObjectIDAttributeType
        )
    }

    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSSelectTerm else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: SelectTerm
    
    public init(_ swiftValue: SelectTerm) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - SelectTerm

extension SelectTerm: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public typealias ObjectiveCType = CSSelectTerm
}


// MARK: - CSSelect

/**
 The `CSSelect` serves as the Objective-C bridging type for `Select`.
 */
@objc
public final class CSSelect: NSObject {
    
    /**
     Creates a `CSSelect` clause for querying `NSNumber` values.
     ```
     NSNumber *maximumAge = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect numberForTerm:[CSSelectTerm maximum:@"age" as:nil]]];
     ```
     - parameter term: the `CSSelectTerm` specifying the attribute/aggregate value to query
     - returns: a `CSSelect` clause for querying an entity attribute
     */
    public static func numberForTerm(term: CSSelectTerm) -> CSSelect {
        
        return self.init(Select<NSNumber>(term.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSDecimalNumber` values.
     ```
     NSNumber *averageAge = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect decimalNumberForTerm:[CSSelectTerm average:@"age" as:nil]]];
     ```
     - parameter term: the `CSSelectTerm` specifying the attribute/aggregate value to query
     - returns: a `CSSelect` clause for querying an entity attribute
     */
    public static func decimalNumberForTerm(term: CSSelectTerm) -> CSSelect {
        
        return self.init(Select<NSDecimalNumber>(term.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSString` values.
     ```
     NSString *fullName = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect stringForTerm:[CSSelectTerm attribute:@"fullName"]]
         fetchClauses:@[[CSWhere keyPath:@"employeeID" isEqualTo: @1111]]];
     ```
     - parameter term: the `CSSelectTerm` specifying the attribute/aggregate value to query
     - returns: a `CSSelect` clause for querying an entity attribute
     */
    public static func stringForTerm(term: CSSelectTerm) -> CSSelect {
        
        return self.init(Select<NSString>(term.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSDate` values.
     ```
     NSDate *lastUpdatedDate = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect dateForTerm:[CSSelectTerm maximum:@"updatedDate" as:nil]]];
     ```
     - parameter term: the `CSSelectTerm` specifying the attribute/aggregate value to query
     - returns: a `CSSelect` clause for querying an entity attribute
     */
    public static func dateForTerm(term: CSSelectTerm) -> CSSelect {
        
        return self.init(Select<NSDate>(term.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSData` values.
     ```
     NSData *imageData = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect dataForTerm:[CSSelectTerm attribute:@"imageData" as:nil]]
         fetchClauses:@[[CSWhere keyPath:@"employeeID" isEqualTo: @1111]]];
     ```
     - parameter term: the `CSSelectTerm` specifying the attribute/aggregate value to query
     - returns: a `CSSelect` clause for querying an entity attribute
     */
    public static func dataForTerm(term: CSSelectTerm) -> CSSelect {
        
        return self.init(Select<NSData>(term.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSManagedObjectID` values.
     ```
     NSManagedObjectID *objectIDForOldest = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect objectID]
         fetchClauses:@[[CSWhere keyPath:@"employeeID" isEqualTo: @1111]]];
     ```
     - parameter term: the `CSSelectTerm` specifying the attribute/aggregate value to query
     - returns: a `CSSelect` clause for querying an entity attribute
     */
    public static func objectID() -> CSSelect {
        
        return self.init(Select<NSManagedObjectID>(.ObjectID()))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSDictionary` of an entity's attribute keys and values.
     ```
     NSDictionary *keyValues = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect dictionaryForTerm:[CSSelectTerm maximum:@"age" as:nil]]];
     ```
     - parameter term: the `CSSelectTerm` specifying the attribute/aggregate value to query
     - returns: a `CSSelect` clause for querying an entity attribute
     */
    public static func dictionaryForTerm(term: CSSelectTerm) -> CSSelect {
        
        return self.init(Select<NSDictionary>(term.bridgeToSwift))
    }
    
    public static func dictionaryForTerms(terms: [CSSelectTerm]) -> CSSelect {
        
        return self.init(Select<NSDictionary>(terms.map { $0.bridgeToSwift }))
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.attributeType.hashValue
            ^ self.selectTerms.map { $0.hashValue }.reduce(0, combine: ^)
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSSelect else {
            
            return false
        }
        return self.attributeType == object.attributeType
            && self.selectTerms == object.selectTerms
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public init<T: SelectValueResultType>(_ swiftValue: Select<T>) {
        
        self.attributeType = T.attributeType
        self.selectTerms = swiftValue.selectTerms
        super.init()
    }
    
    public init<T: SelectResultType>(_ swiftValue: Select<T>) {
        
        self.attributeType = .UndefinedAttributeType
        self.selectTerms = swiftValue.selectTerms
        super.init()
    }
    
    
    // MARK: Internal
    
    internal let attributeType: NSAttributeType
    internal let selectTerms: [SelectTerm]
}


// MARK: - Select

extension Select: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSelect {
        
        return CSSelect(self)
    }
}
