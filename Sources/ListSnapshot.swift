//
//  ListSnapshot.swift
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

import CoreData

#if canImport(UIKit)
import UIKit

#elseif canImport(AppKit)
import AppKit

#endif


// MARK: - LiveList

public struct ListSnapshot<D: DynamicObject>: SnapshotResult, RandomAccessCollection, Hashable {

    // MARK: Public

    public typealias SectionID = String
    public typealias ItemID = D.ObjectID

    public subscript<S: Sequence>(indices indices: S) -> [ObjectType] where S.Element == Index {

        let context = self.context!
        let objectIDs = self.diffableSnapshot.itemIdentifiers
        return indices.map { position in

            let objectID = objectIDs[position]
            return context.fetchExisting(objectID)!
        }
    }

    public subscript(section sectionID: SectionID) -> [ObjectType] {

        let context = self.context!
        let objectIDs = self.itemIdentifiers(inSection: sectionID)
        return objectIDs.map {
            
            return context.fetchExisting($0)!
        }
    }

    public subscript<S: Sequence>(section sectionID: SectionID, itemIndices itemIndices: S) -> [ObjectType] where S.Element == Int {

        let context = self.context!
        let objectIDs = self.itemIdentifiers(inSection: sectionID)
        return itemIndices.map { position in

            let objectID = objectIDs[position]
            return context.fetchExisting(objectID)!
        }
    }

    public var numberOfItems: Int {

        return self.diffableSnapshot.numberOfItems
    }

    public var numberOfSections: Int {

        return self.diffableSnapshot.numberOfSections
    }

    public var sectionIdentifiers: [String] {

        return self.diffableSnapshot.sectionIdentifiers as [String]
    }

    public var itemIdentifiers: [ItemID] {

        return self.diffableSnapshot.itemIdentifiers as [ItemID]
    }

    public func numberOfItems(inSection identifier: SectionID) -> Int {

        return self.diffableSnapshot.numberOfItems(inSection: identifier as NSString)
    }

    public func itemIdentifiers(inSection identifier: SectionID) -> [ItemID] {

        return self.diffableSnapshot.itemIdentifiers(inSection: identifier as NSString)
    }

    public func itemIdentifiers(inSection identifier: SectionID, atIndices indices: IndexSet) -> [ItemID] {

        let itemIDs = self.itemIdentifiers(inSection: identifier)
        return indices.map({ itemIDs[$0] })
    }

    public func sectionIdentifier(containingItem identifier: ItemID) -> SectionID? {

        return self.diffableSnapshot.sectionIdentifier(containingItem: identifier) as SectionID?
    }

    public func indexOfItem(_ identifier: ItemID) -> Index? {

        return self.diffableSnapshot.indexOfItem(identifier)
    }

    public func indexOfSection(_ identifier: SectionID) -> Int? {

        return self.diffableSnapshot.indexOfSection(identifier as NSString)
    }

    public mutating func appendItems(_ identifiers: [ItemID], toSection sectionIdentifier: SectionID? = nil) {

        self.diffableSnapshot.appendItems(identifiers, toSection: sectionIdentifier as NSString?)
    }

    public mutating func insertItems(_ identifiers: [ItemID], beforeItem beforeIdentifier: ItemID) {

        self.diffableSnapshot.insertItems(identifiers, beforeItem: beforeIdentifier)
    }

    public mutating func insertItems(_ identifiers: [ItemID], afterItem afterIdentifier: ItemID) {

        self.diffableSnapshot.insertItems(identifiers, afterItem: afterIdentifier)
    }

    public mutating func deleteItems(_ identifiers: [ItemID]) {

        self.diffableSnapshot.deleteItems(identifiers)
    }

    public mutating func deleteAllItems() {

        self.diffableSnapshot.deleteAllItems()
    }

    public mutating func moveItem(_ identifier: ItemID, beforeItem toIdentifier: ItemID) {

        self.diffableSnapshot.moveItem(identifier, beforeItem: toIdentifier)
    }

    public mutating func moveItem(_ identifier: ItemID, afterItem toIdentifier: ItemID) {

        self.diffableSnapshot.moveItem(identifier, afterItem: toIdentifier)
    }

    public mutating func reloadItems(_ identifiers: [ItemID]) {

        self.diffableSnapshot.reloadItems(identifiers)
    }

    public mutating func appendSections(_ identifiers: [SectionID]) {

        self.diffableSnapshot.appendSections(identifiers as [NSString])
    }

    public mutating func insertSections(_ identifiers: [SectionID], beforeSection toIdentifier: SectionID) {

        self.diffableSnapshot.insertSections(identifiers as [NSString], beforeSection: toIdentifier as NSString)
    }

    public mutating func insertSections(_ identifiers: [SectionID], afterSection toIdentifier: SectionID) {

        self.diffableSnapshot.insertSections(identifiers as [NSString], afterSection: toIdentifier as NSString)
    }

    public mutating func deleteSections(_ identifiers: [SectionID]) {

        self.diffableSnapshot.deleteSections(identifiers as [NSString])
    }

    public mutating func moveSection(_ identifier: SectionID, beforeSection toIdentifier: SectionID) {

        self.diffableSnapshot.moveSection(identifier as NSString, beforeSection: toIdentifier as NSString)
    }

    public mutating func moveSection(_ identifier: SectionID, afterSection toIdentifier: SectionID) {

        self.diffableSnapshot.moveSection(identifier as NSString, afterSection: toIdentifier as NSString)
    }

    public mutating func reloadSections(_ identifiers: [SectionID]) {

        self.diffableSnapshot.reloadSections(identifiers as [NSString])
    }
    
    
    // MARK: SnapshotResult
    
    public typealias ObjectType = D
    
    
    // MARK: RandomAccessCollection
    
    public var startIndex: Index {
        
        return self.diffableSnapshot.itemIdentifiers.startIndex
    }
    
    public var endIndex: Index {
        
        return self.diffableSnapshot.itemIdentifiers.endIndex
    }
    
    public subscript(position: Index) -> ObjectType {
        
        let context = self.context!
        let objectID = self.diffableSnapshot.itemIdentifiers[position]
        return context.fetchExisting(objectID)!
    }
    
    
    // MARK: Sequence
    
    public typealias Element = ObjectType
    
    public typealias Index = Int
    
    
    // MARK: Equatable
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        
        return lhs.id == rhs.id
    }
    
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(self.id)
    }
    
    
    // MARK: Internal
    
    internal init() {

        self.diffableSnapshot = Internals.FallbackDiffableDataSourceSnapshot()
        self.context = nil
    }
    
    internal init(diffableSnapshot: Internals.DiffableDataSourceSnapshot, context: NSManagedObjectContext) {

        self.diffableSnapshot = diffableSnapshot
        self.context = context
    }
    
    
    // MARK: Private
    
    private let id: UUID = .init()
    private let context: NSManagedObjectContext?
    private var diffableSnapshot: Internals.DiffableDataSourceSnapshot
}
