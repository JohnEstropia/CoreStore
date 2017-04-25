//
//  MigrationMappingProvider.swift
//  CoreStore
//
//  Copyright © 2017 John Rommel Estropia
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
import Foundation


// MARK: - SchemaMappingProvider

public protocol SchemaMappingProvider {
    
    var sourceSchema: DynamicSchema { get }
    var destinationSchema: DynamicSchema { get }
    
    func createMappingModel() throws -> (mappingModel: NSMappingModel, migrationType: MigrationType)
}

public protocol EntityMappingProvider {
    
    var source: (schema: DynamicSchema, entity: DynamicEntity) { get }
    var destination: (schema: DynamicSchema, entity: DynamicEntity) { get }
    
    func createEntityMapping() -> NSEntityMapping
}


// MARK: - XcodeMappingModelProvider

open class XcodeMappingModelProvider<S: DynamicSchema, D: DynamicSchema>: SchemaMappingProvider {
    
    private let mappingModelBundles: [Bundle]
    
    public required init(source: SourceSchema, destination: DestinationSchema, mappingModelBundles: [Bundle] = Bundle.allBundles) {
        
        self.sourceSchema = source
        self.destinationSchema = destination
        self.mappingModelBundles = mappingModelBundles
    }
    
    
    // MARK: SchemaMappingProvider
    
    public typealias SourceSchema = S
    public typealias DestinationSchema = D
    
    public let sourceSchema: SourceSchema
    public let destinationSchema: DestinationSchema
    
    public func createMappingModel() throws -> (mappingModel: NSMappingModel, migrationType: MigrationType) {
        
        let sourceModel = self.sourceSchema.rawModel()
        let destinationModel = self.destinationSchema.rawModel()
        
        if let mappingModel = NSMappingModel(
            from: self.mappingModelBundles,
            forSourceModel: sourceModel,
            destinationModel: destinationModel) {
            
            return (
                mappingModel,
                .heavyweight(
                    sourceVersion: self.sourceSchema.modelVersion,
                    destinationVersion: self.destinationSchema.modelVersion
                )
            )
        }
        
        let mappingModel = try NSMappingModel.inferredMappingModel(
            forSourceModel: sourceModel,
            destinationModel: destinationModel
        )
        return (
            mappingModel,
            .lightweight(
                sourceVersion: self.sourceSchema.modelVersion,
                destinationVersion: self.destinationSchema.modelVersion
            )
        )
    }
}


// MARK: - UnsafeMigrationProxyObject

public final class UnsafeMigrationProxyObject {
    
    public subscript(kvcKey: KeyPath) -> Any? {
        
        get {
            
            return self.rawObject.cs_accessValueForKVCKey(kvcKey)
        }
        set {
            
            self.rawObject.cs_setValue(newValue, forKVCKey: kvcKey)
        }
    }
    
    
    // MARK: Internal
    
    internal init(_ rawObject: NSManagedObject) {
        
        self.rawObject = rawObject
    }
    
    
    // MARK: Private
    
    private let rawObject: NSManagedObject
}
