//
//  FetchedResultsControllerDelegate.swift
//  CoreStore
//
//  Copyright (c) 2015 John Rommel Estropia
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
    
    internal weak var handler: FetchedResultsControllerHandler?
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
    
    @objc dynamic func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.deletedSections = []
        self.insertedSections = []
        
        self.handler?.controllerWillChangeContent(controller)
    }
    
    @objc dynamic func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.handler?.controllerDidChangeContent(controller)
    }
    
    @objc dynamic func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if #available(iOS 9, *) {
            
            self.handler?.controller(
                controller,
                didChangeObject: anObject,
                atIndexPath: indexPath,
                forChangeType: type,
                newIndexPath: newIndexPath
            )
            return
        }
        
        // Workaround a nasty bug introduced in XCode 7 targeted at iOS 8 devices
        // http://stackoverflow.com/questions/31383760/ios-9-attempt-to-delete-and-reload-the-same-index-path/31384014#31384014
        // https://forums.developer.apple.com/message/9998#9998
        // https://forums.developer.apple.com/message/31849#31849
        switch type {
            
        case .Move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else {
                
                return
            }
            if indexPath == newIndexPath
                && self.deletedSections.contains(indexPath.section) {
                    
                    self.handler?.controller(
                        controller,
                        didChangeObject: anObject,
                        atIndexPath: nil,
                        forChangeType: .Insert,
                        newIndexPath: indexPath
                    )
                    return
            }
            
        case .Update:
            guard let section = indexPath?.section else {
                
                return
            }
            if self.deletedSections.contains(section)
                || self.insertedSections.contains(section) {
                    
                    return
            }
            
        default:
            break
        }
        
        self.handler?.controller(
            controller,
            didChangeObject: anObject,
            atIndexPath: indexPath,
            forChangeType: type,
            newIndexPath: newIndexPath
        )
    }
    
    @objc dynamic func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
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
    
    @objc dynamic func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
        return self.handler?.controller(
            controller,
            sectionIndexTitleForSectionName: sectionName
        )
    }
    
    
    // MARK: Private
    
    private var deletedSections = Set<Int>()
    private var insertedSections = Set<Int>()
}
