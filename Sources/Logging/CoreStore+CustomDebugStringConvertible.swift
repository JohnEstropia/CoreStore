//
//  CoreStore+CustomDebugStringConvertible.swift
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


// MARK: - AsynchronousDataTransaction

extension AsynchronousDataTransaction: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpInfo: DumpInfo {
        
        return [
            ("context", self.context),
            ("supportsUndo", self.supportsUndo),
            ("bypassesQueueing", self.bypassesQueueing),
            ("isCommitted", self.isCommitted),
            ("result", self.result)
        ]
    }
}


// MARK: - CloudStorageOptions

extension CloudStorageOptions: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpValue: String {
        
        var flags = [String]()
        if self.contains(.RecreateLocalStoreOnModelMismatch) {
            
            flags.append(".RecreateLocalStoreOnModelMismatch")
        }
        if self.contains(.AllowSynchronousLightweightMigration) {
            
            flags.append(".AllowSynchronousLightweightMigration")
        }
        switch flags.count {
            
        case 0:
            return "[.None]"
            
        case 1:
            return "[.\(flags[0])]"
            
        default:
            let description = "[\n" + flags.joinWithSeparator(",\n")
            return description.indent(1) + "\n]"
        }
    }
}


// MARK: - CoreStoreError

extension CoreStoreError: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpValue: String {
        
        switch self {
            
        case .Unknown:                      return ".Unknown"
        case .DifferentStorageExistsAtURL:  return ".DifferentStorageExistsAtURL"
        case .MappingModelNotFound:         return ".MappingModelNotFound"
        case .ProgressiveMigrationRequired: return ".ProgressiveMigrationRequired"
        case .InternalError:                return ".InternalError"
        }
    }
    
    private var cs_dumpInfo: DumpInfo {
        
        var info: DumpInfo = [
            ("_domain", self._domain),
            ("_code", self._code),
        ]
        switch self {
            
        case .Unknown:
            break
            
        case .DifferentStorageExistsAtURL(let existingPersistentStoreURL):
            info.append(("existingPersistentStoreURL", existingPersistentStoreURL))
            
        case .MappingModelNotFound(let localStoreURL, let targetModel, let targetModelVersion):
            info.append(("localStoreURL", localStoreURL))
            info.append(("targetModel", targetModel))
            info.append(("targetModelVersion", targetModelVersion))
            
        case .ProgressiveMigrationRequired(let localStoreURL):
            info.append(("localStoreURL", localStoreURL))
            
        case .InternalError(let NSError):
            info.append(("NSError", NSError))
        }
        return info
    }
}


// MARK: - DataStack

extension DataStack: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpInfo: DumpInfo {
        
        // TODO: print entities and persistentStores
        return [
            ("coordinator", self.coordinator),
            ("rootSavingContext", self.rootSavingContext),
            ("mainContext", self.mainContext),
            ("model", self.model),
            ("migrationChain", self.migrationChain)
        ]
    }
}


// MARK: - ICloudStore

extension ICloudStore: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpInfo: DumpInfo {
        
        return [
            ("configuration", self.configuration),
            ("storeOptions", self.storeOptions),
            ("cacheFileURL", self.cacheFileURL),
            ("cloudStorageOptions", self.cloudStorageOptions)
        ]
    }
}


// MARK: - InMemoryStore

extension InMemoryStore: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpInfo: DumpInfo {
        
        return [
            ("configuration", self.configuration),
            ("storeOptions", self.storeOptions)
        ]
    }
}


// MARK: - Into

extension Into: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpInfo: DumpInfo {
        
        return [
            ("entityClass", self.entityClass),
            ("configuration", self.configuration),
            ("inferStoreIfPossible", self.inferStoreIfPossible)
        ]
    }
}


// MARK: - LegacySQLiteStore

extension LegacySQLiteStore: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpInfo: DumpInfo {
        
