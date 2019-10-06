//
//  LiveQuery.swift
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

#if canImport(SwiftUI) && canImport(Combine)

import CoreData
import Combine
import SwiftUI


#warning("TODO: autoupdating doesn't work yet")
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
@propertyWrapper
public struct LiveQuery<Result: LiveResult>: DynamicProperty {
    
    // MARK: Public
    
    @Environment(\.dataStack)
    public var dataStack: DataStack
    
    public typealias ObjectType = Result.ObjectType
    
    
    // MARK: @propertyWrapper
    
    public fileprivate(set) var wrappedValue: Result {
        
        get {

            return self.nonMutatingWrappedValue.wrappedValue
        }
        set {
            
            self.nonMutatingWrappedValue = LazyNonmutating { newValue }
        }
    }
    
    public var projectedValue: Result {
        
        return self.wrappedValue
    }
    

    // MARK: DynamicProperty

    public mutating func update() {

        SwiftUI.withAnimation {

            let dataStack = self.dataStack
            if self.set(dataStack: dataStack) {
                
                return
            }
            self.wrappedValue = self.newWrappedValue(dataStack)
        }
    }
    
    
    // MARK: FilePrivate
    
    fileprivate let newWrappedValue: (DataStack) -> Result
    
    fileprivate init(newWrappedValue: @escaping (DataStack) -> Result) {
        
        self.newWrappedValue = newWrappedValue
    }
    
    
    // MARK: Private
    
    private var nonMutatingWrappedValue: LazyNonmutating<Result> = .init { fatalError() }
    
    private var currentDataStack: DataStack?
    
    private mutating func set(dataStack: DataStack) -> Bool {

        guard self.currentDataStack != dataStack else {
            
            return false
        }
        self.currentDataStack = dataStack
        
        let newWrappedValue = self.newWrappedValue
        self.nonMutatingWrappedValue = LazyNonmutating<Result> {
            
            newWrappedValue(dataStack)
        }
        return true
    }
    
    
    // MARK: - LazyNonmutating
    
    fileprivate final class LazyNonmutating<Value> {
        
        // MARK: FilePrivate
        
        lazy var wrappedValue: Value = self.initializer()

        init(_ initializer: @escaping () -> Value) {
            
            self.initializer = initializer
        }
        

        // MARK: Private
        
        private var initializer: () -> Value
    }
}


#if canImport(UIKit) || canImport(AppKit)

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
extension LiveQuery {

    public init<D: DynamicObject>(liveList: LiveList<D>) where Result == LiveList<D> {

        self.init(
            newWrappedValue: { _ in liveList }
        )
    }

    public init<D: DynamicObject>(_ clauseChain: FetchChainBuilder<D>) where Result == LiveList<D> {
        
        self.init(
            newWrappedValue: { $0.liveList(clauseChain) }
        )
    }

    public init<D: DynamicObject>(_ clauseChain: SectionMonitorChainBuilder<D>) where Result == LiveList<D> {
        
        self.init(
            newWrappedValue: { $0.liveList(clauseChain) }
        )
    }
}

#endif

#endif
