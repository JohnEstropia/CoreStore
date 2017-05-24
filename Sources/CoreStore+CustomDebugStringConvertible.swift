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
            ("isCommitted", self.isCommitted)
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
        if self.contains(.recreateLocalStoreOnModelMismatch) {
            
            flags.append(".recreateLocalStoreOnModelMismatch")
        }
        if self.contains(.allowSynchronousLightweightMigration) {
            
            flags.append(".allowSynchronousLightweightMigration")
        }
        switch flags.count {
            
        case 0:
            return "[.none]"
            
        case 1:
            return "[.\(flags[0])]"
            
        default:
            var string = "[\n"
            string.append(flags.joined(separator: ",\n"))
            string.indent(1)
            string.append("\n]")
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
            ("errorDomain", type(of: self).errorDomain),
            ("errorCode", self.errorCode),
        ]
        switch self {
            
        case .unknown:
            firstLine = ".unknown"
            
        case .differentStorageExistsAtURL(let existingPersistentStoreURL):
            firstLine = ".differentStorageExistsAtURL"
            info.append(("existingPersistentStoreURL", existingPersistentStoreURL))
            
        case .mappingModelNotFound(let localStoreURL, let targetModel, let targetModelVersion):
            firstLine = ".mappingModelNotFound"
            info.append(("localStoreURL", localStoreURL))
            info.append(("targetModel", targetModel))
            info.append(("targetModelVersion", targetModelVersion))
            
        case .progressiveMigrationRequired(let localStoreURL):
            firstLine = ".progressiveMigrationRequired"
            info.append(("localStoreURL", localStoreURL))
            
        case .internalError(let NSError):
            firstLine = ".internalError"
            info.append(("NSError", NSError))
            
        case .userError(error: let error):
            firstLine = ".userError"
            info.append(("Error", error))
            
        case .userCancelled:
            firstLine = ".userCancelled"
        }
        
        return createFormattedString(
            "\(firstLine) (", ")",
            info
        )
    }
}


// MARK: - CoreStoreSchema

extension CoreStoreSchema: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("modelVersion", self.modelVersion),
            ("entitiesByConfiguration", self.entitiesByConfiguration),
            ("rawModel", self.rawModel())
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
            ("schemaHistory", self.schemaHistory),
            ("coordinator.persistentStores", self.coordinator.persistentStores)
        )
    }
}


// MARK: - Entity

extension Entity: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("type", self.type),
            ("entityName", self.entityName),
            ("isAbstract", self.isAbstract),
            ("versionHashModifier", self.versionHashModifier as Any)
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
            ("configuration", self.configuration as Any),
            ("storeOptions", self.storeOptions as Any),
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
            ("configuration", self.configuration as Any),
            ("storeOptions", self.storeOptions as Any)
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
            ("configuration", self.configuration as Any),
            ("inferStoreIfPossible", self.inferStoreIfPossible)
        )
    }
}


// MARK: - UnsafeDataModelSchema

extension UnsafeDataModelSchema: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("modelVersion", self.modelVersion),
            ("rawModel", self.rawModel())
        )
    }
}


// MARK: - ListMonitor

@available(OSX 10.12, *)
private struct CoreStoreFetchedSectionInfoWrapper: CoreStoreDebugStringConvertible {
    
    let sectionInfo: NSFetchedResultsSectionInfo
    
    var coreStoreDumpString: String {
        
        return createFormattedString(
            "\"\(self.sectionInfo.name)\" (", ")",
            ("numberOfObjects", self.sectionInfo.numberOfObjects),
            ("indexTitle", self.sectionInfo.indexTitle as Any)
        )
    }
}

@available(OSX 10.12, *)
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


// MARK: - LocalStorageOptions
 
