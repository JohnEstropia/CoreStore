//
//  Internals.DiffableDataSourceSnapshot.swift
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

#if canImport(UIKit) || canImport(AppKit)

import CoreData

#if canImport(UIKit)
import UIKit

#elseif canImport(AppKit)
import AppKit

#endif


// MARK: - Internals

extension Internals {

    // MARK: Internal

    internal typealias DiffableDataSourceSnapshot = _Internal_DiffableDataSourceSnapshot


    // MARK: - FallbackDiffableDataSourceSnapshot

    // Implementation based on https://github.com/ra1028/DiffableDataSources
    internal struct FallbackDiffableDataSourceSnapshot: DiffableDataSourceSnapshot {

        // MARK: Internal

        init(sections: [NSFetchedResultsSectionInfo]) {

            self.structure = .init(sections: sections)
        }

        // MARK: DiffableDataSourceSnapshot

        init() {

            self.structure = .init()
        }

        var numberOfItems: Int {

            return self.itemIdentifiers.count
        }

        var numberOfSections: Int {

            return self.sectionIdentifiers.count
        }

        var sectionIdentifiers: [NSString] {

            return self.structure.allSectionIDs
        }

        var itemIdentifiers: [NSManagedObjectID] {

            self.structure.allItemIDs
        }

        func numberOfItems(inSection identifier: NSString) -> Int {

            return self.itemIdentifiers(inSection: identifier).count
        }

        func itemIdentifiers(inSection identifier: NSString) -> [NSManagedObjectID] {

            return self.structure.items(in: identifier)
        }

        func sectionIdentifier(containingItem identifier: NSManagedObjectID) -> NSString? {

            return self.structure.section(containing: identifier)
        }

        func indexOfItem(_ identifier: NSManagedObjectID) -> Int? {

            return self.itemIdentifiers.firstIndex(of: identifier)
        }

        func indexOfSection(_ identifier: NSString) -> Int? {

            return self.sectionIdentifiers.firstIndex(of: identifier)
        }

        mutating func appendItems(_ identifiers: [NSManagedObjectID], toSection sectionIdentifier: NSString?) {

            self.structure.append(itemIDs: identifiers, to: sectionIdentifier)
        }

        mutating func insertItems(_ identifiers: [NSManagedObjectID], beforeItem beforeIdentifier: NSManagedObjectID) {

            self.structure.insert(itemIDs: identifiers, before: beforeIdentifier)
        }

        mutating func insertItems(_ identifiers: [NSManagedObjectID], afterItem afterIdentifier: NSManagedObjectID) {

            self.structure.insert(itemIDs: identifiers, after: afterIdentifier)
        }

        mutating func deleteItems(_ identifiers: [NSManagedObjectID]) {

            self.structure.remove(itemIDs: identifiers)
        }

        mutating func deleteAllItems() {

            self.structure.removeAllItems()
        }

        mutating func moveItem(_ identifier: NSManagedObjectID, beforeItem toIdentifier: NSManagedObjectID) {

            self.structure.move(itemID: identifier, before: toIdentifier)
        }

        mutating func moveItem(_ identifier: NSManagedObjectID, afterItem toIdentifier: NSManagedObjectID) {

            self.structure.move(itemID: identifier, after: toIdentifier)
        }

        mutating func reloadItems(_ identifiers: [NSManagedObjectID]) {

            self.structure.update(itemIDs: identifiers)
        }

        mutating func appendSections(_ identifiers: [NSString]) {

            self.structure.append(sectionIDs: identifiers)
        }

        mutating func insertSections(_ identifiers: [NSString], beforeSection toIdentifier: NSString) {

            self.structure.insert(sectionIDs: identifiers, before: toIdentifier)
        }

        mutating func insertSections(_ identifiers: [NSString], afterSection toIdentifier: NSString) {

            self.structure.insert(sectionIDs: identifiers, after: toIdentifier)
        }

        mutating func deleteSections(_ identifiers: [NSString]) {

            self.structure.remove(sectionIDs: identifiers)
        }

        mutating func moveSection(_ identifier: NSString, beforeSection toIdentifier: NSString) {

            self.structure.move(sectionID: identifier, before: toIdentifier)
        }

        mutating func moveSection(_ identifier: NSString, afterSection toIdentifier: NSString) {

            self.structure.move(sectionID: identifier, after: toIdentifier)
        }

