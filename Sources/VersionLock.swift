//
//  VersionLock.swift
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

import Foundation


// MARK: - VersionLock

public struct VersionLock: ExpressibleByDictionaryLiteral, Equatable {
    
    public typealias HashElement = UInt64
    
    public let hashesByEntityName: [EntityName: Data]
    
    public init(_ intArrayByEntityName: [EntityName: [HashElement]]) {
        
        self.init(keyValues: intArrayByEntityName.map({ $0 }))
    }
    
    
    // MARK: ExpressibleByDictionaryLiteral
    
    public typealias Key = EntityName
    public typealias Value = [HashElement]
    
    public init(dictionaryLiteral elements: (EntityName, [HashElement])...) {
        
        self.init(keyValues: elements)
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: VersionLock, rhs: VersionLock) -> Bool {
        
        return lhs.hashesByEntityName == rhs.hashesByEntityName
    }
    
    
    // MARK: Internal
    
    internal init(entityVersionHashesByName: [String: Data]) {
        
        self.hashesByEntityName = entityVersionHashesByName
    }
    
    
    // MARK: Private
    
    private init(keyValues: [(EntityName, [HashElement])]) {
        
        var hashesByEntityName: [EntityName: Data] = [:]
        for (entityName, intArray) in keyValues {
            
            hashesByEntityName[entityName] = Data(
                buffer: UnsafeBufferPointer(
                    start: intArray,
                    count: intArray.count
                )
            )
        }
        self.hashesByEntityName = hashesByEntityName
    }
}



