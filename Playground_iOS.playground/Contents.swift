import UIKit
import CoreStore
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/// Model Declaration =====
class Animal: CoreStoreObject {

    @Field.Stored("species")
    var species: String = "Swift"

    @Field.Coded("color", coder: FieldCoders.NSCoding.self)
    var color: UIColor = .orange

    @Field.Relationship("master")
    var master: Person?
}

class Person: CoreStoreObject {

    @Field.Stored("name")
    var name: String?

    @Field.Relationship("pets", inverse: \.$master)
    var pets: Set<Animal>
}
/// =======================

/// Stack setup ===========
let dataStack = DataStack(
    CoreStoreSchema(
        modelVersion: "V1",
        entities: [
            Entity<Animal>("Animal"),
            Entity<Person>("Person")
        ],
        versionLock: [
            "Animal": [0x4a201cc685d53c0a, 0x16e6c3b561577875, 0xb032e2da61c792a0, 0xa133b801051acee4],
            "Person": [0xca938eea1af4bd56, 0xbca30994506356ad, 0x7a7cc655898816ef, 0x1a4551ffedc9b214]
        ]
    )
)
dataStack.addStorage(
    SQLiteStore(fileName: "data.sqlite"),
    completion: { result in

        switch result {

        case .failure(let error):
            print(error)

        case .success:
            /// Transactions ==========
            dataStack.perform(
                asynchronous: { transaction in

                    let animal = transaction.create(Into<Animal>())
                    animal.species = "Sparrow"
                    animal.color = .yellow

                    let person = transaction.create(Into<Person>())
                    person.name = "John"
                    person.pets.insert(animal)
                },
                completion: { result in

                    switch result {

                    case .failure(let error):
                        print(error)

                    case .success:
                        /// Accessing Objects =====
                        let bird = try! dataStack.fetchOne(
                            From<Animal>()
                                .where(\.$species == "Sparrow")
                        )!
                        print(bird.species)
                        print(bird.color as Any)
                        print(bird)

                        let owner = bird.master!
                        print(owner.name as Any)
                        print(owner.pets.count)
                        print(owner)
                        /// =======================
                    }
                }
            )
            /// =======================
        }
    }
)


