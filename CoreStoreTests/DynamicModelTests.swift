//
//  DynamicModelTests.swift
//  CoreStore
//
//  Created by John Estropia on 2017/04/03.
//  Copyright © 2017 John Rommel Estropia. All rights reserved.
//

import XCTest

import CoreData

@testable import CoreStore


class Animal: ManagedObject {
    
    let species = Attribute.Required<String>("species", default: "Swift")
    let master = Relationship.ToOne<Person>("master", inverse: { $0.pet })
}

class Dog: Animal {
    
    let nickname = Attribute.Optional<String>("nickname")
    let age = Attribute.Required<Int>("age", default: 1)
}

class Person: ManagedObject {
    
    let name = Attribute.Required<String>("name")
    let pet = Relationship.ToOne<Animal>("pet")
}


class DynamicModelTests: BaseTestDataTestCase {
    
    func testDynamicModels_CanBeDeclaredCorrectly() {
        
        let dataStack = DataStack(
            dynamicModel: ObjectModel(
                version: "V1",
                entities: [
                    Entity<Animal>("Animal"),
                    Entity<Dog>("Dog"),
                    Entity<Person>("Person")
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
            
            let expectation = self.expectation(description: "done")
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let animal = transaction.create(Into<Animal>())
                    XCTAssertEqual(animal.species*, "Swift")
                    XCTAssertTrue(type(of: animal.species*) == String.self)
                    
                    animal.species .= "Sparrow"
                    XCTAssertEqual(animal.species*, "Sparrow")
                    
                    let dog = transaction.create(Into<Dog>())
                    XCTAssertEqual(dog.species*, "Swift")
                    XCTAssertEqual(dog.nickname*, nil)
                    
                    dog.species .= "Dog"
                    XCTAssertEqual(dog.species*, "Dog")
                    
                    dog.nickname .= "Spot"
                    XCTAssertEqual(dog.nickname*, "Spot")
                    
                    let person = transaction.create(Into<Person>())
                    XCTAssertNil(person.pet.value)
                    
                    person.pet .= dog
                    XCTAssertEqual(person.pet.value, dog)
                    XCTAssertEqual(person.pet.value?.master.value, person)
                    XCTAssertEqual(dog.master.value, person)
                    XCTAssertEqual(dog.master.value?.pet.value, dog)
                },
                success: {
                    
                    print("done")
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
                    XCTAssertEqual(bird!.species*, "Sparrow")
                    
                    let p2 = Dog.where({ $0.nickname == "Spot" })
                    XCTAssertEqual(p2.predicate, NSPredicate(format: "%K == %@", "nickname", "Spot"))
                    
                    let dog = transaction.fetchOne(From<Dog>(), p2)
                    XCTAssertNotNil(dog)
                    XCTAssertEqual(dog!.nickname*, "Spot")
                    XCTAssertEqual(dog!.species*, "Dog")
                    
                    let person = transaction.fetchOne(From<Person>())
                    XCTAssertNotNil(person)
                    XCTAssertEqual(person!.pet.value, dog)
                    
                    let p3 = Dog.where({ $0.age == 10 })
                    XCTAssertEqual(p3.predicate, NSPredicate(format: "%K == %d", "age", 10))
                },
                success: {
            
                    expectation.fulfill()
                    withExtendedLifetime(stack, {})
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
