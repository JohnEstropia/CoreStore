//
//  DynamicModelTests.swift
//  CoreStore
//
//  Created by John Estropia on 2017/04/03.
//  Copyright © 2017 John Rommel Estropia. All rights reserved.
//

import XCTest

import CoreData
import CoreStore


class DynamicModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDynamicModels_CanBeDeclaredCorrectly() {
        
        class Bird: CoreStoreManagedObject {
            
            let species = Attribute.Required<String>("species", default: "Swift")
        }
        class Mascot: Bird {
            
            let nickname = Attribute.Optional<String>("nickname")
            let year = Attribute.Required<Int>("year", default: 2016)
        }
        
        let k1 = Bird.keyPath({ $0.species })
        XCTAssertEqual(k1, "species")
        
        let k2 = Mascot.keyPath({ $0.species })
        XCTAssertEqual(k2, "species")
        
        let k3 = Mascot.keyPath({ $0.nickname })
        XCTAssertEqual(k3, "nickname")
        
        let entities = [
            "Bird": Entity<Bird>("Bird").entityDescription,
            "Mascot": Entity<Mascot>("Mascot").entityDescription
        ]
        enum Static {
            
            static let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        let rawBird = NSManagedObject(entity: entities["Bird"]!, insertInto: Static.context)
        let rawMascot = NSManagedObject(entity: entities["Mascot"]!, insertInto: Static.context)
        
        
        let bird = Bird(rawBird)
        XCTAssertEqual(bird.species*, "Swift")
        XCTAssertTrue(type(of: bird.species*) == String.self)
        
        bird.species .= "Sparrow"
        XCTAssertEqual(bird.species*, "Sparrow")
        
        let mascot = Mascot(rawMascot)
        XCTAssertEqual(mascot.species*, "Swift")
        XCTAssertEqual(mascot.nickname*, nil)
        
        mascot.nickname .= "Riko"
        XCTAssertEqual(mascot.nickname*, "Riko")
        
        
        let p1 = Bird.where({ $0.species == "Swift" })
        XCTAssertEqual(p1.predicate, Where("%K == %@", "species", "Swift").predicate)

        let p2 = Mascot.where({ $0.nickname == "Riko" })
        XCTAssertEqual(p2.predicate, Where("%K == %@", "nickname", "Riko").predicate)
        
        let p3 = Mascot.where({ $0.year == 2016 })
        XCTAssertEqual(p3.predicate, Where("%K == %@", "year", 2016).predicate)
    }
}
