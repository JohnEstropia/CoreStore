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

/**
 A `ListSnapshot` holds a stable list of `DynamicObject` identifiers. This is typically created by a `ListPublisher` and are designed to work well with `DiffableDataSource.TableView`s and `DiffableDataSource.CollectionView`s. For detailed examples, see the documentation on `DiffableDataSource.TableView` and `DiffableDataSource.CollectionView`.

 While the `ListSnapshot` stores only object identifiers, all accessors to its items return `ObjectPublisher`s, which are lazily created. For more details, see the documentation on `ListObject`.

 Since `ListSnapshot` is a value type, you can freely modify its items.
 */
public struct ListSnapshot<O: DynamicObject>: RandomAccessCollection, Hashable {

    // MARK: Public (Accessors)

    /**
     The `DynamicObject` type associated with this list
     */
    public typealias ObjectType = O

    /**
     The type for the section IDs
     */
    public typealias SectionID = String

    /**
     The type for the item IDs
     */
    public typealias ItemID = O.ObjectID

    /**
     Returns the object at the given index.

     - parameter index: the index of the object. Using an index above the valid range will raise an exception.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified index
     */
    public subscript(index: Index) -> ObjectPublisher<O> {

        let context = self.context!
        let itemID = self.diffableSnapshot.itemIdentifiers[index]
        return context.objectPublisher(objectID: itemID)
    }

    /**
     Returns the object at the given index, or `nil` if out of bounds.

     - parameter index: the index for the object. Using an index above the valid range will return `nil`.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified index, or `nil` if out of bounds
     */
    public subscript(safeIndex index: Index) -> ObjectPublisher<O>? {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers
        guard itemIDs.indices.contains(index) else {

            return nil
        }
        let itemID = itemIDs[index]
        return context.objectPublisher(objectID: itemID)
    }

    /**
     Returns the object at the given `sectionIndex` and `itemIndex`.

     - parameter sectionIndex: the section index for the object. Using a `sectionIndex` with an invalid range will raise an exception.
     - parameter itemIndex: the index for the object within the section. Using an `itemIndex` with an invalid range will raise an exception.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified section and item index
     */
    public subscript(sectionIndex: Int, itemIndex: Int) -> ObjectPublisher<O> {

        let context = self.context!
        let snapshot = self.diffableSnapshot
        let sectionID = snapshot.sectionIdentifiers[sectionIndex]
        let itemID = snapshot.itemIdentifiers(inSection: sectionID)[itemIndex]
        return context.objectPublisher(objectID: itemID)
    }

    /**
     Returns the object at the given section and item index, or `nil` if out of bounds.

     - parameter sectionIndex: the section index for the object. Using a `sectionIndex` with an invalid range will return `nil`.
     - parameter itemIndex: the index for the object within the section. Using an `itemIndex` with an invalid range will return `nil`.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified section and item index, or `nil` if out of bounds
     */
    public subscript(safeSectionIndex sectionIndex: Int, safeItemIndex itemIndex: Int) -> ObjectPublisher<O>? {

        let context = self.context!
        let snapshot = self.diffableSnapshot
        let sectionIDs = snapshot.sectionIdentifiers
        guard sectionIDs.indices.contains(sectionIndex) else {

            return nil
        }
        let sectionID = sectionIDs[sectionIndex]
        let itemIDs = snapshot.itemIdentifiers(inSection: sectionID)
        guard itemIDs.indices.contains(itemIndex) else {

            return nil
        }
        let itemID = itemIDs[itemIndex]
        return context.objectPublisher(objectID: itemID)
    }

    /**
     Returns the object at the given `IndexPath`.

     - parameter indexPath: the `IndexPath` for the object. Using an `indexPath` with an invalid range will raise an exception.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified index path
     */
    public subscript(indexPath: IndexPath) -> ObjectPublisher<O> {

        return self[indexPath[0], indexPath[1]]
    }

    /**
     Returns the object at the given `IndexPath`, or `nil` if out of bounds.

     - parameter indexPath: the `IndexPath` for the object. Using an `indexPath` with an invalid range will return `nil`.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified index path, or `nil` if out of bounds
     */
    public subscript(safeIndexPath indexPath: IndexPath) -> ObjectPublisher<O>? {

        return self[
            safeSectionIndex: indexPath[0],
            safeItemIndex: indexPath[1]
        ]
    }

    /**
     Checks if the `ListSnapshot` has at least one section

     - returns: `true` if at least one section exists, `false` otherwise
     */
    public func hasSections() -> Bool {

        return self.diffableSnapshot.numberOfSections > 0
    }

