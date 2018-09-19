//
//  InferredSchemaMappingProvider.swift
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

import CoreData
import Foundation


// MARK: - InferredSchemaMappingProvider

/**
 A `SchemaMappingProvider` that tries to infer model migration between two `DynamicSchema` versions by searching all `xcmappingmodel`s from `Bundle.allBundles` or by relying on lightweight migration if possible. Throws an error if lightweight migration is impossible for the two `DynamicSchema`. This mapping is automatically used as a fallback mapping provider, even if no mapping providers are explicitly declared in the `StorageInterface`.
 */
public final class InferredSchemaMappingProvider: Hashable, SchemaMappingProvider {
    
    // MARK: Equatable
    
    public static func == (lhs: InferredSchemaMappingProvider, rhs: InferredSchemaMappingProvider) -> Bool {
        
        return true
    }
    
    
    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {

        hasher.combine(ObjectIdentifier(type(of: self)))
    }
    
    
    // MARK: SchemaMappingProvider
    
    public func cs_createMappingModel(from sourceSchema: DynamicSchema, to destinationSchema: DynamicSchema, storage: LocalStorage) throws -> (mappingModel: NSMappingModel, migrationType: MigrationType) {
        
        let sourceModel = sourceSchema.rawModel()
        let destinationModel = destinationSchema.rawModel()
        
        if let mappingModel = NSMappingModel(
            from: Bundle.allBundles,
            forSourceModel: sourceModel,
            destinationModel: destinationModel) {
            
            return (
                mappingModel,
                .heavyweight(
                    sourceVersion: sourceSchema.modelVersion,
                    destinationVersion: destinationSchema.modelVersion
                )
            )
        }
        do {
            
            let mappingModel = try NSMappingModel.inferredMappingModel(
                forSourceModel: sourceModel,
                destinationModel: destinationModel
            )
            return (
                mappingModel,
                .lightweight(
                    sourceVersion: sourceSchema.modelVersion,
                    destinationVersion: destinationSchema.modelVersion
                )
            )
        }
        catch {
            
            throw CoreStoreError(error)
        }
    }
}
