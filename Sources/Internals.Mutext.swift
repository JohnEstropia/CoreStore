//
//  Internals.Mutex.swift
//  CoreStore
//
//  Copyright © 2026 John Rommel Estropia
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
import Synchronization
import os


// MARK: - Internals

extension Internals {
    
    // MARK: - Mutex
    
    internal struct Mutex<Value: ~Copyable>: ~Copyable, @unchecked Sendable {
        
        // MARK: Internal
        
        init(_ initialValue: consuming sending Value) {
            
            self.storage = .init(initialValue)
        }
        
        borrowing func withLock<Result, E>(
            _ body: (inout sending Value) throws(E) -> sending Result
        ) throws(E) -> sending Result
        where E: Error, Result: ~Copyable {
            
            let storage = self.storage
            storage.lock()
            defer {
                
                storage.unlock()
            }
            return try body(&storage.value)
        }
        
        borrowing func withLockUnchecked<Result, E>(
            _ body: (inout sending Value) throws(E) -> Result
        ) throws(E) -> sending Result
        where E: Error {
            
            let storage = self.storage
            storage.lock()
            defer {
                
                storage.unlock()
            }
            return try body(&storage.value)
        }
        
        
        // MARK: Private
        
        private let storage: Storage
        
        
        // MARK: - Storage
        
        fileprivate final class Storage {
            
            // MARK: FilePrivate
            
            var value: Value
            
            init(_ initialValue: consuming sending Value) {
                
                self.unfairLock = .allocate(capacity: 1)
                self.unfairLock.initialize(to: os_unfair_lock())
                self.value = initialValue
            }
            
            deinit {
                
                self.unfairLock.deinitialize(count: 1)
                self.unfairLock.deallocate()
            }
            
            func lock() {
                os_unfair_lock_lock(self.unfairLock)
            }

            func unlock() {
                os_unfair_lock_unlock(self.unfairLock)
            }
            
            
            // MARK: Private
            
            private let unfairLock: os_unfair_lock_t
        }
    }
}
