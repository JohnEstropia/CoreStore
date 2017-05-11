//
//  SchemaHistory.swift
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


// MARK: - SchemaHistory

/**
 The `SchemaHistory` encapsulates multiple `DynamicSchema` across multiple model versions. It contains all model history and is used by the `DataStack` to 
 */
public final class SchemaHistory: ExpressibleByArrayLiteral {
    
    /**
     The version string for the current model version. The `DataStack` will try to migrate all `StorageInterface`s added to itself to this version, following the version steps provided by the `migrationChain`.
     */
    public let currentModelVersion: ModelVersion
    
    /**
     The schema for the current model version. The `DataStack` will try to migrate all `StorageInterface`s added to itself to this version, following the version steps provided by the `migrationChain`.
     */
    public var currentSchema: DynamicSchema {
        
        return self.schema(for: self.currentModelVersion)!
    }
    
    /**
     The version string for the current model version. The `DataStack` will try to migrate all `StorageInterface`s added to itself to this version, following the version steps provided by the `migrationChain`.
     */
    public let migrationChain: MigrationChain
    
    /**
     Initializes a `SchemaHistory` with all models declared in the specified (.xcdatamodeld) model file.
     - Important: Use this initializer only if all model versions are either `XcodeDataModelSchema`s or `LegacyXcodeDataModelSchema`s. Do not use this initializer if even one of the model versions is a `CoreStoreSchema`; use the `SchemaHistory.init(allSchema:migrationChain:exactCurrentModelVersion:)` initializer instead.
     - parameter modelName: the name of the (.xcdatamodeld) model file. If not specified, the application name (CFBundleName) will be used if it exists, or "CoreData" if it the bundle name was not set.
     - parameter bundle: an optional bundle to load models from. If not specified, the main bundle will be used.
     - parameter migrationChain: the `MigrationChain` that indicates the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     */
    public convenience init(modelName: XcodeDataModelFileName, bundle: Bundle = Bundle.main, migrationChain: MigrationChain = nil) {
        
        guard let modelFilePath = bundle.path(forResource: modelName, ofType: "momd") else {
            
            // For users migrating from very old Xcode versions: Old xcdatamodel files are not contained inside xcdatamodeld (with a "d"), and will thus fail this check. If that was the case, create a new xcdatamodeld file and copy all contents into the new model.
            let foundModels = bundle
                .paths(forResourcesOfType: "momd", inDirectory: nil)
                .map({ ($0 as NSString).lastPathComponent })
            CoreStore.abort("Could not find \"\(modelName).momd\" from the bundle \"\(bundle.bundleIdentifier ?? "<nil>")\". Other model files in bundle: \(foundModels.coreStoreDumpString)")
        }
        
        let modelFileURL = URL(fileURLWithPath: modelFilePath)
        let versionInfoPlistURL = modelFileURL.appendingPathComponent("VersionInfo.plist", isDirectory: false)
        
        guard let versionInfo = NSDictionary(contentsOf: versionInfoPlistURL),
            let versionHashes = versionInfo["NSManagedObjectModel_VersionHashes"] as? [String: AnyObject] else {
                
                CoreStore.abort("Could not load \(cs_typeName(NSManagedObjectModel.self)) metadata from path \"\(versionInfoPlistURL)\".")
        }
        
        let modelVersions = Set(versionHashes.keys)
        let modelVersionHints = migrationChain.leafVersions
        let currentModelVersion: String
        if let plistModelVersion = versionInfo["NSManagedObjectModel_CurrentVersionName"] as? String,
            modelVersionHints.isEmpty || modelVersionHints.contains(plistModelVersion) {
            
            currentModelVersion = plistModelVersion
        }
        else if let resolvedVersion = modelVersions.intersection(modelVersionHints).first {
            
            CoreStore.log(
                .warning,
                message: "The \(cs_typeName(MigrationChain.self)) leaf versions do not include the model file's current version. Resolving to version \"\(resolvedVersion)\"."
            )
            currentModelVersion = resolvedVersion
        }
        else if let resolvedVersion = modelVersions.first ?? modelVersionHints.first {
            
            if !modelVersionHints.isEmpty {
                
                CoreStore.log(
                    .warning,
                    message: "The \(cs_typeName(MigrationChain.self)) leaf versions do not include any of the model file's embedded versions. Resolving to version \"\(resolvedVersion)\"."
                )
            }
            currentModelVersion = resolvedVersion
        }
        else {
            
            CoreStore.abort("No model files were found in URL \"\(modelFileURL)\".")
        }
        var allSchema: [DynamicSchema] = []
        for modelVersion in modelVersions {
            
            let fileURL = modelFileURL.appendingPathComponent("\(modelVersion).mom", isDirectory: false)
            allSchema.append(XcodeDataModelSchema(modelName: modelVersion, modelVersionFileURL: fileURL))
        }
        self.init(
            allSchema: allSchema,
            migrationChain: migrationChain,
            exactCurrentModelVersion: currentModelVersion
        )
    }
    
    /**
     Initializes a `SchemaHistory` with a list of `DynamicSchema` and a `MigrationChain` to describe the order of progressive migrations.
     - parameter schema: a `DynamicSchema` that represents a model version
     - parameter otherSchema: a list of `DynamicSchema` that represent other model versions
     - parameter migrationChain: the `MigrationChain` that indicates the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     - parameter exactCurrentModelVersion: an optional string to explicitly select the current model version string. This is useful if the `DataStack` should load a non-latest model version (usually to prepare data before migration). If not provided, the current model version will be computed from the `MigrationChain`.
     */
    public convenience init(_ schema: DynamicSchema, _ otherSchema: DynamicSchema..., migrationChain: MigrationChain = nil, exactCurrentModelVersion: String? = nil) {
        
        self.init(
            allSchema: [schema] + otherSchema,
            migrationChain: migrationChain,
            exactCurrentModelVersion: exactCurrentModelVersion
        )
    }
    