        return [
            ("configuration", self.configuration),
            ("storeOptions", self.storeOptions),
            ("fileURL", self.fileURL),
            ("mappingModelBundles", self.mappingModelBundles),
            ("localStorageOptions", self.localStorageOptions)
        ]
    }
}


// MARK: - LocalStorageOptions
 
extension LocalStorageOptions: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpValue: String {
     
        var flags = [String]()
        if self.contains(.RecreateStoreOnModelMismatch) {
            
            flags.append(".RecreateStoreOnModelMismatch")
        }
        if self.contains(.PreventProgressiveMigration) {
            
            flags.append(".PreventProgressiveMigration")
        }
        if self.contains(.AllowSynchronousLightweightMigration) {
            
            flags.append(".AllowSynchronousLightweightMigration")
        }
        switch flags.count {
            
        case 0:
            return "[.None]"
            
        case 1:
            return "[.\(flags[0])]"
            
        default:
            let description = "[\n" + flags.joinWithSeparator(",\n")
            return description.indent(1) + "\n]"
        }
    }
}


// MARK: - MigrationChain

extension MigrationChain: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpValue: String {
        
        guard self.valid else {
            
            return "<invalid migration chain>"
        }
        
        var paths = [String]()
        for var version in self.rootVersions {
            
            var steps = [version]
            while let nextVersion = self.nextVersionFrom(version) {
                
                steps.append(nextVersion)
                version = nextVersion
            }
            paths.append(steps.joinWithSeparator(" → "))
        }
        switch paths.count {
            
        case 0:
            return "[]"
            
        case 1:
            return "[\(paths[0])]"
            
        default:
            var dump = "["
            paths.forEach {
                
                dump.appendContentsOf("\n\($0);")
            }
            return dump.indent(1) + "\n]"
        }
    }
}


// MARK: - SQLiteStore

extension SQLiteStore: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpInfo: DumpInfo {
        
        return [
            ("configuration", self.configuration),
            ("storeOptions", self.storeOptions),
            ("fileURL", self.fileURL),
            ("mappingModelBundles", self.mappingModelBundles),
            ("localStorageOptions", self.localStorageOptions)
        ]
    }
}


// MARK: - SynchronousDataTransaction

extension SynchronousDataTransaction: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpInfo: DumpInfo {
        
        return [
            ("context", self.context),
            ("supportsUndo", self.supportsUndo),
            ("bypassesQueueing", self.bypassesQueueing),
            ("isCommitted", self.isCommitted),
            ("result", self.result)
        ]
    }
}


// MARK: - UnsafeDataTransaction

extension UnsafeDataTransaction: CustomDebugStringConvertible, IndentableDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.cs_dump()
    }
    
    
    // MARK: IndentableDebugStringConvertible
    
    private var cs_dumpInfo: DumpInfo {
        
        return [
            ("context", self.context),
            ("supportsUndo", self.supportsUndo)
        ]
    }
}


// MARK: - Private: Utilities

private typealias DumpInfo = [(key: String, value: Any)]

private func formattedValue(any: Any) -> String {
    
    if let any = any as? IndentableDebugStringConvertible {
        
        return formattedValue(any)
    }
    return "\(any)"
}

private func formattedValue(any: IndentableDebugStringConvertible) -> String {
    
    return any.cs_dumpValue
}

private extension String {
    
    private static func indention(level: Int = 1) -> String {
        
        return String(count: level * 4, repeatedValue: Character(" "))
    }
    
    private func trimSwiftModuleName() -> String {
        
        if self.hasPrefix("Swift.") {
            
            return self.substringFromIndex("Swift.".endIndex)
        }
        return self
    }
    
    private func indent(level: Int) -> String {
        
        return self.stringByReplacingOccurrencesOfString("\n", withString: "\n\(String.indention(level))")
    }
    
    private mutating func appendDumpInfo(key: String, _ value: Any) {
        
        self.appendContentsOf("\n.\(key) = \(formattedValue(value));")
    }
    
