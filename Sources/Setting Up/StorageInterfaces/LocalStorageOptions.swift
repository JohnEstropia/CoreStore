//
//  LocalStorageOptions.swift
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


// MARK: - LocalStorageOptions

/**
 The `LocalStorageOptions` provides settings that tells the `DataStack` how to setup the persistent store for `LocalStorage` implementers.
 */
public struct LocalStorageOptions: OptionSetType, NilLiteralConvertible {
    
    /**
     Tells the `DataStack` that the store should not be migrated or recreated, and should simply fail on model mismatch
     */
    public static let None = LocalStorageOptions(rawValue: 0)
    
    /**
     Tells the `DataStack` to delete and recreate the store on model mismatch, otherwise exceptions will be thrown on failure instead
     */
    public static let RecreateStoreOnModelMismatch = LocalStorageOptions(rawValue: 1 << 0)
    
    /**
     Tells the `DataStack` to prevent progressive migrations for the store
     */
    public static let PreventProgressiveMigration = LocalStorageOptions(rawValue: 1 << 1)
    
    /**
     Tells the `DataStack` to allow lightweight migration for the store when added synchronously
     */
    public static let AllowSynchronousLightweightMigration = LocalStorageOptions(rawValue: 1 << 2)
    
    
    // MARK: OptionSetType
    
    public init(rawValue: Int) {
        
        self.rawValue = rawValue
    }
    
    
    // MARK: RawRepresentable
    
    public let rawValue: Int
    
    
    // MARK: NilLiteralConvertible
    
    public init(nilLiteral: ()) {
        
        self.rawValue = 0
    }
}