    /**
     Initializes a `SchemaHistory` with a list of `DynamicSchema` and a `MigrationChain` to describe the order of progressive migrations.
     - parameter allSchema: a list of `DynamicSchema` that represent model versions
     - parameter migrationChain: the `MigrationChain` that indicates the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     - parameter exactCurrentModelVersion: an optional string to explicitly select the current model version string. This is useful if the `DataStack` should load a non-latest model version (usually to prepare data before migration). If not provided, the current model version will be computed from the `MigrationChain`.
     */
    public required init(allSchema: [DynamicSchema], migrationChain: MigrationChain = nil, exactCurrentModelVersion: String? = nil) {
        
        if allSchema.isEmpty {
            
            CoreStore.abort("The \"allSchema\" argument of the \(cs_typeName(SchemaHistory.self)) initializer cannot be empty.")
        }
        CoreStore.assert(
            migrationChain.isValid,
            "Invalid migration chain passed to the \(cs_typeName(SchemaHistory.self)). Check that the model versions' order are correct and that no repetitions or ambiguities exist."
        )
        var schemaByVersion: [ModelVersion: DynamicSchema] = [:]
        for schema in allSchema {
            
            let modelVersion = schema.modelVersion
            CoreStore.assert(
                schemaByVersion[modelVersion] == nil,
                "Multiple model schema found for model version \"\(modelVersion)\"."
            )
            schemaByVersion[modelVersion] = schema
        }
        let modelVersions = Set(schemaByVersion.keys)
        let currentModelVersion: ModelVersion
        if let exactCurrentModelVersion = exactCurrentModelVersion {
            
            if !migrationChain.isEmpty && !migrationChain.contains(exactCurrentModelVersion) {
                
                CoreStore.abort("An \"exactCurrentModelVersion\" argument was provided to \(cs_typeName(SchemaHistory.self)) initializer but a matching schema could not be found from the provided \(cs_typeName(MigrationChain.self)).")
            }
            if schemaByVersion[exactCurrentModelVersion] == nil {
                
                CoreStore.abort("An \"exactCurrentModelVersion\" argument was provided to \(cs_typeName(SchemaHistory.self)) initializer but a matching schema could not be found from the \(cs_typeName(DynamicSchema.self)) list.")
            }
            currentModelVersion = exactCurrentModelVersion
        }
        else if migrationChain.isEmpty && schemaByVersion.count == 1 {
            
            currentModelVersion = schemaByVersion.keys.first!
        }
        else {
            
            let candidateVersions = modelVersions.intersection(migrationChain.leafVersions)
            switch candidateVersions.count {
                
            case 0:
                CoreStore.abort("None of the \(cs_typeName(MigrationChain.self)) leaf versions provided to the \(cs_typeName(SchemaHistory.self)) initializer matches any scheme from the \(cs_typeName(DynamicSchema.self)) list.")
                
            case 1:
                currentModelVersion = candidateVersions.first!
                
            default:
                CoreStore.abort("Could not resolve the \(cs_typeName(SchemaHistory.self)) current model version because the \(cs_typeName(MigrationChain.self)) have ambiguous leaf versions: \(candidateVersions)")
            }
        }
        
        self.schemaByVersion = schemaByVersion
        self.migrationChain = migrationChain
        self.currentModelVersion = currentModelVersion
        self.rawModel = schemaByVersion[currentModelVersion]!.rawModel()
    }
    
    
    // MARK: ExpressibleByArrayLiteral
    
    public typealias Element = DynamicSchema
    
    public convenience init(arrayLiteral elements: DynamicSchema...) {

        self.init(
            allSchema: elements,
            migrationChain: MigrationChain(elements.map({ $0.modelVersion })),
            exactCurrentModelVersion: nil
        )
    }
    
    
    // MARK: Internal
    
    internal let schemaByVersion: [ModelVersion: DynamicSchema]
    internal let rawModel: NSManagedObjectModel
    
    internal private(set) lazy var entityDescriptionsByEntityIdentifier: [EntityIdentifier: NSEntityDescription] = cs_lazy { [unowned self] in
        
        var mapping: [EntityIdentifier: NSEntityDescription] = [:]
        self.rawModel.entities.forEach { (entityDescription) in
            
            let entityIdentifier = EntityIdentifier(entityDescription)
            mapping[entityIdentifier] = entityDescription
        }
        return mapping
    }
    
    internal func rawModel(for modelVersion: ModelVersion) -> NSManagedObjectModel? {
        
        if modelVersion == self.currentModelVersion {
            
            return self.rawModel
        }
        return self.schemaByVersion[modelVersion]?.rawModel()
    }
    
    internal func schema(for modelVersion: ModelVersion) -> DynamicSchema? {
        
        return self.schemaByVersion[modelVersion]
    }
    
    internal func schema(for storeMetadata: [String: Any]) -> DynamicSchema? {
        
        guard let modelHashes = storeMetadata[NSStoreModelVersionHashesKey] as! [String: Data]? else {
            
            return nil
        }
        for (_, schema) in self.schemaByVersion {
            
            let rawModel = schema.rawModel()
            if modelHashes == rawModel.entityVersionHashesByName {
                
                return schema
            }
        }
        return nil
    }
    
    internal func mergedModels() -> [NSManagedObjectModel] {
        
        return self.schemaByVersion.values.map({ $0.rawModel() })
    }
}
