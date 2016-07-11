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
import CoreData


// MARK: - AsynchronousDataTransaction

extension AsynchronousDataTransaction: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("context", self.context),
            ("supportsUndo", self.supportsUndo),
            ("bypassesQueueing", self.bypassesQueueing),
            ("isCommitted", self.isCommitted),
            ("result", self.result)
        )
    }
}


// MARK: - CloudStorageOptions

extension CloudStorageOptions: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
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
            var string = "[\n"
            string.appendContentsOf(flags.joinWithSeparator(",\n"))
            string.indent(1)
            string.appendContentsOf("\n]")
            return string
        }
    }
}


// MARK: - CoreStoreError

extension CoreStoreError: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        let firstLine: String
        var info: DumpInfo = [
            ("_domain", self._domain),
            ("_code", self._code),
        ]
        switch self {
            
        case .Unknown:
            firstLine = ".Unknown"
            
        case .DifferentStorageExistsAtURL(let existingPersistentStoreURL):
            firstLine = ".DifferentStorageExistsAtURL"
            info.append(("existingPersistentStoreURL", existingPersistentStoreURL))
            
        case .MappingModelNotFound(let localStoreURL, let targetModel, let targetModelVersion):
            firstLine = ".MappingModelNotFound"
            info.append(("localStoreURL", localStoreURL))
            info.append(("targetModel", targetModel))
            info.append(("targetModelVersion", targetModelVersion))
            
        case .ProgressiveMigrationRequired(let localStoreURL):
            firstLine = ".ProgressiveMigrationRequired"
            info.append(("localStoreURL", localStoreURL))
            
        case .InternalError(let NSError):
            firstLine = ".InternalError"
            info.append(("NSError", NSError))
        }
        
        return createFormattedString(
            "\(firstLine) (", ")",
            info
        )
    }
}


// MARK: - DataStack

extension DataStack: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("coordinator", self.coordinator),
            ("rootSavingContext", self.rootSavingContext),
            ("mainContext", self.mainContext),
            ("model", self.model),
            ("migrationChain", self.migrationChain),
            ("coordinator.persistentStores", self.coordinator.persistentStores)
        )
    }
}


// MARK: - From

extension From: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        var info: DumpInfo = [("entityClass", self.entityClass)]
        if let configurations = self.configurations {
            
            info.append(("configurations", configurations))
        }
        return createFormattedString(
            "(", ")",
            info
        )
    }
}


// MARK: - GroupBy

extension GroupBy: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("keyPaths", self.keyPaths)
        )
    }
}


#if os(iOS) || os(OSX)

// MARK: - ICloudStore

extension ICloudStore: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("configuration", self.configuration),
            ("storeOptions", self.storeOptions),
            ("cacheFileURL", self.cacheFileURL),
            ("cloudStorageOptions", self.cloudStorageOptions)
        )
    }
}
    
#endif


// MARK: - InMemoryStore

extension InMemoryStore: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("configuration", self.configuration),
            ("storeOptions", self.storeOptions)
        )
    }
}


// MARK: - Into

extension Into: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("entityClass", self.entityClass),
            ("configuration", self.configuration),
            ("inferStoreIfPossible", self.inferStoreIfPossible)
        )
    }
}


// MARK: - LegacySQLiteStore

extension LegacySQLiteStore: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("configuration", self.configuration),
            ("storeOptions", self.storeOptions),
            ("fileURL", self.fileURL),
            ("mappingModelBundles", self.mappingModelBundles),
            ("localStorageOptions", self.localStorageOptions)
        )
    }
}


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - ListMonitor

private struct CoreStoreFetchedSectionInfoWrapper: CoreStoreDebugStringConvertible {
    
    let sectionInfo: NSFetchedResultsSectionInfo
    
    var coreStoreDumpString: String {
        
        return createFormattedString(
            "\"\(self.sectionInfo.name)\" (", ")",
            ("numberOfObjects", self.sectionInfo.numberOfObjects),
            ("indexTitle", self.sectionInfo.indexTitle)
        )
    }
}

extension ListMonitor: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("isPendingRefetch", self.isPendingRefetch),
            ("numberOfObjects", self.numberOfObjects()),
            ("sections", self.sections().map(CoreStoreFetchedSectionInfoWrapper.init))
        )
    }
}
#endif


// MARK: - LocalStorageOptions
 
extension LocalStorageOptions: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
     
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
            var string = "[\n"
            string.appendContentsOf(flags.joinWithSeparator(",\n"))
            string.indent(1)
            string.appendContentsOf("\n]")
            return string
        }
    }
}


// MARK: - MigrationChain

extension MigrationChain: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
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
            var string = "["
            paths.forEach {
                
                string.appendContentsOf("\n\($0);")
            }
            string.indent(1)
            string.appendContentsOf("\n]")
            return string
        }
    }
}


// MARK: - MigrationType

extension MigrationResult: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        switch self {
            
        case .Success(let migrationTypes):
            return createFormattedString(
                ".Success (", ")",
                ("migrationTypes", migrationTypes)
            )
            
