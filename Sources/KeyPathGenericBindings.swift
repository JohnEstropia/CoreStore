//
//  KeyPathGenericBindings.swift
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

import Foundation
import CoreGraphics
import CoreData


// MARK: - AllowedObjectiveCKeyPathValue

/**
 Used only for utility methods. Types allowed as `Value` generic type to `KeyPath` utilities.
 */
public protocol AllowedObjectiveCKeyPathValue {}


// MARK: - AllowedOptionalObjectiveCKeyPathValue

/**
 Used only for utility methods. Types allowed as `Value` generic type to `KeyPath` utilities.
 */
public protocol AllowedOptionalObjectiveCKeyPathValue: AllowedObjectiveCKeyPathValue {}

extension Bool: AllowedObjectiveCKeyPathValue {}

extension CGFloat: AllowedObjectiveCKeyPathValue {}

extension Data: AllowedOptionalObjectiveCKeyPathValue {}

extension Date: AllowedOptionalObjectiveCKeyPathValue {}

extension Double: AllowedObjectiveCKeyPathValue {}

extension Float: AllowedObjectiveCKeyPathValue {}

extension Int: AllowedObjectiveCKeyPathValue {}

extension Int8: AllowedObjectiveCKeyPathValue {}

extension Int16: AllowedObjectiveCKeyPathValue {}

extension Int32: AllowedObjectiveCKeyPathValue {}

extension Int64: AllowedObjectiveCKeyPathValue {}

extension NSData: AllowedOptionalObjectiveCKeyPathValue {}

extension NSDate: AllowedOptionalObjectiveCKeyPathValue {}

extension NSManagedObject: AllowedOptionalObjectiveCKeyPathValue {}

extension NSNumber: AllowedOptionalObjectiveCKeyPathValue {}

extension NSString: AllowedOptionalObjectiveCKeyPathValue {}

extension NSSet: AllowedOptionalObjectiveCKeyPathValue {}

extension NSOrderedSet: AllowedOptionalObjectiveCKeyPathValue {}

extension NSURL: AllowedOptionalObjectiveCKeyPathValue {}

extension NSUUID: AllowedOptionalObjectiveCKeyPathValue {}

extension String: AllowedOptionalObjectiveCKeyPathValue {}

extension URL: AllowedOptionalObjectiveCKeyPathValue {}

extension UUID: AllowedOptionalObjectiveCKeyPathValue {}

extension Optional: AllowedObjectiveCKeyPathValue where Wrapped: AllowedOptionalObjectiveCKeyPathValue {}


// MARK: - AllowedObjectiveCAttributeKeyPathValue

/**
 Used only for utility methods. Types allowed as `Value` generic type to `KeyPath` utilities.
 */
public protocol AllowedObjectiveCAttributeKeyPathValue: AllowedObjectiveCKeyPathValue {}

extension Bool: AllowedObjectiveCAttributeKeyPathValue {}

extension CGFloat: AllowedObjectiveCAttributeKeyPathValue {}

extension Data: AllowedObjectiveCAttributeKeyPathValue {}

extension Date: AllowedObjectiveCAttributeKeyPathValue {}

extension Double: AllowedObjectiveCAttributeKeyPathValue {}

extension Float: AllowedObjectiveCAttributeKeyPathValue {}

extension Int: AllowedObjectiveCAttributeKeyPathValue {}

extension Int8: AllowedObjectiveCAttributeKeyPathValue {}

extension Int16: AllowedObjectiveCAttributeKeyPathValue {}

extension Int32: AllowedObjectiveCAttributeKeyPathValue {}

extension Int64: AllowedObjectiveCAttributeKeyPathValue {}

extension NSData: AllowedObjectiveCAttributeKeyPathValue {}

extension NSDate: AllowedObjectiveCAttributeKeyPathValue {}

extension NSNumber: AllowedObjectiveCAttributeKeyPathValue {}

extension NSString: AllowedObjectiveCAttributeKeyPathValue {}

extension NSURL: AllowedObjectiveCAttributeKeyPathValue {}

extension NSUUID: AllowedObjectiveCAttributeKeyPathValue {}

extension String: AllowedObjectiveCAttributeKeyPathValue {}

extension URL: AllowedObjectiveCAttributeKeyPathValue {}

extension UUID: AllowedObjectiveCAttributeKeyPathValue {}

extension Optional: AllowedObjectiveCAttributeKeyPathValue where Wrapped: AllowedObjectiveCAttributeKeyPathValue, Wrapped: AllowedOptionalObjectiveCKeyPathValue {}


// MARK: - AllowedObjectiveCRelationshipKeyPathValue

/**
 Used only for utility methods. Types allowed as `Value` generic type to `KeyPath` utilities.
 */
public protocol AllowedObjectiveCRelationshipKeyPathValue: AllowedOptionalObjectiveCKeyPathValue {}

extension NSManagedObject: AllowedObjectiveCRelationshipKeyPathValue {}

extension NSSet: AllowedObjectiveCRelationshipKeyPathValue {}

extension NSOrderedSet: AllowedObjectiveCRelationshipKeyPathValue {}

extension Optional: AllowedOptionalObjectiveCKeyPathValue, AllowedObjectiveCRelationshipKeyPathValue where Wrapped: AllowedObjectiveCRelationshipKeyPathValue {}


// MARK: - AllowedObjectiveCToManyRelationshipKeyPathValue

/**
 Used only for utility methods. Types allowed as `Value` generic type to `KeyPath` utilities.
 */
public protocol AllowedObjectiveCToManyRelationshipKeyPathValue: AllowedOptionalObjectiveCKeyPathValue {}

extension NSSet: AllowedObjectiveCToManyRelationshipKeyPathValue {}

extension NSOrderedSet: AllowedObjectiveCToManyRelationshipKeyPathValue {}

extension Optional: AllowedObjectiveCToManyRelationshipKeyPathValue where Wrapped: AllowedObjectiveCToManyRelationshipKeyPathValue, Wrapped: AllowedObjectiveCRelationshipKeyPathValue {}


// MARK: - Deprecated

@available(*, deprecated, renamed: "AllowedObjectiveCToManyRelationshipKeyPathValue")
public typealias AllowedCoreStoreObjectCollectionKeyPathValue = AllowedObjectiveCToManyRelationshipKeyPathValue