    private mutating func appendDumpInfo(key: String, _ value: IndentableDebugStringConvertible) {
        
        self.appendContentsOf("\n.\(key) = \(formattedValue(value));")
    }
}


// MARK: - Private: IndentableDebugStringConvertible

private protocol IndentableDebugStringConvertible {
    
    static func cs_typeString() -> String
    
    var cs_dumpValue: String { get }
    var cs_dumpInfo: DumpInfo { get }
    
    func cs_dump() -> String
}

private extension IndentableDebugStringConvertible {
    
    private static func cs_typeString() -> String {
        
        return String(reflecting: self)
    }
    
    private var cs_dumpValue: String {
        
        return ""
    }
    
    private var cs_dumpInfo: DumpInfo {
    
        return []
    }
    
    private func cs_dump() -> String {
        
        let value = self.cs_dumpValue
        let info = self.cs_dumpInfo
        
        var dump = "(\(self.dynamicType.cs_typeString()))"
        if !value.isEmpty {
            
            dump.appendContentsOf(" \(value)")
        }
        if info.isEmpty {
            
            return dump
        }
        else {
            
            dump.appendContentsOf(" {")
            info.forEach {
                
                dump.appendDumpInfo($0, $1)
            }
            return dump.indent(1) + "\n}"
        }
    }
}


// MARK: -

extension Array: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        var string = "\(self.count) items ["
        if self.isEmpty {
            
            string.appendContentsOf("]")
            return string
        }
        else {
            
            for (index, item) in self.enumerate() {
                
                string.appendContentsOf("\n\(index) = \(formattedValue(item));")
            }
            return string.indent(1) + "\n]"
        }
    }
}

extension Dictionary: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        var string = "\(self.count) key-values ["
        if self.isEmpty {
            
            string.appendContentsOf("]")
            return string
        }
        else {
            
            for (key, value) in self {
                
                string.appendContentsOf("\n\(formattedValue(key)) = \(formattedValue(value));")
            }
            return string.indent(1) + "\n]"
        }
    }
}

extension NSAttributeDescription: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        var string = "{"
        
        string.appendDumpInfo("attributeType", self.attributeType)
        string.appendDumpInfo("attributeValueClassName", self.attributeValueClassName)
        string.appendDumpInfo("defaultValue", self.defaultValue)
        string.appendDumpInfo("valueTransformerName", self.valueTransformerName)
        string.appendDumpInfo("allowsExternalBinaryDataStorage", self.allowsExternalBinaryDataStorage)
        
        string.appendDumpInfo("entity", self.entity.name)
        string.appendDumpInfo("name", self.name)
        string.appendDumpInfo("optional", self.optional)
        string.appendDumpInfo("transient", self.transient)
        string.appendDumpInfo("userInfo", self.userInfo)
        string.appendDumpInfo("indexed", self.indexed)
        string.appendDumpInfo("versionHash", self.versionHash)
        string.appendDumpInfo("versionHashModifier", self.versionHashModifier)
        string.appendDumpInfo("indexedBySpotlight", self.indexedBySpotlight)
        string.appendDumpInfo("storedInExternalRecord", self.storedInExternalRecord)
        string.appendDumpInfo("renamingIdentifier", self.renamingIdentifier)
        
        return string.indent(1) + "\n}"
    }
}

extension NSAttributeType: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        switch self {
            
        case .UndefinedAttributeType:       return ".UndefinedAttributeType"
        case .Integer16AttributeType:       return ".Integer16AttributeType"
        case .Integer32AttributeType:       return ".Integer32AttributeType"
        case .Integer64AttributeType:       return ".Integer64AttributeType"
        case .DecimalAttributeType:         return ".DecimalAttributeType"
        case .DoubleAttributeType:          return ".DoubleAttributeType"
        case .FloatAttributeType:           return ".FloatAttributeType"
        case .StringAttributeType:          return ".StringAttributeType"
        case .BooleanAttributeType:         return ".BooleanAttributeType"
        case .DateAttributeType:            return ".DateAttributeType"
        case .BinaryDataAttributeType:      return ".BinaryDataAttributeType"
        case .TransformableAttributeType:   return ".TransformableAttributeType"
        case .ObjectIDAttributeType:        return ".ObjectIDAttributeType"
        }
    }
}