        case .Failure(let error):
            return createFormattedString(
                ".Failure (", ")",
                ("error", error)
            )
        }
    }
}


// MARK: - MigrationType

extension MigrationType: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        switch self {
            
        case .None(let version):
            return ".None (\"\(version)\")"
            
        case .Lightweight(let sourceVersion, let destinationVersion):
            return ".Lightweight (\"\(sourceVersion)\" → \"\(destinationVersion)\")"
            
        case .Heavyweight(let sourceVersion, let destinationVersion):
            return ".Heavyweight (\"\(sourceVersion)\" → \"\(destinationVersion)\")"
        }
    }
}


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - ObjectMonitor

extension ObjectMonitor: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("isObjectDeleted", self.isObjectDeleted),
            ("object", self.object)
        )
    }
}
#endif

// MARK: - OrderBy

extension OrderBy: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("sortDescriptors", self.sortDescriptors)
        )
    }
}


// MARK: - SaveResult

extension SaveResult: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        switch self {
            
        case .Success(let hasChanges):
            return createFormattedString(
                ".Success (", ")",
                ("hasChanges", hasChanges)
            )
            
        case .Failure(let error):
            return createFormattedString(
                ".Failure (", ")",
                ("error", error)
            )
        }
    }
}


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - SectionBy

extension SectionBy: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("sectionKeyPath", self.sectionKeyPath)
        )
    }
}
#endif


// MARK: - Select

extension Select: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("selectTerms", self.selectTerms)
        )
    }
}


// MARK: - SelectTerm

extension SelectTerm: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        switch self {
            
        case ._Attribute(let keyPath):
            return createFormattedString(
                ".Attribute (", ")",
                ("keyPath", keyPath)
            )
            
        case ._Aggregate(let function, let keyPath, let alias, let nativeType):
            return createFormattedString(
                ".Aggregate (", ")",
                ("function", function),
                ("keyPath", keyPath),
                ("alias", alias),
                ("nativeType", nativeType)
            )
            
        case ._Identity(let alias, let nativeType):
            return createFormattedString(
                ".Identity (", ")",
                ("alias", alias),
                ("nativeType", nativeType)
            )
        }
    }
}


// MARK: - SetupResult

extension SetupResult: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        switch self {
            
        case .Success(let storage):
            return createFormattedString(
                ".Success (", ")",
                ("storage", storage)
            )
            
        case .Failure(let error):
            return createFormattedString(
                ".Failure (", ")",
                ("error", error)
            )
        }
    }
}


// MARK: - SQLiteStore

extension SQLiteStore: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("configuration", self.configuration),
            ("storeOptions", self.storeOptions),
            ("fileURL", self.fileURL),
            ("mappingModelBundles", self.mappingModelBundles),
            ("localStorageOptions", self.localStorageOptions)
        )
    }
}


// MARK: - SynchronousDataTransaction

extension SynchronousDataTransaction: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("context", self.context),
            ("supportsUndo", self.supportsUndo),
            ("bypassesQueueing", self.bypassesQueueing),
            ("isCommitted", self.isCommitted),
            ("result", self.result)
        )
    }
}


// MARK: - Tweak

extension Tweak: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return "<no info>"
    }
}


// MARK: - UnsafeDataTransaction

extension UnsafeDataTransaction: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("context", self.context),
            ("supportsUndo", self.supportsUndo)
        )
    }
}


// MARK: - Where

extension Where: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("predicate", self.predicate)
        )
    }
}


// MARK: - Private: Utilities

private typealias DumpInfo = [(key: String, value: Any)]

private func formattedValue(any: Any) -> String {
    
    switch any {
        
    case let any as CoreStoreDebugStringConvertible:
        return any.coreStoreDumpString
        
    default:
        return "\(any)"
    }
}

private func formattedDebugDescription(any: Any) -> String {
    
    var string = "(\(String(reflecting: any.dynamicType))) "
    string.appendContentsOf(formattedValue(any))
    return string
}

private func createFormattedString(firstLine: String, _ lastLine: String, _ info: (key: String, value: Any)...) -> String {
    
    return createFormattedString(firstLine, lastLine, info)
}

private func createFormattedString(firstLine: String, _ lastLine: String, _ info: [(key: String, value: Any)]) -> String {
    
    var string = firstLine
    for (key, value) in info {
        
        string.appendDumpInfo(key, value)
    }
    string.indent(1)
    string.appendContentsOf("\n\(lastLine)")
    return string
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
    
    private mutating func indent(level: Int) {
        
        self = self.stringByReplacingOccurrencesOfString("\n", withString: "\n\(String.indention(level))")
    }
    
    private mutating func appendDumpInfo(key: String, _ value: Any) {
        
        self.appendContentsOf("\n.\(key) = \(formattedValue(value));")
    }
}


// MARK: - Private: CoreStoreDebugStringConvertible

public protocol CoreStoreDebugStringConvertible {
    
    var coreStoreDumpString: String { get }
}


// MARK: - Private:

