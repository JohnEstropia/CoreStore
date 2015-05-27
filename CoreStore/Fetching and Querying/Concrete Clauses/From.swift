//
//  From.swift
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


// MARK: - From

/**
A `Form` clause binds the `NSManagedObject` entity type to the generics type system.
*/
public struct From<T: NSManagedObject> {
    
    // MARK: Public
    
    public init(){
        
        self.findPersistentStores = { _ in nil }
    }
    
    public init(_ entity: T.Type) {
        
        self.findPersistentStores = { _ in nil }
    }
    
    public init(_ configurations: String...) {
        
        self.init(configurations: configurations)
    }
    
    public init(_ configurations: [String]) {
        
        self.init(configurations: configurations)
    }
    
    public init(_ entity: T.Type, _ configurations: String...) {
        
        self.init(configurations: configurations)
    }
    
    public init(_ entity: T.Type, _ configurations: [String]) {
        
        self.init(configurations: configurations)
    }
    
    public init(_ storeURLs: NSURL...) {
        
        self.init(storeURLs: storeURLs)
    }
    
    public init(_ storeURLs: [NSURL]) {
        
        self.init(storeURLs: storeURLs)
    }
    
    public init(_ entity: T.Type, _ storeURLs: NSURL...) {
        
        self.init(storeURLs: storeURLs)
    }
    
    public init(_ entity: T.Type, _ storeURLs: [NSURL]) {
        
        self.init(storeURLs: storeURLs)
    }
    
    public init(_ persistentStores: NSPersistentStore...) {
        
        self.init(persistentStores: persistentStores)
    }
    
    public init(_ persistentStores: [NSPersistentStore]) {
        
        self.init(persistentStores: persistentStores)
    }
    
    public init(_ entity: T.Type, _ persistentStores: NSPersistentStore...) {
        
        self.init(persistentStores: persistentStores)
    }
    
    public init(_ entity: T.Type, _ persistentStores: [NSPersistentStore]) {
        
        self.init(persistentStores: persistentStores)
    }
    
    
    // MARK: Internal
    
    internal func applyToFetchRequest(fetchRequest: NSFetchRequest, context: NSManagedObjectContext) {
        
        fetchRequest.entity = context.entityDescriptionForEntityClass(T.self)
        fetchRequest.affectedStores = self.findPersistentStores(context: context)
    }
    
    
    // MARK: Private
    
    private let findPersistentStores: (context: NSManagedObjectContext) -> [NSPersistentStore]?
    
    private init(configurations: [String]) {
        
        let configurationsSet = Set(configurations)
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(T.self)?.filter {
                
                return configurationsSet.contains($0.configurationName)
            }
        }
    }
    
    private init(storeURLs: [NSURL]) {
        
        let storeURLsSet = Set(storeURLs)
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(T.self)?.filter {
                
                return $0.URL != nil && storeURLsSet.contains($0.URL!)
            }
        }
    }
    
    private init(persistentStores: [NSPersistentStore]) {
        
        let persistentStores = Set(persistentStores)
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(T.self)?.filter {
                
                return persistentStores.contains($0)
            }
        }
    }
}
