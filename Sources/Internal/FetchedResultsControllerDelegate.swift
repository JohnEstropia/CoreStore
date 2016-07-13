//
//  FetchedResultsControllerDelegate.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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

// MARK: - FetchedResultsControllerHandler

internal protocol FetchedResultsControllerHandler: class {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String?
}


// MARK: - FetchedResultsControllerDelegate

internal final class FetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: Internal
    
    @nonobjc
    internal var enabled = true
    
    @nonobjc
    internal weak var handler: FetchedResultsControllerHandler?
    
    @nonobjc
    internal weak var fetchedResultsController: NSFetchedResultsController? {
        
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
    dynamic func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        guard self.enabled else {
            
            return
        }
        
        self.deletedSections = []
        self.insertedSections = []
        
        self.handler?.controllerWillChangeContent(controller)
    }
    
    @objc
    dynamic func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        guard self.enabled else {
            
            return
        }
        
        self.handler?.controllerDidChangeContent(controller)
    }
    
    @objc
    dynamic func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        guard self.enabled else {
            
            return
        }
        
        guard let actualType = NSFetchedResultsChangeType(rawValue: type.rawValue) else {
            
            // This fix is for a bug where iOS passes 0 for NSFetchedResultsChangeType, but this is not a valid enum case.
            // Swift will then always execute the first case of the switch causing strange behaviour.
            // https://forums.developer.apple.com/thread/12184#31850
            return
        }
        
        // This whole dance is a workaround for a nasty bug introduced in XCode 7 targeted at iOS 8 devices
        // http://stackoverflow.com/questions/31383760/ios-9-attempt-to-delete-and-reload-the-same-index-path/31384014#31384014
        // https://forums.developer.apple.com/message/9998#9998
        // https://forums.developer.apple.com/message/31849#31849
        
        switch actualType {
            
        case .Update:
            guard let section = indexPath?.indexAtPosition(0) else {
                
                return
            }
            if self.deletedSections.contains(section)
                || self.insertedSections.contains(section) {
                    
                    return
            }
            
        case .Move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else {
                
                return
            }
            guard indexPath == newIndexPath else {
                
                break
            }
            if self.insertedSections.contains(indexPath.indexAtPosition(0)) {
                
                // Observers that handle the .Move change are advised to delete then reinsert the object instead of just moving. This is especially true when indexPath and newIndexPath are equal. For example, calling tableView.moveRowAtIndexPath(_:toIndexPath) when both indexPaths are the same will crash the tableView.
                self.handler?.controller(
                    controller,
                    didChangeObject: anObject,
                    atIndexPath: indexPath,
                    forChangeType: .Move,
                    newIndexPath: newIndexPath
                )
                return
            }
            if self.deletedSections.contains(indexPath.indexAtPosition(0)) {
                
                self.handler?.controller(
                    controller,
                    didChangeObject: anObject,
                    atIndexPath: nil,
                    forChangeType: .Insert,
                    newIndexPath: indexPath
                )
                return
            }
            self.handler?.controller(
                controller,
                didChangeObject: anObject,
                atIndexPath: indexPath,
                forChangeType: .Update,
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
    dynamic func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        guard self.enabled else {
            
            return
        }
        
        switch type {
            
        case .Delete:   self.deletedSections.insert(sectionIndex)
        case .Insert:   self.insertedSections.insert(sectionIndex)
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
    dynamic func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
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

#endif
