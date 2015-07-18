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
        
        self.entityClass = T.self
        self.findPersistentStores = { _ in nil }
    }
    
    public init(_ entity: T.Type) {
        
        self.entityClass = entity
        self.findPersistentStores = { _ in nil }
    }
    
    public init(_ entityClass: AnyClass) {
        
        self.entityClass = entityClass
        self.findPersistentStores = { _ in nil }
    }
    
    public init(_ configurations: String?...) {
        
        self.init(entityClass: T.self, configurations: configurations)
    }
    
    public init(_ configurations: [String?]) {
        
        self.init(entityClass: T.self, configurations: configurations)
    }
    
    public init(_ entity: T.Type, _ configurations: String?...) {
        
        self.init(entityClass: entity, configurations: configurations)
    }
    
    public init(_ entity: T.Type, _ configurations: [String?]) {
        
        self.init(entityClass: entity, configurations: configurations)
    }
    
    public init(_ entityClass: AnyClass, _ configurations: String?...) {
        
        self.init(entityClass: entityClass, configurations: configurations)
    }
    
    public init(_ entityClass: AnyClass, _ configurations: [String?]) {
        
        self.init(entityClass: entityClass, configurations: configurations)
    }
    
    public init(_ storeURLs: NSURL...) {
        
        self.init(entityClass: T.self, storeURLs: storeURLs)
    }
    
    public init(_ storeURLs: [NSURL]) {
        
        self.init(entityClass: T.self, storeURLs: storeURLs)
    }
    
    public init(_ entity: T.Type, _ storeURLs: NSURL...) {
        
        self.init(entityClass: entity, storeURLs: storeURLs)
    }
    
    public init(_ entity: T.Type, _ storeURLs: [NSURL]) {
        
        self.init(entityClass: entity, storeURLs: storeURLs)
    }
    
    public init(_ entityClass: AnyClass, _ storeURLs: NSURL...) {
        
        self.init(entityClass: entityClass, storeURLs: storeURLs)
    }
    
    public init(_ entityClass: AnyClass, _ storeURLs: [NSURL]) {
        
        self.init(entityClass: entityClass, storeURLs: storeURLs)
    }
    
    public init(_ persistentStores: NSPersistentStore...) {
        
        self.init(entityClass: T.self, persistentStores: persistentStores)
    }
    
    public init(_ persistentStores: [NSPersistentStore]) {
        
        self.init(entityClass: T.self, persistentStores: persistentStores)
    }
    
    public init(_ entity: T.Type, _ persistentStores: NSPersistentStore...) {
        
        self.init(entityClass: entity, persistentStores: persistentStores)
    }
    
    public init(_ entity: T.Type, _ persistentStores: [NSPersistentStore]) {
        
        self.init(entityClass: entity, persistentStores: persistentStores)
    }
    
    public init(_ entityClass: AnyClass, _ persistentStores: NSPersistentStore...) {
        
        self.init(entityClass: entityClass, persistentStores: persistentStores)
    }
    
    public init(_ entityClass: AnyClass, _ persistentStores: [NSPersistentStore]) {
        
        self.init(entityClass: entityClass, persistentStores: persistentStores)
    }
    
    
    // MARK: Internal
    
    internal func applyToFetchRequest(fetchRequest: NSFetchRequest, context: NSManagedObjectContext) {
        
        fetchRequest.entity = context.entityDescriptionForEntityClass(self.entityClass)
        fetchRequest.affectedStores = self.findPersistentStores(context: context)
    }
    
    
    // MARK: Private
    
    private let entityClass: AnyClass
    
    private let findPersistentStores: (context: NSManagedObjectContext) -> [NSPersistentStore]?
    
    private init(entityClass: AnyClass, configurations: [String?]) {
        
        let configurationsSet = Set(configurations.map { $0 ?? Into.defaultConfigurationName })
        self.entityClass = entityClass
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(entityClass)?.filter {
                
                return configurationsSet.contains($0.configurationName)
            }
        }
    }
    
    private init(entityClass: AnyClass, storeURLs: [NSURL]) {
        
        let storeURLsSet = Set(storeURLs)
        self.entityClass = entityClass
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(entityClass)?.filter {
                
                return $0.URL != nil && storeURLsSet.contains($0.URL!)
            }
        }
    }
    
    private init(entityClass: AnyClass, persistentStores: [NSPersistentStore]) {
        
        let persistentStores = Set(persistentStores)
        self.entityClass = entityClass
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(entityClass)?.filter {
                
                return persistentStores.contains($0)
            }
        }
    }
}
