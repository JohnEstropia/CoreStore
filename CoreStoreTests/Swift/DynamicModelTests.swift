//
//  DynamicModelTests.swift
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

import XCTest

@testable
import CoreStore

#if os(macOS)
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

    let spouse = Relationship.ToOne<Person>("spouse")
    
    let pets = Relationship.ToManyUnordered<Animal>("pets", inverse: { $0.master })

    private let _spouse = Relationship.ToOne<Person>("_spouseInverse", inverse: { $0.spouse })

    
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
            String(keyPath: \Person.title),
            String(keyPath: \Person.name)
        ]
    }
}


// MARK: - DynamicModelTests

class DynamicModelTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatDynamicModels_CanBeDeclaredCorrectly() {
        
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
                    "Person": [0x2831cf046084d96d, 0xbe19b13ace54641, 0x635a082728b0f6f0, 0x3d4ef2dd4b74a87c]
                ]
            )
        )
        self.prepareStack(dataStack, configurations: [nil]) { (stack) in
            
            let k1 = String(keyPath: \Animal.species)
            XCTAssertEqual(k1, "species")

            let k2 = String(keyPath: \Dog.species)
            XCTAssertEqual(k2, "species")
            
            let k3 = String(keyPath: \Dog.nickname)
            XCTAssertEqual(k3, "nickname")
            
            let updateDone = self.expectation(description: "update-done")
            let fetchDone = self.expectation(description: "fetch-done")
            let willSetPriorObserverDone = self.expectation(description: "willSet-observe-prior-done")
            let willSetNotPriorObserverDone = self.expectation(description: "willSet-observe-notPrior-done")
            let didSetObserverDone = self.expectation(description: "didSet-observe-done")
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let animal = transaction.create(Into<Animal>())
                    XCTAssertEqual(animal.species.value, "Swift")
                    XCTAssertTrue(type(of: animal.species.value) == String.self)
                    
                    animal.species .= "Sparrow"
                    XCTAssertEqual(animal.species.value, "Sparrow")
                    
                    animal.color .= .yellow
                    XCTAssertEqual(animal.color.value, Color.yellow)

                    for property in Animal.metaProperties(includeSuperclasses: true) {

                        switch property.keyPath {

                        case String(keyPath: \Animal.species):
                            XCTAssertTrue(property is ValueContainer<Animal>.Required<String>)

                        case String(keyPath: \Animal.master):
                            XCTAssertTrue(property is RelationshipContainer<Animal>.ToOne<Person>)

                        case String(keyPath: \Animal.color):
                            XCTAssertTrue(property is TransformableContainer<Animal>.Optional<Color>)

                        default:
                            XCTFail("Unknown KeyPath: \"\(property.keyPath)\"")
                        }
                    }
                    
                    let dog = transaction.create(Into<Dog>())
                    XCTAssertEqual(dog.species.value, "Swift")
                    XCTAssertEqual(dog.nickname.value, nil)
                    XCTAssertEqual(dog.age.value, 1)

                    for property in Dog.metaProperties(includeSuperclasses: true) {

                        switch property.keyPath {

                        case String(keyPath: \Dog.species):
                            XCTAssertTrue(property is ValueContainer<Animal>.Required<String>)

                        case String(keyPath: \Dog.master):
                            XCTAssertTrue(property is RelationshipContainer<Animal>.ToOne<Person>)

                        case String(keyPath: \Dog.color):
                            XCTAssertTrue(property is TransformableContainer<Animal>.Optional<Color>)

                        case String(keyPath: \Dog.nickname):
                            XCTAssertTrue(property is ValueContainer<Dog>.Optional<String>)

                        case String(keyPath: \Dog.age):
                            XCTAssertTrue(property is ValueContainer<Dog>.Required<Int>)

                        case String(keyPath: \Dog.friends):
                            XCTAssertTrue(property is RelationshipContainer<Dog>.ToManyOrdered<Dog>)

                        case String(keyPath: \Dog.friendedBy):
                            XCTAssertTrue(property is RelationshipContainer<Dog>.ToManyUnordered<Dog>)

                        default:
                            XCTFail("Unknown KeyPath: \"\(property.keyPath)\"")
                        }
                    }

//                    #if swift(>=5.1)
//
//                    let dogKeyPathBuilder = Dog.keyPathBuilder()
//                    XCTAssertEqual(dogKeyPathBuilder.species.keyPathString, "SELF.species")
//                    XCTAssertEqual(dogKeyPathBuilder.master.title.keyPathString, "SELF.master.title")
//                    let a = dogKeyPathBuilder.master
//                    let b = dogKeyPathBuilder.master.spouse
//                    let c = dogKeyPathBuilder.master.spouse.pets
//                    let d = dogKeyPathBuilder.master.spouse.pets.color
//                    XCTAssertEqual(dogKeyPathBuilder.master.spouse.pets.color.keyPathString, "SELF.master.spouse.pets.color")
//
//                    #endif

                    let didSetObserver = dog.species.observe(options: [.new, .old]) { (object, change) in

                        XCTAssertEqual(object, dog)
                        XCTAssertEqual(change.kind, .setting)
                        XCTAssertEqual(change.newValue, "Dog")
                        XCTAssertEqual(change.oldValue, "Swift")
                        XCTAssertFalse(change.isPrior)
                        XCTAssertEqual(object.species.value, "Dog")
                        didSetObserverDone.fulfill()
                    }
                    let willSetObserver = dog.species.observe(options: [.new, .old, .prior]) { (object, change) in

                        XCTAssertEqual(object, dog)
                        XCTAssertEqual(change.kind, .setting)
                        XCTAssertEqual(change.oldValue, "Swift")

                        if change.isPrior {

                            XCTAssertNil(change.newValue)
                            XCTAssertEqual(object.species.value, "Swift")
                            willSetPriorObserverDone.fulfill()
                        }
                        else {

                            XCTAssertEqual(change.newValue, "Dog")
                            XCTAssertEqual(object.species.value, "Dog")
                            willSetNotPriorObserverDone.fulfill()
                        }
                    }
                    
                    dog.species .= "Dog"
                    XCTAssertEqual(dog.species.value, "Dog")

                    didSetObserver.invalidate()
                    willSetObserver.invalidate()
                    
                    dog.nickname .= "Spot"
                    XCTAssertEqual(dog.nickname.value, "Spot")
                    
                    let person = transaction.create(Into<Person>())
                    XCTAssertTrue(person.pets.value.isEmpty)
                    
                    XCTAssertEqual(
                        person.rawObject!
                            .runtimeType()
                            .keyPathsForValuesAffectingValue(forKey: "displayName"),
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
                    
                    let personSnapshot1 = person.asSnapshot(in: transaction)!
                    XCTAssertEqual(person.name.value, personSnapshot1.name)
                    XCTAssertEqual(person.title.value, personSnapshot1.title)
                    XCTAssertEqual(person.displayName.value, personSnapshot1.displayName)
                    
                    person.title .= "Sir"
                    XCTAssertEqual(person.displayName.value, "Sir John")
                    
                    XCTAssertEqual(personSnapshot1.name, "John")
                    XCTAssertEqual(personSnapshot1.title, "Mr.")
                    XCTAssertEqual(personSnapshot1.displayName, "Mr. John")
                    
                    let personSnapshot2 = person.asSnapshot(in: transaction)!
                    XCTAssertEqual(person.name.value, personSnapshot2.name)
                    XCTAssertEqual(person.title.value, personSnapshot2.title)
                    XCTAssertEqual(person.displayName.value, personSnapshot2.displayName)

                    var personSnapshot3 = personSnapshot2
                    personSnapshot3.name = "James"
                    XCTAssertEqual(personSnapshot1.name, "John")
                    XCTAssertEqual(personSnapshot1.displayName, "Mr. John")
                    XCTAssertEqual(personSnapshot2.name, "John")
                    XCTAssertEqual(personSnapshot2.displayName, "Sir John")
                    XCTAssertEqual(personSnapshot3.name, "James")
                    XCTAssertEqual(personSnapshot3.displayName, "Sir John")

                    
                    person.pets.value.insert(dog)
                    XCTAssertEqual(person.pets.count, 1)
                    XCTAssertEqual(person.pets.value.first, dog)
                    XCTAssertEqual(person.pets.value.first?.master.value, person)
                    XCTAssertEqual(dog.master.value, person)
                    XCTAssertEqual(dog.master.value?.pets.value.first, dog)
                },
                success: { _ in
                    
                    updateDone.fulfill()
                },
                failure: { _ in
                    
                    XCTFail()
                }
            )
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let p1 = Where<Animal>({ $0.species == "Sparrow" })
                    XCTAssertEqual(p1.predicate, NSPredicate(format: "%K == %@", "species", "Sparrow"))
                    
                    let bird = try transaction.fetchOne(From<Animal>(), p1)
                    XCTAssertNotNil(bird)
                    XCTAssertEqual(bird!.species.value, "Sparrow")
                    
                    let p2 = Where<Dog>({ $0.nickname == "Spot" })
                    XCTAssertEqual(p2.predicate, NSPredicate(format: "%K == %@", "nickname", "Spot"))
                    
                    let dog = try transaction.fetchOne(From<Dog>().where(\.nickname == "Spot"))
                    XCTAssertNotNil(dog)
                    XCTAssertEqual(dog!.nickname.value, "Spot")
                    XCTAssertEqual(dog!.species.value, "Dog")
                    
                    let person = try transaction.fetchOne(From<Person>())
                    XCTAssertNotNil(person)
                    XCTAssertEqual(person!.pets.value.first, dog)
                    
                    let p3 = Where<Dog>({ $0.age == 10 })
                    XCTAssertEqual(p3.predicate, NSPredicate(format: "%K == %d", "age", 10))

                    let totalAge = try transaction.queryValue(From<Dog>().select(Int.self, .sum(\Dog.age)))
                    XCTAssertEqual(totalAge, 1)
                    
                    _ = try transaction.fetchAll(
                        From<Dog>()
                            .where(\Animal.species == "Dog" && \Dog.age == 10)
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>()
                            .where(\Dog.age == 10 && \Animal.species == "Dog")
                            .orderBy(.ascending({ $0.species }))
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        Where<Dog>({ $0.age > 10 && $0.age <= 15 })
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        Where<Dog>({ $0.species == "Dog" && $0.age == 10 })
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        Where<Dog>({ $0.age == 10 && $0.species == "Dog" })
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        Where<Dog>({ $0.age > 10 && $0.age <= 15 })
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        (\Dog.age > 10 && \Dog.age <= 15)
                    )
                },
                success: { _ in
            
                    fetchDone.fulfill()
                },
                failure: { _ in
                    
                    XCTFail()
                }
            )
            self.waitAndCheckExpectations()
        }
    }
    
    @objc
    dynamic func test_ThatDynamicModelKeyPaths_CanBeCreated() {
        
        XCTAssertEqual(String(keyPath: \Animal.species), "species")
        XCTAssertEqual(String(keyPath: \Dog.species), "species")
    }
    
    @nonobjc
    func prepareStack(_ dataStack: DataStack, configurations: [ModelConfiguration] = [nil], _ closure: (_ dataStack: DataStack) -> Void) {
        
        do {
            
            try configurations.forEach { (configuration) in
                
                try dataStack.addStorageAndWait(
                    SQLiteStore(
                        fileURL: SQLiteStore.defaultRootDirectory
                            .appendingPathComponent(UUID().uuidString)
                            .appendingPathComponent("\(Self.self)_\((configuration ?? "-null-")).sqlite"),
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