extension NSBundle: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\(self.bundleIdentifier.flatMap({ "\"\($0)\"" }) ?? "<unknown bundle identifier>") (\(self.bundleURL.lastPathComponent ?? "<unknown bundle URL>"))"
    }
}

extension NSDeleteRule: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        switch self {
            
        case .NoActionDeleteRule:   return ".NoActionDeleteRule"
        case .NullifyDeleteRule:    return ".NullifyDeleteRule"
        case .CascadeDeleteRule:    return ".CascadeDeleteRule"
        case .DenyDeleteRule:       return ".DenyDeleteRule"
        }
    }
}

extension NSEntityDescription: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        var string = "{"
        string.appendDumpInfo("managedObjectClassName", self.managedObjectClassName!)
        string.appendDumpInfo("name", self.name)
        string.appendDumpInfo("abstract", self.abstract)
        string.appendDumpInfo("superentity", self.superentity?.name)
        string.appendDumpInfo("subentities", self.subentities.map({ $0.name }))
        string.appendDumpInfo("properties", self.properties)
        string.appendDumpInfo("userInfo", self.userInfo)
        string.appendDumpInfo("versionHash", self.versionHash)
        string.appendDumpInfo("versionHashModifier", self.versionHashModifier)
        string.appendDumpInfo("renamingIdentifier", self.renamingIdentifier)
        string.appendDumpInfo("compoundIndexes", self.compoundIndexes)
        if #available(iOS 9.0, *) {
            
            string.appendDumpInfo("uniquenessConstraints", self.uniquenessConstraints)
        }
        return string.indent(1) + "\n}"
    }
}

extension NSError: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        var string = "{"
        string.appendDumpInfo("domain", self.domain)
        string.appendDumpInfo("code", self.code)
        string.appendDumpInfo("userInfo", self.userInfo)
        return string.indent(1) + "\n}"
    }
}

extension NSManagedObjectModel: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        var string = "{"
        string.appendDumpInfo("configurations", self.configurations)
        string.appendDumpInfo("entities", self.entities)
        return string.indent(1) + "\n}"
    }
}

extension NSMappingModel: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\(self)"
    }
}

extension NSRelationshipDescription: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        var string = "{"
        
        string.appendDumpInfo("destinationEntity", self.destinationEntity?.name)
        string.appendDumpInfo("inverseRelationship", self.inverseRelationship?.name)
        string.appendDumpInfo("minCount", self.minCount)
        string.appendDumpInfo("maxCount", self.maxCount)
        string.appendDumpInfo("deleteRule", self.deleteRule)
        string.appendDumpInfo("toMany", self.toMany)
        string.appendDumpInfo("ordered", self.ordered)
        
        string.appendDumpInfo("entity", self.entity.name)
        string.appendDumpInfo("name", self.name)
        string.appendDumpInfo("optional", self.optional)
        string.appendDumpInfo("transient", self.transient)
        string.appendDumpInfo("userInfo", self.userInfo)
        string.appendDumpInfo("indexed", self.indexed)
        string.appendDumpInfo("versionHash", self.versionHash)
        string.appendDumpInfo("versionHashModifier", self.versionHashModifier)
        string.appendDumpInfo("indexedBySpotlight", self.indexedBySpotlight)
        string.appendDumpInfo("storedInExternalRecord", self.storedInExternalRecord)
        string.appendDumpInfo("renamingIdentifier", self.renamingIdentifier)
        
        return string.indent(1) + "\n}"
    }
}

extension NSURL: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\"\(self)\""
    }
}

extension Optional: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        if let value = self {
            
            return formattedValue(value)
        }
        return "nil"
    }
}

extension String: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\"\(self)\""
    }
}