extension LocalStorageOptions: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
     
        var flags = [String]()
        if self.contains(.recreateStoreOnModelMismatch) {
            
            flags.append(".recreateStoreOnModelMismatch")
        }
        if self.contains(.preventProgressiveMigration) {
            
            flags.append(".preventProgressiveMigration")
        }
        if self.contains(.allowSynchronousLightweightMigration) {
            
            flags.append(".allowSynchronousLightweightMigration")
        }
        switch flags.count {
            
        case 0:
            return "[.none]"
            
        case 1:
            return "[.\(flags[0])]"
            
        default:
            var string = "[\n"
            string.append(flags.joined(separator: ",\n"))
            string.indent(1)
            string.append("\n]")
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
        
        guard self.isValid else {
            
            return "<invalid migration chain>"
        }
        
        var paths = [String]()
        for var version in self.rootVersions {
            
            var steps = [version]
            while let nextVersion = self.nextVersionFrom(version) {
                
                steps.append(nextVersion)
                version = nextVersion
            }
            paths.append(steps.joined(separator: " → "))
        }
        switch paths.count {
            
        case 0:
            return "[]"
            
        case 1:
            return "[\(paths[0])]"
            
        default:
            var string = "["
            paths.forEach {
                
                string.append("\n\($0);")
            }
            string.indent(1)
            string.append("\n]")
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
            
        case .success(let migrationTypes):
            return createFormattedString(
                ".success (", ")",
                ("migrationTypes", migrationTypes)
            )
            
        case .failure(let error):
            return createFormattedString(
                ".failure (", ")",
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
            
        case .none(let version):
            return ".none (\"\(version)\")"
            
        case .lightweight(let sourceVersion, let destinationVersion):
            return ".lightweight (\"\(sourceVersion)\" → \"\(destinationVersion)\")"
            
        case .heavyweight(let sourceVersion, let destinationVersion):
            return ".heavyweight (\"\(sourceVersion)\" → \"\(destinationVersion)\")"
        }
    }
}


// MARK: - ObjectMonitor

@available(OSX 10.12, *)
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
            ("object", self.object as Any)
        )
    }
}


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

@available(*, deprecated, message: "Use the new DataStack.perform(asynchronous:...) and DataStack.perform(synchronous:...) family of APIs")
extension SaveResult: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        switch self {
            
        case .success(let hasChanges):
            return createFormattedString(
                ".success (", ")",
                ("hasChanges", hasChanges)
            )
            
        case .failure(let error):
            return createFormattedString(
                ".failure (", ")",
                ("error", error)
            )
        }
    }
}


// MARK: - SectionBy

@available(OSX 10.12, *)
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


// MARK: - SchemaHistory

extension SchemaHistory: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("currentModelVersion", self.currentModelVersion),
            ("migrationChain", self.migrationChain),
            ("schemaByVersion", self.schemaByVersion)
        )
    }
}


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
            
        case ._attribute(let keyPath):
            return createFormattedString(
                ".attribute (", ")",
                ("keyPath", keyPath)
            )
            
        case ._aggregate(let function, let keyPath, let alias, let nativeType):
            return createFormattedString(
                ".aggregate (", ")",
                ("function", function),
                ("keyPath", keyPath),
                ("alias", alias),
                ("nativeType", nativeType)
            )
            
        case ._identity(let alias, let nativeType):
            return createFormattedString(
                ".identity (", ")",
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
            
        case .success(let storage):
            return createFormattedString(
                ".success (", ")",
                ("storage", storage)
            )
            
        case .failure(let error):
            return createFormattedString(
                ".failure (", ")",
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
            ("configuration", self.configuration as Any),
            ("storeOptions", self.storeOptions as Any),
            ("fileURL", self.fileURL),
            ("migrationMappingProviders", self.migrationMappingProviders),
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
            ("isCommitted", self.isCommitted)
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


// MARK: - VersionLock

extension VersionLock: CustomStringConvertible, CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        
        var string = "["
        if self.hashesByEntityName.isEmpty {
            
            string.append(":]")
            return string
        }
        for (index, keyValue) in self.hashesByEntityName.sorted(by: { $0.key < $1.key }).enumerated() {
            
            let data = keyValue.value
            let count = data.count
            let bytes = data.withUnsafeBytes { (pointer: UnsafePointer<HashElement>) in
                
                return (0 ..< (count / MemoryLayout<HashElement>.size))
                    .map({ "\("0x\(String(pointer[$0], radix: 16, uppercase: false))")" })
            }
            string.append("\(index == 0 ? "\n" : ",\n")\"\(keyValue.key)\": [\(bytes.joined(separator: ", "))]")
        }
        string.indent(1)
        string.append("\n]")
        return string
    }
    
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return self.description
    }
}