extension Array: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        var string = "\(self.count) item(s) ["
        if self.isEmpty {
            
            string.appendContentsOf("]")
            return string
        }
        else {
            
            for (index, item) in self.enumerate() {
                
                string.appendContentsOf("\n\(index) = \(formattedValue(item));")
            }
            string.indent(1)
            string.appendContentsOf("\n]")
            return string
        }
    }
}

extension Dictionary: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        var string = "\(self.count) key-value(s) ["
        if self.isEmpty {
            
            string.appendContentsOf("]")
            return string
        }
        else {
            
            for (key, value) in self {
                
                string.appendContentsOf("\n\(formattedValue(key)) = \(formattedValue(value));")
            }
            string.indent(1)
            string.appendContentsOf("\n]")
            return string
        }
    }
}

extension NSAttributeDescription: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("attributeType", self.attributeType),
            ("attributeValueClassName", self.attributeValueClassName),
            ("defaultValue", self.defaultValue),
            ("valueTransformerName", self.valueTransformerName),
            ("allowsExternalBinaryDataStorage", self.allowsExternalBinaryDataStorage),
            ("entity.name", self.entity.name),
            ("name", self.name),
            ("optional", self.optional),
            ("transient", self.transient),
            ("userInfo", self.userInfo),
            ("indexed", self.indexed),
            ("versionHash", self.versionHash),
            ("versionHashModifier", self.versionHashModifier),
            ("indexedBySpotlight", self.indexedBySpotlight),
            ("storedInExternalRecord", self.storedInExternalRecord),
            ("renamingIdentifier", self.renamingIdentifier)
        )
    }
}

extension NSAttributeType: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
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

extension NSBundle: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return "\(self.bundleIdentifier.flatMap({ "\"\($0)\"" }) ?? "<unknown bundle identifier>") (\(self.bundleURL.lastPathComponent ?? "<unknown bundle URL>"))"
    }
}

extension NSDeleteRule: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        switch self {
            
        case .NoActionDeleteRule:   return ".NoActionDeleteRule"
        case .NullifyDeleteRule:    return ".NullifyDeleteRule"
        case .CascadeDeleteRule:    return ".CascadeDeleteRule"
        case .DenyDeleteRule:       return ".DenyDeleteRule"
        }
    }
}

extension NSEntityDescription: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        var info: DumpInfo = [
            ("managedObjectClassName", self.managedObjectClassName!),
            ("name", self.name),
            ("abstract", self.abstract),
            ("superentity?.name", self.superentity?.name),
            ("subentities", self.subentities.map({ $0.name })),
            ("properties", self.properties),
            ("userInfo", self.userInfo),
            ("versionHash", self.versionHash),
            ("versionHashModifier", self.versionHashModifier),
            ("renamingIdentifier", self.renamingIdentifier),
            ("compoundIndexes", self.compoundIndexes)
        ]
        if #available(iOS 9.0, OSXApplicationExtension 10.11, OSX 10.11, *) {
            
            info.append(("uniquenessConstraints", self.uniquenessConstraints))
        }
        return createFormattedString(
            "(", ")",
            info
        )
    }
}

extension NSError: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("domain", self.domain),
            ("code", self.code),
            ("userInfo", self.userInfo)
        )
    }
}

extension NSManagedObjectModel: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("configurations", self.configurations),
            ("entities", self.entities)
        )
    }
}

extension NSManagedObjectID: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "\(self.URIRepresentation().coreStoreDumpString) (", ")",
            ("entity.name", self.entity.name),
            ("temporaryID", self.temporaryID),
            ("persistentStore?.URL", self.persistentStore?.URL)
        )
    }
}

extension NSMappingModel: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return "\(self)"
    }
}

extension NSPredicate: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return "\"\(self)\""
    }
}

extension NSRelationshipDescription: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("destinationEntity?.name", self.destinationEntity?.name),
            ("inverseRelationship?.name", self.inverseRelationship?.name),
            ("minCount", self.minCount),
            ("maxCount", self.maxCount),
            ("deleteRule", self.deleteRule),
            ("toMany", self.toMany),
            ("ordered", self.ordered),
            ("entity.name", self.entity.name),
            ("name", self.name),
            ("optional", self.optional),
            ("transient", self.transient),
            ("userInfo", self.userInfo),
            ("indexed", self.indexed),
            ("versionHash", self.versionHash),
            ("versionHashModifier", self.versionHashModifier),
            ("indexedBySpotlight", self.indexedBySpotlight),
            ("storedInExternalRecord", self.storedInExternalRecord),
            ("renamingIdentifier", self.renamingIdentifier)
        )
    }
}

extension NSSortDescriptor: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("key", self.key),
            ("ascending", self.ascending),
            ("selector", self.selector)
        )
    }
}

extension NSURL: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return "\"\(self)\""
    }
}

extension Optional: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        if let value = self {
            
            return formattedValue(value)
        }
        return "nil"
    }
}

extension Selector: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return self == nil ? "nil" : "\"\(self)\""
    }
}

extension String: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return "\"\(self)\""
    }
}
