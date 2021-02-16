//
//  LiveList.swift
//  CoreStore
//
//  Copyright © 2021 John Rommel Estropia
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

#if canImport(Combine) && canImport(SwiftUI)

import Combine
import SwiftUI


// MARK: - LiveList

@propertyWrapper
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public struct LiveList<Object: DynamicObject>: DynamicProperty {
    
    // MARK: Public
    
    public typealias Items = ListSnapshot<Object>
    
    public init(
        _ listPublisher: ListPublisher<Object>
    ) {
        
        self.observer = .init(listPublisher: listPublisher)
    }
    
    public init(
        _ from: From<Object>,
        _ fetchClauses: FetchClause...,
        in dataStack: DataStack
    ) {
        
        self.init(from, fetchClauses, in: dataStack)
    }
    
    public init(
        _ from: From<Object>,
        _ fetchClauses: [FetchClause],
        in dataStack: DataStack
    ) {
        
        self.init(dataStack.publishList(from, fetchClauses))
    }
    
    public init<B: FetchChainableBuilderType>(
        _ clauseChain: B,
        in dataStack: DataStack
    ) where B.ObjectType == Object {
        
        self.init(dataStack.publishList(clauseChain))
    }
    
    public init(
        _ from: From<Object>,
        _ sectionBy: SectionBy<Object>,
        _ fetchClauses: FetchClause...,
        in dataStack: DataStack
    ) {
        
        self.init(from, sectionBy, fetchClauses, in: dataStack)
    }
    
    public init(
        _ from: From<Object>,
        _ sectionBy: SectionBy<Object>,
        _ fetchClauses: [FetchClause],
        in dataStack: DataStack
    ) {
        
        self.init(dataStack.publishList(from, sectionBy, fetchClauses))
    }
    
    public init<B: SectionMonitorBuilderType>(
        _ clauseChain: B,
        in dataStack: DataStack
    ) where B.ObjectType == Object {
        
        self.init(dataStack.publishList(clauseChain))
    }
    
    
    // MARK: @propertyWrapper
    
    public var wrappedValue: Items {
        
        return self.observer.items
    }
    
    public var projectedValue: ListPublisher<Object> {
        
        return self.observer.listPublisher
    }
    
    
    // MARK: DynamicProperty
    
    public mutating func update() {
        
        self._observer.update()
    }
    
    
    // MARK: Private
    
    @ObservedObject
    private var observer: Observer
    
    
    // MARK: - Observer
    
    private final class Observer: ObservableObject {
        
        @Published
        var items: Items
        
        let listPublisher: ListPublisher<Object>
        
        init(listPublisher: ListPublisher<Object>) {
            
            self.listPublisher = listPublisher
            self.items = listPublisher.snapshot
            
            listPublisher.addObserver(self) { [weak self] (listPublisher) in
                
                guard let self = self else {
                    
                    return
                }
                self.items = listPublisher.snapshot
            }
        }
        
        deinit {
            
            self.listPublisher.removeObserver(self)
        }
    }
}

#endif
