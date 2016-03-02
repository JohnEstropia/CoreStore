//
//  StorageInterface.swift
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

import CoreData


// MARK: - StorageInterface

public protocol StorageInterface: class {

    static var storeType: String { get }
    
    var storeURL: NSURL? { get }
    
    var configuration: String? { get }
    
    var storeOptions: [String: AnyObject]? { get }
    
    var internalStore: NSPersistentStore? { get set }
    
    func addToPersistentStoreCoordinatorSynchronously(coordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore
    
    func addToPersistentStoreCoordinatorAsynchronously(coordinator: NSPersistentStoreCoordinator, completion: (NSPersistentStore) -> Void, failure: (NSError) -> Void) throws
}

public extension StorageInterface {
    
    public func addToPersistentStoreCoordinatorSynchronously(coordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore {
        
        return try coordinator.addPersistentStoreSynchronously(
            self.dynamicType.storeType,
            configuration: self.configuration,
            URL: self.storeURL,
            options: self.storeOptions
        )
    }
    
    public func addToPersistentStoreCoordinatorAsynchronously(coordinator: NSPersistentStoreCoordinator, completion: (NSPersistentStore) -> Void, failure: (NSError) -> Void) throws {
        
        coordinator.performBlock {
            
            do {
                
                let persistentStore = try coordinator.addPersistentStoreWithType(
                    self.dynamicType.storeType,
                    configuration: self.configuration,
                    URL: self.storeURL,
                    options: self.storeOptions
                )
                completion(persistentStore)
            }
            catch {
                
                failure(error as NSError)
            }
        }
    }
}


// MARK: - DefaultInitializableStore

public protocol DefaultInitializableStore: StorageInterface {
    
    init()
}

