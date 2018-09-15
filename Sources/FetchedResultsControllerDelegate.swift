//
//  FetchedResultsControllerDelegate.swift
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


// MARK: - FetchedResultsControllerHandler

@available(macOS 10.12, *)
internal protocol FetchedResultsControllerHandler: class {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: Any, atIndexPath indexPath: IndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String?) -> String?
}


// MARK: - FetchedResultsControllerDelegate

@available(macOS 10.12, *)
internal final class FetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: Internal
    
    @nonobjc
    internal var enabled = true
    
    @nonobjc
    internal let taskGroup = DispatchGroup()
    
    @nonobjc
    internal weak var handler: FetchedResultsControllerHandler?
    
    @nonobjc
    internal weak var fetchedResultsController: CoreStoreFetchedResultsController? {
        
        didSet {
            
            oldValue?.delegate = nil
            self.fetchedResultsController?.delegate = self
        }
    }
    
    deinit {
        
        self.fetchedResultsController?.delegate = nil
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    
    @objc
    dynamic func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.taskGroup.enter()
        guard self.enabled else {
            
            return
        }
        
        self.deletedSections = []
        self.insertedSections = []
        
        self.handler?.controllerWillChangeContent(controller)
    }
    
    @objc
    dynamic func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        defer {
            
            self.taskGroup.leave()
        }
        guard self.enabled else {
            
            return
        }
        
        self.handler?.controllerDidChangeContent(controller)
    }
    
    @objc
    dynamic func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard self.enabled else {
            
            return
        }
        
        guard var actualType = NSFetchedResultsChangeType(rawValue: type.rawValue) else {
            
            // This fix is for a bug where iOS passes 0 for NSFetchedResultsChangeType, but this is not a valid enum case.
            // Swift will then always execute the first case of the switch causing strange behaviour.
            // https://forums.developer.apple.com/thread/12184#31850
            return
        }
        
        // This whole dance is a workaround for a nasty bug introduced in XCode 7 targeted at iOS 8 devices
        // http://stackoverflow.com/questions/31383760/ios-9-attempt-to-delete-and-reload-the-same-index-path/31384014#31384014
        // https://forums.developer.apple.com/message/9998#9998
        // https://forums.developer.apple.com/message/31849#31849

        if #available(iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
         
            // I don't know if iOS 10 even attempted to fix this mess...
            if case .update = actualType,
                indexPath != nil,
                newIndexPath != nil {
                
                actualType = .move
            }
        }
        
        switch actualType {
            
        case .update:
            guard let section = indexPath?[0] else {
                
                return
            }
            if self.deletedSections.contains(section)
                || self.insertedSections.contains(section) {
                
                return
            }
            
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else {
                
                return
            }
            guard indexPath == newIndexPath else {
                
                break
            }
            if self.insertedSections.contains(indexPath[0]) {
                
                // Observers that handle the .Move change are advised to delete then reinsert the object instead of just moving. This is especially true when indexPath and newIndexPath are equal. For example, calling tableView.moveRowAtIndexPath(_:toIndexPath) when both indexPaths are the same will crash the tableView.
                self.handler?.controller(
                    controller,
                    didChangeObject: anObject,
                    atIndexPath: indexPath,
                    forChangeType: .move,
                    newIndexPath: newIndexPath
                )
                return
            }
            if self.deletedSections.contains(indexPath[0]) {
                
                self.handler?.controller(
                    controller,
                    didChangeObject: anObject,
                    atIndexPath: nil,
                    forChangeType: .insert,
                    newIndexPath: indexPath
                )
                return
            }
            guard #available(iOS 9.0, tvOS 9.0, watchOS 3.0, *) else {
                
                return
            }
            self.handler?.controller(
                controller,
                didChangeObject: anObject,
                atIndexPath: indexPath,
                forChangeType: .update,
                newIndexPath: nil
            )
            return
            
        default:
            break
        }
        
        self.handler?.controller(
            controller,
            didChangeObject: anObject,
            atIndexPath: indexPath,
            forChangeType: actualType,
            newIndexPath: newIndexPath
        )
    }
    
    @objc
    dynamic func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        guard self.enabled else {
            
            return
        }
        
        switch type {
            
        case .delete:   self.deletedSections.insert(sectionIndex)
        case .insert:   self.insertedSections.insert(sectionIndex)
        default: break
        }
        
        self.handler?.controller(
            controller,
            didChangeSection: sectionInfo,
            atIndex: sectionIndex,
            forChangeType: type
        )
    }
    
    @objc
    dynamic func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
        return self.handler?.controller(
            controller,
            sectionIndexTitleForSectionName: sectionName
        )
    }
    
    
    // MARK: Private
    
    @nonobjc
    private var deletedSections = Set<Int>()
    
    @nonobjc
    private var insertedSections = Set<Int>()
}
