//
//  DynamicModelTests.swift
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

import XCTest

@testable
import CoreStore

#if os(OSX)
    typealias Color = NSColor
#else
    
    typealias Color = UIColor
#endif

class Animal: CoreStoreObject {
    
    let species = Value.Required<String>("species", initial: "Swift")
    let master = Relationship.ToOne<Person>("master")
    let color = Transformable.Optional<Color>("color")
}

class Dog: Animal {
    
    let nickname = Value.Optional<String>("nickname")
    let age = Value.Required<Int>("age", initial: 1)
    let friends = Relationship.ToManyOrdered<Dog>("friends")
    let friendedBy = Relationship.ToManyUnordered<Dog>("friendedBy", inverse: { $0.friends })
}

class Person: CoreStoreObject {
    
    let title = Value.Required<String>(
        "title",
        initial: "Mr.",
        customSetter: Person.setTitle
    )
    
    let name = Value.Required<String>(
        "name",
        initial: "",
        customSetter: Person.setName
    )
    
    let displayName = Value.Optional<String>(
        "displayName",
        isTransient: true,
        customGetter: Person.getDisplayName(_:),
        affectedByKeyPaths: Person.keyPathsAffectingDisplayName()
    )
    
    let pets = Relationship.ToManyUnordered<Animal>("pets", inverse: { $0.master })
    
    private static func setTitle(_ partialObject: PartialObject<Person>, _ newValue: String) {
        
        partialObject.setPrimitiveValue(newValue, for: { $0.title })
        partialObject.setPrimitiveValue(nil, for: { $0.displayName })
    }
    
    private static func setName(_ partialObject: PartialObject<Person>, _ newValue: String) {
        
        partialObject.setPrimitiveValue(newValue, for: { $0.name })
        partialObject.setPrimitiveValue(nil, for: { $0.displayName })
    }
    
    static func getDisplayName(_ partialObject: PartialObject<Person>) -> String? {
        
        if let displayName = partialObject.primitiveValue(for: { $0.displayName }) {
            
            return displayName
        }
        let title = partialObject.value(for: { $0.title })
        let name = partialObject.value(for: { $0.name })
        let displayName = "\(title) \(name)"
        partialObject.setPrimitiveValue(displayName, for: { $0.displayName })
        return displayName
    }
    
    static func keyPathsAffectingDisplayName() -> Set<String> {
        
        return [
            self.keyPath({ $0.title }),
            self.keyPath({ $0.name })
        ]
    }
}


// MARK: - DynamicModelTests

class DynamicModelTests: BaseTestDataTestCase {
    
