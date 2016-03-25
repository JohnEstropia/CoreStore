//
//  CSImportableObject.swift
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


// MARK: - CSImportableObject

@objc
public protocol CSImportableObject: class, AnyObject {
    
    /**
     Return the expected class of the import source. If not implemented, transactions will not validate the import source's type.
     
     - returns: the expected class of the import source
     */
    @objc
    optional static func classForImportSource() -> AnyClass
    
    /**
     Return `YES` if an object should be created from `source`. Return `NO` to ignore and skip `source`. If not implemented, transactions assume `YES`.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     - returns: `YES` if an object should be created from `source`. Return `NO` to ignore.
     */
    @objc
    optional static func shouldInsertFromImportSource(source: AnyObject, inTransaction transaction: CSBaseDataTransaction) -> Bool
    
    /**
     Implements the actual importing of data from `source`. Implementers should pull values from `source` and assign them to the receiver's attributes. Note that throwing from this method will cause subsequent imports that are part of the same `-importObjects:sourceArray:` call to be cancelled.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     */
    @objc
    func didInsertFromImportSource(source: AnyObject, inTransaction transaction: CSBaseDataTransaction) throws
}
