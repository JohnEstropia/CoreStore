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


// MARK: - ListSnapshot

public struct ListSnapshot<O: DynamicObject>: SnapshotResult, RandomAccessCollection, Hashable {

    // MARK: Public

    public typealias SectionID = String
    public typealias ItemID = O.ObjectID

    public subscript<S: Sequence>(indices indices: S) -> [LiveObject<O>] where S.Element == Index {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.allItemIDs
        return indices.map { position in

            let itemID = itemIDs[position]
            return LiveObject<O>(id: itemID, context: context)
        }
    }

    public subscript(section sectionID: SectionID) -> [LiveObject<O>] {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIDs(inSection: sectionID)
        return itemIDs.map {

            return LiveObject<O>(id: $0, context: context)
        }
    }

    public subscript<S: Sequence>(section sectionID: SectionID, itemIndices itemIndices: S) -> [LiveObject<O>] where S.Element == Int {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIDs(inSection: sectionID)
        return itemIndices.map { position in

            let itemID = itemIDs[position]
            return LiveObject<O>(id: itemID, context: context)
        }
    }

    public var numberOfItems: Int {

        return self.diffableSnapshot.numberOfItems
    }

    public var numberOfSections: Int {

        return self.diffableSnapshot.numberOfSections
    }

    public var sectionIDs: [SectionID] {

        return self.diffableSnapshot.allSectionIDs
    }

    public var itemIdentifiers: [ItemID] {

        return self.diffableSnapshot.allItemIDs
    }

    public func numberOfItems(inSection identifier: SectionID) -> Int {

        return self.diffableSnapshot.numberOfItems(inSection: identifier)
    }

    public func itemIdentifiers(inSection identifier: SectionID) -> [ItemID] {

        return self.diffableSnapshot.itemIDs(inSection: identifier)
    }

    public func itemIdentifiers(inSection identifier: SectionID, atIndices indices: IndexSet) -> [ItemID] {

        let itemIDs = self.diffableSnapshot.itemIDs(inSection: identifier)
        return indices.map({ itemIDs[$0] })
    }

    public func sectionIdentifier(containingItem identifier: ItemID) -> SectionID? {

        return self.diffableSnapshot.sectionIDs(containingItem: identifier)
    }

    public func indexOfItem(_ identifier: ItemID) -> Index? {

        return self.diffableSnapshot.indexOfItemID(identifier)
    }

    public func indexOfSection(_ identifier: SectionID) -> Int? {

        return self.diffableSnapshot.indexOfSectionID(identifier)
    }

    public mutating func appendItems(_ identifiers: [ItemID], toSection sectionIdentifier: SectionID? = nil) {

        self.diffableSnapshot.appendItems(identifiers, toSection: sectionIdentifier)
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

        self.diffableSnapshot.reloadItems(identifiers, nextStateTag: .init())
    }

    public mutating func appendSections(_ identifiers: [SectionID]) {

        self.diffableSnapshot.appendSections(identifiers)
    }

    public mutating func insertSections(_ identifiers: [SectionID], beforeSection toIdentifier: SectionID) {

        self.diffableSnapshot.insertSections(identifiers, beforeSection: toIdentifier)
    }

    public mutating func insertSections(_ identifiers: [SectionID], afterSection toIdentifier: SectionID) {

        self.diffableSnapshot.insertSections(identifiers, afterSection: toIdentifier)
    }

    public mutating func deleteSections(_ identifiers: [SectionID]) {

        self.diffableSnapshot.deleteSections(identifiers)
    }

    public mutating func moveSection(_ identifier: SectionID, beforeSection toIdentifier: SectionID) {

        self.diffableSnapshot.moveSection(identifier, beforeSection: toIdentifier)
    }

    public mutating func moveSection(_ identifier: SectionID, afterSection toIdentifier: SectionID) {

        self.diffableSnapshot.moveSection(identifier, afterSection: toIdentifier)
    }

    public mutating func reloadSections(_ identifiers: [SectionID]) {

        self.diffableSnapshot.reloadSections(identifiers, nextStateTag: .init())
    }
    
    
    // MARK: SnapshotResult
    
    public typealias ObjectType = O
    
    
    // MARK: RandomAccessCollection
    
    public var startIndex: Index {
        
        return self.diffableSnapshot.allItemIDs.startIndex
    }
    
    public var endIndex: Index {
        
        return self.diffableSnapshot.allItemIDs.endIndex
    }
    
    public subscript(position: Index) -> Element {
        
        let context = self.context!
        let itemID = self.diffableSnapshot.allItemIDs[position]
        return LiveObject<O>(id: itemID, context: context)
    }
    
    
    // MARK: Sequence
    
    public typealias Element = LiveObject<O>
    
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

        self.diffableSnapshot = .init()
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
