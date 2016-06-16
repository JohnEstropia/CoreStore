//
//  CSListMonitor.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - CSListMonitor

/**
 The `CSListMonitor` serves as the Objective-C bridging type for `ListMonitor<T>`.
 
 - SeeAlso: `ListMonitor`
 */
@objc
public final class CSListMonitor: NSObject, CoreStoreObjectiveCType {
    
    // MARK: Public (Accessors)
    
    /**
     Returns the object at the given index within the first section. This subscript indexer is typically used for `CSListMonitor`s created without section groupings.
     
     - parameter index: the index of the object. Using an index above the valid range will raise an exception.
     - returns: the `NSManagedObject` at the specified index
     */
    @objc
    public subscript(index: Int) -> AnyObject {
        
        return self.bridgeToSwift[index]
    }
    
    /**
     Returns the object at the given index, or `nil` if out of bounds. This indexer is typically used for `CSListMonitor`s created without section groupings.
     
     - parameter index: the index for the object. Using an index above the valid range will return `nil`.
     - returns: the `NSManagedObject` at the specified index, or `nil` if out of bounds
     */
    @objc
    public func objectAtSafeIndex(index: Int) -> AnyObject? {
        
        return self.bridgeToSwift[safeIndex: index]
    }
    
    /**
     Returns the object at the given `sectionIndex` and `itemIndex`. This indexer is typically used for `CSListMonitor`s created as sectioned lists.
     
     - parameter sectionIndex: the section index for the object. Using a `sectionIndex` with an invalid range will raise an exception.
     - parameter itemIndex: the index for the object within the section. Using an `itemIndex` with an invalid range will raise an exception.
     - returns: the `NSManagedObject` at the specified section and item index
     */
    @objc
    public func objectAtSectionIndex(sectionIndex: Int, itemIndex: Int) -> AnyObject {
        
        return self.bridgeToSwift[sectionIndex, itemIndex]
    }

    /**
     Returns the object at the given section and item index, or `nil` if out of bounds. This indexer is typically used for `CSListMonitor`s created as sectioned lists.
     
     - parameter sectionIndex: the section index for the object. Using a `sectionIndex` with an invalid range will return `nil`.
     - parameter itemIndex: the index for the object within the section. Using an `itemIndex` with an invalid range will return `nil`.
     - returns: the `NSManagedObject` at the specified section and item index, or `nil` if out of bounds
     */
    @objc
    public func objectAtSafeSectionIndex(sectionIndex: Int, safeItemIndex itemIndex: Int) -> AnyObject? {
        
        return self.bridgeToSwift[safeSectionIndex: sectionIndex, safeItemIndex: itemIndex]
    }
    