// MARK: - XcodeDataModelSchema

extension XcodeDataModelSchema: CustomDebugStringConvertible, CoreStoreDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return formattedDebugDescription(self)
    }
    
    
    // MARK: CoreStoreDebugStringConvertible
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("modelVersion", self.modelVersion),
            ("modelVersionFileURL", self.modelVersionFileURL),
            ("rawModel", self.rawModel())
        )
    }
}


// MARK: - Private: Utilities

private typealias DumpInfo = [(key: String, value: Any)]

private func formattedValue(_ any: Any) -> String {
    
    switch any {
        
    case let any as CoreStoreDebugStringConvertible:
        return any.coreStoreDumpString
        
    default:
        return "\(any)"
    }
}

private func formattedDebugDescription(_ any: Any) -> String {
    
    var string = "(\(String(reflecting: type(of: any)))) "
    string.append(formattedValue(any))
    return string
}

private func createFormattedString(_ firstLine: String, _ lastLine: String, _ info: (key: String, value: Any)...) -> String {
    
    return createFormattedString(firstLine, lastLine, info)
}

private func createFormattedString(_ firstLine: String, _ lastLine: String, _ info: [(key: String, value: Any)]) -> String {
    
    var string = firstLine
    for (key, value) in info {
        
        string.appendDumpInfo(key, value)
    }
    string.indent(1)
    string.append("\n\(lastLine)")
    return string
}

fileprivate extension String {
    
    fileprivate static func indention(_ level: Int = 1) -> String {
        
        return String(repeating: " ", count: level * 4)
    }
    
    fileprivate func trimSwiftModuleName() -> String {
        
        if self.hasPrefix("Swift.") {
            
            return self.substring(from: "Swift.".endIndex)
        }
        return self
    }
    
    fileprivate mutating func indent(_ level: Int) {
        
        self = self.replacingOccurrences(of: "\n", with: "\n\(String.indention(level))")
    }
    
    fileprivate mutating func appendDumpInfo(_ key: String, _ value: Any) {
        
        self.append("\n.\(key) = \(formattedValue(value));")
    }
}


// MARK: - Private: CoreStoreDebugStringConvertible

public protocol CoreStoreDebugStringConvertible {
    
    var coreStoreDumpString: String { get }
}


// MARK: - Standard Types:

extension Array: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        var string = "\(self.count) item(s) ["
        if self.isEmpty {
            
            string.append("]")
            return string
        }
        else {
            
            for (index, item) in self.enumerated() {
                
                string.append("\n\(index) = \(formattedValue(item));")
            }
            string.indent(1)
            string.append("\n]")
            return string
        }
    }
}

extension Dictionary: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        var string = "\(self.count) key-value(s) ["
        if self.isEmpty {
            
            string.append("]")
            return string
        }
        else {
            
            for (key, value) in self {
                
                string.append("\n\(formattedValue(key)) = \(formattedValue(value));")
            }
            string.indent(1)
            string.append("\n]")
            return string
        }
    }
}

extension NSAttributeDescription: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("attributeType", self.attributeType),
            ("attributeValueClassName", self.attributeValueClassName as Any),
            ("defaultValue", self.defaultValue as Any),
            ("valueTransformerName", self.valueTransformerName as Any),
            ("allowsExternalBinaryDataStorage", self.allowsExternalBinaryDataStorage),
            ("entity.name", self.entity.name as Any),
            ("name", self.name),
            ("isOptional", self.isOptional),
            ("isTransient", self.isTransient),
            ("userInfo", self.userInfo as Any),
            ("isIndexed", self.isIndexed),
            ("versionHash", self.versionHash),
            ("versionHashModifier", self.versionHashModifier as Any),
            ("isIndexedBySpotlight", self.isIndexedBySpotlight),
            ("isStoredInExternalRecord", self.isStoredInExternalRecord),
            ("renamingIdentifier", self.renamingIdentifier as Any)
        )
    }
}

