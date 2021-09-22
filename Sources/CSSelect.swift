//
//  CSSelect.swift
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

import Foundation
import CoreData


// MARK: - CSSelectTerm

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public final class CSSelectTerm: NSObject {

    @objc
    public convenience init(keyPath: KeyPathString) {

        fatalError()
    }

    @objc
    public static func average(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {

        fatalError()
    }

    @objc
    public static func count(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {

        fatalError()
    }

    @objc
    public static func maximum(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {

        fatalError()
    }

    @objc
    public static func minimum(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {

        fatalError()
    }

    @objc
    public static func sum(_ keyPath: KeyPathString, as alias: KeyPathString?) -> CSSelectTerm {

        fatalError()
    }

    @objc
    public static func objectIDAs(_ alias: KeyPathString? = nil) -> CSSelectTerm {

        fatalError()
    }

    
    // MARK: NSObject
    
    public override var hash: Int {

        fatalError()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {

        fatalError()
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: SelectTerm<NSManagedObject>
    
    public init<O: NSManagedObject>(_ swiftValue: SelectTerm<O>) {

        fatalError()
    }
}


// MARK: - SelectTerm

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
extension SelectTerm where O: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSelectTerm {

        fatalError()
    }
}


// MARK: - CSSelect

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public final class CSSelect: NSObject {

    @objc
    public convenience init(numberTerm: CSSelectTerm) {

        fatalError()
    }

    @objc
    public convenience init(decimalTerm: CSSelectTerm) {

        fatalError()
    }

    @objc
    public convenience init(stringTerm: CSSelectTerm) {

        fatalError()
    }

    @objc
    public convenience init(dateTerm: CSSelectTerm) {

        fatalError()
    }

    @objc
    public convenience init(dataTerm: CSSelectTerm) {

        fatalError()
    }

    @objc
    public convenience init(objectIDTerm: ()) {

        fatalError()
    }

    @objc
    public static func dictionaryForTerm(_ term: CSSelectTerm) -> CSSelect {

        fatalError()
    }

    @objc
    public static func dictionaryForTerms(_ terms: [CSSelectTerm]) -> CSSelect {

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
    
    
    // MARK: CoreStoreObjectiveCType
    
    public init<O: NSManagedObject, T: QueryableAttributeType>(_ swiftValue: Select<O, T>) {

        fatalError()
    }
    
    public init<O: NSManagedObject, T>(_ swiftValue: Select<O, T>) {

        fatalError()
    }
}


// MARK: - Select

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
extension Select where O: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSelect {

        fatalError()
    }
}
