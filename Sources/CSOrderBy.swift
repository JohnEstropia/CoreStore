//
//  CSOrderBy.swift
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


// MARK: - CSOrderBy

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public final class CSOrderBy: NSObject, CSFetchClause, CSQueryClause, CSDeleteClause {
    
    @objc
    public var sortDescriptors: [NSSortDescriptor] {

        fatalError()
    }

    @objc
    public convenience init(sortDescriptor: NSSortDescriptor) {

        fatalError()
    }

    @objc
    public convenience init(sortDescriptors: [NSSortDescriptor]) {

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
    
    
    // MARK: CSFetchClause, CSQueryClause, CSDeleteClause
    
    @objc
    public func applyToFetchRequest(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {

        fatalError()
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: OrderBy<NSManagedObject>
    
    public init<O: NSManagedObject>(_ swiftValue: OrderBy<O>) {

        fatalError()
    }
}


// MARK: - OrderBy

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
extension OrderBy where O: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSOrderBy {

        fatalError()
    }
}