extension NSAttributeType: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        switch self {
            
        case .undefinedAttributeType:       return ".undefinedAttributeType"
        case .integer16AttributeType:       return ".integer16AttributeType"
        case .integer32AttributeType:       return ".integer32AttributeType"
        case .integer64AttributeType:       return ".integer64AttributeType"
        case .decimalAttributeType:         return ".decimalAttributeType"
        case .doubleAttributeType:          return ".doubleAttributeType"
        case .floatAttributeType:           return ".floatAttributeType"
        case .stringAttributeType:          return ".stringAttributeType"
        case .booleanAttributeType:         return ".booleanAttributeType"
        case .dateAttributeType:            return ".dateAttributeType"
        case .binaryDataAttributeType:      return ".binaryDataAttributeType"
        case .transformableAttributeType:   return ".transformableAttributeType"
        case .objectIDAttributeType:        return ".objectIDAttributeType"
        }
    }
}

extension Bundle: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return "\(self.bundleIdentifier.flatMap({ "\"\($0)\"" }) ?? "<unknown bundle identifier>") (\(self.bundleURL.lastPathComponent))"
    }
}

extension NSDeleteRule: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        switch self {
            
        case .noActionDeleteRule:   return ".noActionDeleteRule"
        case .nullifyDeleteRule:    return ".nullifyDeleteRule"
        case .cascadeDeleteRule:    return ".cascadeDeleteRule"
        case .denyDeleteRule:       return ".denyDeleteRule"
        }
    }
}

extension NSEntityDescription: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        var info: DumpInfo = [
            ("managedObjectClassName", self.managedObjectClassName!),
            ("name", self.name as Any),
            ("isAbstract", self.isAbstract),
            ("superentity?.name", self.superentity?.name as Any),
            ("subentities", self.subentities.map({ $0.name })),
            ("properties", self.properties),
            ("userInfo", self.userInfo as Any),
            ("versionHash", self.versionHash),
            ("versionHashModifier", self.versionHashModifier as Any),
            ("renamingIdentifier", self.renamingIdentifier as Any),
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
            "\(self.uriRepresentation().coreStoreDumpString) (", ")",
            ("entity.name", self.entity.name as Any),
            ("isTemporaryID", self.isTemporaryID as Any),
            ("persistentStore?.url", self.persistentStore?.url as Any)
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
            ("destinationEntity?.name", self.destinationEntity?.name as Any),
            ("inverseRelationship?.name", self.inverseRelationship?.name as Any),
            ("minCount", self.minCount),
            ("maxCount", self.maxCount),
            ("deleteRule", self.deleteRule),
            ("isToMany", self.isToMany),
            ("isOrdered", self.isOrdered),
            ("entity.name", self.entity.name as Any),
            ("name", self.name),
            ("isOptional", self.isOptional),
            ("isTransient", self.isTransient),
            ("userInfo", self.userInfo as Any),
            ("isIndexed", self.isIndexed),
            ("versionHash", self.versionHash),
            ("versionHashModifier", self.versionHashModifier as Any),
            ("isIndexedBySpotlight", self.isIndexedBySpotlight),
            ("isStoredInExternalRecord", self.isStoredInExternalRecord),
            ("renamingIdentifier", self.renamingIdentifier as Any)
        )
    }
}

extension NSSortDescriptor: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return createFormattedString(
            "(", ")",
            ("key", self.key as Any),
            ("ascending", self.ascending),
            ("selector", self.selector as Any)
        )
    }
}

extension NSString: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return "\"\(self)\""
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
        
        return "\"\(self)\""
    }
}

extension String: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return "\"\(self)\""
    }
}

extension URL: CoreStoreDebugStringConvertible {
    
    public var coreStoreDumpString: String {
        
        return "\"\(self)\""
    }
}
