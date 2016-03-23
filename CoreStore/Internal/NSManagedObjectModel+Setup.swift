//
//  NSManagedObjectModel+Setup.swift
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


// MARK: - NSManagedObjectModel

internal extension NSManagedObjectModel {
    
    // MARK: Internal
    
    @nonobjc internal class func fromBundle(bundle: NSBundle, modelName: String, modelVersionHints: Set<String> = []) -> NSManagedObjectModel {
        
        guard let modelFilePath = bundle.pathForResource(modelName, ofType: "momd") else {
            
            fatalError("Could not find \"\(modelName).momd\" from the bundle. \(bundle)")
        }
        
        let modelFileURL = NSURL(fileURLWithPath: modelFilePath)
        let versionInfoPlistURL = modelFileURL.URLByAppendingPathComponent("VersionInfo.plist", isDirectory: false)
        
        guard let versionInfo = NSDictionary(contentsOfURL: versionInfoPlistURL),
            let versionHashes = versionInfo["NSManagedObjectModel_VersionHashes"] as? [String: AnyObject] else {
                
                fatalError("Could not load \(typeName(NSManagedObjectModel)) metadata from path \"\(versionInfoPlistURL)\".")
        }
        
        let modelVersions = Set(versionHashes.keys)
        let currentModelVersion: String
        if let plistModelVersion = versionInfo["NSManagedObjectModel_CurrentVersionName"] as? String where modelVersionHints.isEmpty || modelVersionHints.contains(plistModelVersion) {
            
            currentModelVersion = plistModelVersion
        }
        else if let resolvedVersion = modelVersions.intersect(modelVersionHints).first {
            
            CoreStore.log(
                .Warning,
                message: "The MigrationChain leaf versions do not include the model file's current version. Resolving to version \"\(resolvedVersion)\"."
            )
            currentModelVersion = resolvedVersion
        }
        else if let resolvedVersion = modelVersions.first ?? modelVersionHints.first {
            
            if !modelVersionHints.isEmpty {
                
                CoreStore.log(
                    .Warning,
                    message: "The MigrationChain leaf versions do not include any of the model file's embedded versions. Resolving to version \"\(resolvedVersion)\"."
                )
            }
            currentModelVersion = resolvedVersion
        }
        else {
            
            fatalError("No model files were found in URL \"\(modelFileURL)\".")
        }
        
        var modelVersionFileURL: NSURL?
        for modelVersion in modelVersions {
            
            let fileURL = modelFileURL.URLByAppendingPathComponent("\(modelVersion).mom", isDirectory: false)
            
            if modelVersion == currentModelVersion {
                
                modelVersionFileURL = fileURL
                continue
            }
            
            precondition(
                NSManagedObjectModel(contentsOfURL: fileURL) != nil,
                "Could not find the \"\(modelVersion).mom\" version file for the model at URL \"\(modelFileURL)\"."
            )
        }
        
        if let modelVersionFileURL = modelVersionFileURL,
            let rootModel = NSManagedObjectModel(contentsOfURL: modelVersionFileURL) {
                
                rootModel.modelVersionFileURL = modelVersionFileURL
                rootModel.modelVersions = modelVersions
                rootModel.currentModelVersion = currentModelVersion
                return rootModel
        }
        
        fatalError("Could not create an \(typeName(NSManagedObjectModel)) from the model at URL \"\(modelFileURL)\".")
    }
    
    @nonobjc private(set) internal var currentModelVersion: String? {
        
        get {
            
            let value: NSString? = getAssociatedObjectForKey(
                &PropertyKeys.currentModelVersion,
                inObject: self
            )
            return value as? String
        }
        set {
            
            setAssociatedCopiedObject(
                newValue == nil ? nil : (newValue! as NSString),
                forKey: &PropertyKeys.currentModelVersion,
                inObject: self
            )
        }
    }
    
    @nonobjc private(set) internal var modelVersions: Set<String>? {
        
        get {
            
            let value: NSSet? = getAssociatedObjectForKey(
                &PropertyKeys.modelVersions,
                inObject: self
            )
            return value as? Set<String>
        }
        set {
            
            setAssociatedCopiedObject(
                newValue == nil ? nil : (newValue! as NSSet),
                forKey: &PropertyKeys.modelVersions,
                inObject: self
            )
        }
    }
    
    @nonobjc internal func entityNameForClass(entityClass: AnyClass) -> String {
        
        return self.entityNameMapping[NSStringFromClass(entityClass)]!
    }
    
    @nonobjc internal func entityTypesMapping() -> [String: NSManagedObject.Type] {
        
        var mapping = [String: NSManagedObject.Type]()
        self.entityNameMapping.forEach { (className, entityName) in
            
            mapping[entityName] = (NSClassFromString(className)! as! NSManagedObject.Type)
        }
        return mapping
    }
    
    @nonobjc internal func mergedModels() -> [NSManagedObjectModel] {
        
        return self.modelVersions?.map { self[$0] }.flatMap { $0 == nil ? [] : [$0!] } ?? [self]
    }
    
    @nonobjc internal subscript(modelVersion: String) -> NSManagedObjectModel? {
        
        if modelVersion == self.currentModelVersion {
            
            return self
        }
        
        guard let modelFileURL = self.modelFileURL,
            let modelVersions = self.modelVersions
            where modelVersions.contains(modelVersion) else {
                
                return nil
        }
        
        let versionModelFileURL = modelFileURL.URLByAppendingPathComponent("\(modelVersion).mom", isDirectory: false)
        guard let model = NSManagedObjectModel(contentsOfURL: versionModelFileURL) else {
            
            return nil
        }
        
        model.currentModelVersion = modelVersion
        model.modelVersionFileURL = versionModelFileURL
        model.modelVersions = modelVersions
        return model
    }
    
    @nonobjc internal subscript(metadata: [String: AnyObject]) -> NSManagedObjectModel? {
        
        guard let modelHashes = metadata[NSStoreModelVersionHashesKey] as? [String : NSData] else {
            
            return nil
        }
        for modelVersion in self.modelVersions ?? [] {
            
            if let versionModel = self[modelVersion] where modelHashes == versionModel.entityVersionHashesByName {
                
                return versionModel
            }
        }
        return nil
    }
    
    
    // MARK: Private
    
    private var modelFileURL: NSURL? {
        
        get {
            
            return self.modelVersionFileURL?.URLByDeletingLastPathComponent
        }
    }
    
    private var modelVersionFileURL: NSURL? {
        
        get {
            
            let value: NSURL? = getAssociatedObjectForKey(
                &PropertyKeys.modelVersionFileURL,
                inObject: self
            )
            return value
        }
        set {
            
            setAssociatedCopiedObject(
                newValue,
                forKey: &PropertyKeys.modelVersionFileURL,
                inObject: self
            )
        }
    }
    
    private var entityNameMapping: [String: String] {
        
        get {
            
            if let mapping: NSDictionary = getAssociatedObjectForKey(&PropertyKeys.entityNameMapping, inObject: self) {
                
                return mapping as! [String: String]
            }
            
            var mapping = [String: String]()
            self.entities.forEach {
                
                guard let entityName = $0.name else {
                    
                    return
                }
                
                let className = $0.managedObjectClassName
                mapping[className] = entityName
            }
            setAssociatedCopiedObject(
                mapping as NSDictionary,
                forKey: &PropertyKeys.entityNameMapping,
                inObject: self
            )
            return mapping
        }
    }
    
    private struct PropertyKeys {
        
        static var entityNameMapping: Void?
        
        static var modelVersionFileURL: Void?
        static var modelVersions: Void?
        static var currentModelVersion: Void?
    }
}
