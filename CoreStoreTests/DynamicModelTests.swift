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


class Bird: ManagedObject {
    
    let species = Attribute.Required<String>("species", default: "Swift")
}
class Mascot: Bird {
    
    let nickname = Attribute.Optional<String>("nickname")
    let year = Attribute.Required<Int>("year", default: 2016)
}


class DynamicModelTests: BaseTestDataTestCase {
    
    func testDynamicModels_CanBeDeclaredCorrectly() {
        
        let dataStack = DataStack(
            dynamicModel: ObjectModel(
                version: "V1",
                entities: [
                    Entity<Bird>("Bird"),
                    Entity<Mascot>("Mascot")
                ]
            )
        )
        self.prepareStack(dataStack, configurations: [nil]) { (stack) in
            
            let k1 = Bird.keyPath({ $0.species })
            XCTAssertEqual(k1, "species")
            
            let k2 = Mascot.keyPath({ $0.species })
            XCTAssertEqual(k2, "species")
            
            let k3 = Mascot.keyPath({ $0.nickname })
            XCTAssertEqual(k3, "nickname")
            
            let expectation = self.expectation(description: "done")
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let bird = transaction.create(Into<Bird>())
                    XCTAssertEqual(bird.species*, "Swift")
                    XCTAssertTrue(type(of: bird.species*) == String.self)
                    
                    bird.species .= "Sparrow"
                    XCTAssertEqual(bird.species*, "Sparrow")
                    
                    let mascot = transaction.create(Into<Mascot>())
                    XCTAssertEqual(mascot.species*, "Swift")
                    XCTAssertEqual(mascot.nickname*, nil)
                    
                    mascot.nickname .= "Riko"
                    XCTAssertEqual(mascot.nickname*, "Riko")
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
                    
                    let p1 = Bird.where({ $0.species == "Sparrow" })
                    XCTAssertEqual(p1.predicate, Where("%K == %@", "species", "Sparrow").predicate)
                    
                    let bird = transaction.fetchOne(From<Bird>())
                    XCTAssertNotNil(bird)
                    XCTAssertEqual(bird!.species*, "Sparrow")
                    
                    let p2 = Mascot.where({ $0.nickname == "Riko" })
                    XCTAssertEqual(p2.predicate, Where("%K == %@", "nickname", "Riko").predicate)
                    
                    let mascot = transaction.fetchOne(From<Mascot>())
                    XCTAssertNotNil(mascot)
                    XCTAssertEqual(mascot!.nickname*, "Riko")
                    
                    let p3 = Mascot.where({ $0.year == 2016 })
                    XCTAssertEqual(p3.predicate, Where("%K == %@", "year", 2016).predicate)
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
