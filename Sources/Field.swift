//
//  Field.swift
//  CoreStore
//
//  Copyright © 2020 John Rommel Estropia
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


// MARK: - DynamicObject

extension DynamicObject where Self: CoreStoreObject {

    /**
     The containing type for value propertiess. `Field` properties support any type that conforms to `ImportableAttributeType`.
     ```
     class Animal: CoreStoreObject {
         @Field.Stored("species")
         var species = ""

         @Field.Stored("nickname")
         var nickname: String?

         @Field.PlistCoded("color")
         var color: UIColor?
     }
     ```
     - Important: `Field` properties are required to be used as `@propertyWrapper`s. Any other declaration not using the `@Field.*(...) var` syntax will be ignored.
     */
    public typealias Field = FieldContainer<Self>
}


// MARK: - FieldContainer

/**
 The containing type for value properties. Use the `DynamicObject.Field` typealias instead for shorter syntax.
 ```
 class Animal: CoreStoreObject {
     @Field.Stored("species")
     var species = ""

     @Field.Stored("nickname")
     var nickname: String?

     @Field.PlistCoded("color")
     var color: UIColor?
 }
 ```
 */
public enum FieldContainer<O: CoreStoreObject> {}
