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

    @Field.Stored("species")
    var species: String = "Swift"

    @Field.Coded("color", coder: FieldCoders.NSCoding.self)
    var color: Color? = .blue

    @Field.Relationship("master")
    var master: Person?
}

class Dog: Animal {
    
    static let commonNicknames = ["Spot", "Benjie", "Max", "Milo"]

    @Field.Stored(
        "nickname",
        dynamicInitialValue: {
            commonNicknames.randomElement()!
        }
    )
    var nickname: String

    @Field.Stored("age")
    var age: Int = 1

    @Field.Relationship("friends")
    var friends: [Dog]

    @Field.Relationship("friendedBy", inverse: \.$friends)
    var friendedBy: Set<Dog>
}

struct CustomType {
    var string = "customString"
}

enum Job: String, CaseIterable {

    case unemployed
    case engineer
    case doctor
    case lawyer

    init?(data: Data) {

        guard
            let rawValue = String(data: data, encoding: .utf8),
            let value = Self.init(rawValue: rawValue)
            else {

            return nil
        }
        self = value
    }

    func toData() -> Data {

        return Data(self.rawValue.utf8)
    }
}

class Person: CoreStoreObject {

    @Field.Stored(
        "title",
        customSetter: { (object, field, newValue) in
            field.primitiveValue = newValue
            object.$displayName.primitiveValue = nil
        }
    )
    var title: String = "Mr."

    @Field.Stored(
        "name",
        customSetter: { (object, field, newValue) in
            field.primitiveValue = newValue
            object.$displayName.primitiveValue = nil
        }
    )
    var name: String = ""

    @Field.Virtual(
        "displayName",
        customGetter: Person.getDisplayName(_:_:),
        affectedByKeyPaths: Person.keyPathsAffectingDisplayName()
    )
    var displayName: String?

    @Field.Virtual(
        "customType",
        customGetter: { (object, field) in

            if let value = field.primitiveValue {

                return value
            }
            let value = CustomType()
            field.primitiveValue = value
            return value
        }
    )
    var customField: CustomType

    @Field.Coded(
        "job",
        coder: (
            encode: { $0.toData() },
            decode: { $0.flatMap(Job.init(data:)) ?? .unemployed }
        ),
        dynamicInitialValue: {
            Job.allCases.randomElement()!
        }
    )
    var job: Job

    @Field.Relationship("spouse")
    var spouse: Person?

    @Field.Relationship("pets", inverse: \.$master)
    var pets: Set<Animal>

    @Field.Relationship("_spouseInverse", inverse: \.$spouse)
    private var spouseInverse: Person?
    
    private static func getDisplayName(_ object: ObjectProxy<Person>, _ field: ObjectProxy<Person>.FieldProxy<String?>) -> String? {

        if let value = field.primitiveValue {

            return value
        }
        let title = object.$title.value
        let name = object.$name.value
        let value = "\(title) \(name)"
        field.primitiveValue = value
        return value
    }
    
