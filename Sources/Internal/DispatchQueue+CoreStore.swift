//
//  DispatchQueue+CoreStore.swift
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


// MARK: - DispatchQueue

internal extension DispatchQueue {
    
    internal convenience init(serialWith label: String) {
        
        self.init(
            label: label,
            qos: .default,
            attributes: .allZeros,
            autoreleaseFrequency: .inherit,
            target: nil
        )
    }
    
    internal convenience init(concurrentWith label: String) {
        
        self.init(
            label: label,
            qos: .default,
            attributes: .concurrent,
            autoreleaseFrequency: .inherit,
            target: nil
        )
    }
    
    internal func cs_isCurrentExecutionContext() -> Bool {
        
        let specific = ObjectIdentifier(self)
        
        self.setSpecific(key: Static.specificKey, value: specific)
        return DispatchQueue.getSpecific(key: Static.specificKey) == specific
    }
    
    internal func cs_sync<T>(_ closure: () throws -> T) rethrows -> T {
        
        return self.sync { autoreleasepool(invoking: closure) }
    }
    
    internal func cs_async(_ closure: () -> Void) {
        
        self.async { autoreleasepool(invoking: closure) }
    }
    
    internal func cs_barrierSync<T>(_ closure: () throws -> T) rethrows -> T {
        
        return self.sync(flags: .barrier) { autoreleasepool(invoking: closure) }
    }
    
    internal func cs_barrierAsync(_ closure: () -> Void) {
        
        self.async(flags: .barrier) { autoreleasepool(invoking: closure) }
    }
    
    
    // MARK: Private
    
    private enum Static {
        
        static let specificKey = DispatchSpecificKey<ObjectIdentifier>()
    }
}
