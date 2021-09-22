//
//  CSDataStack+Observing.swift
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


// MARK: - CSDataStack

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
extension CSDataStack {
    
    @objc
    public func monitorObject(_ object: NSManagedObject) -> CSObjectMonitor {

        fatalError()
    }

    @objc
    public func monitorListFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> CSListMonitor {

        fatalError()
    }

    @objc
    public func monitorListByCreatingAsynchronously(_ createAsynchronously: @escaping (CSListMonitor) -> Void, from: CSFrom, fetchClauses: [CSFetchClause]) {

        fatalError()
    }

    @objc
    public func monitorSectionedListFrom(_ from: CSFrom, sectionBy: CSSectionBy, fetchClauses: [CSFetchClause]) -> CSListMonitor {

        fatalError()
    }

    public func monitorSectionedListByCreatingAsynchronously(_ createAsynchronously: @escaping (CSListMonitor) -> Void, from: CSFrom, sectionBy: CSSectionBy, fetchClauses: [CSFetchClause]) {

        fatalError()
    }
}
