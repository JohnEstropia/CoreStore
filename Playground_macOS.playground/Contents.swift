import AppKit
import CoreStore
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/// Model Declaration =====
class Animal: CoreStoreObject {
    let species = Value.Required<String>("species", initial: "Swift")
    let master = Relationship.ToOne<Person>("master")
    let color = Transformable.Optional<NSColor>("color", initial: .orange)
}

class Person: CoreStoreObject {
    let name = Value.Optional<String>("name")
    let pets = Relationship.ToManyUnordered<Animal>("pets", inverse: { $0.master })
}
/// =======================

/// Stack setup ===========
let dataStack = DataStack(
    CoreStoreSchema(
        modelVersion: "V1",
        entities: [
            Entity<Animal>("Animal"),
            Entity<Person>("Person")
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
                    animal.species .= "Sparrow"
                    animal.color .= .yellow

                    let person = transaction.create(Into<Person>())
                    person.name .= "John"
                    person.pets.value.insert(animal)
                },
                completion: { result in

                    switch result {

                    case .failure(let error):
                        print(error)

                    case .success:
                        /// Accessing Objects =====
                        let bird = try! dataStack.fetchOne(From<Animal>().where(\.species == "Sparrow"))!
                        print(bird.species.value)
                        print(bird.color.value as Any)
                        print(bird)

                        let owner = bird.master.value!
                        print(owner.name.value as Any)
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
