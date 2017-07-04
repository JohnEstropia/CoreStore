//
//  CoreStoreManagedObject.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2017/06/04.
//  Copyright © 2017 John Rommel Estropia. All rights reserved.
//

import CoreData


// MARK: - CoreStoreManagedObject

@objc internal class CoreStoreManagedObject: NSManagedObject {
    
    internal typealias CustomGetter = @convention(block) (_ rawObject: Any) -> Any?
    internal typealias CustomSetter = @convention(block) (_ rawObject: Any, _ newValue: Any?) -> Void
    internal typealias CustomGetterSetter = (getter: CustomGetter?, setter: CustomSetter?)
    
    @nonobjc @inline(__always)
    internal static func cs_subclassName(for entity: DynamicEntity, in modelVersion: ModelVersion) -> String {
        
        return "_\(NSStringFromClass(CoreStoreManagedObject.self))__\(modelVersion)__\(NSStringFromClass(entity.type))__\(entity.entityName)"
    }
}


// MARK: - Private

private enum Static {
    
    static let queue = DispatchQueue.concurrent("com.coreStore.coreStoreManagerObjectBarrierQueue")
    static var cache: [ObjectIdentifier: [KeyPathString: Set<KeyPathString>]] = [:]
}
