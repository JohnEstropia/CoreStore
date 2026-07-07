//
//  ListState.swift
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

#if canImport(Observation) && canImport(SwiftUI)

import Observation
import SwiftUI


// MARK: - ListState

/**
 A property wrapper type that can read `ListPublisher` changes.
 */
@propertyWrapper
public struct ListState<Object: DynamicObject>: DynamicProperty {
    
    // MARK: Public
    
    /**
     Creates an instance that observes `ListPublisher` changes and exposes a `ListSnapshot` value.
     ```
     @ListState
     var people: ListSnapshot<Person>
     
     init(listPublisher: ListPublisher<Person>) {
     
        self._people = .init(listPublisher)
     }
     
     var body: some View {
     
        List {
     
            ForEach(objectIn: self.people) { person in

                ProfileView(person)
            }
        }
        .animation(.default)
     }
     ```
     
     - parameter listPublisher: The `ListPublisher` that the `ListState` will observe changes for
     */
    @MainActor
    public init(
        _ listPublisher: ListPublisher<Object>
    ) {
        
        self._observer = .init(wrappedValue: .init(listPublisher: listPublisher))
    }
    
    /**
     Creates an instance that observes the specified `FetchChainableBuilderType` and exposes a `ListSnapshot` value.
     ```
     @ListState(
         From<Person>()
             .where(\.isMember == true)
             .orderBy(.ascending(\.lastName)),
         in: Globals.dataStack
     )
     var people: ListSnapshot<Person>
     
     var body: some View {
     
        List {
     
            ForEach(objectIn: self.people) { person in

                ProfileView(person)
            }
        }
        .animation(.default)
     }
     ```
     
     - parameter clauseChain: a `FetchChainableBuilderType` built from a chain of clauses
     */
    @MainActor
    public init<B: FetchChainableBuilderType>(
        _ clauseChain: B,
        in dataStack: DataStack
    ) where B.ObjectType == Object {
        
        self.init(dataStack.publishList(clauseChain))
    }
    
    /**
     Creates an instance that observes the specified `SectionMonitorBuilderType` and exposes a `ListSnapshot` value.
     ```
     @ListState(
         From<Person>()
             .sectionBy(\.age)
             .where(\.isMember == true)
             .orderBy(.ascending(\.lastName)),
         in: Globals.dataStack
     )
     var people: ListSnapshot<Person>
     
     var body: some View {
     
         List {
             
             ForEach(sectionIn: self.people) { section in
                 
                 Section(header: Text(section.sectionID)) {

                     ForEach(objectIn: section) { person in

                         ProfileView(person)
                     }
                 }
             }
         }
         .animation(.default)
     }
     ```
     
     - parameter clauseChain: a `SectionMonitorBuilderType` built from a chain of clauses
     */
    @MainActor
    public init<B: SectionMonitorBuilderType>(
        _ clauseChain: B,
        in dataStack: DataStack
    ) where B.ObjectType == Object {
        
        self.init(dataStack.publishList(clauseChain))
    }
    
    /**
     Creates an instance that observes the specified `From` and `FetchClause`s and exposes a `ListSnapshot` value.
     ```
     @ListState(
         From<Person>(),
         Where<Person>(\.isMember == true),
         OrderBy<Person>(.ascending(\.lastName)),
         in: Globals.dataStack
     )
     var people: ListSnapshot<Person>
     
     var body: some View {
     
        List {
     
            ForEach(objectIn: self.people) { person in

                ProfileView(person)
            }
        }
        .animation(.default)
     }
     ```
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     */
    @MainActor
    public init(
        _ from: From<Object>,
        _ fetchClauses: FetchClause...,
        in dataStack: DataStack
    ) {
        
        self.init(from, fetchClauses, in: dataStack)
    }
    
