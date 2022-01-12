//
//  CSListObserver.swift
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


// MARK: - CSListObserver

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public protocol CSListObserver: AnyObject {

    @objc
    optional func listMonitorWillChange(_ monitor: CSListMonitor)

    @objc
    optional func listMonitorDidChange(_ monitor: CSListMonitor)

    @objc
    optional func listMonitorWillRefetch(_ monitor: CSListMonitor)

    @objc
    optional func listMonitorDidRefetch(_ monitor: CSListMonitor)
}


// MARK: - ListObjectObserver

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public protocol CSListObjectObserver: CSListObserver {

    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didInsertObject object: Any, toIndexPath indexPath: IndexPath)

    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didDeleteObject object: Any, fromIndexPath indexPath: IndexPath)

    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didUpdateObject object: Any, atIndexPath indexPath: IndexPath)

    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didMoveObject object: Any, fromIndexPath: IndexPath, toIndexPath: IndexPath)
}


// MARK: - CSListSectionObserver

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public protocol CSListSectionObserver: CSListObjectObserver {

    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int)
    
    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int)
}