        mutating func reloadSections(_ identifiers: [NSString]) {

            self.structure.update(sectionIDs: identifiers)
        }


        // MARK: Private

        private var structure: BackingStructure


        // MARK: - BackingStructure

        internal struct BackingStructure {

            // MARK: Internal

            var sections: [Section]

            init() {

                self.sections = []
            }

            init(sections: [NSFetchedResultsSectionInfo]) {

                self.sections = sections.map {

                    Section(
                        id: $0.name as NSString,
                        items: $0.objects?
                            .compactMap({ ($0 as? NSManagedObject)?.objectID })
                            .map(Item.init(id:)) ?? [],
                        isReloaded: false
                    )
                }
            }

            var allSectionIDs: [NSString] {

                return self.sections.map({ $0.id })
            }

            var allItemIDs: [NSManagedObjectID] {

                return self.sections.lazy.flatMap({ $0.elements }).map({ $0.id })
            }

            func items(in sectionID: NSString) -> [NSManagedObjectID] {

                guard let sectionIndex = self.sectionIndex(of: sectionID) else {

                    Internals.abort("Section \"\(sectionID)\" does not exist")
                }
                return self.sections[sectionIndex].elements.map({ $0.id })
            }

            func section(containing itemID: NSManagedObjectID) -> NSString? {

                return self.itemPositionMap()[itemID]?.section.id
            }

            mutating func append(itemIDs: [NSManagedObjectID], to sectionID: NSString?) {

                let index: Array<Section>.Index
                if let sectionID = sectionID {

                    guard let sectionIndex = self.sectionIndex(of: sectionID) else {

                        Internals.abort("Section \"\(sectionID)\" does not exist")
                    }
                    index = sectionIndex
                }
                else {

                    let section = self.sections
                    guard !section.isEmpty else {

                        Internals.abort("No sections exist")
                    }
                    index = section.index(before: section.endIndex)
                }

                let items = itemIDs.lazy.map(Item.init)
                self.sections[index].elements.append(contentsOf: items)
            }

            mutating func insert(itemIDs: [NSManagedObjectID], before beforeItemID: NSManagedObjectID) {

                guard let itemPosition = self.itemPositionMap()[beforeItemID] else {

                    Internals.abort("Item \(beforeItemID) does not exist")
                }
                let items = itemIDs.lazy.map(Item.init)
                self.sections[itemPosition.sectionIndex].elements
                    .insert(contentsOf: items, at: itemPosition.itemRelativeIndex)
            }

            mutating func insert(itemIDs: [NSManagedObjectID], after afterItemID: NSManagedObjectID) {

                guard let itemPosition = self.itemPositionMap()[afterItemID] else {

                    Internals.abort("Item \(afterItemID) does not exist")
                }
                let itemIndex = self.sections[itemPosition.sectionIndex].elements
                    .index(after: itemPosition.itemRelativeIndex)
                let items = itemIDs.lazy.map(Item.init)
                self.sections[itemPosition.sectionIndex].elements
                    .insert(contentsOf: items, at: itemIndex)
            }

            mutating func remove(itemIDs: [NSManagedObjectID]) {

                let itemPositionMap = self.itemPositionMap()
                var removeIndexSetMap: [Int: IndexSet] = [:]

                for itemID in itemIDs {

                    guard let itemPosition = itemPositionMap[itemID] else {

                        continue
                    }
                    removeIndexSetMap[itemPosition.sectionIndex, default: []]
                        .insert(itemPosition.itemRelativeIndex)
                }
                for (sectionIndex, removeIndexSet) in removeIndexSetMap {

                    for range in removeIndexSet.rangeView.reversed() {

                        self.sections[sectionIndex].elements.removeSubrange(range)
                    }
                }
            }

            mutating func removeAllItems() {

                for sectionIndex in self.sections.indices {

                    self.sections[sectionIndex].elements.removeAll()
                }
            }

            mutating func move(itemID: NSManagedObjectID, before beforeItemID: NSManagedObjectID) {

                guard let removed = self.remove(itemID: itemID) else {

                    Internals.abort("Item \(itemID) does not exist")
                }
                guard let itemPosition = self.itemPositionMap()[beforeItemID] else {

                    Internals.abort("Item \(beforeItemID) does not exist")
                }
                self.sections[itemPosition.sectionIndex].elements
                    .insert(removed, at: itemPosition.itemRelativeIndex)
            }