    /**
     Returns the object at the given `NSIndexPath`. This subscript indexer is typically used for `CSListMonitor`s created as sectioned lists.
     
     - parameter indexPath: the `NSIndexPath` for the object. Using an `indexPath` with an invalid range will raise an exception.
     - returns: the `NSManagedObject` at the specified index path
     */
    @objc
    public func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        
        return self.bridgeToSwift[indexPath]
    }
    
    /**
     Returns the object at the given `NSIndexPath`, or `nil` if out of bounds. This subscript indexer is typically used for `CSListMonitor`s created as sectioned lists.
     
     - parameter indexPath: the `NSIndexPath` for the object. Using an `indexPath` with an invalid range will return `nil`.
     - returns: the `NSManagedObject` at the specified index path, or `nil` if out of bounds
     */
    @objc
    public func objectAtSafeIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        
        return self.bridgeToSwift[safeIndexPath: indexPath]
    }
    
    /**
     Checks if the `CSListMonitor` has at least one object in any section.
     
     - returns: `YES` if at least one object in any section exists, `NO` otherwise
     */
    @objc
    @warn_unused_result
    public func hasObjects() -> Bool {
        
        return self.bridgeToSwift.hasObjects()
    }
    
    /**
     Checks if the `CSListMonitor` has at least one object the specified section.
     
     - parameter section: the section index. Using an index outside the valid range will return `NO`.
     - returns: `YES` if at least one object in the specified section exists, `NO` otherwise
     */
    @objc
    @warn_unused_result
    public func hasObjectsInSection(section: Int) -> Bool {
        
        return self.bridgeToSwift.hasObjectsInSection(section)
    }
    
    /**
     Returns all objects in all sections
     
     - returns: all objects in all sections
     */
    @objc
    @warn_unused_result
    public func objectsInAllSections() -> [NSManagedObject] {
        
        return self.bridgeToSwift.objectsInAllSections()
    }
    
    /**
     Returns all objects in the specified section
     
     - parameter section: the section index. Using an index outside the valid range will raise an exception.
     - returns: all objects in the specified section
     */
    @objc
    @warn_unused_result
    public func objectsInSection(section: Int) -> [NSManagedObject] {
        
        return self.bridgeToSwift.objectsInSection(section)
    }
    
    /**
     Returns all objects in the specified section, or `nil` if out of bounds.
     
     - parameter section: the section index. Using an index outside the valid range will return `nil`.
     - returns: all objects in the specified section, or `nil` if out of bounds
     */
    @objc
    @warn_unused_result
    public func objectsInSafeSection(safeSectionIndex section: Int) -> [NSManagedObject]? {
        
        return self.bridgeToSwift.objectsInSection(safeSectionIndex: section)
    }

    /**
     Returns the number of sections
     
     - returns: the number of sections
     */
    @objc
    @warn_unused_result
    public func numberOfSections() -> Int {
        
        return self.bridgeToSwift.numberOfSections()
    }
    
    /**
     Returns the number of objects in all sections
     
     - returns: the number of objects in all sections
     */
    @objc
    @warn_unused_result
    public func numberOfObjects() -> Int {
        
        return self.bridgeToSwift.numberOfObjects()
    }

    /**
     Returns the number of objects in the specified section
     
     - parameter section: the section index. Using an index outside the valid range will raise an exception.
     - returns: the number of objects in the specified section
     */
    @objc
    @warn_unused_result
    public func numberOfObjectsInSection(section: Int) -> Int {
        
        return self.bridgeToSwift.numberOfObjectsInSection(section)
    }
    
    /**
     Returns the number of objects in the specified section, or `nil` if out of bounds.
     
     - parameter section: the section index. Using an index outside the valid range will return `nil`.
     - returns: the number of objects in the specified section, or `nil` if out of bounds
     */
    @objc
    @warn_unused_result
    public func numberOfObjectsInSafeSection(safeSectionIndex section: Int) -> NSNumber? {
        
        return self.bridgeToSwift.numberOfObjectsInSection(safeSectionIndex: section)
    }
    
    /**
     Returns the `NSFetchedResultsSectionInfo` for the specified section
     
     - parameter section: the section index. Using an index outside the valid range will raise an exception.
     - returns: the `NSFetchedResultsSectionInfo` for the specified section
     */
    @objc
    @warn_unused_result
    public func sectionInfoAtIndex(section: Int) -> NSFetchedResultsSectionInfo {
        
        return self.bridgeToSwift.sectionInfoAtIndex(section)
    }
    
    /**
     Returns the `NSFetchedResultsSectionInfo` for the specified section, or `nil` if out of bounds.
     
     - parameter section: the section index. Using an index outside the valid range will return `nil`.
     - returns: the `NSFetchedResultsSectionInfo` for the specified section, or `nil` if the section index is out of bounds.
     */
    @objc
    @warn_unused_result
    public func sectionInfoAtSafeSectionIndex(safeSectionIndex section: Int) -> NSFetchedResultsSectionInfo? {
        
        return self.bridgeToSwift.sectionInfoAtIndex(safeSectionIndex: section)
    }
    
    /**
     Returns the `NSFetchedResultsSectionInfo`s for all sections
     
     - returns: the `NSFetchedResultsSectionInfo`s for all sections
     */
    @objc
    @warn_unused_result
    public func sections() -> [NSFetchedResultsSectionInfo] {
        
        return self.bridgeToSwift.sections()
    }
    
    /**
     Returns the target section for a specified "Section Index" title and index.
     
     - parameter title: the title of the Section Index
     - parameter index: the index of the Section Index
     - returns: the target section for the specified "Section Index" title and index.
     */
    @objc
    @warn_unused_result
    public func targetSectionForSectionIndexTitle(title title: String, index: Int) -> Int {
        
        return self.bridgeToSwift.targetSectionForSectionIndex(title: title, index: index)
    }
    
    /**
     Returns the section index titles for all sections
     
     - returns: the section index titles for all sections
     */
    @objc
    @warn_unused_result
    public func sectionIndexTitles() -> [String] {
        
        return self.bridgeToSwift.sectionIndexTitles()
    }
    
    /**
     Returns the index of the `NSManagedObject` if it exists in the `CSListMonitor`'s fetched objects, or `nil` if not found.
     
     - parameter object: the `NSManagedObject` to search the index of
     - returns: the index of the `NSManagedObject` if it exists in the `CSListMonitor`'s fetched objects, or `nil` if not found.
     */
    @objc
    @warn_unused_result
    public func indexOf(object: NSManagedObject) -> NSNumber? {
        
        return self.bridgeToSwift.indexOf(object)
    }
    
    /**
     Returns the `NSIndexPath` of the `NSManagedObject` if it exists in the `CSListMonitor`'s fetched objects, or `nil` if not found.
     
     - parameter object: the `NSManagedObject` to search the index of
     - returns: the `NSIndexPath` of the `NSManagedObject` if it exists in the `ListMonitor`'s fetched objects, or `nil` if not found.
     */
    @objc
    @warn_unused_result
    public func indexPathOf(object: NSManagedObject) -> NSIndexPath? {
        
        return self.bridgeToSwift.indexPathOf(object)
    }
    
    
    // MARK: Public (Observers)
    
    /**
     Registers a `CSListObserver` to be notified when changes to the receiver's list occur.
     
     To prevent retain-cycles, `CSListMonitor` only keeps `weak` references to its observers.
     
     For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
     
     Calling `-addListObserver:` multiple times on the same observer is safe, as `CSListMonitor` unregisters previous notifications to the observer before re-registering them.
     
     - parameter observer: a `CSListObserver` to send change notifications to
     */
    @objc
    public func addListObserver(observer: CSListObserver) {
        
        let swift = self.bridgeToSwift
        swift.unregisterObserver(observer)
        swift.registerObserver(
            observer,
            willChange: { (observer, monitor) in
                
                observer.listMonitorWillChange?(monitor.bridgeToObjectiveC)
            },
            didChange: { (observer, monitor) in
                
                observer.listMonitorDidChange?(monitor.bridgeToObjectiveC)
            },
            willRefetch: { (observer, monitor) in
                
                observer.listMonitorWillRefetch?(monitor.bridgeToObjectiveC)
            },
            didRefetch: { (observer, monitor) in
                
                observer.listMonitorDidRefetch?(monitor.bridgeToObjectiveC)
            }
        )
    }
    
    /**
     Registers a `CSListObjectObserver` to be notified when changes to the receiver's list occur.
     
     To prevent retain-cycles, `CSListMonitor` only keeps `weak` references to its observers.
     
     For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
     
     Calling `-addListObjectObserver:` multiple times on the same observer is safe, as `ListMonitor` unregisters previous notifications to the observer before re-registering them.
     
     - parameter observer: a `CSListObjectObserver` to send change notifications to
     */
    public func addListObjectObserver(observer: CSListObjectObserver) {
        
        let swift = self.bridgeToSwift
        swift.unregisterObserver(observer)
        swift.registerObserver(
            observer,
            willChange: { (observer, monitor) in
                
                observer.listMonitorWillChange?(monitor.bridgeToObjectiveC)
            },
            didChange: { (observer, monitor) in
                
                observer.listMonitorDidChange?(monitor.bridgeToObjectiveC)
            },
            willRefetch: { (observer, monitor) in
                
                observer.listMonitorWillRefetch?(monitor.bridgeToObjectiveC)
            },
            didRefetch: { (observer, monitor) in
                
                observer.listMonitorDidRefetch?(monitor.bridgeToObjectiveC)
            }
        )
        swift.registerObserver(
            observer,
            didInsertObject: { (observer, monitor, object, toIndexPath) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didInsertObject: object, toIndexPath: toIndexPath)
            },
            didDeleteObject: { (observer, monitor, object, fromIndexPath) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didDeleteObject: object, fromIndexPath: fromIndexPath)
            },
            didUpdateObject: { (observer, monitor, object, atIndexPath) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didUpdateObject: object, atIndexPath: atIndexPath)
            },
            didMoveObject: { (observer, monitor, object, fromIndexPath, toIndexPath) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didMoveObject: object, fromIndexPath: fromIndexPath, toIndexPath: toIndexPath)
            }
        )
    }
    
    /**
     Registers a `CSListSectionObserver` to be notified when changes to the receiver's list occur.
     
     To prevent retain-cycles, `CSListMonitor` only keeps `weak` references to its observers.
     
     For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
     
     Calling `-addListSectionObserver:` multiple times on the same observer is safe, as `ListMonitor` unregisters previous notifications to the observer before re-registering them.
     
     - parameter observer: a `CSListSectionObserver` to send change notifications to
     */
    @objc
    public func addListSectionObserver(observer: CSListSectionObserver) {
        
        let swift = self.bridgeToSwift
        swift.unregisterObserver(observer)
        swift.registerObserver(
            observer,
            willChange: { (observer, monitor) in
                
                observer.listMonitorWillChange?(monitor.bridgeToObjectiveC)
            },
            didChange: { (observer, monitor) in
                
                observer.listMonitorDidChange?(monitor.bridgeToObjectiveC)
            },
            willRefetch: { (observer, monitor) in
                
                observer.listMonitorWillRefetch?(monitor.bridgeToObjectiveC)
            },
            didRefetch: { (observer, monitor) in
                
                observer.listMonitorDidRefetch?(monitor.bridgeToObjectiveC)
            }
        )
        swift.registerObserver(
            observer,
            didInsertObject: { (observer, monitor, object, toIndexPath) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didInsertObject: object, toIndexPath: toIndexPath)
            },
            didDeleteObject: { (observer, monitor, object, fromIndexPath) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didDeleteObject: object, fromIndexPath: fromIndexPath)
            },
            didUpdateObject: { (observer, monitor, object, atIndexPath) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didUpdateObject: object, atIndexPath: atIndexPath)
            },
            didMoveObject: { (observer, monitor, object, fromIndexPath, toIndexPath) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didMoveObject: object, fromIndexPath: fromIndexPath, toIndexPath: toIndexPath)
            }
        )
        swift.registerObserver(
            observer,
            didInsertSection: { (observer, monitor, sectionInfo, toIndex) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didInsertSection: sectionInfo, toSectionIndex: toIndex)
            },
            didDeleteSection: { (observer, monitor, sectionInfo, fromIndex) in
                
                observer.listMonitor?(monitor.bridgeToObjectiveC, didDeleteSection: sectionInfo, fromSectionIndex: fromIndex)
            }
        )
    }
    
    /**
     Unregisters a `CSListObserver` from receiving notifications for changes to the receiver's list.
     
     For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
     
     - parameter observer: a `CSListObserver` to unregister notifications to
     */
    @objc
    public func removeListObserver(observer: CSListObserver) {
        
        self.bridgeToSwift.unregisterObserver(observer)
    }

    
    // MARK: Public (Refetching)
    
    /**
     Returns `YES` if a call to `-refetch:` was made to the `CSListMonitor` and is currently waiting for the fetching to complete. Returns `NO` otherwise.
     */
    @objc
    public var isPendingRefetch: Bool {
        
        return self.bridgeToSwift.isPendingRefetch
    }
    
    /**
     Asks the `CSListMonitor` to refetch its objects using the specified series of `CSFetchClause`s. Note that this method does not execute the fetch immediately; the actual fetching will happen after the `NSFetchedResultsController`'s last `controllerDidChangeContent(_:)` notification completes.
     
     `refetch(...)` broadcasts `listMonitorWillRefetch(...)` to its observers immediately, and then `listMonitorDidRefetch(...)` after the new fetch request completes.
     
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses. Note that only specified clauses will be changed; unspecified clauses will use previous values.
     */
    @objc
    public func refetch(fetchClauses: [CSFetchClause]) {
        
        self.bridgeToSwift.refetch { (fetchRequest) in
            
            fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        }
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSListMonitor else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: self.dynamicType))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    @nonobjc
    public let bridgeToSwift: ListMonitor<NSManagedObject>
    
    @nonobjc
    public required init<T: NSManagedObject>(_ swiftValue: ListMonitor<T>) {
        
        self.bridgeToSwift = swiftValue.upcast()
        super.init()
    }
}


// MARK: - ListMonitor

extension ListMonitor: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSListMonitor {
        
        return CSListMonitor(self)
    }
}

#endif