    func testDynamicModels_CanBeDeclaredCorrectly() {
        
        let dataStack = DataStack(
            CoreStoreSchema(
                modelVersion: "V1",
                entities: [
                    Entity<Animal>("Animal"),
                    Entity<Dog>("Dog"),
                    Entity<Person>("Person")
                ],
                versionLock: [
                    "Animal": [0x1b59d511019695cf, 0xdeb97e86c5eff179, 0x1cfd80745646cb3, 0x4ff99416175b5b9a],
                    "Dog": [0xe3f0afeb109b283a, 0x29998d292938eb61, 0x6aab788333cfc2a3, 0x492ff1d295910ea7],
                    "Person": [0x66d8bbfd8b21561f, 0xcecec69ecae3570f, 0xc4b73d71256214ef, 0x89b99bfe3e013e8b]
                ]
            )
        )
        self.prepareStack(dataStack, configurations: [nil]) { (stack) in
            
            let k1 = Animal.keyPath({ $0.species })
            XCTAssertEqual(k1, "species")
            
            let k2 = Dog.keyPath({ $0.species })
            XCTAssertEqual(k2, "species")
            
            let k3 = Dog.keyPath({ $0.nickname })
            XCTAssertEqual(k3, "nickname")
            
            let updateDone = self.expectation(description: "update-done")
            let fetchDone = self.expectation(description: "fetch-done")
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let animal = transaction.create(Into<Animal>())
                    XCTAssertEqual(animal.species.value, "Swift")
                    XCTAssertTrue(type(of: animal.species.value) == String.self)
                    
                    animal.species .= "Sparrow"
                    XCTAssertEqual(animal.species.value, "Sparrow")
                    
                    animal.color .= .yellow
                    XCTAssertEqual(animal.color.value, Color.yellow)
                    
                    let dog = transaction.create(Into<Dog>())
                    XCTAssertEqual(dog.species.value, "Swift")
                    XCTAssertEqual(dog.nickname.value, nil)
                    XCTAssertEqual(dog.age.value, 1)
                    
                    dog.species .= "Dog"
                    XCTAssertEqual(dog.species.value, "Dog")
                    
                    dog.nickname .= "Spot"
                    XCTAssertEqual(dog.nickname.value, "Spot")
                    
                    let person = transaction.create(Into<Person>())
                    XCTAssertTrue(person.pets.value.isEmpty)
                    
                    XCTAssertEqual(
                        object_getClass(person.rawObject!).keyPathsForValuesAffectingValue(forKey: "displayName"),
                        ["title", "name"]
                    )
                    
                    person.name .= "Joe"
                    
                    XCTAssertEqual(person.rawObject!.value(forKey: "name") as! String?, "Joe")
                    XCTAssertEqual(person.rawObject!.value(forKey: "displayName") as! String?, "Mr. Joe")
                    
                    person.rawObject!.setValue("AAAA", forKey: "displayName")
                    XCTAssertEqual(person.rawObject!.value(forKey: "displayName") as! String?, "AAAA")
                    
                    person.name .= "John"
                    XCTAssertEqual(person.name.value, "John")
                    XCTAssertEqual(person.displayName.value, "Mr. John") // Custom getter
                    
                    person.title .= "Sir"
                    XCTAssertEqual(person.displayName.value, "Sir John")
                    
                    person.pets.value.insert(dog)
                    XCTAssertEqual(person.pets.count, 1)
                    XCTAssertEqual(person.pets.value.first, dog)
                    XCTAssertEqual(person.pets.value.first?.master.value, person)
                    XCTAssertEqual(dog.master.value, person)
                    XCTAssertEqual(dog.master.value?.pets.value.first, dog)
                },
                success: {
                    
                    updateDone.fulfill()
                },
                failure: { _ in
                    
                    XCTFail()
                }
            )
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let p1 = Animal.where({ $0.species == "Sparrow" })
                    XCTAssertEqual(p1.predicate, NSPredicate(format: "%K == %@", "species", "Sparrow"))
                    
                    let bird = transaction.fetchOne(From<Animal>(), p1)
                    XCTAssertNotNil(bird)
                    XCTAssertEqual(bird!.species.value, "Sparrow")
                    
                    let p2 = Dog.where({ $0.nickname == "Spot" })
                    XCTAssertEqual(p2.predicate, NSPredicate(format: "%K == %@", "nickname", "Spot"))
                    
                    let dog = transaction.fetchOne(From<Dog>(), p2)
                    XCTAssertNotNil(dog)
                    XCTAssertEqual(dog!.nickname.value, "Spot")
                    XCTAssertEqual(dog!.species.value, "Dog")
                    
                    let person = transaction.fetchOne(From<Person>())
                    XCTAssertNotNil(person)
                    XCTAssertEqual(person!.pets.value.first, dog)
                    
                    let p3 = Dog.where({ $0.age == 10 })
                    XCTAssertEqual(p3.predicate, NSPredicate(format: "%K == %d", "age", 10))
                },
                success: {
            
                    fetchDone.fulfill()
                },
                failure: { _ in
                    
                    XCTFail()
                }
            )
            self.waitAndCheckExpectations()
        }
    }
    
    @nonobjc
    func prepareStack(_ dataStack: DataStack, configurations: [ModelConfiguration] = [nil], _ closure: (_ dataStack: DataStack) -> Void) {
        
        do {
            
            try configurations.forEach { (configuration) in
                
                try dataStack.addStorageAndWait(
                    SQLiteStore(
                        fileURL: SQLiteStore.defaultRootDirectory
                            .appendingPathComponent(UUID().uuidString)
                            .appendingPathComponent("\(type(of: self))_\((configuration ?? "-null-")).sqlite"),
                        configuration: configuration,
                        localStorageOptions: .recreateStoreOnModelMismatch
                    )
                )
            }
        }
        catch let error as NSError {
            
            XCTFail(error.coreStoreDumpString)
        }
        closure(dataStack)
    }
}
