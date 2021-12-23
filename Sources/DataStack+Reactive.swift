//
//  DataStack+Reactive.swift
//  CoreStore
//
//  Copyright © 2021 John Rommel Estropia
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

#if canImport(Combine)

import Combine


// MARK: - DataStack

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
extension DataStack {
    
    // MARK: Public
    
    /**
     Combine utilities for the `DataStack` are exposed through this namespace
     */
    public var reactive: DataStack.ReactiveNamespace {
        
        return .init(self)
    }
    
    // MARK: - ReactiveNamespace
    
    /**
     Combine utilities for the `DataStack` are exposed through this namespace. Extend this type if you need to add other Combine Publisher utilities for `DataStack`.
     */
    public struct ReactiveNamespace {
        
        // MARK: Public
        
        /**
         The `DataStack` instance
         */
        public let base: DataStack
        
        
        // MARK: Internal
        
        internal init(_ base: DataStack) {
            
            self.base = base
        }
    }
}


// MARK: - DataStack.ReactiveNamespace

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
extension DataStack.ReactiveNamespace {
    
    // MARK: Public
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `addStorage(...)` API. Asynchronously adds a `StorageInterface` to the stack.
     ```
     dataStack.reactive
         .addStorage(
             InMemoryStore(configuration: "Config1")
         )
         .sink(
             receiveCompletion: { result in
                 // ...
             },
             receiveValue: { storage in
                 // ...
             }
         )
         .store(in: &cancellables)
     ```
     - parameter storage: the storage
     - returns: A `Future` that emits a `StorageInterface` instance added to the `DataStack`. Note that the `StorageInterface` event value may not always be the same instance as the parameter argument if a previous `StorageInterface` was already added at the same URL and with the same configuration.
     */
    public func addStorage<T: StorageInterface>(_ storage: T) -> Future<T, CoreStoreError> {
        
        return .init { (promise) in
            
            self.base.addStorage(
                storage,
                completion: { (result) in
                    
                    switch result {
                    
                    case .success(let storage):
                        promise(.success(storage))
                        
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            )
        }
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `addStorage(...)` API. Asynchronously adds a `LocalStorage` to the stack. Migrations are also initiated by default. The event emits `DataStack.AddStoragePublisher.MigrationProgress` `enum` values.
     ```
     dataStack.reactive
         .addStorage(
             SQLiteStore(
                 fileName: "core_data.sqlite",
                 configuration: "Config1"
             )
         )
         .sink(
             receiveCompletion: { result in
                 // ...
             },
             receiveValue: { (progress) in
                 print("\(round(progress.fractionCompleted * 100)) %") // 0.0 ~ 1.0
             }
         )
         .store(in: &cancellables)
     ```
     - parameter storage: the local storage
     - returns: A `DataStack.AddStoragePublisher` that emits a `DataStack.AddStoragePublisher.MigrationProgress` value with metadata for migration progress. Note that the `LocalStorage` event value may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
     */
    public func addStorage<T: LocalStorage>(_ storage: T) -> DataStack.AddStoragePublisher<T> {
        
        return .init(
            dataStack: self.base,
            storage: storage
        )
    }

    
    /**
     Reactive extension for `CoreStore.DataStack`'s `perform(asynchronous:...)` API. Performs a transaction asynchronously where `NSManagedObject` creates, updates, and deletes can be made. The changes are commited automatically after the `task` closure returns. The event value will be the value returned from the `task` closure. Any errors thrown from inside the `task` will be wrapped in a `CoreStoreError` and reported to the completion `.failure`. To cancel/rollback changes, call `transaction.cancel()`, which throws a `CoreStoreError.userCancelled`.
     ```
     dataStack.reactive
         .perform(
             asynchronous: { (transaction) -> (inserted: Set<NSManagedObject>, deleted: Set<NSManagedObject>) in
     
                 // ...
                 return (
                     transaction.insertedObjects(),
                     transaction.deletedObjects()
                 )
             }
         )
         .sink(
             receiveCompletion: { result in
                 // ...
             },
             receiveValue: { value in
                 let inserted = dataStack.fetchExisting(value0.inserted)
                 let deleted = dataStack.fetchExisting(value0.deleted)
                 // ...
             }
         )
         .store(in: &cancellables)
     ```
     - parameter task: the asynchronous closure where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     - returns: A `Future` whose event value be the value returned from the `task` closure.
     */
    public func perform<Output>(
        _ asynchronous: @escaping (AsynchronousDataTransaction) throws -> Output
    ) -> Future<Output, CoreStoreError> {
        
        return .init { (promise) in
            
            self.base.perform(
                asynchronous: asynchronous,
                success: { promise(.success($0)) },
                failure: { promise(.failure($0)) }
            )
        }
    }
}

#endif
