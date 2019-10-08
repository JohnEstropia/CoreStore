//
//  Internals.FallbackDiffableDataUIDispatcher.swift
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

#if canImport(QuartzCore)
import QuartzCore

#endif


// MARK: - Internals

extension Internals {

    // MARK: Internal

//    // Implementation based on https://github.com/ra1028/DiffableDataSources
//    internal final class FallbackDiffableDataUIDispatcher {
//
//        // MARK: Internal
//
//        internal func apply() {
//
//        }
//
//        func snapshot() -> DiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
//            var snapshot = DiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
//            snapshot.structure.sections = currentSnapshot.structure.sections
//            return snapshot
//        }
//
//        func itemIdentifier(for indexPath: IndexPath) -> ItemIdentifierType? {
//            guard 0..<sections.endIndex ~= indexPath.section else {
//                return nil
//            }
//
//            let items = sections[indexPath.section].elements
//
//            guard 0..<items.endIndex ~= indexPath.item else {
//                return nil
//            }
//
//            return items[indexPath.item].differenceIdentifier
//        }
//
//        func unsafeItemIdentifier(for indexPath: IndexPath, file: StaticString = #file, line: UInt = #line) -> ItemIdentifierType {
//            guard let itemIdentifier = itemIdentifier(for: indexPath) else {
//                universalError("Item not found at the specified index path(\(indexPath)).")
//            }
//
//            return itemIdentifier
//        }
//
//        func indexPath(for itemIdentifier: ItemIdentifierType) -> IndexPath? {
//            let indexPathMap: [ItemIdentifierType: IndexPath] = sections.enumerated()
//                .reduce(into: [:]) { result, section in
//                    for (itemIndex, item) in section.element.elements.enumerated() {
//                        result[item.differenceIdentifier] = IndexPath(
//                            item: itemIndex,
//                            section: section.offset
//                        )
//                    }
//            }
//            return indexPathMap[itemIdentifier]
//        }
//
//        func numberOfSections() -> Int {
//            return sections.count
//        }
//
//        func numberOfItems(inSection section: Int) -> Int {
//            return sections[section].elements.count
//        }
//
//
//
//        // MARK: Private
//
//        private let dispatcher: MainThreadSerialDispatcher = .init()
//
//        private var currentSnapshot: Internals.DiffableDataSourceSnapshot = FallbackDiffableDataSourceSnapshot()
//        private var sections: [FallbackDiffableDataSourceSnapshot.BackingStructure.Section] = []
//
//
//        // MARK: - MainThreadSerialDispatcher
//
//        fileprivate final class MainThreadSerialDispatcher {
//
//            // MARK: FilePrivate
//
//            fileprivate init() {
//
//                self.executingCount.initialize(to: 0)
//            }
//
//            deinit {
//
//                self.executingCount.deinitialize(count: 1)
//                self.executingCount.deallocate()
//            }
//
//            fileprivate func dispatch(_ action: @escaping () -> Void) {
//
//                let count = OSAtomicIncrement32(self.executingCount)
//                if Thread.isMainThread && count == 1 {
//
//                    action()
//                    OSAtomicDecrement32(executingCount)
//                }
//                else {
//
//                    DispatchQueue.main.async { [weak self] in
//
//                        guard let self = self else {
//
//                            return
//                        }
//                        action()
//                        OSAtomicDecrement32(self.executingCount)
//                    }
//                }
//            }
//
//
//            // MARK: Private
//
//            private let executingCount: UnsafeMutablePointer<Int32> = .allocate(capacity: 1)
//        }
//    }
}

#endif
