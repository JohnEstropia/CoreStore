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
 
 - SeeAlso: `SelectTerm`
 */
@objc
public final class CSSelectTerm: NSObject {
    
    /**
     Provides a `CSSelectTerm` to a `CSSelect` clause for querying an entity attribute.
     ```
     NSString *fullName = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:CSSelectString(CSAttribute(@"fullname"))
         fetchClauses:@[[CSWhere keyPath:@"employeeID" isEqualTo: @1111]]];
     ```
     - parameter keyPath: the attribute name
     */
    @objc
    public convenience init(keyPath: KeyPathString) {

        self.init(.attribute(keyPath))
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
    @objc
    public static func average(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {
        
        return self.init(.average(keyPath, as: alias))
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
    @objc
    public static func count(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {
        
        return self.init(.count(keyPath, as: alias))
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
    @objc
    public static func maximum(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {
        
        return self.init(.maximum(keyPath, as: alias))
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
    @objc
    public static func minimum(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {
        
        return self.init(.minimum(keyPath, as: alias))
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
    @objc
    public static func sum(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {
        
        return self.init(.sum(keyPath, as: alias))
    }
    
    /**
     Provides a `CSSelectTerm` to a `CSSelect` clause for querying the `NSManagedObjectID`.
     ```
     NSManagedObjectID *objectID = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect objectIDForTerm:[CSSelectTerm objectIDAs:nil]]
         fetchClauses:@[[CSWhere keyPath:@"employeeID" isEqualTo: @1111]]];
     ```
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "objecID" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    @objc
    public static func objectIDAs(_ alias: KeyPathString? = nil) -> CSSelectTerm {
        
        return self.init(.objectID(as: alias))
    }

    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSSelectTerm else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: SelectTerm<NSManagedObject>
    
    public init<D: NSManagedObject>(_ swiftValue: SelectTerm<D>) {
        
        self.bridgeToSwift = swiftValue.downcast()
        super.init()
    }
}


// MARK: - SelectTerm

extension SelectTerm where D: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSelectTerm {
        
        return CSSelectTerm(self)
    }
    
    
    // MARK: FilePrivate
    
    fileprivate func downcast() -> SelectTerm<NSManagedObject> {
        
        switch self {
            
        case ._attribute(let keyPath):
            return SelectTerm<NSManagedObject>._attribute(keyPath)
            
        case ._aggregate(let function, let keyPath, let alias, let nativeType):
            return SelectTerm<NSManagedObject>._aggregate(function: function, keyPath: keyPath, alias: alias, nativeType: nativeType)
            
        case ._identity(let alias, let nativeType):
            return SelectTerm<NSManagedObject>._identity(alias: alias, nativeType: nativeType)
        }
    }
}


// MARK: - CSSelect

/**
 The `CSSelect` serves as the Objective-C bridging type for `Select`.
 
 - SeeAlso: `Select`
 */
@objc
public final class CSSelect: NSObject {
    
    /**
     Creates a `CSSelect` clause for querying `NSNumber` values.
     ```
     NSNumber *maxAge = [CSCoreStore
        queryValueFrom:CSFromClass([MyPersonEntity class])
        select:CSSelectNumber(CSAggregateMax(@"age"))
        // ...
     ```
     - parameter numberTerm: the `CSSelectTerm` specifying the attribute/aggregate value to query
     */
    @objc
    public convenience init(numberTerm: CSSelectTerm) {
        
        self.init(Select<NSManagedObject, NSNumber>(numberTerm.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSDecimalNumber` values.
     ```
     NSDecimalNumber *averagePrice = [CSCoreStore
        queryValueFrom:CSFromClass([MyPersonEntity class])
        select:CSSelectDecimal(CSAggregateAverage(@"price"))
        // ...
     ```
     - parameter decimalTerm: the `CSSelectTerm` specifying the attribute/aggregate value to query
     */
    @objc
    public convenience init(decimalTerm: CSSelectTerm) {
        
        self.init(Select<NSManagedObject, NSDecimalNumber>(decimalTerm.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSString` values.
     ```
     NSString *fullname = [CSCoreStore
        queryValueFrom:CSFromClass([MyPersonEntity class])
        select:CSSelectString(CSAttribute(@"fullname"))
        // ...
     ```
     - parameter stringTerm: the `CSSelectTerm` specifying the attribute/aggregate value to query
     */
    @objc
    public convenience init(stringTerm: CSSelectTerm) {
        
        self.init(Select<NSManagedObject, NSString>(stringTerm.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSDate` values.
     ```
     NSDate *lastUpdate = [CSCoreStore
        queryValueFrom:CSFromClass([MyPersonEntity class])
        select:CSSelectDate(CSAggregateMax(@"updatedDate"))
        // ...
     ```
     - parameter dateTerm: the `CSSelectTerm` specifying the attribute/aggregate value to query
     */
    @objc
    public convenience init(dateTerm: CSSelectTerm) {
        
        self.init(Select<NSManagedObject, Date>(dateTerm.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSData` values.
     ```
     NSData *imageData = [CSCoreStore
        queryValueFrom:CSFromClass([MyPersonEntity class])
        select:CSSelectData(CSAttribute(@"imageData"))
        // ...
     ```
     - parameter dataTerm: the `CSSelectTerm` specifying the attribute/aggregate value to query
     */
    @objc
    public convenience init(dataTerm: CSSelectTerm) {
        
        self.init(Select<NSManagedObject, Data>(dataTerm.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSManagedObjectID` values.
     ```
     NSManagedObjectID *objectID = [CSCoreStore
        queryValueFrom:CSFromClass([MyPersonEntity class])
        select:CSSelectObjectID()
        // ...
     ```
     */
    @objc
    public convenience init(objectIDTerm: ()) {
        
        self.init(Select<NSManagedObject, NSManagedObjectID>(.objectID()))
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
    @objc
    public static func dictionaryForTerm(_ term: CSSelectTerm) -> CSSelect {
        
        return self.init(Select<NSManagedObject, NSDictionary>(term.bridgeToSwift))
    }
    
    /**
     Creates a `CSSelect` clause for querying `NSDictionary` of an entity's attribute keys and values.
     ```
     NSDictionary *keyValues = [CSCoreStore
         queryValueFrom:[CSFrom entityClass:[MyPersonEntity class]]
         select:[CSSelect dictionaryForTerms:@[
             [CSSelectTerm attribute:@"name" as:nil],
             [CSSelectTerm attribute:@"age" as:nil]
         ]]];
     ```
     - parameter terms: the `CSSelectTerm`s specifying the attribute/aggregate values to query
     - returns: a `CSSelect` clause for querying an entity attribute
     */
    @objc
    public static func dictionaryForTerms(_ terms: [CSSelectTerm]) -> CSSelect {
        
        return self.init(Select<NSManagedObject, NSDictionary>(terms.map { $0.bridgeToSwift }))
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.attributeType.hashValue
            ^ self.selectTerms.map { $0.hashValue }.reduce(0, ^)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSSelect else {
            
            return false
        }
        return self.attributeType == object.attributeType
            && self.selectTerms == object.selectTerms
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public init<D: NSManagedObject, T: QueryableAttributeType>(_ swiftValue: Select<D, T>) {
        
        self.attributeType = T.cs_rawAttributeType
        self.selectTerms = swiftValue.selectTerms.map({ $0.downcast() })
        self.bridgeToSwift = swiftValue
        super.init()
    }
    
    public init<D: NSManagedObject, T>(_ swiftValue: Select<D, T>) {
        
        self.attributeType = .undefinedAttributeType
        self.selectTerms = swiftValue.selectTerms.map({ $0.downcast() })
        self.bridgeToSwift = swiftValue
        super.init()
    }
    
    
    // MARK: Internal
    
    internal let attributeType: NSAttributeType
    internal let selectTerms: [SelectTerm<NSManagedObject>]
    
    
    // MARK: Internal
    
    internal func applyToFetchRequest(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        
        fetchRequest.includesPendingChanges = false
        fetchRequest.resultType = .dictionaryResultType
        
        func attributeDescription(for keyPath: String, in entity: NSEntityDescription) -> NSAttributeDescription? {
            
            let components = keyPath.components(separatedBy: ".")
            switch components.count {
                
            case 0:
                return nil
                
            case 1:
                return entity.attributesByName[components[0]]
                
            default:
                guard let relationship = entity.relationshipsByName[components[0]],
                    let destinationEntity = relationship.destinationEntity else {
                        
                        return nil
                }
                return attributeDescription(
                    for: components.dropFirst().joined(separator: "."),
                    in: destinationEntity
                )
            }
        }
        
        var propertiesToFetch = [Any]()
        for term in self.selectTerms {
            
            switch term {
                
            case ._attribute(let keyPath):
                propertiesToFetch.append(keyPath)
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                let entityDescription = fetchRequest.entity!
                if let attributeDescription = attributeDescription(for: keyPath, in: entityDescription) {
                    
                    let expressionDescription = NSExpressionDescription()
                    expressionDescription.name = alias
                    if nativeType == .undefinedAttributeType {
                        
                        expressionDescription.expressionResultType = attributeDescription.attributeType
                    }
                    else {
                        
                        expressionDescription.expressionResultType = nativeType
                    }
                    expressionDescription.expression = NSExpression(
                        forFunction: function,
                        arguments: [NSExpression(forKeyPath: keyPath)]
                    )
                    propertiesToFetch.append(expressionDescription)
                }
                else {
                    
                    CoreStore.log(
                        .warning,
                        message: "The key path \"\(keyPath)\" could not be resolved in entity \(cs_typeName(entityDescription.managedObjectClassName)) as an attribute and will be ignored by \(cs_typeName(self)) query clause."
                    )
                }
                
            case ._identity(let alias, let nativeType):
                let expressionDescription = NSExpressionDescription()
                expressionDescription.name = alias
                if nativeType == .undefinedAttributeType {
                    
                    expressionDescription.expressionResultType = .objectIDAttributeType
                }
                else {
                    
                    expressionDescription.expressionResultType = nativeType
                }
                expressionDescription.expression = NSExpression.expressionForEvaluatedObject()
                
                propertiesToFetch.append(expressionDescription)
            }
        }
        
        fetchRequest.propertiesToFetch = propertiesToFetch
    }
    
    
    // MARK: Private
    
    private let bridgeToSwift: CoreStoreDebugStringConvertible
}


// MARK: - Select

extension Select where D: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSelect {
        
        return CSSelect(self)
    }
    
    
    // MARK: FilePrivate
    
    fileprivate func downcast() -> Select<NSManagedObject, T> {
        
        return Select<NSManagedObject, T>(self.selectTerms.map({ $0.downcast() }))
    }
}
