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
            ("_domain", self._domain.cs_dump()),
            ("_code", self._code.cs_dump()),
        ]
        switch self {
            
        case .Unknown:
            break
            
        case .DifferentStorageExistsAtURL(let existingPersistentStoreURL):
            info.append(("existingPersistentStoreURL", existingPersistentStoreURL.cs_dump()))
            
        case .MappingModelNotFound(let localStoreURL, let targetModel, let targetModelVersion):
            info.append(("localStoreURL", localStoreURL.cs_dump()))
            info.append(("targetModel", targetModel.cs_dump()))
            info.append(("targetModelVersion", targetModelVersion.cs_dump()))
            
        case .ProgressiveMigrationRequired(let localStoreURL):
            info.append(("localStoreURL", localStoreURL.cs_dump()))
            
        case .InternalError(let NSError):
            info.append(("NSError", NSError.cs_dump()))
        }
        return info
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


// MARK: - Private

private typealias DumpInfo = [(key: String, value: IndentableDebugStringConvertible)]

private func formattedValue(any: Any) -> String {
    
    if let any = any as? IndentableDebugStringConvertible {
        
        return formattedValue(any)
    }
    return "\(any)"
}

private func formattedValue(any: IndentableDebugStringConvertible) -> String {
    
    return any.cs_dumpValue
}

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
            for (key, value) in info {
                
                dump.appendContentsOf("\n.\(key) = \(formattedValue(value))")
            }
            return dump.indent(1) + "\n}"
        }
    }
}

extension String: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\"\(self)\""
    }
}

extension NSURL: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\"\(self)\""
    }
}

extension Int: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\(self)"
    }
}

extension NSManagedObjectModel: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\(self)"
    }
}

extension NSMappingModel: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\(self)"
    }
}

extension NSError: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\(self)"
    }
}

extension NSBundle: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        return "\(self.bundleURL.lastPathComponent ?? "<unknown bundle URL>") (\(self.bundleIdentifier ?? "<unknown bundle identifier>"))"
    }
}

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

extension Optional: IndentableDebugStringConvertible {
    
    private var cs_dumpValue: String {
        
        if let value = self {
            
            return formattedValue(value)
        }
        return "nil"
    }
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
}
