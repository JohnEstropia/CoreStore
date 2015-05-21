//
//  NSError+HardcoreData.swift
//  HardcoreData
//
//  Copyright (c) 2014 John Rommel Estropia
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

/**
The `NSError` error domain for `HardcoreData`.
*/
public let HardcoreDataErrorDomain = "com.hardcoredata.error"

/**
The `NSError` error codes for `HardcoreDataErrorDomain`.
*/
public enum HardcoreDataErrorCode: Int {
    
    /**
    A failure occured because of an unknown error.
    */
    case UnknownError
    
    /**
    The `NSPersistentStore` could note be initialized because another store existed at the specified `NSURL`.
    */
    case DifferentPersistentStoreExistsAtURL
}


// MARK: - NSError+HardcoreData

public extension NSError {
   
    /**
    If the error's domain is equal to `HardcoreDataErrorDomain`, returns the associated `HardcoreDataErrorCode`. For other domains, returns `nil`.
    */
    public var hardcoreDataErrorCode: HardcoreDataErrorCode? {
        
        return (self.domain == HardcoreDataErrorDomain
            ? HardcoreDataErrorCode(rawValue: self.code)
            : nil)
    }
    
    
    // MARK: Internal
    
    internal convenience init(hardcoreDataErrorCode: HardcoreDataErrorCode) {
        
        self.init(hardcoreDataErrorCode: hardcoreDataErrorCode, userInfo: nil)
    }
    
    internal convenience init(hardcoreDataErrorCode: HardcoreDataErrorCode, userInfo: [NSObject: AnyObject]?) {
        
        self.init(
            domain: HardcoreDataErrorDomain,
            code: hardcoreDataErrorCode.rawValue,
            userInfo: userInfo)
    }
}