    /**
     Checks if the `ListSnapshot` has at least one object in any section.

     - returns: `true` if at least one object in any section exists, `false` otherwise
     */
    public func hasObjects() -> Bool {

        return self.diffableSnapshot.numberOfItems > 0
    }

    /**
     Checks if the `ListSnapshot` has at least one object the specified section.

     - parameter section: the section index. Using an index outside the valid range will return `false`.
     - returns: `true` if at least one object in the specified section exists, `false` otherwise
     */
    public func hasObjects(in sectionIndex: Int) -> Bool {

        let snapshot = self.diffableSnapshot
        let sectionIDs = snapshot.sectionIdentifiers
        guard sectionIDs.indices.contains(sectionIndex) else {

            return false
        }
        let sectionID = sectionIDs[sectionIndex]
        return snapshot.numberOfItems(inSection: sectionID) > 0
    }







    public var numberOfItems: Int {

        return self.diffableSnapshot.numberOfItems
    }

    public var numberOfSections: Int {

        return self.diffableSnapshot.numberOfSections
    }

    public var sectionIdentifiers: [SectionID] {

        return self.diffableSnapshot.sectionIdentifiers
    }

    public var itemIdentifiers: [ItemID] {

        return self.diffableSnapshot.itemIdentifiers
    }

    public func numberOfItems(inSection identifier: SectionID) -> Int {

        return self.diffableSnapshot.numberOfItems(inSection: identifier)
    }

    public func itemIdentifiers(inSection identifier: SectionID) -> [ItemID] {

        return self.diffableSnapshot.itemIdentifiers(inSection: identifier)
    }

    public func itemIdentifiers(inSection identifier: SectionID, atIndices indices: IndexSet) -> [ItemID] {

        let itemIDs = self.diffableSnapshot.itemIdentifiers(inSection: identifier)
        return indices.map({ itemIDs[$0] })
    }

    public func sectionIdentifier(containingItem identifier: ItemID) -> SectionID? {

        return self.diffableSnapshot.sectionIdentifier(containingItem: identifier)
    }

    public func indexOfItem(_ identifier: ItemID) -> Index? {

        return self.diffableSnapshot.indexOfItem(identifier)
    }

    public func indexOfSection(_ identifier: SectionID) -> Int? {

        return self.diffableSnapshot.indexOfSection(identifier)
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

        self.diffableSnapshot.reloadItems(identifiers)
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

        self.diffableSnapshot.reloadSections(identifiers)
    }

    public func items<S: Sequence>(atIndices indices: S) -> [ObjectPublisher<O>] where S.Element == Index {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers
        return indices.map { position in

            let itemID = itemIDs[position]
            return ObjectPublisher<O>(objectID: itemID, context: context)
        }
    }

    public subscript(section sectionID: SectionID) -> [ObjectPublisher<O>] {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers(inSection: sectionID)
        return itemIDs.map {

            return ObjectPublisher<O>(objectID: $0, context: context)
        }
    }

    public subscript<S: Sequence>(section sectionID: SectionID, itemIndices itemIndices: S) -> [ObjectPublisher<O>] where S.Element == Int {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers(inSection: sectionID)
        return itemIndices.map { position in

            let itemID = itemIDs[position]
            return ObjectPublisher<O>(objectID: itemID, context: context)
        }
    }

    
    
    // MARK: RandomAccessCollection
    
    public var startIndex: Index {
        
        return self.diffableSnapshot.itemIdentifiers.startIndex
    }
    
    public var endIndex: Index {
        
        return self.diffableSnapshot.itemIdentifiers.endIndex
    }
    
    
    // MARK: Sequence
    
    public typealias Element = ObjectPublisher<O>
    
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
    
    internal private(set) var diffableSnapshot: DiffableDataSourceSnapshotProtocol
    
    internal init() {

//        if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) {
//
//            self.diffableSnapshot = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>()
//        }
//        else {
            
            self.diffableSnapshot = Internals.DiffableDataSourceSnapshot()
//        }
        self.context = nil
    }
    
//    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
//    internal init(diffableSnapshot: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>, context: NSManagedObjectContext) {
//
//        self.diffableSnapshot = diffableSnapshot
//        self.context = context
//    }
    
    internal init(diffableSnapshot: Internals.DiffableDataSourceSnapshot, context: NSManagedObjectContext) {

        self.diffableSnapshot = diffableSnapshot
        self.context = context
    }
    
    
    // MARK: Private
    
    private let id: UUID = .init()
    private let context: NSManagedObjectContext?

}
