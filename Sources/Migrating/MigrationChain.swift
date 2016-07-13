//
//  MigrationChain.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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


// MARK: - MigrationChain

/**
 A `MigrationChain` indicates the sequence of model versions to be used as the order for progressive migrations. This is typically passed to the `DataStack` initializer and will be applied to all stores added to the `DataStack` with `addSQLiteStore(...)` and its variants.
 
 Initializing with empty values (either `nil`, `[]`, or `[:]`) instructs the `DataStack` to use the .xcdatamodel's current version as the final version, and to disable progressive migrations:
 ```
 let dataStack = DataStack(migrationChain: nil)
 ```
 This means that the mapping model will be computed from the store's version straight to the `DataStack`'s model version.
 To support progressive migrations, specify the linear order of versions:
 ```
 let dataStack = DataStack(migrationChain:
    ["MyAppModel", "MyAppModelV2", "MyAppModelV3", "MyAppModelV4"])
 ```
 or for more complex migration paths, a version tree that maps the key-values to the source-destination versions:
 ```
 let dataStack = DataStack(migrationChain: [
     "MyAppModel": "MyAppModelV3",
     "MyAppModelV2": "MyAppModelV4",
     "MyAppModelV3": "MyAppModelV4"
 ])
 ```
 This allows for different migration paths depending on the starting version. The example above resolves to the following paths:
 - MyAppModel-MyAppModelV3-MyAppModelV4
 - MyAppModelV2-MyAppModelV4
 - MyAppModelV3-MyAppModelV4
 
 The `MigrationChain` is validated when passed to the `DataStack` and unless it is empty, will raise an assertion if any of the following conditions are met:
 - a version appears twice in an array
 - a version appears twice as a key in a dictionary literal
 - a loop is found in any of the paths
 */
public struct MigrationChain: NilLiteralConvertible, StringLiteralConvertible, DictionaryLiteralConvertible, ArrayLiteralConvertible, Equatable {
    
    /**
     Initializes the `MigrationChain` with empty values, which instructs the `DataStack` to use the .xcdatamodel's current version as the final version, and to disable progressive migrations.
    */
    public init() {
        
        self.versionTree = [:]
        self.rootVersions = []
        self.leafVersions = []
        self.valid = true
    }
    
    /**
     Initializes the `MigrationChain` with a single model version, which instructs the `DataStack` to use the the specified version as the final version, and to disable progressive migrations.
     */
    public init(_ value: String) {
        
        self.versionTree = [:]
        self.rootVersions = [value]
        self.leafVersions = [value]
        self.valid = true
    }
    
    /**
     Initializes the `MigrationChain` with a linear order of versions, which becomes the order of the `DataStack`'s progressive migrations.
     */
    public init<T: CollectionType where T.Generator.Element == String, T.Index: BidirectionalIndexType>(_ elements: T) {
        
        CoreStore.assert(Set(elements).count == Array(elements).count, "\(cs_typeName(MigrationChain))'s migration chain could not be created due to duplicate version strings.")
        
        var lastVersion: String?
        var versionTree = [String: String]()
        var valid = true
        for version in elements {
            
            if let lastVersion = lastVersion,
                let _ = versionTree.updateValue(version, forKey: lastVersion) {
                
                valid = false
            }
            lastVersion = version
        }
        
        self.versionTree = versionTree
        self.rootVersions = Set([elements.first].flatMap { $0 == nil ? [] : [$0!] })
        self.leafVersions = Set([elements.last].flatMap { $0 == nil ? [] : [$0!] })
        self.valid = valid
    }
    
    /**
     Initializes the `MigrationChain` with a version tree, which becomes the order of the `DataStack`'s progressive migrations.
     */
    public init(_ elements: [(String, String)]) {
        
        var valid = true
        var versionTree = [String: String]()
        elements.forEach { (sourceVersion, destinationVersion) in
            
            guard let _ = versionTree.updateValue(destinationVersion, forKey: sourceVersion) else {
                
                return
            }
            
            CoreStore.assert(false, "\(cs_typeName(MigrationChain))'s migration chain could not be created due to ambiguous version paths.")
            
            valid = false
        }
        let leafVersions = Set(
            elements
                .filter { versionTree[$1] == nil }
                .map { $1 }
        )
        
        let isVersionAmbiguous = { (start: String) -> Bool in
            
            var checklist: Set<String> = [start]
            var version = start
            while let nextVersion = versionTree[version] where nextVersion != version {
                
                if checklist.contains(nextVersion) {
                    
                    CoreStore.assert(false, "\(cs_typeName(MigrationChain))'s migration chain could not be created due to looping version paths.")
                    
                    return true
                }
                checklist.insert(nextVersion)
                version = nextVersion
            }
            
            return false
        }
        
        self.versionTree = versionTree
        self.rootVersions = Set(versionTree.keys).subtract(versionTree.values)
        self.leafVersions = leafVersions
        self.valid = valid && Set(versionTree.keys).union(versionTree.values).filter { isVersionAmbiguous($0) }.count <= 0
    }
    
    /**
     Initializes the `MigrationChain` with a version tree, which becomes the order of the `DataStack`'s progressive migrations.
     */
    public init(_ dictionary: [String: String]) {
        
        self.init(dictionary.map { $0 })
    }
    
    
    // MARK: NilLiteralConvertible
    
    public init(nilLiteral: ()) {
        
        self.init()
    }
    
    
    // MARK: StringLiteralConvertible
    
    public init(stringLiteral value: String) {
        
        self.init(value)
    }
    
    
    // MARK: ExtendedGraphemeClusterLiteralConvertible
    
    public init(extendedGraphemeClusterLiteral value: String) {
        
        self.init(value)
    }
    
    
    // MARK: UnicodeScalarLiteralConvertible
    
    public init(unicodeScalarLiteral value: String) {
        
        self.init(value)
    }
    
    
    // MARK: DictionaryLiteralConvertible
    
    public init(dictionaryLiteral elements: (String, String)...) {
        
        self.init(elements)
    }
    
    
    // MARK: ArrayLiteralConvertible
    
    public init(arrayLiteral elements: String...) {
        
        self.init(elements)
    }
    
    
    // MARK: Internal
    
    internal let rootVersions: Set<String>
    internal let leafVersions: Set<String>
    internal let valid: Bool
    
    internal var empty: Bool {
        
        return self.versionTree.count <= 0
    }
    
    internal func contains(version: String) -> Bool {
        
        return self.rootVersions.contains(version)
            || self.leafVersions.contains(version)
            || self.versionTree[version] != nil
    }
    
    internal func nextVersionFrom(version: String) -> String? {
        
        guard let nextVersion = self.versionTree[version] where nextVersion != version else {
            
            return nil
        }
        return nextVersion
    }
    
    
    // MARK: Private
    
    private let versionTree: [String: String]
}


// MARK: - MigrationChain: Equatable

@warn_unused_result
public func == (lhs: MigrationChain, rhs: MigrationChain) -> Bool {
    
    return lhs.versionTree == rhs.versionTree
        && lhs.rootVersions == rhs.rootVersions
        && lhs.leafVersions == rhs.leafVersions
        && lhs.valid == rhs.valid
}