            mutating func move(itemID: NSManagedObjectID, after afterItemID: NSManagedObjectID) {

                guard let removed = self.remove(itemID: itemID) else {

                    Internals.abort("Item \(itemID) does not exist")
                }
                guard let itemPosition = self.itemPositionMap()[afterItemID] else {

                    Internals.abort("Item \(afterItemID) does not exist")
                }
                let itemIndex = self.sections[itemPosition.sectionIndex].elements
                    .index(after: itemPosition.itemRelativeIndex)
                self.sections[itemPosition.sectionIndex].elements
                    .insert(removed, at: itemIndex)
            }

            mutating func update(itemIDs: [NSManagedObjectID]) {

                let itemPositionMap = self.itemPositionMap()
                for itemID in itemIDs {

                    guard let itemPosition = itemPositionMap[itemID] else {

                        Internals.abort("Item \(itemID) does not exist")
                    }
                    self.sections[itemPosition.sectionIndex].elements[itemPosition.itemRelativeIndex].isReloaded = true
                }
            }

            mutating func append(sectionIDs: [NSString]) {

                let newSections = sectionIDs.lazy.map(Section.init)
                self.sections.append(contentsOf: newSections)
            }

            mutating func insert(sectionIDs: [NSString], before beforeSectionID: NSString) {

                guard let sectionIndex = self.sectionIndex(of: beforeSectionID) else {

                    Internals.abort("Section \"\(beforeSectionID)\" does not exist")
                }
                let newSections = sectionIDs.lazy.map(Section.init)
                self.sections.insert(contentsOf: newSections, at: sectionIndex)
            }

            mutating func insert(sectionIDs: [NSString], after afterSectionID: NSString) {

                guard let beforeIndex = self.sectionIndex(of: afterSectionID) else {

                    Internals.abort("Section \"\(afterSectionID)\" does not exist")
                }
                let sectionIndex = self.sections.index(after: beforeIndex)
                let newSections = sectionIDs.lazy.map(Section.init)
                self.sections.insert(contentsOf: newSections, at: sectionIndex)
            }

            mutating func remove(sectionIDs: [NSString]) {

                for sectionID in sectionIDs {

                    self.remove(sectionID: sectionID)
                }
            }

            mutating func move(sectionID: NSString, before beforeSectionID: NSString) {

                guard let removed = self.remove(sectionID: sectionID) else {

                    Internals.abort("Section \"\(sectionID)\" does not exist")
                }
                guard let sectionIndex = self.sectionIndex(of: beforeSectionID) else {

                    Internals.abort("Section \"\(beforeSectionID)\" does not exist")
                }
                self.sections.insert(removed, at: sectionIndex)
            }

            mutating func move(sectionID: NSString, after afterSectionID: NSString) {

                guard let removed = self.remove(sectionID: sectionID) else {

                    Internals.abort("Section \"\(sectionID)\" does not exist")
                }
                guard let beforeIndex = self.sectionIndex(of: afterSectionID) else {

                    Internals.abort("Section \"\(afterSectionID)\" does not exist")
                }
                let sectionIndex = self.sections.index(after: beforeIndex)
                self.sections.insert(removed, at: sectionIndex)
            }

            mutating func update(sectionIDs: [NSString]) {

                for sectionID in sectionIDs {

                    guard let sectionIndex = self.sectionIndex(of: sectionID) else {

                        continue
                    }
                    self.sections[sectionIndex].isReloaded = true
                }
            }


            // MARK: Private

            private func sectionIndex(of sectionID: NSString) -> Array<Section>.Index? {

                return self.sections.firstIndex(where: { $0.id == sectionID })
            }

            @discardableResult
            private mutating func remove(itemID: NSManagedObjectID) -> Item? {

                guard let itemPosition = self.itemPositionMap()[itemID] else {

                    return nil
                }
                return self.sections[itemPosition.sectionIndex].elements
                    .remove(at: itemPosition.itemRelativeIndex)
            }

            @discardableResult
            private mutating func remove(sectionID: NSString) -> Section? {

                guard let sectionIndex = self.sectionIndex(of: sectionID) else {

                    return nil
                }
                return self.sections.remove(at: sectionIndex)
            }