    /**
     Creates an instance that observes the specified `From` and `FetchClause`s and exposes a `ListSnapshot` value.
     ```
     @ListState(
         From<Person>(),
         [
             Where<Person>(\.isMember == true),
             OrderBy<Person>(.ascending(\.lastName))
         ],
         in: Globals.dataStack
     )
     var people: ListSnapshot<Person>
     
     var body: some View {
     
        List {
     
            ForEach(objectIn: self.people) { person in

                ProfileView(person)
            }
        }
        .animation(.default)
     }
     ```
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     */
    @MainActor
    public init(
        _ from: From<Object>,
        _ fetchClauses: [FetchClause],
        in dataStack: DataStack
    ) {
        
        self.init(dataStack.publishList(from, fetchClauses))
    }
    
    /**
     Creates an instance that observes the specified `From`, `SectionBy`, and `FetchClause`s and exposes a sectioned `ListSnapshot` value.
     ```
     @ListState(
         From<Person>(),
         SectionBy(\.age),
         Where<Person>(\.isMember == true),
         OrderBy<Person>(.ascending(\.lastName)),
         in: Globals.dataStack
     )
     var people: ListSnapshot<Person>
     
     var body: some View {
     
        List {
     
            ForEach(sectionIn: self.people) { section in
                 
                Section(header: Text(section.sectionID)) {

                    ForEach(objectIn: section) { person in

                        ProfileView(person)
                    }
                }
            }
        }
        .animation(.default)
     }
     ```
     
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     */
    @MainActor
    public init(
        _ from: From<Object>,
        _ sectionBy: SectionBy<Object>,
        _ fetchClauses: FetchClause...,
        in dataStack: DataStack
    ) {
        
        self.init(from, sectionBy, fetchClauses, in: dataStack)
    }
    
    /**
     Creates an instance that observes the specified `From`, `SectionBy`, and `FetchClause`s and exposes a sectioned `ListSnapshot` value.
     ```
     @ListState(
         From<Person>(),
         SectionBy(\.age),
         [
             Where<Person>(\.isMember == true),
             OrderBy<Person>(.ascending(\.lastName))
         ],
         in: Globals.dataStack
     )
     var people: ListSnapshot<Person>
     
     var body: some View {
     
        List {
     
            ForEach(sectionIn: self.people) { section in
                 
                Section(header: Text(section.sectionID)) {

                    ForEach(objectIn: section) { person in

                        ProfileView(person)
                    }
                }
            }
        }
        .animation(.default)
     }
     ```
     
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     */
    @MainActor
    public init(
        _ from: From<Object>,
        _ sectionBy: SectionBy<Object>,
        _ fetchClauses: [FetchClause],
        in dataStack: DataStack
    ) {
        
        self.init(dataStack.publishList(from, sectionBy, fetchClauses))
    }
    
    
    // MARK: @propertyWrapper
    
    @MainActor
    public var wrappedValue: ListSnapshot<Object> {
        
        return self.observer.items
    }
    
    @MainActor
    public var projectedValue: ListPublisher<Object> {
        
        return self.observer.listPublisher
    }
    
    
    // MARK: DynamicProperty
    
    public mutating func update() {
        
        self._observer.update()
    }
    
    
    // MARK: Private
    
    @State
    private var observer: Observer
    
    
    // MARK: - Observer
    
    @MainActor
    private final class Observer: Observation.Observable {
        
        private let registrar = ObservationRegistrar()
        private var _items: ListSnapshot<Object>
        
        let listPublisher: ListPublisher<Object>
        
        var items: ListSnapshot<Object> {
            
            get {
                
                self.registrar.access(self, keyPath: \.items)
                return self._items
            }
            set {
                
                self.registrar.withMutation(of: self, keyPath: \.items) {
                    
                    self._items = newValue
                }
            }
        }
        
        init(listPublisher: ListPublisher<Object>) {
            
            self.listPublisher = listPublisher
            self._items = listPublisher.snapshot
            
            listPublisher.addObserver(self) { [weak self] (listPublisher) in
                
                guard let self = self else {
                    
                    return
                }
                self.items = listPublisher.snapshot
            }
        }
        
        isolated deinit {
            
            self.listPublisher.removeObserver(self)
        }
    }
}

#endif