    private static func keyPathsAffectingDisplayName() -> Set<String> {
        
        return [
            String(keyPath: \Person.$title),
            String(keyPath: \Person.$name)
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
                    Entity<Dog>("Dog", indexes: [[\Dog.$nickname, \Dog.$age]]),
                    Entity<Person>("Person")
                ],
                versionLock: [
                    "Animal": [0x1b59d511019695cf, 0xdeb97e86c5eff179, 0x1cfd80745646cb3, 0x4ff99416175b5b9a],
                    "Dog": [0xad6de93adc5565d, 0x7897e51253eba5a3, 0xd12b9ce0b13600f3, 0x5a4827cd794cd15e],
                    "Person": [0xf3e6ba6016bbedc6, 0x50dedf64f0eba490, 0xa32088a0ee83468d, 0xb72d1d0b37bd0992]
                ]
            )
        )
        self.prepareStack(dataStack, configurations: [nil]) { (stack) in
            
            let k1 = String(keyPath: \Animal.$species)
            XCTAssertEqual(k1, "species")

            let k2 = String(keyPath: \Dog.$species)
            XCTAssertEqual(k2, "species")
            
            let k3 = String(keyPath: \Dog.$nickname)
            XCTAssertEqual(k3, "nickname")
            
            let updateDone = self.expectation(description: "update-done")
            let fetchDone = self.expectation(description: "fetch-done")
            let willSetPriorObserverDone = self.expectation(description: "willSet-observe-prior-done")
            let willSetNotPriorObserverDone = self.expectation(description: "willSet-observe-notPrior-done")
            let didSetObserverDone = self.expectation(description: "didSet-observe-done")
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let animal = transaction.create(Into<Animal>())
                    XCTAssertEqual(animal.species, "Swift")
                    XCTAssertTrue(type(of: animal.species) == String.self)
                    XCTAssertEqual(animal.color, Color.blue)
                    
                    animal.species = "Sparrow"
                    XCTAssertEqual(animal.species, "Sparrow")
                    
                    animal.color = .yellow
                    XCTAssertEqual(animal.color, Color.yellow)

                    for property in Animal.metaProperties(includeSuperclasses: true) {

                        switch property.keyPath {

                        case String(keyPath: \Animal.$species):
                            XCTAssertTrue(property is FieldContainer<Animal>.Stored<String>)

                        case String(keyPath: \Animal.$master):
                            XCTAssertTrue(property is FieldContainer<Animal>.Relationship<Person?>)

                        case String(keyPath: \Animal.$color):
                            XCTAssertTrue(property is FieldContainer<Animal>.Coded<Color?>)

                        default:
                            XCTFail("Unknown KeyPath: \"\(property.keyPath)\"")
                        }
                    }
                    
                    let dog = transaction.create(Into<Dog>())
                    XCTAssertEqual(dog.species, "Swift")
                    XCTAssertEqual(dog.age, 1)
                    XCTAssertTrue(Dog.commonNicknames.contains(dog.nickname))

                    for property in Dog.metaProperties(includeSuperclasses: true) {

                        switch property.keyPath {

                        case String(keyPath: \Dog.$species):
                            XCTAssertTrue(property is FieldContainer<Animal>.Stored<String>)

                        case String(keyPath: \Dog.$master):
                            XCTAssertTrue(property is FieldContainer<Animal>.Relationship<Person?>)

                        case String(keyPath: \Dog.$color):
                            XCTAssertTrue(property is FieldContainer<Animal>.Coded<Color?>)

                        case String(keyPath: \Dog.$nickname):
                            XCTAssertTrue(property is FieldContainer<Dog>.Stored<String>)

                        case String(keyPath: \Dog.$age):
                            XCTAssertTrue(property is FieldContainer<Dog>.Stored<Int>)

                        case String(keyPath: \Dog.$friends):
                            XCTAssertTrue(property is FieldContainer<Dog>.Relationship<[Dog]>)

                        case String(keyPath: \Dog.$friendedBy):
                            XCTAssertTrue(property is FieldContainer<Dog>.Relationship<Set<Dog>>)

                        default:
                            XCTFail("Unknown KeyPath: \"\(property.keyPath)\"")
                        }
                    }

                    let didSetObserver = dog.observe(\.$species, options: [.new, .old]) { (object, change) in

                        XCTAssertEqual(object, dog)
                        XCTAssertEqual(change.kind, .setting)
                        XCTAssertEqual(change.newValue, "Dog")
                        XCTAssertEqual(change.oldValue, "Swift")
                        XCTAssertFalse(change.isPrior)
                        XCTAssertEqual(object.species, "Dog")
                        didSetObserverDone.fulfill()
                    }
                    let willSetObserver = dog.observe(\.$species, options: [.new, .old, .prior]) { (object, change) in

                        XCTAssertEqual(object, dog)
                        XCTAssertEqual(change.kind, .setting)
                        XCTAssertEqual(change.oldValue, "Swift")

                        if change.isPrior {

                            XCTAssertNil(change.newValue)
                            XCTAssertEqual(object.species, "Swift")
                            willSetPriorObserverDone.fulfill()
                        }
                        else {

                            XCTAssertEqual(change.newValue, "Dog")
                            XCTAssertEqual(object.species, "Dog")
                            willSetNotPriorObserverDone.fulfill()
                        }
                    }
                    
                    dog.species = "Dog"
                    XCTAssertEqual(dog.species, "Dog")

                    didSetObserver.invalidate()
                    willSetObserver.invalidate()
                    
                    dog.nickname = "Spot"
                    XCTAssertEqual(dog.nickname, "Spot")
                    
                    let person = transaction.create(Into<Person>())
                    XCTAssertTrue(person.pets.isEmpty)
                    XCTAssertEqual(person.customField.string, "customString")
                    let initialJob = person.job
                    XCTAssertTrue(Job.allCases.contains(initialJob))
                    
                    XCTAssertEqual(
                        person.rawObject!
                            .runtimeType()
                            .keyPathsForValuesAffectingValue(forKey: "displayName"),
                        ["title", "name"]
                    )
                    
                    person.name = "Joe"
                    
                    XCTAssertEqual(person.rawObject!.value(forKey: "name") as! String?, "Joe")
                    XCTAssertEqual(person.rawObject!.value(forKey: "displayName") as! String?, "Mr. Joe")
                    
                    person.rawObject!.setValue("AAAA", forKey: "displayName")
                    XCTAssertEqual(person.rawObject!.value(forKey: "displayName") as! String?, "AAAA")
                    
                    person.name = "John"
                    XCTAssertEqual(person.name, "John")
                    XCTAssertEqual(person.displayName, "Mr. John") // Custom getter
                    
                    let personSnapshot1 = person.asSnapshot(in: transaction)!
                    XCTAssertEqual(person.name, personSnapshot1.$name)
                    XCTAssertEqual(person.title, personSnapshot1.$title)
                    XCTAssertEqual(person.displayName, personSnapshot1.$displayName)
                    XCTAssertEqual(person.job, personSnapshot1.$job)
                    
                    person.title = "Sir"
                    XCTAssertEqual(person.displayName, "Sir John")
                    
                    XCTAssertEqual(personSnapshot1.$name, "John")
                    XCTAssertEqual(personSnapshot1.$title, "Mr.")
                    XCTAssertEqual(personSnapshot1.$displayName, "Mr. John")

                    person.customField.string = "newCustomString"
                    XCTAssertEqual(person.customField.string, "newCustomString")

                    person.job = .engineer
                    XCTAssertEqual(person.job, .engineer)
                    
                    let personSnapshot2 = person.asSnapshot(in: transaction)!
                    XCTAssertEqual(person.name, personSnapshot2.$name)
                    XCTAssertEqual(person.title, personSnapshot2.$title)
                    XCTAssertEqual(person.displayName, personSnapshot2.$displayName)
                    XCTAssertEqual(person.job, personSnapshot2.$job)

                    var personSnapshot3 = personSnapshot2
                    personSnapshot3.$name = "James"
                    XCTAssertEqual(personSnapshot1.$name, "John")
                    XCTAssertEqual(personSnapshot1.$displayName, "Mr. John")
                    XCTAssertEqual(personSnapshot1.$job, initialJob)
                    XCTAssertEqual(personSnapshot2.$name, "John")
                    XCTAssertEqual(personSnapshot2.$displayName, "Sir John")
                    XCTAssertEqual(personSnapshot2.$job, .engineer)
                    XCTAssertEqual(personSnapshot3.$name, "James")
                    XCTAssertEqual(personSnapshot3.$displayName, "Sir John")
                    XCTAssertEqual(personSnapshot3.$job, .engineer)
                    

                    
                    person.pets.insert(dog)
                    XCTAssertEqual(person.pets.count, 1)
                    XCTAssertEqual(person.pets.first, dog)
                    XCTAssertEqual(person.pets.first?.master, person)
                    XCTAssertEqual(dog.master, person)
                    XCTAssertEqual(dog.master?.pets.first, dog)
                },
                success: { _ in

                    let person = try! stack.fetchOne(From<Person>())
                    XCTAssertNotNil(person)

                    let personPublisher = person!.asPublisher(in: stack)
                    XCTAssertEqual(personPublisher.$name, "John")
                    XCTAssertEqual(personPublisher.$displayName, "Sir John")
                    XCTAssertEqual(personPublisher.$job, .engineer)

                    updateDone.fulfill()
                },
                failure: { _ in
                    
                    XCTFail()
                }
            )
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let p1 = Where<Animal>({ $0.$species == "Sparrow" })
                    XCTAssertEqual(p1.predicate, NSPredicate(format: "%K == %@", "species", "Sparrow"))
                    
                    let bird = try transaction.fetchOne(From<Animal>(), p1)
                    XCTAssertNotNil(bird)
                    XCTAssertEqual(bird!.species, "Sparrow")
                    XCTAssertEqual(bird!.color, Color.yellow)
                    
                    let p2 = Where<Dog>({ $0.$nickname == "Spot" })
                    XCTAssertEqual(p2.predicate, NSPredicate(format: "%K == %@", "nickname", "Spot"))
                    
                    let dog = try transaction.fetchOne(From<Dog>().where(\.$nickname == "Spot"))
                    XCTAssertNotNil(dog)
                    XCTAssertEqual(dog!.nickname, "Spot")
                    XCTAssertEqual(dog!.species, "Dog")
                    
                    let person = try transaction.fetchOne(From<Person>())
                    XCTAssertNotNil(person)
                    XCTAssertEqual(person!.name, "John")
                    XCTAssertEqual(person!.title, "Sir")
                    XCTAssertEqual(person!.displayName, "Sir John")
                    XCTAssertEqual(person!.customField.string, "customString")
                    XCTAssertEqual(person!.job, .engineer)
                    XCTAssertEqual(person!.pets.first, dog)
                    
                    let p3 = Where<Dog>({ $0.$age == 10 })
                    XCTAssertEqual(p3.predicate, NSPredicate(format: "%K == %d", "age", 10))

                    let totalAge = try transaction.queryValue(
                        From<Dog>().select(Int.self, .sum(\.$age))
                    )
                    XCTAssertEqual(totalAge, 1)
                    
                    _ = try transaction.fetchAll(
                        From<Dog>()
                            .where(\Animal.$species == "Dog" && \Dog.$age == 10)
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>()
                            .where(\Dog.$age == 10 && \Animal.$species == "Dog")
                            .orderBy(.ascending({ $0.$species }))
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        Where<Dog>({ $0.$age > 10 && $0.$age <= 15 })
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        Where<Dog>({ $0.$species == "Dog" && $0.$age == 10 })
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        Where<Dog>({ $0.$age == 10 && $0.$species == "Dog" })
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        Where<Dog>({ $0.$age > 10 && $0.$age <= 15 })
                    )
                    _ = try transaction.fetchAll(
                        From<Dog>(),
                        (\Dog.$age > 10 && \Dog.$age <= 15)
                    )
                },
                success: { _ in
            
                    fetchDone.fulfill()
                },
                failure: { _ in
                    
                    XCTFail()
                }
            )
        }
        
        self.waitForExpectations(timeout: 10, handler: { _ in })
        
        self.addTeardownBlock {
            dataStack.unsafeRemoveAllPersistentStoresAndWait()
        }
    }
    
    @objc
    dynamic func test_ThatDynamicModelKeyPaths_CanBeCreated() {
        
        XCTAssertEqual(String(keyPath: \Animal.$species), "species")
        XCTAssertEqual(String(keyPath: \Dog.$species), "species")
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
