//
//  CSCoreStore.swift
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


// MARK: - CSCoreStore

/**
 The `CSCoreStore` serves as the Objective-C bridging type for `CoreStore`.
 
 - SeeAlso: `CoreStore`
 */
@objc
public final class CSCoreStore: NSObject {
    
    /**
     The default `CSDataStack` instance to be used. If `defaultStack` is not set before the first time accessed, a default-configured `CSDataStack` will be created.
     
     - SeeAlso: `CSDataStack`
     - Note: Changing the `defaultStack` is thread safe, but it is recommended to setup `CSDataStacks` on a common queue (e.g. the main queue).
     */
    @objc
    public static var defaultStack: CSDataStack {
        
        get {
            
            return CoreStore.defaultStack.bridgeToObjectiveC
        }
        set {
            
            CoreStore.defaultStack = newValue.bridgeToSwift
        }
    }
    
    
    // MARK: Private
    
    private override init() {
        
        fatalError()
    }
}