            private func itemPositionMap() -> [NSManagedObjectID: ItemPosition] {

                return self.sections.enumerated().reduce(into: [:]) { result, section in

                    for (itemRelativeIndex, item) in section.element.elements.enumerated() {

                        result[item.id] = ItemPosition(
                            item: item,
                            itemRelativeIndex: itemRelativeIndex,
                            section: section.element,
                            sectionIndex: section.offset
                        )
                    }
                }
            }


            // MARK: - Item

            internal struct Item: Identifiable, Equatable {

                var isReloaded: Bool

                init(id: NSManagedObjectID, isReloaded: Bool) {

                    self.id = id
                    self.isReloaded = isReloaded
                }

                init(id: NSManagedObjectID) {

                    self.init(id: id, isReloaded: false)
                }

                func isContentEqual(to source: Item) -> Bool {

                    return !self.isReloaded && self.id == source.id
                }

                // MARK: Identifiable

                var id: NSManagedObjectID
            }


            // MARK: - Section

            internal struct Section: Identifiable, Equatable {

                var elements: [Item] = []
                var isReloaded: Bool

                init(id: NSString, items: [Item], isReloaded: Bool) {
                    self.id = id
                    self.elements = items
                    self.isReloaded = isReloaded
                }

                init(id: NSString) {

                    self.init(id: id, items: [], isReloaded: false)
                }

                init<S: Sequence>(source: Section, elements: S) where S.Element == Item {

                    self.init(id: source.id, items: Array(elements), isReloaded: source.isReloaded)
                }

                func isContentEqual(to source: Section) -> Bool {

                    return !self.isReloaded && self.id == source.id
                }

                // MARK: Identifiable

                var id: NSString
            }


            // MARK: - ItemPosition

            fileprivate struct ItemPosition {

                var item: Item
                var itemRelativeIndex: Int
                var section: Section
                var sectionIndex: Int
            }
        }
    }
}


// MARK: - NSDiffableDataSourceSnapshot: Internals.DiffableDataSourceSnapshot

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
extension NSDiffableDataSourceSnapshot: Internals.DiffableDataSourceSnapshot where SectionIdentifierType == NSString, ItemIdentifierType == NSManagedObjectID {}


// MARK: - Internals.DiffableDataSourceSnapshot

internal protocol _Internal_DiffableDataSourceSnapshot {

    init()

    var numberOfItems: Int { get }
    var numberOfSections: Int { get }
    var sectionIdentifiers: [NSString] { get }
    var itemIdentifiers: [NSManagedObjectID] { get }

    func numberOfItems(inSection identifier: NSString) -> Int
    func itemIdentifiers(inSection identifier: NSString) -> [NSManagedObjectID]
    func sectionIdentifier(containingItem identifier: NSManagedObjectID) -> NSString?
    func indexOfItem(_ identifier: NSManagedObjectID) -> Int?
    func indexOfSection(_ identifier: NSString) -> Int?

    mutating func appendItems(_ identifiers: [NSManagedObjectID], toSection sectionIdentifier: NSString?)
    mutating func insertItems(_ identifiers: [NSManagedObjectID], beforeItem beforeIdentifier: NSManagedObjectID)
    mutating func insertItems(_ identifiers: [NSManagedObjectID], afterItem afterIdentifier: NSManagedObjectID)
    mutating func deleteItems(_ identifiers: [NSManagedObjectID])
    mutating func deleteAllItems()
    mutating func moveItem(_ identifier: NSManagedObjectID, beforeItem toIdentifier: NSManagedObjectID)
    mutating func moveItem(_ identifier: NSManagedObjectID, afterItem toIdentifier: NSManagedObjectID)
    mutating func reloadItems(_ identifiers: [NSManagedObjectID])
    mutating func appendSections(_ identifiers: [NSString])
    mutating func insertSections(_ identifiers: [NSString], beforeSection toIdentifier: NSString)
    mutating func insertSections(_ identifiers: [NSString], afterSection toIdentifier: NSString)
    mutating func deleteSections(_ identifiers: [NSString])
    mutating func moveSection(_ identifier: NSString, beforeSection toIdentifier: NSString)
    mutating func moveSection(_ identifier: NSString, afterSection toIdentifier: NSString)
    mutating func reloadSections(_ identifiers: [NSString])
}




#endif
