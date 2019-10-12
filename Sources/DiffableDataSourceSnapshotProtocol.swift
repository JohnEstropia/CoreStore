//
//  DiffableDataSourceSnapshotProtocol.swift
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


// MARK: - DiffableDataSourceSnapshotProtocol

internal protocol DiffableDataSourceSnapshotProtocol {

    init()

    var numberOfItems: Int { get }
    var numberOfSections: Int { get }
    var sectionIdentifiers: [String] { get }
    var itemIdentifiers: [NSManagedObjectID] { get }

    func numberOfItems(inSection identifier: String) -> Int
    func itemIdentifiers(inSection identifier: String) -> [NSManagedObjectID]
    func sectionIdentifier(containingItem identifier: NSManagedObjectID) -> String?
    func indexOfItem(_ identifier: NSManagedObjectID) -> Int?
    func indexOfSection(_ identifier: String) -> Int?

    mutating func appendItems(_ identifiers: [NSManagedObjectID], toSection sectionIdentifier: String?)
    mutating func insertItems(_ identifiers: [NSManagedObjectID], beforeItem beforeIdentifier: NSManagedObjectID)
    mutating func insertItems(_ identifiers: [NSManagedObjectID], afterItem afterIdentifier: NSManagedObjectID)
    mutating func deleteItems(_ identifiers: [NSManagedObjectID])
    mutating func deleteAllItems()
    mutating func moveItem(_ identifier: NSManagedObjectID, beforeItem toIdentifier: NSManagedObjectID)
    mutating func moveItem(_ identifier: NSManagedObjectID, afterItem toIdentifier: NSManagedObjectID)
    mutating func reloadItems(_ identifiers: [NSManagedObjectID])
    mutating func appendSections(_ identifiers: [String])
    mutating func insertSections(_ identifiers: [String], beforeSection toIdentifier: String)
    mutating func insertSections(_ identifiers: [String], afterSection toIdentifier: String)
    mutating func deleteSections(_ identifiers: [String])
    mutating func moveSection(_ identifier: String, beforeSection toIdentifier: String)
    mutating func moveSection(_ identifier: String, afterSection toIdentifier: String)
    mutating func reloadSections(_ identifiers: [String])
}
