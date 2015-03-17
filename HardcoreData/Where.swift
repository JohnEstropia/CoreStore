//
//  Where.swift
//  HardcoreData
//
//  Copyright (c) 2015 John Rommel Estropia
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


public func &&(left: Where, right: Where) -> Where {
    
    return Where(NSCompoundPredicate(type: .AndPredicateType, subpredicates: [left.predicate, right.predicate]))
}

public func ||(left: Where, right: Where) -> Where {
    
    return Where(NSCompoundPredicate(type: .OrPredicateType, subpredicates: [left.predicate, right.predicate]))
}

public prefix func !(clause: Where) -> Where {
    
    return Where(NSCompoundPredicate(type: .NotPredicateType, subpredicates: [clause.predicate]))
}


// MARK: - Where

public struct Where: FetchClause {
    
    // MARK: Public
    
    public init(_ predicate: NSPredicate) {
        
        self.predicate = predicate
    }
    
    public init() {
        
        self.init(true)
    }
    
    public init(_ value: Bool) {
        
        self.init(NSPredicate(value: value))
    }
    
    public init(_ format: String, _ args: NSObject...) {
        
        self.init(NSPredicate(format: format, argumentArray: args))
    }
    
    public init(_ format: String, argumentArray: [NSObject]?) {
        
        self.init(NSPredicate(format: format, argumentArray: argumentArray))
    }
    
    public init(_ keyPath: KeyPath, isEqualTo value: NSObject?) {
        
        self.init(value == nil
            ? NSPredicate(format: "\(keyPath) == nil")
            : NSPredicate(format: "\(keyPath) == %@", value!))
    }
    
    public let predicate: NSPredicate
    
    
    // MARK: QueryClause
    
    public func applyToFetchRequest(fetchRequest: NSFetchRequest) {
        
        if fetchRequest.predicate != nil {
            
            HardcoreData.log(.Warning, message: "An existing predicate for the <\(NSFetchRequest.self)> was overwritten by <\(self.dynamicType)> query clause.")
        }
        
        fetchRequest.predicate = self.predicate
    }
}
