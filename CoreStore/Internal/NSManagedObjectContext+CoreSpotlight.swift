//
//  NSManagedObjectContext+CoreSpotlight.swift
//  CoreStore
//
//  Copyright (c) 2016 John Rommel Estropia
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
import CoreSpotlight
import MobileCoreServices
#if USE_FRAMEWORKS
    import GCDKit
#endif


// MARK: - NSManagedObjectContext

internal extension NSManagedObjectContext {

    // MARK: Internal
    
    internal func commitCompletionForSearchableItems() -> (() -> Void) {
        
        guard #available(iOS 9.0, *) else {
            
            return {}
        }
        
        guard CSSearchableIndex.isIndexingAvailable() else {
            
            return {}
        }

        let searchableItems = self.insertedObjects.flatMap {
            
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeJSON as String)
            attributeSet.title = "aa"
            attributeSet.contentDescription = "bb"
            
            let item = CSSearchableItem(
                uniqueIdentifier: "aa",
                domainIdentifier: "jp.eureka.sample",
                attributeSet: attributeSet
            )
            return item
        }
        return {
            
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(
                searchableItems,
                completionHandler: { (error) -> Void in
                    
                    //...
                }
            )
        }
        //
        //
        //        for case (let object as CoreSpotlightSearchableObject) in self.context.insertedObjects {
        //
        //            object.coreSpotlightIndexValue
        //        }
        //
        //        public var insertedObjects: Set<NSManagedObject> { get }
        //        public var updatedObjects: Set<NSManagedObject> { get }
        //        public var deletedObjects: Set<NSManagedObject> { get }
        //        public var registeredObjects: Set<NSManagedObject> { get }
    }

}
