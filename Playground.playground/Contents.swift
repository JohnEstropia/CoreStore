import UIKit
import CoreStore

class Animal: CoreStoreObject {
    let species = Value.Required<String>("species", initial: "Swift")
    let master = Relationship.ToOne<Person>("master")
    let color = Transformable.Optional<UIColor>("color", initial: .orange)
}

class Person: CoreStoreObject {
    let name = Value.Required<String>("name", initial: "")
    let pets = Relationship.ToManyUnordered<Animal>("pets", inverse: { $0.master })
}


let dataStack = DataStack(
    CoreStoreSchema(
        modelVersion: "V1",
        entities: [
            Entity<Animal>("Animal"),
            Entity<Person>("Person")
        ]
    )
)
try dataStack.addStorageAndWait()

dataStack.perform(synchronous: { transaction in

    let animal = transaction.create(Into<Animal>())
    animal.species .= "Sparrow"
    animal.color .= .yellow

    let person = transaction.create(Into<Person>())
    person.name .= "John"
    person.pets.value.insert(animal)
})

let bird = dataStack.fetchOne(From<Animal>().where(\.species == "Sparrow"))!
bird.species.value
bird.color.value
print(bird)

let owner = bird.master.value!
owner.name.value
owner.pets.count
print(owner)
