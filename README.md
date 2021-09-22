<p align="center">
<img alt="CoreStore" src="https://github.com/JohnEstropia/CoreStore/raw/develop/CoreStore.png" width=614 />
<br />
<br />
Unleashing the real power of Core Data with the elegance and safety of Swift
<br />
<br />
<a href="https://app.bitrise.io/app/e736852157296019#/builds"><img alt="Build Status" src="https://img.shields.io/bitrise/e736852157296019/master.svg?label=build&token=vhgAmaiF3tWZoQyFLkKM7g&logo=bitrise" /></a>
<a href="https://github.com/JohnEstropia/CoreStore/commits"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/johnestropia/corestore.svg?style=flat" /></a>
<a href="http://cocoadocs.org/docsets/CoreStore"><img alt="Platform" src="https://img.shields.io/cocoapods/p/CoreStore.svg?style=flat" /></a>
<a href="https://raw.githubusercontent.com/JohnEstropia/CoreStore/master/LICENSE"><img alt="License" src="https://img.shields.io/cocoapods/l/CoreStore.svg?style=flat" /></a>
<br /><br />Dependency managers<br />
<a href="https://cocoapods.org/pods/CoreStore"><img alt="Cocoapods compatible" src="https://img.shields.io/cocoapods/v/CoreStore.svg?style=flat&label=Cocoapods" /></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage compatible" src="https://img.shields.io/badge/Carthage-compatible-16a085.svg?style=flat" /></a>
<a href="https://swift.org/source-compatibility/#current-list-of-projects"><img alt="Swift Package Manager compatible" src="https://img.shields.io/badge/Swift_Package_Manager-compatible-orange.svg?style=flat" /></a>
<br /><br />Contact<br />
<a href="http://swift-corestore-slack.herokuapp.com/"><img alt="Join us on Slack!" src="http://swift-corestore-slack.herokuapp.com/badge.svg?logo=slack" /></a>
<a href="https://twitter.com/JohnEstropia"><img alt="Reach me on Twitter!" src="https://img.shields.io/badge/twitter-%40JohnEstropia-3498db.svg?logo=twitter" /></a>
<a href="https://github.com/sponsors/JohnEstropia"><img alt="Sponsor" src="https://img.shields.io/badge/%E2%9D%A4-Sponsor-ff69bf"></a>
<br />
</p>

* **Swift 5.5:** iOS 11+ / macOS 10.13+ / watchOS 4.0+ / tvOS 11.0+
* Previously supported Swift versions: [Swift 5.4](https://github.com/JohnEstropia/CoreStore/tree/8.0.1), [Swift 5.3](https://github.com/JohnEstropia/CoreStore/tree/7.3.1), [Swift 5.1](https://github.com/JohnEstropia/CoreStore/tree/7.0.4), [Swift 5.0](https://github.com/JohnEstropia/CoreStore/tree/6.3.2), [Swift 4.2](https://github.com/JohnEstropia/CoreStore/tree/6.2.1), [Swift 3.2](https://github.com/JohnEstropia/CoreStore/tree/4.2.3)

Upgrading from previous CoreStore versions? Check out the [🆕 features](#features) and make sure to read the [Change logs](https://github.com/JohnEstropia/CoreStore/releases).

CoreStore is part of the [Swift Source Compatibility projects](https://swift.org/source-compatibility/#current-list-of-projects).

## Contents

- [TL;DR (a.k.a. sample codes)](#tldr-aka-sample-codes)
- [Why use CoreStore?](#why-use-corestore)
- [Architecture](#architecture)
- CoreStore Tutorials (All of these have demos in the **Demo** app project!)
    - [Setting up](#setting-up)
        - [In-memory store](#in-memory-store)
        - [Local store](#local-store)
    - [Migrations](#migrations)
        - [Declaring model versions](#declaring-model-versions)
        - [Starting migrations](#starting-migrations)
        - [Progressive migrations](#progressive-migrations)
        - [Forecasting migrations](#forecasting-migrations)
        - [Custom migrations](#custom-migrations)
    - [Saving and processing transactions](#saving-and-processing-transactions)
        - [Transaction types](#transaction-types)
            - [Asynchronous transactions](#asynchronous-transactions)
            - [Synchronous transactions](#synchronous-transactions)
            - [Unsafe transactions](#unsafe-transactions)
        - [Creating objects](#creating-objects)
        - [Updating objects](#updating-objects)
        - [Deleting objects](#deleting-objects)
        - [Passing objects safely](#passing-objects-safely)
    - [Importing data](#importing-data)
    - [Fetching and querying](#fetching-and-querying)
        - [`From` clause](#from-clause)
        - [Fetching](#fetching)
            - [`Where` clause](#where-clause)
            - [`OrderBy` clause](#orderby-clause)
            - [`Tweak` clause](#tweak-clause)
        - [Querying](#querying)
            - [`Select<T>` clause](#selectt-clause)
            - [`GroupBy` clause](#groupby-clause)
    - [Logging and error reporting](#logging-and-error-reporting)
    - [Observing changes and notifications](#observing-changes-and-notifications)
        - [Observe a single property](#observe-a-single-property)
        - [Observe a single object's updates](#observe-a-single-objects-updates)
        - [Observe a single object's per-property updates](#observe-a-single-objects-per-property-updates)
        - [Observe a diffable list](#observe-a-diffable-list)
        - [Observe detailed list changes](#observe-detailed-list-changes)
    - [Type-safe `CoreStoreObject`s](#type-safe-corestoreobjects)
        - [New `@Field` Property Wrapper syntax](#new-field-property-wrapper-syntax)
            - [`@Field.Stored` ](#fieldstored)
            - [`@Field.Virtual` ](#fieldvirtual)
            - [`@Field.Coded` ](#fieldcoded)
            - [`@Field.Relationship` ](#fieldrelationship)
            - [`@Field` usage notes](#field-usage-notes)
        - [`VersionLock`s](#versionlocks)
    - [Reactive Programming](#reactive-programming)
        - [RxSwift](#rxswift)
        - 🆕[Combine](#combine)
            - 🆕[`DataStack.reactive`](#datastackreactive)
            - 🆕[`ListPublisher.reactive`](#listpublisherreactive)
            - 🆕[`ObjectPublisher.reactive`](#objectpublisherreactive)
    - 🆕[SwiftUI Utilities](#swiftui-utilities)
        - 🆕[SwiftUI Views`](#swiftui-views)
            - 🆕[`ListReader`](#listreader)
            - 🆕[`ObjectReader`](#objectreader)
        - 🆕[SwiftUI Property Wrappers](#swiftui-property-wrappers)
            - 🆕[`ListState`](#liststate)
            - 🆕[`ObjectState`](#objectstate)
        - 🆕[SwiftUI Extensions](#swiftui-extensions)
            - 🆕[`ForEach`](#foreach)
- [Roadmap](#roadmap)
- [Installation](#installation)
- [Changesets](#changesets)
- [Contact](#contact)
- [Who uses CoreStore?](#who-uses-corestore)
- [License](#license)



## TL;DR (a.k.a. sample codes)

Pure-Swift models:
```swift
class Person: CoreStoreObject {
    @Field.Stored("name")
    var name: String = ""
    
    @Field.Relationship("pets", inverse: \Dog.$master)
    var pets: Set<Dog>
}
```
(Classic `NSManagedObject`s also supported)

Setting-up with progressive migration support:
```swift
dataStack = DataStack(
    xcodeModelName: "MyStore",
    migrationChain: ["MyStore", "MyStoreV2", "MyStoreV3"]
)
```

Adding a store:
```swift
dataStack.addStorage(
    SQLiteStore(fileName: "MyStore.sqlite"),
    completion: { (result) -> Void in
        // ...
    }
)
```

Starting transactions:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let person = transaction.create(Into<Person>())
        person.name = "John Smith"
        person.age = 42
    },
    completion: { (result) -> Void in
        switch result {
        case .success: print("success!")
        case .failure(let error): print(error)
        }
    }
)
```

Fetching objects (simple):
```swift
let people = try dataStack.fetchAll(From<Person>())
```

Fetching objects (complex):
```swift
let people = try dataStack.fetchAll(
    From<Person>()
        .where(\.age > 30),
        .orderBy(.ascending(\.name), .descending(.\age)),
        .tweak({ $0.includesPendingChanges = false })
)
```

Querying values:
```swift
let maxAge = try dataStack.queryValue(
    From<Person>()
        .select(Int.self, .maximum(\.age))
)
```

But really, there's a reason I wrote this huge *README*. Read up on the details!

Check out the **Demo** app project for sample codes as well!


## Why use CoreStore?

CoreStore was (and is) heavily shaped by real-world needs of developing data-dependent apps. It enforces safe and convenient Core Data usage while letting you take advantage of the industry's encouraged best practices.

### Features

- **🆕[SwiftUI](#swiftui-utilities) and [Combine](#combine) API utilities.** `ListPublisher`s and `ObjectPublisher`s now have their `@ListState` and `@ObjectState` SwiftUI property wrappers. Combine `Publisher` s are also available through the `ListPublisher.reactive`, `ObjectPublisher.reactive`, and `DataStack.reactive` namespaces.
- **Backwards-portable [DiffableDataSources implementation](#observe-a-diffable-list)!** `UITableViews` and `UICollectionViews` now have a new ally: `ListPublisher`s provide diffable snapshots that make reloading animations very easy and very safe. Say goodbye to `UITableViews` and `UICollectionViews` reload errors!
- **💎Tight design around Swift’s code elegance and type safety.** CoreStore fully utilizes Swift's community-driven language features.
- **🚦Safer concurrency architecture.** CoreStore makes it hard to fall into common concurrency mistakes. The main `NSManagedObjectContext` is strictly read-only, while all updates are done through serial *transactions*. *(See [Saving and processing transactions](#saving-and-processing-transactions))*
- **🔍Clean fetching and querying API.** Fetching objects is easy, but querying for raw aggregates (`min`, `max`, etc.) and raw property values is now just as convenient. *(See [Fetching and querying](#fetching-and-querying))*
- **🔭Type-safe, easy to configure observers.** You don't have to deal with the burden of setting up `NSFetchedResultsController`s and KVO. As an added bonus, list and object observable types all support multiple observers. This means you can have multiple view controllers efficiently share a single resource! *(See [Observing changes and notifications](#observing-changes-and-notifications))*
- **📥Efficient importing utilities.** Map your entities once with their corresponding import source (JSON for example), and importing from *transactions* becomes elegant. Uniquing is also done with an efficient find-and-replace algorithm. *(See [Importing data](#importing-data))*
- **🗑Say goodbye to *.xcdatamodeld* files!** While CoreStore supports `NSManagedObject`s, it offers `CoreStoreObject` whose subclasses can declare type-safe properties all in Swift code without the need to maintain separate resource files for the models. As bonus, these special properties support custom types, and can be used to create type-safe keypaths and queries. *(See [Type-safe `CoreStoreObject`s](#type-safe-corestoreobjects))*
- **🔗Progressive migrations.** No need to think how to migrate from all previous model versions to your latest model. Just tell the `DataStack` the sequence of version strings (`MigrationChain`s) and CoreStore will automatically use progressive migrations when needed. *(See [Migrations](#migrations))*
- **Easier custom migrations.** Say goodbye to *.xcmappingmodel* files; CoreStore can now infer entity mappings when possible, while still allowing an easy way to write custom mappings. *(See [Migrations](#migrations))*
- **📝Plug-in your own logging framework.** Although a default logger is built-in, all logging, asserting, and error reporting can be funneled to `CoreStoreLogger` protocol implementations. *(See [Logging and error reporting](#logging-and-error-reporting))*
- **⛓Heavy support for multiple persistent stores per data stack.** CoreStore lets you manage separate stores in a single `DataStack`, just the way *.xcdatamodeld* configurations are designed to. CoreStore will also manage one stack by default, but you can create and manage as many as you need. *(See [Setting up](#setting-up))*
- **🎯Free to name entities and their class names independently.** CoreStore gets around a restriction with other Core Data wrappers where the entity name should be the same as the `NSManagedObject` subclass name. CoreStore loads entity-to-class mappings from the managed object model file, so you can assign independent names for the entities and their class names.
- **📙Full Documentation.** No magic here; all public classes, functions, properties, etc. have detailed *Apple Docs*. This *README* also introduces a lot of concepts and explains a lot of CoreStore's behavior.
- **ℹ️Informative (and pretty) logs.** All CoreStore and Core Data-related types now have very informative and pretty print outputs! *(See [Logging and error reporting](#logging-and-error-reporting))*
- **🛡More extensive Unit Tests.** Extending CoreStore is safe without having to worry about breaking old behavior.

*Have ideas that may benefit other Core Data users? [Feature Request](https://github.com/JohnEstropia/CoreStore/issues)s are welcome!*



## Architecture
For maximum safety and performance, CoreStore will enforce coding patterns and practices it was designed for. (Don't worry, it's not as scary as it sounds.) But it is advisable to understand the "magic" of CoreStore before you use it in your apps.

If you are already familiar with the inner workings of CoreData, here is a mapping of `CoreStore` abstractions:

| *Core Data* | *CoreStore* |
| --- | --- |
| `NSPersistentContainer`<br />(.xcdatamodeld file) | `DataStack` |
| `NSPersistentStoreDescription`<br />("Configuration"s in the .xcdatamodeld file) | `StorageInterface` implementations<br />(`InMemoryStore`, `SQLiteStore`) |
| `NSManagedObjectContext` | `BaseDataTransaction` subclasses<br />(`SynchronousDataTransaction`, `AsynchronousDataTransaction`, `UnsafeDataTransaction`) |

A lot of Core Data wrapper libraries set up their `NSManagedObjectContext`s this way:

<img src="https://cloud.githubusercontent.com/assets/3029684/16707160/984ef25c-4600-11e6-869f-8db7d2c63668.png" alt="nested contexts" height=380 />

Nesting saves from child context to the root context ensures maximum data integrity between contexts without blocking the main queue. But <a href="http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/">in reality</a>, merging contexts is still by far faster than saving contexts. CoreStore's `DataStack` takes the best of both worlds by treating the main `NSManagedObjectContext` as a read-only context (or "viewContext"), and only allows changes to be made within *transactions* on the child context:

<img src="https://cloud.githubusercontent.com/assets/3029684/16707161/9adeb962-4600-11e6-8bc8-4ec85764dba4.png" alt="nested contexts and merge hybrid" height=292 />

This allows for a butter-smooth main thread, while still taking advantage of safe nested contexts.



## Setting up
The simplest way to initialize CoreStore is to add a default store to the default stack:
```swift
try CoreStoreDefaults.dataStack.addStorageAndWait()
```
This one-liner does the following:
- Triggers the lazy-initialization of `CoreStoreDefaults.dataStack` with a default `DataStack`
- Sets up the stack's `NSPersistentStoreCoordinator`, the root saving `NSManagedObjectContext`, and the read-only main `NSManagedObjectContext`
- Adds an `SQLiteStore` in the *"Application Support/<bundle id>"* directory (or the *"Caches/<bundle id>"* directory on tvOS) with the file name *"[App bundle name].sqlite"*
- Creates and returns the `NSPersistentStore` instance on success, or an `NSError` on failure

For most cases, this configuration is enough as it is. But for more hardcore settings, refer to this extensive example:
```swift
let dataStack = DataStack(
    xcodeModelName: "MyModel", // loads from the "MyModel.xcdatamodeld" file
    migrationChain: ["MyStore", "MyStoreV2", "MyStoreV3"] // model versions for progressive migrations
)
let migrationProgress = dataStack.addStorage(
    SQLiteStore(
        fileURL: sqliteFileURL, // set the target file URL for the sqlite file
        configuration: "Config2", // use entities from the "Config2" configuration in the .xcdatamodeld file
        localStorageOptions: .recreateStoreOnModelMismatch // if migration paths cannot be resolved, recreate the sqlite file
    ),
    completion: { (result) -> Void in
        switch result {
        case .success(let storage):
            print("Successfully added sqlite store: \(storage)")
        case .failure(let error):
            print("Failed adding sqlite store with error: \(error)")
        }
    }
)

CoreStoreDefaults.dataStack = dataStack // pass the dataStack to CoreStore for easier access later on
```

> 💡If you have never heard of "Configurations", you'll find them in your *.xcdatamodeld* file
> <img src="https://cloud.githubusercontent.com/assets/3029684/8333192/e52cfaac-1acc-11e5-9902-08724f9f1324.png" alt="xcode configurations screenshot" height=212 />

In our sample code above, note that you don't need to do the `CoreStoreDefaults.dataStack = dataStack` line. You can just as well hold a reference to the `DataStack` like below and call all its instance methods directly:
```swift
class MyViewController: UIViewController {
    let dataStack = DataStack(xcodeModelName: "MyModel") // keep reference to the stack
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try self.dataStack.addStorageAndWait(SQLiteStore.self)
        }
        catch { // ...
        }
    }
    func methodToBeCalledLaterOn() {
        let objects = self.dataStack.fetchAll(From<MyEntity>())
        print(objects)
    }
}
```

> 💡By default, CoreStore will initialize `NSManagedObject`s from *.xcdatamodeld* files, but you can create models completely from source code using `CoreStoreObject`s and `CoreStoreSchema`.  To use this feature, refer to [Type-safe `CoreStoreObject`s](#type-safe-corestoreobjects).

Notice that in our previous examples, `addStorageAndWait(_:)` and `addStorage(_:completion:)` both accept either `InMemoryStore`, or `SQLiteStore`. These implement the `StorageInterface` protocol.

### In-memory store
The most basic `StorageInterface` concrete type is the `InMemoryStore`, which just stores objects in memory. Since `InMemoryStore`s always start with a fresh empty data, they do not need any migration information.
```swift
try dataStack.addStorageAndWait(
    InMemoryStore(
        configuration: "Config2" // optional. Use entities from the "Config2" configuration in the .xcdatamodeld file
    )
)
```
Asynchronous variant:
```swift
try dataStack.addStorage(
    InMemoryStore(
        configuration: "Config2
    ),
    completion: { storage in
        // ...
    }
)
```

(A reactive-programming variant of this method is explained in detail in the section on [`DataStack` Combine publishers](#datastackreactive))

### Local Store
The most common `StorageInterface` you will probably use is the `SQLiteStore`, which saves data in a local SQLite file.
```swift
let migrationProgress = dataStack.addStorage(
    SQLiteStore(
        fileName: "MyStore.sqlite",
        configuration: "Config2", // optional. Use entities from the "Config2" configuration in the .xcdatamodeld file
        migrationMappingProviders: [Bundle.main], // optional. The bundles that contain required .xcmappingmodel files
        localStorageOptions: .recreateStoreOnModelMismatch // optional. Provides settings that tells the DataStack how to setup the persistent store
    ),
    completion: { /* ... */ }
)
```
Refer to the *SQLiteStore.swift* source documentation for detailed explanations for each of the default values.

CoreStore can decide the default values for these properties, so `SQLiteStore`s can be initialized with no arguments:
```swift
try dataStack.addStorageAndWait(SQLiteStore())
```

(The asynchronous variant of this method is explained further in the next section on [Migrations](#starting-migrations), and a reactive-programming variant in the section on [`DataStack` Combine publishers](#datastackreactive))

The file-related properties of `SQLiteStore` are actually requirements of another protocol that it implements, the `LocalStorage` protocol:
```swift
public protocol LocalStorage: StorageInterface {
    var fileURL: NSURL { get }
    var migrationMappingProviders: [SchemaMappingProvider] { get }
    var localStorageOptions: LocalStorageOptions { get }
    func dictionary(forOptions: LocalStorageOptions) -> [String: AnyObject]?
    func cs_eraseStorageAndWait(metadata: [String: Any], soureModelHint: NSManagedObjectModel?) throws
}
```
If you have custom `NSIncrementalStore` or `NSAtomicStore` subclasses, you can implement this protocol and use it similarly to `SQLiteStore`.


## Migrations

### Declaring model versions
Model versions are now expressed as a first-class protocol, `DynamicSchema`. CoreStore currently supports the following schema classes:
- **`XcodeDataModelSchema`**: a model version with entities loaded from a *.xcdatamodeld* file.
- **`CoreStoreSchema`**: a model version created with `CoreStoreObject` entities. *(See [Type-safe `CoreStoreObject`s](#type-safe-corestore-objects))*
- **`UnsafeDataModelSchema`**: a model version created with an existing `NSManagedObjectModel` instance.

All the `DynamicSchema` for all model versions are then collected within a single `SchemaHistory` instance, which is then handed to the `DataStack`. Here are some common use cases:

**Multiple model versions grouped in a *.xcdatamodeld* file (Core Data standard method)**
```swift
CoreStoreDefaults.dataStack = DataStack(
    xcodeModelName: "MyModel",
    bundle: Bundle.main,
    migrationChain: ["MyAppModel", "MyAppModelV2", "MyAppModelV3", "MyAppModelV4"]
)
```

**`CoreStoreSchema`-based model version (No *.xcdatamodeld* file needed)**
*(For more details, see also [Type-safe `CoreStoreObject`s](#type-safe-corestore-objects))*
```swift
class Animal: CoreStoreObject {
    // ...
}
class Dog: Animal {
    // ...
}
class Person: CoreStoreObject {
    // ...
}

CoreStoreDefaults.dataStack = DataStack(
    CoreStoreSchema(
        modelVersion: "V1",
        entities: [
            Entity<Animal>("Animal", isAbstract: true),
            Entity<Dog>("Dog"),
            Entity<Person>("Person")
        ]
    )
)
```

**Models in a *.xcdatamodeld* file during past app versions, but migrated to the new `CoreStoreSchema` method**
```swift
class Animal: CoreStoreObject {
    // ...
}
class Dog: Animal {
    // ...
}
class Person: CoreStoreObject {
    // ...
}

let legacySchema = XcodeDataModelSchema.from(
    modelName: "MyModel", // .xcdatamodeld name
    bundle: bundle,
    migrationChain: ["MyAppModel", "MyAppModelV2", "MyAppModelV3", "MyAppModelV4"]
)
let newSchema = CoreStoreSchema(
    modelVersion: "V1",
    entities: [
        Entity<Animal>("Animal", isAbstract: true),
        Entity<Dog>("Dog"),
        Entity<Person>("Person")
    ]
)
CoreStoreDefaults.dataStack = DataStack(
    schemaHistory: SchemaHistory(
        legacySchema + [newSchema],
        migrationChain: ["MyAppModel", "MyAppModelV2", "MyAppModelV3", "MyAppModelV4", "V1"] 
    )
)   
```

**`CoreStoreSchema`-based model versions with progressive migration**
```swift
typealias Animal = V2.Animal
typealias Dog = V2.Dog
typealias Person = V2.Person
enum V2 {
    class Animal: CoreStoreObject {
        // ...
    }
    class Dog: Animal {
        // ...
    }
    class Person: CoreStoreObject {
        // ...
    }
}
enum V1 {
    class Animal: CoreStoreObject {
        // ...
    }
    class Dog: Animal {
        // ...
    }
    class Person: CoreStoreObject {
        // ...
    }
}

CoreStoreDefaults.dataStack = DataStack(
    CoreStoreSchema(
        modelVersion: "V1",
        entities: [
            Entity<V1.Animal>("Animal", isAbstract: true),
            Entity<V1.Dog>("Dog"),
            Entity<V1.Person>("Person")
        ]
    ),
    CoreStoreSchema(
        modelVersion: "V2",
        entities: [
            Entity<V2.Animal>("Animal", isAbstract: true),
            Entity<V2.Dog>("Dog"),
            Entity<V2.Person>("Person")
        ]
    ),
    migrationChain: ["V1", "V2"]
)
```


### Starting migrations
We have seen `addStorageAndWait(...)` used to initialize our persistent store. As the method name's *~AndWait* suffix suggests though, this method blocks so it should not do long tasks such as data migrations. In fact CoreStore will only attempt a synchronous **lightweight** migration if you explicitly provide the `.allowSynchronousLightweightMigration` option:
```swift
try dataStack.addStorageAndWait(
    SQLiteStore(
        fileURL: sqliteFileURL,
        localStorageOptions: .allowSynchronousLightweightMigration
    )
}
```
if you do so, any model mismatch will be thrown as an error. 

In general though, if migrations are expected the asynchronous variant `addStorage(_:completion:)` method is recommended instead:
```swift
let migrationProgress: Progress? = try dataStack.addStorage(
    SQLiteStore(
        fileName: "MyStore.sqlite",
        configuration: "Config2"
    ),
    completion: { (result) -> Void in
        switch result {
        case .success(let storage):
            print("Successfully added sqlite store: \(storage)")
        case .failure(let error):
            print("Failed adding sqlite store with error: \(error)")
        }
    }
)
```
The `completion` block reports a `SetupResult` that indicates success or failure.

(A reactive-programming variant of this method is explained further in the section on [`DataStack` Combine publishers](#datastackreactive))

Notice that this method also returns an optional `Progress`. If `nil`, no migrations are needed, thus progress reporting is unnecessary as well. If not `nil`, you can use this to track migration progress by using standard KVO on the `"fractionCompleted"` key, or by using a closure-based utility exposed in *Progress+Convenience.swift*:
```swift
migrationProgress?.setProgressHandler { [weak self] (progress) -> Void in
    self?.progressView?.setProgress(Float(progress.fractionCompleted), animated: true)
    self?.percentLabel?.text = progress.localizedDescription // "50% completed"
    self?.stepLabel?.text = progress.localizedAdditionalDescription // "0 of 2"
}
```
This closure is executed on the main thread so UIKit and AppKit calls can be done safely.


### Progressive migrations
By default, CoreStore uses Core Data's default automatic migration mechanism. In other words, CoreStore will try to migrate the existing persistent store until it matches the `SchemaHistory`'s `currentModelVersion`. If no mapping model path is found from the store's version to the data model's version, CoreStore gives up and reports an error.

The `DataStack` lets you specify hints on how to break a migration into several sub-migrations using a `MigrationChain`. This is typically passed to the `DataStack` initializer and will be applied to all stores added to the `DataStack` with `addSQLiteStore(...)` and its variants:
```swift
let dataStack = DataStack(migrationChain: 
    ["MyAppModel", "MyAppModelV2", "MyAppModelV3", "MyAppModelV4"])
```
The most common usage is to pass in the model version (*.xcdatamodeld* version names for `NSManagedObject`s, or the `modelName` for `CoreStoreSchema`s) in increasing order as above.

For more complex, non-linear migration paths, you can also pass in a version tree that maps the key-values to the source-destination versions:
```swift
let dataStack = DataStack(migrationChain: [
    "MyAppModel": "MyAppModelV3",
    "MyAppModelV2": "MyAppModelV4",
    "MyAppModelV3": "MyAppModelV4"
])
```
This allows for different migration paths depending on the starting version. The example above resolves to the following paths:
- MyAppModel-MyAppModelV3-MyAppModelV4
- MyAppModelV2-MyAppModelV4
- MyAppModelV3-MyAppModelV4

Initializing with empty values (either `nil`, `[]`, or `[:]`) instructs the `DataStack` to disable progressive migrations and revert to the default migration behavior (i.e. use the *.xcdatamodeld*'s current version as the final version):
```swift
let dataStack = DataStack(migrationChain: nil)
```

The `MigrationChain` is validated when passed to the `DataStack` and unless it is empty, will raise an assertion if any of the following conditions are met:
- a version appears twice in an array
- a version appears twice as a key in a dictionary literal
- a loop is found in any of the paths

> ⚠️**Important: If a `MigrationChain` is specified, the *.xcdatamodeld*'s "Current Version" will be bypassed** and the `MigrationChain`'s leafmost version will be the `DataStack`'s base model version.


### Forecasting migrations

Sometimes migrations are huge and you may want prior information so your app could display a loading screen, or to display a confirmation dialog to the user. For this, CoreStore provides a `requiredMigrationsForStorage(_:)` method you can use to inspect a persistent store before you actually call `addStorageAndWait(_:)` or `addStorage(_:completion:)`:
```swift
do {
    let storage = SQLiteStorage(fileName: "MyStore.sqlite")
    let migrationTypes: [MigrationType] = try dataStack.requiredMigrationsForStorage(storage)
    if migrationTypes.count > 1
        || (migrationTypes.filter { $0.isHeavyweightMigration }.count) > 0 {
        // ... will migrate more than once. Show special waiting screen
    }
    else if migrationTypes.count > 0 {
        // ... will migrate just once. Show simple activity indicator
    }
    else {
        // ... Do nothing
    }
    dataStack.addStorage(storage, completion: { /* ... */ })
}
catch {
    // ... either inspection of the store failed, or if no mapping model was found/inferred
}
```
`requiredMigrationsForStorage(_:)` returns an array of `MigrationType`s, where each item in the array may be either of the following values:
```swift
case lightweight(sourceVersion: String, destinationVersion: String)
case heavyweight(sourceVersion: String, destinationVersion: String)
```
Each `MigrationType` indicates the migration type for each step in the `MigrationChain`. Use these information as fit for your app.


### Custom migrations

CoreStore offers several ways to declare migration mappings:

- `CustomSchemaMappingProvider`: A mapping provider that infers mapping initially, but also accepts custom mappings for specified entities. This was added to support custom migrations with `CoreStoreObject`s as well, but may also be used with `NSManagedObject`s.
- `XcodeSchemaMappingProvider`: A mapping provider which loads entity mappings from *.xcmappingmodel* files in a specified `Bundle`.
- `InferredSchemaMappingProvider`: The default mapping provider which tries to infer model migration between two `DynamicSchema` versions either by searching all *.xcmappingmodel* files from `Bundle.allBundles`, or by relying on lightweight migration if possible.

These mapping providers conform to `SchemaMappingProvider` and can be passed to `SQLiteStore`'s initializer:
```swift
let dataStack = DataStack(migrationChain: ["MyAppModel", "MyAppModelV2", "MyAppModelV3", "MyAppModelV4"])
_ = try dataStack.addStorage(
    SQLiteStore(
        fileName: "MyStore.sqlite",
        migrationMappingProviders: [
            XcodeSchemaMappingProvider(from: "V1", to: "V2", mappingModelBundle: Bundle.main),
            CustomSchemaMappingProvider(from: "V2", to: "V3", entityMappings: [.deleteEntity("Person") ])
        ]
    ),
    completion: { (result) -> Void in
        // ...
    }
)
```

For version migrations present in the `DataStack`'s `MigrationChain` but not handled by any of the `SQLiteStore`'s `migrationMappingProviders` array, CoreStore will automatically try to use `InferredSchemaMappingProvider` as fallback. Finally if the `InferredSchemaMappingProvider` could not resolve any mapping, the migration will fail and the `DataStack.addStorage(...)` method will report the failure.

For `CustomSchemaMappingProvider`, more granular updates are supported through the dynamic objects `UnsafeSourceObject` and `UnsafeDestinationObject`. The example below allows the migration to conditionally ignore some objects:
```swift
let person_v2_to_v3_mapping = CustomSchemaMappingProvider(
    from: "V2",
    to: "V3",
    entityMappings: [
        .transformEntity(
            sourceEntity: "Person",
            destinationEntity: "Person",
            transformer: { (sourceObject: UnsafeSourceObject, createDestinationObject: () -> UnsafeDestinationObject) in
                
                if (sourceObject["isVeryOldAccount"] as! Bool?) == true {
                    return // this account is too old, don't migrate 
                }
                // migrate the rest
                let destinationObject = createDestinationObject()
                destinationObject.enumerateAttributes { (attribute, sourceAttribute) in
                
                if let sourceAttribute = sourceAttribute {
                    destinationObject[attribute] = sourceObject[sourceAttribute]
                }
            }
        ) 
    ]
)
SQLiteStore(
    fileName: "MyStore.sqlite",
    migrationMappingProviders: [person_v2_to_v3_mapping]
)
```
The `UnsafeSourceObject` is a read-only proxy for an object existing in the source model version. The `UnsafeDestinationObject` is a read-write object that is inserted (optionally) to the destination model version. Both classes' properties are accessed through key-value-coding.


## Saving and processing transactions
To ensure deterministic state for objects in the read-only `NSManagedObjectContext`, CoreStore does not expose API's for updating and saving directly from the main context (or any other context for that matter.) Instead, you spawn *transactions* from `DataStack` instances:
```swift
let dataStack = self.dataStack
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        // make changes
    },
    completion: { (result) -> Void in
        // ...
    }
)
```
Transaction closures automatically save changes once the closures completes. To cancel and rollback a transaction, throw a `CoreStoreError.userCancelled` from inside the closure by calling `try transaction.cancel()`:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        // ...
        if shouldCancel {
            try transaction.cancel()
        }
        // ...
    },
    completion: { (result) -> Void in
        if case .failure(.userCancelled) = result {
            // ... cancelled
        }
    }
)
```
> ⚠️**Important:** Never use `try?` or `try!` on a `transaction.cancel()` call. Always use `try`. Using `try?` will swallow the cancellation and the transaction will proceed to save as normal. Using `try!` will crash the app as `transaction.cancel()` will *always* throw an error.

The examples above use `perform(asynchronous:...)`, but there are actually 3 types of transactions at your disposal: *asynchronous*, *synchronous*, and *unsafe*.

### Transaction types

#### Asynchronous transactions
are spawned from `perform(asynchronous:...)`. This method returns immediately and executes its closure from a background serial queue. The return value for the closure is declared as a generic type, so any value returned from the closure can be passed to the completion result:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Bool in
        // make changes
        return transaction.hasChanges
    },
    completion: { (result) -> Void in
        switch result {
        case .success(let hasChanges): print("success! Has changes? \(hasChanges)")
        case .failure(let error): print(error)
        }
    }
)
```
The success and failure can also be declared as separate handlers:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Int in
        // make changes
        return transaction.delete(objects)
    },
    success: { (numberOfDeletedObjects: Int) -> Void in
        print("success! Deleted \(numberOfDeletedObjects) objects")
    },
    failure: { (error) -> Void in
        print(error)
    }
)
```

> ⚠️Be careful when returning `NSManagedObject`s or `CoreStoreObject`s from the transaction closure. Those instances are for the transaction's use only. See [Passing objects safely](#passing-objects-safely).

Transactions created from `perform(asynchronous:...)` are instances of `AsynchronousDataTransaction`.

#### Synchronous transactions
are created from `perform(synchronous:...)`. While the syntax is similar to its asynchronous counterpart, `perform(synchronous:...)` waits for its transaction block to complete before returning:
```swift
let hasChanges = dataStack.perform(
    synchronous: { (transaction) -> Bool in
        // make changes
        return transaction.hasChanges
    }
)
```
`transaction` above is a `SynchronousDataTransaction` instance.

Since `perform(synchronous:...)` technically blocks two queues (the caller's queue and the transaction's background queue), it is considered less safe as it's more prone to deadlock. Take special care that the closure does not block on any other external queues.

By default, `perform(synchronous:...)` will wait for observers such as `ListMonitor`s to be notified before the method returns. This may cause deadlocks, especially if you are calling this from the main thread. To reduce this risk, you may try to set the `waitForAllObservers:` parameter to `false`. Doing so tells the `SynchronousDataTransaction` to block only until it completes saving. It will not wait for other context's to receive those changes. This reduces deadlock risk but may have surprising side-effects:
```swift
dataStack.perform(
    synchronous: { (transaction) in
        let person = transaction.create(Into<Person>())
        person.name = "John"
    },
    waitForAllObservers: false
)
let newPerson = dataStack.fetchOne(From<Person>.where(\.name == "John"))
// newPerson may be nil!
// The DataStack may have not yet received the update notification.
```
Due to this complicated nature of synchronous transactions, if your app has very heavy transaction throughput it is highly recommended to use [asynchronous transactions](#asynchronous-transactions) instead.

#### Unsafe transactions
are special in that they do not enclose updates within a closure:
```swift
let transaction = dataStack.beginUnsafe()
// make changes
downloadJSONWithCompletion({ (json) -> Void in

    // make other changes
    transaction.commit()
})
downloadAnotherJSONWithCompletion({ (json) -> Void in

    // make some other changes
    transaction.commit()
})
```
This allows for non-contiguous updates. Do note that this flexibility comes with a price: you are now responsible for managing concurrency for the transaction. As uncle Ben said, "with great power comes great race conditions."

As the above example also shows, with unsafe transactions `commit()` can be called multiple times.


You've seen how to create transactions, but we have yet to see how to make *creates*, *updates*, and *deletes*. The 3 types of transactions above are all subclasses of `BaseDataTransaction`, which implements the methods shown below.

### Creating objects

The `create(...)` method accepts an `Into` clause which specifies the entity for the object you want to create:
```swift
let person = transaction.create(Into<MyPersonEntity>())
```
While the syntax is straightforward, CoreStore does not just naively insert a new object. This single line does the following:
- Checks that the entity type exists in any of the transaction's parent persistent store
- If the entity belongs to only one persistent store, a new object is inserted into that store and returned from `create(...)`
- If the entity does not belong to any store, an assertion failure will be raised. **This is a programmer error and should never occur in production code.**
- If the entity belongs to multiple stores, an assertion failure will be raised. **This is also a programmer error and should never occur in production code.** Normally, with Core Data you can insert an object in this state but saving the `NSManagedObjectContext` will always fail. CoreStore checks this for you at creation time when it makes sense (not during save).

If the entity exists in multiple configurations, you need to provide the configuration name for the destination persistent store:
```swift
let person = transaction.create(Into<MyPersonEntity>("Config1"))
```
or if the persistent store is the auto-generated "Default" configuration, specify `nil`:
```swift
let person = transaction.create(Into<MyPersonEntity>(nil))
```
Note that if you do explicitly specify the configuration name, CoreStore will only try to insert the created object to that particular store and will fail if that store is not found; it will not fall back to any other configuration that the entity belongs to. 

### Updating objects

After creating an object from the transaction, you can simply update its properties as normal:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let person = transaction.create(Into<MyPersonEntity>())
        person.name = "John Smith"
        person.age = 30
    },
    completion: { _ in }
)
```
To update an existing object, fetch the object's instance from the transaction:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let person = try transaction.fetchOne(
            From<MyPersonEntity>()
                .where(\.name == "Jane Smith")
        )
        person.age = person.age + 1
    },
    completion: { _ in }
)
```
*(For more about fetching, see [Fetching and querying](#fetching-and-querying))*

**Do not update an instance that was not created/fetched from the transaction.** If you have a reference to the object already, use the transaction's `edit(...)` method to get an editable proxy instance for that object:
```swift
let jane: MyPersonEntity = // ...

dataStack.perform(
    asynchronous: { (transaction) -> Void in
        // WRONG: jane.age = jane.age + 1
        // RIGHT:
        let jane = transaction.edit(jane)! // using the same variable name protects us from misusing the non-transaction instance
        jane.age = jane.age + 1
    },
    completion: { _ in }
)
```
This is also true when updating an object's relationships. Make sure that the object assigned to the relationship is also created/fetched from the transaction:
```swift
let jane: MyPersonEntity = // ...
let john: MyPersonEntity = // ...

dataStack.perform(
    asynchronous: { (transaction) -> Void in
        // WRONG: jane.friends = [john]
        // RIGHT:
        let jane = transaction.edit(jane)!
        let john = transaction.edit(john)!
        jane.friends = NSSet(array: [john])
    },
    completion: { _ in }
)
```

### Deleting objects

Deleting an object is simpler because you can tell a transaction to delete an object directly without fetching an editable proxy (CoreStore does that for you):
```swift
let john: MyPersonEntity = // ...

dataStack.perform(
    asynchronous: { (transaction) -> Void in
        transaction.delete(john)
    },
    completion: { _ in }
)
```
or several objects at once:
```swift
let john: MyPersonEntity = // ...
let jane: MyPersonEntity = // ...

dataStack.perform(
    asynchronous: { (transaction) -> Void in
        try transaction.delete(john, jane)
        // try transaction.delete([john, jane]) is also allowed
    },
    completion: { _ in }
)
```
If you do not have references yet to the objects to be deleted, transactions have a `deleteAll(...)` method you can pass a query to:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        try transaction.deleteAll(
            From<MyPersonEntity>()
                .where(\.age > 30)
        )
    },
    completion: { _ in }
)
```

### Passing objects safely

Always remember that the `DataStack` and individual transactions manage different `NSManagedObjectContext`s so you cannot just use objects between them. That's why transactions have an `edit(...)` method:
```swift
let jane: MyPersonEntity = // ...

dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let jane = transaction.edit(jane)!
        jane.age = jane.age + 1
    },
    completion: { _ in }
)
```
But `CoreStore`, `DataStack` and `BaseDataTransaction` have a very flexible `fetchExisting(...)` method that you can pass instances back and forth with:
```swift
let jane: MyPersonEntity = // ...

dataStack.perform(
    asynchronous: { (transaction) -> MyPersonEntity in
        let jane = transaction.fetchExisting(jane)! // instance for transaction
        jane.age = jane.age + 1
        return jane
    },
    success: { (transactionJane) in
        let jane = dataStack.fetchExisting(transactionJane)! // instance for DataStack
        print(jane.age)
    },
    failure: { (error) in
        // ...
    }
)
```
`fetchExisting(...)` also works with multiple `NSManagedObject`s, `CoreStoreObject`s, or with `NSManagedObjectID`s:
```swift
var peopleIDs: [NSManagedObjectID] = // ...

dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let jane = try transaction.fetchOne(
            From<MyPersonEntity>()
                .where(\.name == "Jane Smith")
        )
        jane.friends = NSSet(array: transaction.fetchExisting(peopleIDs)!)
        // ...
    },
    completion: { _ in }
)
```


## Importing data
Some times, if not most of the time, the data that we save to Core Data comes from external sources such as web servers or external files. If you have a JSON dictionary for example, you may be extracting values as such:
```swift
let json: [String: Any] = // ...
person.name = json["name"] as? NSString
person.age = json["age"] as? NSNumber
// ...
```
If you have many attributes, you don't want to keep repeating this mapping everytime you want to import data. CoreStore lets you write the data mapping code just once, and all you have to do is call `importObject(...)` or `importUniqueObject(...)` through `BaseDataTransaction` subclasses:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let json: [String: Any] = // ...
        try! transaction.importObject(
            Into<MyPersonEntity>(),
            source: json
        )
    },
    completion: { _ in }
)
```
To support data import for an entity, implement either `ImportableObject` or `ImportableUniqueObject` on the `NSManagedObject` or `CoreStoreObject` subclass:
- `ImportableObject`: Use this protocol if the object have no inherent uniqueness and new objects should always be added when calling `importObject(...)`.
- `ImportableUniqueObject`: Use this protocol to specify a unique ID for an object that will be used to distinguish whether a new object should be created or if an existing object should be updated when calling `importUniqueObject(...)`.

Both protocols require implementers to specify an `ImportSource` which can be set to any type that the object can extract data from:
```swift
typealias ImportSource = NSDictionary
```
```swift
typealias ImportSource = [String: Any]
```
```swift
typealias ImportSource = NSData
```
You can even use external types from popular 3rd-party JSON libraries, or just simple tuples or primitives.

#### `ImportableObject`
`ImportableObject` is a very simple protocol:
```swift
public protocol ImportableObject: AnyObject {
    typealias ImportSource
    static func shouldInsert(from source: ImportSource, in transaction: BaseDataTransaction) -> Bool
    func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws
}
```
First, set `ImportSource` to the expected type of the data source:
```swift
typealias ImportSource = [String: Any]
```
This lets us call `importObject(_:source:)` with any `[String: Any]` type as the argument to `source`:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let json: [String: Any] = // ...
        try! transaction.importObject(
            Into<MyPersonEntity>(),
            source: json
        )
        // ...
    },
    completion: { _ in }
)
```
The actual extraction and assignment of values should be implemented in the `didInsert(from:in:)` method of the `ImportableObject` protocol:
```swift
func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
    self.name = source["name"] as? NSString
    self.age = source["age"] as? NSNumber
    // ...
}
```
Transactions also let you import multiple objects at once using the `importObjects(_:sourceArray:)` method:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let jsonArray: [[String: Any]] = // ...
        try! transaction.importObjects(
            Into<MyPersonEntity>(),
            sourceArray: jsonArray // make sure this is of type Array<MyPersonEntity.ImportSource>
        )
        // ...
    },
    completion: { _ in }
)
```
Doing so tells the transaction to iterate through the array of import sources and calls `shouldInsert(from:in:)` on the `ImportableObject` to determine which instances should be created. You can do validations and return `false` from `shouldInsert(from:in:)` if you want to skip importing from a source and continue on with the other sources in the array.

If on the other hand, your validation in one of the sources failed in such a manner that all other sources should also be rolled back and cancelled, you can `throw` from within `didInsert(from:in:)`:
```swift
func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
    self.name = source["name"] as? NSString
    self.age = source["age"] as? NSNumber
    // ...
    if self.name == nil {
        throw Errors.InvalidNameError
    }
}
```
Doing so can let you abandon an invalid transaction immediately:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let jsonArray: [[String: Any]] = // ...

        try transaction.importObjects(
            Into<MyPersonEntity>(),
            sourceArray: jsonArray
        )
    },
    success: {
        // ...
    },
    failure: { (error) in
        switch error {
        case Errors.InvalidNameError: print("Invalid name")
        // ...
        }
    }
)
```

#### `ImportableUniqueObject`
Typically, we don't just keep creating objects every time we import data. Usually we also need to update already existing objects. Implementing the `ImportableUniqueObject` protocol lets you specify a "unique ID" that transactions can use to search existing objects before creating new ones:
```swift
public protocol ImportableUniqueObject: ImportableObject {
    typealias ImportSource
    typealias UniqueIDType: ImportableAttributeType

    static var uniqueIDKeyPath: String { get }
    var uniqueIDValue: UniqueIDType { get set }

    static func shouldInsert(from source: ImportSource, in transaction: BaseDataTransaction) -> Bool
    static func shouldUpdate(from source: ImportSource, in transaction: BaseDataTransaction) -> Bool
    static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> UniqueIDType?
    func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws
    func update(from source: ImportSource, in transaction: BaseDataTransaction) throws
}
```
Notice that it has the same insert methods as `ImportableObject`, with additional methods for updates and for specifying the unique ID:
```swift
class var uniqueIDKeyPath: String {
    return #keyPath(MyPersonEntity.personID) 
}
var uniqueIDValue: Int { 
    get { return self.personID }
    set { self.personID = newValue }
}
class func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> Int? {
    return source["id"] as? Int
}
```
For `ImportableUniqueObject`, the extraction and assignment of values should be implemented from the `update(from:in:)` method. The `didInsert(from:in:)` by default calls `update(from:in:)`, but you can separate the implementation for inserts and updates if needed.

You can then create/update an object by calling a transaction's `importUniqueObject(...)` method:
```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let json: [String: Any] = // ...
        try! transaction.importUniqueObject(
            Into<MyPersonEntity>(),
            source: json
        )
        // ...
    },
    completion: { _ in }
)
```
or multiple objects at once with the `importUniqueObjects(...)` method:

```swift
dataStack.perform(
    asynchronous: { (transaction) -> Void in
        let jsonArray: [[String: AnyObject]] = // ...
        try! transaction.importUniqueObjects(
            Into<MyPersonEntity>(),
            sourceArray: jsonArray
        )
        // ...
    },
    completion: { _ in }
)
```
As with `ImportableObject`, you can control whether to skip importing an object by implementing 
`shouldInsert(from:in:)` and `shouldUpdate(from:in:)`, or to cancel all objects by `throw`ing an error from the `uniqueID(from:in:)`, `didInsert(from:in:)` or `update(from:in:)` methods.


## Fetching and Querying
Before we dive in, be aware that CoreStore distinguishes between *fetching* and *querying*:
- A *fetch* executes searches from a specific *transaction* or *data stack*. This means fetches can include pending objects (i.e. before a transaction calls on `commit()`.) Use fetches when:
    - results need to be `NSManagedObject` or `CoreStoreObject` instances
    - unsaved objects should be included in the search (though fetches can be configured to exclude unsaved ones)
- A *query* pulls data straight from the persistent store. This means faster searches when computing aggregates such as *count*, *min*, *max*, etc. Use queries when:
    - you need to compute aggregate functions (see below for a list of supported functions)
    - results can be raw values like `NSString`s, `NSNumber`s, `Int`s, `NSDate`s, an `NSDictionary` of key-values, or any type that conform to `QueryableAttributeType`. (See *QueryableAttributeType.swift* for a list of built-in types)
    - only values for specified attribute keys need to be included in the results
    - unsaved objects should be ignored

#### `From` clause
The search conditions for fetches and queries are specified using *clauses*. All fetches and queries require a `From` clause that indicates the target entity type:
```swift
let people = try dataStack.fetchAll(From<MyPersonEntity>())
```
`people` in the example above will be of type `[MyPersonEntity]`. The `From<MyPersonEntity>()` clause indicates a fetch to all persistent stores that `MyPersonEntity` belong to.

If the entity exists in multiple configurations and you need to only search from a particular configuration, indicate in the `From` clause the configuration name for the destination persistent store:
```swift
let people = try dataStack.fetchAll(From<MyPersonEntity>("Config1")) // ignore objects in persistent stores other than the "Config1" configuration
```
or if the persistent store is the auto-generated "Default" configuration, specify `nil`:
```swift
let person = try dataStack.fetchAll(From<MyPersonEntity>(nil))
```
Now we know how to use a `From` clause, let's move on to fetching and querying.

### Fetching

There are currently 5 fetch methods you can call from `CoreStore`, from a `DataStack` instance, or from a `BaseDataTransaction` instance. All of the methods below accept the same parameters: a required `From` clause, and an optional series of `Where`, `OrderBy`, and/or `Tweak` clauses.

- `fetchAll(...)` - returns an array of all objects that match the criteria.
- `fetchOne(...)` - returns the first object that match the criteria.
- `fetchCount(...)` - returns the number of objects that match the criteria.
- `fetchObjectIDs(...)` - returns an array of `NSManagedObjectID`s for all objects that match the criteria.
- `fetchObjectID(...)` - returns the `NSManagedObjectID`s for the first objects that match the criteria.

Each method's purpose is straightforward, but we need to understand how to set the clauses for the fetch.

#### `Where` clause

The `Where` clause is CoreStore's `NSPredicate` wrapper. It specifies the search filter to use when fetching (or querying). It implements all initializers that `NSPredicate` does (except for `-predicateWithBlock:`, which Core Data does not support):
```swift
var people = try dataStack.fetchAll(
    From<MyPersonEntity>(),
    Where<MyPersonEntity>("%K > %d", "age", 30) // string format initializer
)
people = try dataStack.fetchAll(
    From<MyPersonEntity>(),
    Where<MyPersonEntity>(true) // boolean initializer
)
```
If you do have an existing `NSPredicate` instance already, you can pass that to `Where` as well:
```swift
let predicate = NSPredicate(...)
var people = dataStack.fetchAll(
    From<MyPersonEntity>(),
    Where<MyPersonEntity>(predicate) // predicate initializer
)
```
 `Where` clauses are generic types. To avoid verbose repetition of the generic object type, fetch methods support **Fetch Chain builders**. We can also use Swift's Smart KeyPaths as the `Where` clause expression:
```swift
var people = try dataStack.fetchAll(
    From<MyPersonEntity>()
        .where(\.age > 30) // Type-safe!
)
```
`Where` clauses also implement the `&&`, `||`, and `!` logic operators, so you can provide logical conditions without writing too much `AND`, `OR`, and `NOT` strings:
```swift
var people = try dataStack.fetchAll(
    From<MyPersonEntity>()
        .where(\.age > 30 && \.gender == "M")
)
```
If you do not provide a `Where` clause, all objects that belong to the specified `From` will be returned.

#### `OrderBy` clause

The `OrderBy` clause is CoreStore's `NSSortDescriptor` wrapper. Use it to specify attribute keys in which to sort the fetch (or query) results with.
```swift
var mostValuablePeople = try dataStack.fetchAll(
    From<MyPersonEntity>(),
    OrderBy<MyPersonEntity>(.descending("rating"), .ascending("surname"))
)
```
As seen above, `OrderBy` accepts a list of `SortKey` enumeration values, which can be either `.ascending` or `.descending`.
As with `Where` clauses, `OrderBy` clauses are also generic types. To avoid verbose repetition of the generic object type, fetch methods support **Fetch Chain builders**. We can also use Swift's Smart KeyPaths as the `OrderBy` clause expression:
```swift
var people = try dataStack.fetchAll(
    From<MyPersonEntity>()
        .orderBy(.descending(\.rating), .ascending(\.surname)) // Type-safe!
)
```

You can use the `+` and `+=` operator to append `OrderBy`s together. This is useful when sorting conditionally:
```swift
var orderBy = OrderBy<MyPersonEntity>(.descending(\.rating))
if sortFromYoungest {
    orderBy += OrderBy(.ascending(\.age))
}
var mostValuablePeople = try dataStack.fetchAll(
    From<MyPersonEntity>(),
    orderBy
)
```

#### `Tweak` clause

The `Tweak` clause lets you, uh, *tweak* the fetch (or query). `Tweak` exposes the `NSFetchRequest` in a closure where you can make changes to its properties:
```swift
var people = try dataStack.fetchAll(
    From<MyPersonEntity>(),
    Where<MyPersonEntity>("age > %d", 30),
    OrderBy<MyPersonEntity>(.ascending("surname")),
    Tweak { (fetchRequest) -> Void in
        fetchRequest.includesPendingChanges = false
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.includesSubentities = false
    }
)
```
`Tweak` also supports **Fetch Chain builders**:
```swift
var people = try dataStack.fetchAll(
    From<MyPersonEntity>(),
        .where(\.age > 30)
        .orderBy(.ascending(\.surname))
        .tweak {
            $0.includesPendingChanges = false
            $0.returnsObjectsAsFaults = false
            $0.includesSubentities = false
        }
)
```
The clauses are evaluated the order they appear in the fetch/query, so you typically need to set `Tweak` as the last clause.
`Tweak`'s closure is executed only just before the fetch occurs, so make sure that any values captured by the closure is not prone to race conditions.

While `Tweak` lets you micro-configure the `NSFetchRequest`, note that CoreStore already preconfigured that `NSFetchRequest` to suitable defaults. Only use `Tweak` when you know what you are doing!

### Querying

One of the functionalities overlooked by other Core Data wrapper libraries is raw properties fetching. If you are familiar with `NSDictionaryResultType` and `-[NSFetchedRequest propertiesToFetch]`, you probably know how painful it is to setup a query for raw values and aggregate values. CoreStore makes this easy by exposing the 2 methods below:

- `queryValue(...)` - returns a single raw value for an attribute or for an aggregate value. If there are multiple results, `queryValue(...)` only returns the first item.
- `queryAttributes(...)` - returns an array of dictionaries containing attribute keys with their corresponding values.

Both methods above accept the same parameters: a required `From` clause, a required `Select<T>` clause, and an optional series of `Where`, `OrderBy`, `GroupBy`, and/or `Tweak` clauses.

Setting up the `From`, `Where`, `OrderBy`, and `Tweak` clauses is similar to how you would when fetching. For querying, you also need to know how to use the `Select<T>` and `GroupBy` clauses.

#### `Select<T>` clause

The `Select<T>` clause specifies the target attribute/aggregate key, as well as the expected return type: 
```swift
let johnsAge = try dataStack.queryValue(
    From<MyPersonEntity>(),
    Select<Int>("age"),
    Where<MyPersonEntity>("name == %@", "John Smith")
)
```
The example above queries the "age" property for the first object that matches the `Where` condition. `johnsAge` will be bound to type `Int?`, as indicated by the `Select<Int>` generic type. For `queryValue(...)`, types that conform to `QueryableAttributeType` are allowed as the return type (and therefore as the generic type for `Select<T>`).

For `queryAttributes(...)`, only `NSDictionary` is valid for `Select`, thus you are allowed to omit the generic type:
```swift
let allAges = try dataStack.queryAttributes(
    From<MyPersonEntity>(),
    Select("age")
)
```
query methods also support **Query Chain builders**. We can also use Swift's Smart KeyPaths to use in the expressions:
```swift
let johnsAge = try dataStack.queryValue(
    From<MyPersonEntity>()
        .select(\.age) // binds the result to Int
        .where(\.name == "John Smith")
)
```

If you only need a value for a particular attribute, you can just specify the key name (like we did with `Select<Int>("age")`), but several aggregate functions can also be used as parameter to `Select`:
- `.average(...)`
- `.count(...)`
- `.maximum(...)`
- `.minimum(...)`
- `.sum(...)`

```swift
let oldestAge = try dataStack.queryValue(
    From<MyPersonEntity>(),
    Select<Int>(.maximum("age"))
)
```

For `queryAttributes(...)` which returns an array of dictionaries, you can specify multiple attributes/aggregates to `Select`:
```swift
let personJSON = try dataStack.queryAttributes(
    From<MyPersonEntity>(),
    Select("name", "age")
)
```
`personJSON` will then have the value:
```swift
[
    [
        "name": "John Smith",
        "age": 30
    ],
    [
        "name": "Jane Doe",
        "age": 22
    ]
]
```
You can also include an aggregate as well:
```swift
let personJSON = try dataStack.queryAttributes(
    From<MyPersonEntity>(),
    Select("name", .count("friends"))
)
```
which returns:
```swift
[
    [
        "name": "John Smith",
        "count(friends)": 42
    ],
    [
        "name": "Jane Doe",
        "count(friends)": 231
    ]
]
```
The `"count(friends)"` key name was automatically used by CoreStore, but you can specify your own key alias if you need:
```swift
let personJSON = try dataStack.queryAttributes(
    From<MyPersonEntity>(),
    Select("name", .count("friends", as: "friendsCount"))
)
```
which now returns:
```swift
[
    [
        "name": "John Smith",
        "friendsCount": 42
    ],
    [
        "name": "Jane Doe",
        "friendsCount": 231
    ]
]
```

#### `GroupBy` clause

The `GroupBy` clause lets you group results by a specified attribute/aggregate. This is useful only for `queryAttributes(...)` since `queryValue(...)` just returns the first value.
```swift
let personJSON = try dataStack.queryAttributes(
    From<MyPersonEntity>(),
    Select("age", .count("age", as: "count")),
    GroupBy("age")
)
```
`GroupBy` clauses are also generic types and support **Query Chain builders**. We can also use Swift's Smart KeyPaths to use in the expressions:
```swift
let personJSON = try dataStack.queryAttributes(
    From<MyPersonEntity>()
        .select(.attribute(\.age), .count(\.age, as: "count"))
        .groupBy(\.age)
)
```
this returns dictionaries that shows the count for each `"age"`:
```swift
[
    [
        "age": 42,
        "count": 1
    ],
    [
        "age": 22,
        "count": 1
    ]
]
```

## Logging and error reporting
One unfortunate thing when using some third-party libraries is that they usually pollute the console with their own logging mechanisms. CoreStore provides its own default logging class, but you can plug-in your own favorite logger by implementing the `CoreStoreLogger` protocol.
```swift
public protocol CoreStoreLogger {
    func log(level level: LogLevel, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
    func log(error error: CoreStoreError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
    func assert(@autoclosure condition: () -> Bool, @autoclosure message: () -> String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
    func abort(message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
}
```
Implement this protocol with your custom class then pass the instance to `CoreStoreDefaults.logger`:
```swift
CoreStoreDefaults.logger = MyLogger()
```
Doing so channels all logging calls to your logger.

Note that to keep the call stack information intact, all calls to these methods are **NOT** thread-managed. Therefore you have to make sure that your logger is thread-safe or you may otherwise have to dispatch your logging implementation to a serial queue.

Take special care when implementing `CoreStoreLogger`'s `assert(...)` and `abort(...)` functions:
- `assert(...)`: The behavior between `DEBUG` and release builds, or `-O` and `-Onone`, are all left to the implementers' responsibility. CoreStore calls `CoreStoreLogger.assert(...)` only for invalid but usually recoverable errors (for example, early validation failures that may cause an error thrown and handled somewhere else)
- `abort(...)`: This method is *the* last-chance for your app to *synchronously* log a fatal error within CoreStore. The app will be terminated right after this function is called (CoreStore calls `fatalError()` internally)

All CoreStore types have very useful (and pretty formatted!) `print(...)` outputs. 
A couple of examples, `ListMonitor`:

<img width="369" alt="screen shot 2016-07-10 at 22 56 44" src="https://cloud.githubusercontent.com/assets/3029684/16713994/ae06e702-46f1-11e6-83a8-dee48b480bab.png" />

`CoreStoreError.mappingModelNotFoundError`:

<img width="506" alt="MappingModelNotFoundError" src="https://cloud.githubusercontent.com/assets/3029684/16713962/e021f548-46f0-11e6-8100-f9b5ea6b4a08.png" />

These are all implemented with `CustomDebugStringConvertible.debugDescription`, so they work with lldb's `po` command as well.

## Observing changes and notifications

CoreStore provides type-safe wrappers for observing managed objects:

| | 🆕[*ObjectPublisher*](#observe-a-single-objects-updates) | [*ObjectMonitor*](#observe-a-single-objects-per-property-updates) | 🆕[*ListPublisher*](#observe-a-diffable-list) | [*ListMonitor*](#observe-detailed-list-changes) |
| --- | --- | --- | --- | --- |
| *Number of objects* | 1 | 1 | N | N |
| *Allows multiple observers* | ✅ | ✅ | ✅ | ✅ |
| *Emits fine-grained changes* | ❌ | ✅ | ❌ | ✅ |
| *Emits DiffableDataSource snapshots* | ✅ | ❌ | ✅ | ❌ |
| *Delegate methods* | ❌ | ✅ | ❌ | ✅ |
| *Closure callback* | ✅ | ❌ | ✅ | ❌ |
| *SwiftUI support* | ✅ | ❌ | ✅ | ❌ |

### Observe a single property
To get notifications for single property changes in an object, there are two methods depending on the object's base class.

- For `NSManagedObject` subclasses: Use the standard KVO method:
```swift
let observer = person.observe(\.age, options: [.new]) { (person, change)
    print("Happy \(change.newValue)th birthday!")
}
```

- For `CoreStoreObject` subclasses: Call the `observe(...)` method directly on the property. You'll notice that the API itself is a bit similar to the KVO method:
```swift
let observer = person.age.observe(options: [.new]) { (person, change)
    print("Happy \(change.newValue)th birthday!")
}
```

For both methods, you will need to keep a reference to the returned `observer` for the duration of the observation.  

### Observe a single object's updates

Observers of an  `ObjectPublisher` can receive notifications if any of the object's property changes. You can  create an `ObjectPublisher` from the object directly:
```swift
let objectPublisher: ObjectPublisher<Person> = person.asPublisher(in: dataStack)
```
or by indexing a `ListPublisher`'s `ListSnapshot`:
```swift
let listPublisher: ListPublisher<Person> = // ...
// ...
let objectPublisher = listPublisher.snapshot[indexPath]
```
(See [`ListPublisher` examples](#observe-a-diffable-list) below)

To receive notifications, call the  `ObjectPublisher`'s `addObserve(...)` method passing the owner of the callback closure:
```swift
objectPublisher.addObserver(self) { [weak self] (objectPublisher) in
    let snapshot: ObjectSnapshot<Person> = objectPublisher.snapshot
    // handle changes
}
```
Note that the owner instance will not be retained. You may call `ObjectPublisher.removeObserver(...)` explicitly to stop receiving notifications, but the `ObjectPublisher` also discontinues sending events to deallocated observers.

The `ObjectSnapshot` returned from the `ObjectPublisher.snapshot` property returns a full-copy `struct` of all properties of the object. This is ideal for managing states as they are thread-safe and are not affected by further changes to the actual object.  `ObjectPublisher` automatically updates its `snapshot` value to the latest state of the object. 

(A reactive-programming variant of this method is explained in detail in the section on [`ObjectPublisher` Combine publishers](#objectpublisherreactive))


### Observe a single object's per-property updates

If you need to track specifically which properties change in an object, implement the `ObjectObserver` protocol and specify the `EntityType`:
```swift
class MyViewController: UIViewController, ObjectObserver {
    func objectMonitor(monitor: ObjectMonitor<MyPersonEntity>, willUpdateObject object: MyPersonEntity) {
        // ...
    }
    
    func objectMonitor(monitor: ObjectMonitor<MyPersonEntity>, didUpdateObject object: MyPersonEntity, changedPersistentKeys: Set<KeyPathString>) {
        // ...
    }
    
    func objectMonitor(monitor: ObjectMonitor<MyPersonEntity>, didDeleteObject object: MyPersonEntity) {
        // ...
    }
}
```
We then need to keep an `ObjectMonitor` instance and register our `ObjectObserver` as an observer:
```swift
let person: MyPersonEntity = // ...
self.monitor = dataStack.monitorObject(person)
self.monitor.addObserver(self)
```
The controller will then notify our observer whenever the object's attributes change. You can add multiple `ObjectObserver`s to a single `ObjectMonitor` without any problem. This means you can just share around the `ObjectMonitor` instance to different screens without problem.

You can get `ObjectMonitor`'s object through its `object` property. If the object is deleted, the `object` property will become `nil` to prevent further access. 

While `ObjectMonitor` exposes `removeObserver(...)` as well, it only stores `weak` references of the observers and will safely unregister deallocated observers. 

### Observe a diffable list

Observers of a  `ListPublisher` can receive notifications whenever its fetched result set changes. You can  create a `ListPublisher` by fetching from the `DataStack`:
```swift
let listPublisher = dataStack.listPublisher(
    From<Person>()
        .sectionBy(\.age") { "Age \($0)" } // sections are optional
        .where(\.title == "Engineer")
        .orderBy(.ascending(\.lastName))
)
```
To receive notifications, call the  `ListPublisher`'s `addObserve(...)` method passing the owner of the callback closure:
```swift
listPublisher.addObserver(self) { [weak self] (listPublisher) in
    let snapshot: ListSnapshot<Person> = listPublisher.snapshot
    // handle changes
}
```
Note that the owner instance will not be retained. You may call `ListPublisher.removeObserver(...)` explicitly to stop receiving notifications, but the `ListPublisher` also discontinues sending events to deallocated observers.

The `ListSnapshot` returned from the `ListPublisher.snapshot` property returns a full-copy `struct` of all sections and `NSManagedObject` items in the list. This is ideal for managing states as they are thread-safe and are not affected by further changes to the result set.  `ListPublisher` automatically updates its `snapshot` value to the latest state of the fetch. 

(A reactive-programming variant of this method is explained in detail in the section on [`ListPublisher` Combine publishers](#listpublisherreactive))

Unlike  `ListMonitor`s (See [`ListMonitor` examples](#observe-detailed-list-changes) below), a `ListPublisher` does not track detailed inserts, deletes, and moves. In return, a `ListPublisher` is a lot more lightweight and are designed to work well with `DiffableDataSource.TableViewAdapter`s and `DiffableDataSource.CollectionViewAdapter`s:
```swift
self.dataSource = DiffableDataSource.CollectionViewAdapter<Person>(
    collectionView: self.collectionView,
    dataStack: CoreStoreDefaults.dataStack,
    cellProvider: { (collectionView, indexPath, person) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell") as! PersonCell
        cell.setPerson(person)
        return cell
    }
)

// ...

listPublisher.addObserver(self) { [weak self] (listPublisher) in
   self?.dataSource?.apply(
       listPublisher.snapshot, animatingDifferences: true
   )
}
```

### Observe detailed list changes
If you need to track each object's inserts, deletes, moves, and updates, implement one of the `ListObserver` protocols and specify the `EntityType`:
```swift
class MyViewController: UIViewController, ListObserver {
    func listMonitorDidChange(monitor: ListMonitor<MyPersonEntity>) {
        // ...
    }
    
    func listMonitorDidRefetch(monitor: ListMonitor<MyPersonEntity>) {
        // ...
    }
}
```
Including `ListObserver`, there are 3 observer protocols you can implement depending on how detailed you need to handle a change notification:
- `ListObserver`: lets you handle these callback methods:
```swift
    func listMonitorWillChange(_ monitor: ListMonitor<MyPersonEntity>)
    func listMonitorDidChange(_ monitor: ListMonitor<MyPersonEntity>)
    func listMonitorWillRefetch(_ monitor: ListMonitor<MyPersonEntity>)
    func listMonitorDidRefetch(_ monitor: ListMonitor<MyPersonEntity>)
```
`listMonitorDidChange(_:)` and `listMonitorDidRefetch(_:)` implementations are both required. `listMonitorDidChange(_:)` is called whenever the `ListMonitor`'s count, order, or filtered objects change. `listMonitorDidRefetch(_:)` is called when the `ListMonitor.refetch()` was executed or if the internal persistent store was changed. 

- `ListObjectObserver`: in addition to `ListObserver` methods, also lets you handle object inserts, updates, and deletes:
```swift
    func listMonitor(_ monitor: ListMonitor<MyPersonEntity>, didInsertObject object: MyPersonEntity, toIndexPath indexPath: IndexPath)
    func listMonitor(_ monitor: ListMonitor<MyPersonEntity>, didDeleteObject object: MyPersonEntity, fromIndexPath indexPath: IndexPath)
    func listMonitor(_ monitor: ListMonitor<MyPersonEntity>, didUpdateObject object: MyPersonEntity, atIndexPath indexPath: IndexPath)
    func listMonitor(_ monitor: ListMonitor<MyPersonEntity>, didMoveObject object: MyPersonEntity, fromIndexPath: IndexPath, toIndexPath: IndexPath)
```
- `ListSectionObserver`: in addition to `ListObjectObserver` methods, also lets you handle section inserts and deletes:
```swift
    func listMonitor(_ monitor: ListMonitor<MyPersonEntity>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int)
    func listMonitor(_ monitor: ListMonitor<MyPersonEntity>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int)
```

We then need to create a `ListMonitor` instance and register our `ListObserver` as an observer:
```swift
self.monitor = dataStack.monitorList(
    From<MyPersonEntity>()
        .where(\.age > 30)
        .orderBy(.ascending(\.name))
        .tweak { $0.fetchBatchSize = 20 }
)
self.monitor.addObserver(self)
```
Similar to `ObjectMonitor`, a `ListMonitor` can also have multiple `ListObserver`s registered to a single `ListMonitor`.

If you have noticed, the `monitorList(...)` method accepts `Where`, `OrderBy`, and `Tweak` clauses exactly like a fetch. As the list maintained by `ListMonitor` needs to have a deterministic order, at least the `From` and `OrderBy` clauses are required.

A `ListMonitor` created from `monitorList(...)` will maintain a single-section list. You can therefore access its contents with just an index:
```swift
let firstPerson = self.monitor[0]
```

If the list needs to be grouped into sections, create the `ListMonitor` instance with the `monitorSectionedList(...)` method and a `SectionBy` clause:
```swift
self.monitor = dataStack.monitorSectionedList(
    From<MyPersonEntity>()
        .sectionBy(\.age)
        .where(\.gender == "M")
        .orderBy(.ascending(\.age), .ascending(\.name))
        .tweak { $0.fetchBatchSize = 20 }
)
```
A list controller created this way will group the objects by the attribute key indicated by the `SectionBy` clause. One more thing to remember is that the `OrderBy` clause should sort the list in such a way that the `SectionBy` attribute would be sorted together (a requirement shared by `NSFetchedResultsController`.)

The `SectionBy` clause can also be passed a closure to transform the section name into a displayable string:
```swift
self.monitor = dataStack.monitorSectionedList(
    From<MyPersonEntity>()
        .sectionBy(\.age) { (sectionName) -> String? in
            "\(sectionName) years old"
        }
        .orderBy(.ascending(\.age), .ascending(\.name))
)
```
This is useful when implementing a `UITableViewDelegate`'s section header:
```swift
func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = self.monitor.sectionInfoAtIndex(section)
    return sectionInfo.name
}
```

To access the objects of a sectioned list, use an `IndexPath` or a tuple:
```swift
let indexPath = IndexPath(row: 2, section: 1)
let person1 = self.monitor[indexPath]
let person2 = self.monitor[1, 2]
// person1 and person2 are the same object
```

## Type-safe `CoreStoreObject`s
Starting CoreStore 4.0, we can now create persisted objects without depending on *.xcdatamodeld* Core Data files. The new `CoreStoreObject` subclass replaces `NSManagedObject`, and specially-typed properties declared on these classes will be synthesized as Core Data attributes.
```swift
class Animal: CoreStoreObject {
    @Field.Stored("species")
    var species: String = ""
}

class Dog: Animal {
    @Field.Stored("nickname")
    var nickname: String?
    
    @Field.Relationship("master")
    var master: Person?
}

class Person: CoreStoreObject {
    @Field.Stored("name")
    var name: String = ""
    
    @Field.Relationship("pets", inverse: \Dog.$master)
    var pets: Set<Dog>
}
```
The property names to be saved to Core Data is specified as the `keyPath` argument. This lets us refactor our Swift code without affecting the underlying database. For example:
```swift
class Person: CoreStoreObject {
    @Field.Stored("name")
    private var internalName: String = ""
    // note property name is independent of the storage key name
}
```
Here we used the property name `internalName` and made it `private`, but the underlying key-path `"name"` was unchanged so our model will not trigger a data migration.

To tell the `DataStack` about these types, add all `CoreStoreObject`s' entities to a `CoreStoreSchema`:
```swift

CoreStoreDefaults.dataStack = DataStack(
    CoreStoreSchema(
        modelVersion: "V1",
        entities: [
            Entity<Animal>("Animal", isAbstract: true),
            Entity<Dog>("Dog"),
            Entity<Person>("Person")
        ]
    )
)
CoreStoreDefaults.dataStack.addStorage(/* ... */)
```
And that's all CoreStore needs to build the model; **we don't need *.xcdatamodeld* files anymore.**

In addition, `@Field` properties can be used to create type-safe key-path strings
```swift
let keyPath = String(keyPath: \Dog.$nickname)
```
as well as `Where` and `OrderBy` clauses
```swift
let puppies = try dataStack.fetchAll(
    From<Dog>()
        .where(\.$age < 5)
        .orderBy(.ascending(\.$age))
)
```

All CoreStore APIs that are usable with `NSManagedObject`s are also available for `CoreStoreObject`s. These include `ListMonitor`s, `ImportableObject`s, fetching, etc.

### New `@Field` Property Wrapper syntax

> ⚠️**Important:** `@Field` properties are only supported for `CoreStoreObject` subclasses. If you are using `NSManagedObject`s, you need to keep using `@NSManaged` for your attributes.

Starting CoreStore 7.1.0, `CoreStoreObject` properties may be converted to `@Field` Property Wrappers.

> ‼️ Please take note of the warnings below before converting or else the model's hash might change.

**If conversion is too risky, the current `Value.Required`, `Value.Optional`, `Transformable.Required`, `Transformable.Optional`, `Relationship.ToOne`, `Relationship.ToManyOrdered`, and `Relationship.ToManyUnordered` will all be supported for while so you can opt to use them as is for now.**

> ‼️ This cannot be stressed enough, but please make sure to set your schema's [`VersionLock`](#versionlocks) before converting!

#### `@Field.Stored`

The `@Field.Stored` property wrapper is used for persisted value types. This is the replacement for "non-transient" `Value.Required` and `Value.Optional` properties.

<table>
<tr><th>Before</th><th><pre lang=swift>@Field.Stored</pre></th></tr>
<tr>
<td><pre lang=swift>
class Person: CoreStoreObject {
    <br />
    let title = Value.Required&lt;String&gt;("title", initial: "Mr.")
    let nickname = Value.Optional&lt;String&gt;("nickname")
}
</pre></td>
<td><pre lang=swift>
class Person: CoreStoreObject {
    <br />
    @Field.Stored("title")
    var title: String = "Mr."
    <br />
    @Field.Stored("nickname")
    var nickname: String?
}
</pre></td>
</tr>
</table>

> ⚠️ Only `Value.Required` and `Value.Optional` that are NOT transient values can be converted to `Field.Stored`. For transient/computed properties, refer to [`@Field.Virtual`](#fieldvirtual) properties in the next section.
> ⚠️ When converting, make sure that all parameters, including the default values, are exactly the same or else the model's hash might change.


#### `@Field.Virtual`

The `@Field.Virtual` property wrapper is used for unsaved, computed value types. This is the replacement for "transient" `Value.Required` and `Value.Optional` properties.

<table>
<tr><th>Before</th><th><pre lang=swift>@Field.Virtual</pre></th></tr>
<tr>
<td><pre lang=swift>
class Animal: CoreStoreObject {
    <br />
    let speciesPlural = Value.Required&lt;String&gt;(
        "speciesPlural",
        transient: true,
        customGetter: Animal.getSpeciesPlural(_:)
    )
    <br />
    let species = Value.Required&lt;String&gt;("species", initial: "")
    <br />
    static func getSpeciesPlural(_ partialObject: PartialObject&lt;Animal&gt;) -> String? {
        let species = partialObject.value(for: { $0.species })
        return species + "s"
    }
}
</pre></td>
<td><pre lang=swift>
class Animal: CoreStoreObject {
    <br />
    @Field.Virtual(
        "speciesPlural",
        customGetter: { (object, field) in
            return object.$species.value + "s"
        }
    )
    var speciesPlural: String
    <br />
    @Field.Stored("species")
    var species: String = ""
}
</pre></td>
</tr>
</table>

> ⚠️ Only `Value.Required` and `Value.Optional` that ARE transient values can be converted to `Field.Virtual`. For non-transient properties, refer to [`@Field.Stored`](#fieldstored) properties in the previous section.
> ⚠️ When converting, make sure that all parameters, including the default values, are exactly the same or else the model's hash might change.


#### `@Field.Coded`

The `@Field.Coded` property wrapper is used for binary-codable values. This is the new counterpart, **not replacement**, for `Transformable.Required` and `Transformable.Optional` properties. `@Field.Coded` also supports other encodings such as JSON and custom binary converters.

> ‼️ The current `Transformable.Required` and `Transformable.Optional` mechanism have no safe one-to-one conversion to `@Field.Coded`. Please use `@Field.Coded` only for newly added attributes.

<table>
<tr><th>Before</th><th><pre lang=swift>@Field.Coded</pre></th></tr>
<tr>
<td><pre lang=swift>
class Vehicle: CoreStoreObject {
    <br />
    let color = Transformable.Optional&lt;UIColor&gt;("color", initial: .white)
}
</pre></td>
<td><pre lang=swift>
class Vehicle: CoreStoreObject {
    <br />
    @Field.Coded("color", coder: FieldCoders.NSCoding.self)
    var color: UIColor? = .white
}
</pre></td>
</tr>
</table>

Built-in encoders such as `FieldCoders.NSCoding`, `FieldCoders.Json`, and `FieldCoders.Plist` are available, and custom encoding/decoding is also supported:
```swift
class Person: CoreStoreObject {
    
    struct CustomInfo: Codable {
        // ...
    }
    
    @Field.Coded("otherInfo", coder: FieldCoders.Json.self)
    var otherInfo: CustomInfo?
    
    @Field.Coded(
        "photo",
        coder: {
            encode: { $0.toData() },
            decode: { Photo(fromData: $0) }
        }
    )
    var photo: Photo?
}
```

> ‼️**Important:** Any changes in the encoders/decoders are not reflected in the `VersionLock`, so make sure that the encoder and decoder logic is compatible for all versions of your persistent store.

#### `@Field.Relationship`

The `@Field.Relationship` property wrapper is used for link relationships with other `CoreStoreObject`s. This is the replacement for `Relationship.ToOne`, `Relationship.ToManyOrdered`, and `Relationship.ToManyUnordered` properties.

The type of relationship is determined by the `@Field.Relationship`  generic type:

- `Optional<T>` : To-one relationship
- `Array<T>` : To-many ordered relationship
- `Set<T>` : To-many unordered relationship

<table>
<tr><th>Before</th><th><pre lang=swift>@Field.Stored</pre></th></tr>
<tr>
<td><pre lang=swift>
class Pet: CoreStoreObject {
    <br />
    let master = Relationship.ToOne&lt;Person&gt;("master")
}
class Person: CoreStoreObject {
    <br />
    let pets: Relationship.ToManyUnordered&lt;Pet&gt;("pets", inverse: \.$master)
}
</pre></td>
<td><pre lang=swift>
class Pet: CoreStoreObject {
    <br />
    @Field.Relationship("master")
    var master: Person?
}
class Person: CoreStoreObject {
    <br />
    @Field.Relationship("pets", inverse: \.$master)
    var pets: Set&lt;Pet&gt;
}
</pre></td>
</tr>
</table>

> ⚠️ When converting, make sure that all parameters, including the default values, are exactly the same or else the model's hash might change.

Also note how `Relationship`s are linked statically with the `inverse:` argument. **All relationships are required to have an "inverse" relationship**. Unfortunately, due to Swift compiler limitation we can declare the `inverse:` on only one of the relationship-pair.

#### `@Field` usage notes 

**Accessor syntax**

When using key-path utilities, properties using `@Field` property wrappers need to use the `$` syntax:

- Before: `From<Person>.where(\.title == "Mr.")`
- After: `From<Person>.where(\.$title == "Mr.")`

This applies to property access using `ObjectPublisher`s and `ObjectSnapshot`s.

- Before: `let name = personSnapshot.name`
- After: `let name = personSnapshot.$name`


**Default values vs. Initial values**

One common mistake when assigning default values to `CoreStoreObject` properties is to assign it a value and expect it to be evaluated whenever an object is created:

```swift
// ❌
class Person: CoreStoreObject {

    @Field.Stored("identifier")
    var identifier: UUID = UUID() // Wrong!
    
    @Field.Stored("createdDate")
    var createdDate: Date = Date() // Wrong!
}
```

This default value will be evaluated only when the `DataStack` sets up the schema, and all instances will end up having the same values. This syntax for "default values" are usually used only for actual reasonable constant values, or sentinel values such as `""` or `0`.

For actual "initial values", `@Field.Stored` and `@Field.Coded` now supports dynamic evaluation during object creation via the `dynamicInitialValue:` argument:

```swift
// ✅
class Person: CoreStoreObject {

    @Field.Stored("identifier", dynamicInitialValue: { UUID() })
    var identifier: UUID
    
    @Field.Stored("createdDate", dynamicInitialValue: { Date() })
    var createdDate: Date
}
```
When using this feature, a "default value" should not be assigned (i.e. no `=` expression). 


### `VersionLock`s

While it is convenient to be able to declare entities only in code, it is worrying that we might accidentally change the `CoreStoreObject`'s properties and break our users' model version history. For this, the `CoreStoreSchema` allows us to "lock" our properties to a particular configuration. Any changes to that `VersionLock` will raise an assertion failure during the `CoreStoreSchema` initialization, so you can then look for the commit which changed the `VersionLock` hash.

To use `VersionLock`s, create the `CoreStoreSchema`, run the app, and look for a similar log message that is automatically printed to the console:

<img width="700" alt="VersionLock" src="https://cloud.githubusercontent.com/assets/3029684/26525632/757f1bd0-4398-11e7-9795-4132a2df0538.png" />

Copy this dictionary value and use it as the `versionLock:` argument of the `CoreStoreSchema` initializer:
```swift
CoreStoreSchema(
    modelVersion: "V1",
    entities: [
        Entity<Animal>("Animal", isAbstract: true),
        Entity<Dog>("Dog"),
        Entity<Person>("Person"),
    ],
    versionLock: [
        "Animal": [0x1b59d511019695cf, 0xdeb97e86c5eff179, 0x1cfd80745646cb3, 0x4ff99416175b5b9a],
        "Dog": [0xe3f0afeb109b283a, 0x29998d292938eb61, 0x6aab788333cfc2a3, 0x492ff1d295910ea7],
        "Person": [0x66d8bbfd8b21561f, 0xcecec69ecae3570f, 0xc4b73d71256214ef, 0x89b99bfe3e013e8b]
    ]
)
```
You can also get this hash after the `DataStack` has been fully set up by printing to the console:
```swift
print(CoreStoreDefaults.dataStack.modelSchema.printCoreStoreSchema())
```

Once the version lock is set, any changes in the properties or to the model will trigger an assertion failure similar to this:

<img width="700" alt="VersionLock failure" src="https://cloud.githubusercontent.com/assets/3029684/26525666/92f46f0c-4399-11e7-9395-4379f6f20876.png" />

## Reactive Programming
### RxSwift
RxSwift utilities are available through the [RxCoreStore](https://github.com/JohnEstropia/RxCoreStore) external module.

### Combine

Combine publishers are available from the `DataStack`, `ListPublisher`, and `ObjectPublisher`'s `.reactive` namespace property.

#### `DataStack.reactive`

Adding a storage through `DataStack.reactive.addStorage(_:)` returns a publisher that reports a `MigrationProgress` `enum` value. The `.migrating` value is only emitted if the storage goes through a migration. Refer to the [Setting up](#setting-up) section for details on the storage setup process itself.

```swift
dataStack.reactive
    .addStorage(
        SQLiteStore(fileName: "core_data.sqlite")
    )
    .sink(
        receiveCompletion: { result in
            // ...
        },
        receiveValue: { (progress) in
            print("\(round(progress.fractionCompleted * 100)) %") // 0.0 ~ 1.0
            switch progress {
            case .migrating(let storage, let nsProgress):
                // ...
            case .finished(let storage, let migrationRequired):
                // ...
            }
        }
    )
    .store(in: &cancellables)
```

[Transactions](#saving-and-processing-transactions) are also available as publishers through `DataStack.reactive.perform(_:)`, which returns a Combine `Future` that emits any type returned from the closure parameter:
```swift
dataStack.reactive
    .perform(
        asynchronous: { (transaction) -> (inserted: Set<NSManagedObject>, deleted: Set<NSManagedObject>) in

            // ...
            return (
                transaction.insertedObjects(),
                transaction.deletedObjects()
            )
        }
    )
    .sink(
        receiveCompletion: { result in
            // ...
        },
        receiveValue: { value in
            let inserted = dataStack.fetchExisting(value0.inserted)
            let deleted = dataStack.fetchExisting(value0.deleted)
            // ...
        }
    )
    .store(in: &cancellables)
```

For importing convenience, `ImportableObject` and `ImportableUniqueObjects` can be imported directly through `DataStack.reactive.import[Unique]Object(_:source:)` and `DataStack.reactive.import[Unique]Objects(_:sourceArray:)` without having to create a transaction block. In this case the publisher emits objects that are already usable directly from the main queue:
```swift
dataStack.reactive
    .importUniqueObjects(
        Into<Person>(),
        sourceArray: [
            ["name": "John"],
            ["name": "Bob"],
            ["name": "Joe"]
        ]
    )
    .sink(
        receiveCompletion: { result in
            // ...
        },
        receiveValue: { (people) in
            XCTAssertEqual(people?.count, 3)
            // ...
        }
    )
    .store(in: &cancellables)
```

#### `ListPublisher.reactive`

`ListPublisher`s can be used to emit `ListSnapshot`s through Combine using `ListPublisher.reactive.snapshot(emitInitialValue:)`. The snapshot values are emitted in the main queue:
```swift
listPublisher.reactive
    .snapshot(emitInitialValue: true)
    .sink(
        receiveCompletion: { result in
            // ...
        },
        receiveValue: { (listSnapshot) in
            dataSource.apply(
                listSnapshot,
                animatingDifferences: true
            )
        }
    )
    .store(in: &cancellables)
```

#### `ObjectPublisher.reactive`

`ObjectPublisher`s can be used to emit `ObjectSnapshot`s through Combine using `ObjectPublisher.reactive.snapshot(emitInitialValue:)`. The snapshot values are emitted in the main queue:
```swift
objectPublisher.reactive
    .snapshot(emitInitialValue: true)
    .sink(
        receiveCompletion: { result in
            // ...
        },
        receiveValue: { (objectSnapshot) in
            tableViewCell.setObject(objectSnapshot)
        }
    )
    .store(in: &tableViewCell.cancellables)
```


## SwiftUI Utilities

Observing list and object changes in SwiftUI can be done through a couple of approaches. One is by creating [views that autoupdates their contents](#swiftui-views), or by declaring [property wrappers that trigger view updates](#swiftui-property-wrappers). Both approaches are implemented almost the same internally, but this lets you be flexible depending on the structure of your custom `View`s.

### SwiftUI Views

CoreStore provides `View` containers that automatically update their contents when data changes.

#### `ListReader`

A `ListReader` observes changes to a `ListPublisher` and creates its content views dynamically. The builder closure receives a `ListSnapshot` value that can be used to create the contents:
```swift
let people: ListPublisher<Person>

var body: some View {
   List {
       ListReader(self.people) { listSnapshot in
           ForEach(objectIn: listSnapshot) { person in
               // ...
           }
       }
   }
   .animation(.default)
}
```
As shown above, a typical use case is to use it together with CoreStore's [`ForEach` extensions](#foreach).

A `KeyPath` can also be optionally provided to extract specific properties of the `ListSnapshot`:
```swift
let people: ListPublisher<Person>

var body: some View {
    ListReader(self.people, keyPath: \.count) { count in
        Text("Number of members: \(count)")
    }
}
```

#### `ObjectReader`

An `ObjectReader` observes changes to an `ObjectPublisher` and creates its content views dynamically. The builder closure receives an `ObjectSnapshot` value that can be used to create the contents:
```swift
let person: ObjectPublisher<Person>

var body: some View {
   ObjectReader(self.person) { objectSnapshot in
       // ...
   }
   .animation(.default)
}
```

A `KeyPath` can also be optionally provided to extract specific properties of the `ObjectSnapshot`:
```swift
let person: ObjectPublisher<Person>

var body: some View {
    ObjectReader(self.person, keyPath: \.fullName) { fullName in
        Text("Name: \(fullName)")
    }
}
```

By default, an `ObjectReader` does not create its views wheen the object observed is deleted from the store. In those cases, the `placeholder:` argument can be used to provide a custom `View` to display when the object is deleted:
```swift
let person: ObjectPublisher<Person>

var body: some View {
   ObjectReader(
       self.person,
       content: { objectSnapshot in
           // ...
       },
       placeholder: { Text("Record not found") }
   )
}
```

### SwiftUI Property Wrappers

As an alternative to `ListReader` and `ObjectReader`, CoreStore also provides property wrappers that trigger view updates when the data changes.

#### `ListState`

A `@ListState` property exposes a `ListSnapshot` value that automatically updates to the latest changes.
```swift
@ListState
var people: ListSnapshot<Person>

init(listPublisher: ListPublisher<Person>) {
   self._people = .init(listPublisher)
}

var body: some View {
   List {
       ForEach(objectIn: self.people) { objectSnapshot in
           // ...
       }
   }
   .animation(.default)
}
```
As shown above, a typical use case is to use it together with CoreStore's [`ForEach` extensions](#foreach).

If a `ListPublisher` instance is not available yet, the fetch can be done inline by providing the fetch clauses and the `DataStack` instance. By doing so the property can be declared without an initial value:
```swift
@ListState(
    From<Person>()
        .sectionBy(\.age)
        .where(\.isMember == true)
        .orderBy(.ascending(\.lastName))
)
var people: ListSnapshot<Person>

var body: some View {
    List {
        ForEach(sectionIn: self.people) { section in
            Section(header: Text(section.sectionID)) {
                ForEach(objectIn: section) { person in
                    // ...
                }
            }
        }
    }
    .animation(.default)
}
```

For other initialization variants, refer to the *ListState.swift*  source documentations.


#### `ObjectState`

An `@ObjectState` property exposes an optional `ObjectSnapshot` value that automatically updates to the latest changes.
```swift
@ObjectState
var person: ObjectSnapshot<Person>?

init(objectPublisher: ObjectPublisher<Person>) {
   self._person = .init(objectPublisher)
}

var body: some View {
   HStack {
       if let person = self.person {
           AsyncImage(person.$avatarURL)
           Text(person.$fullName)
       }
       else {
           Text("Record removed")
       }
   }
}
```
As shown above, the property's value will be `nil` if the object has been deleted, so this can be used to display placeholders if needed.

### SwiftUI Extensions

For convenience, CoreStore provides extensions to the standard SwiftUI types.

#### `ForEach`

Several `ForEach` initializer overloads are available. Choose depending on your input data and the expected closure data. Refer to the table below (Take note of the argument labels as they are important):

<table>
<tr><th>Data</th><th>Example</th></tr>
<tr>
<td>
Signature: 
<pre lang=swift>
ForEach(_: [ObjectSnapshot&lt;O&gt;])
</pre>
Closure: 
<pre lang=swift>
ObjectSnapshot&lt;O&gt;
</pre>
</td>
<td><pre lang=swift>
let array: [ObjectSnapshot&lt;Person&gt;]
<br />
var body: some View {
    <br />
    List {
        <br />
        ForEach(self.array) { objectSnapshot in
            <br />
            // ...
        }
    }
}
</pre></td>
</tr>
<tr>
<td>
Signature: 
<pre lang=swift>
ForEach(objectIn: ListSnapshot&lt;O&gt;)
</pre>
Closure: 
<pre lang=swift>
ObjectPublisher&lt;O&gt;
</pre>
</td>
<td><pre lang=swift>
let listSnapshot: ListSnapshot&lt;Person&gt;
<br />
var body: some View {
    <br />
    List {
        <br />
        ForEach(objectIn: self.listSnapshot) { objectPublisher in
            <br />
            // ...
        }
    }
}
</pre></td>
</tr>
<tr>
<td>
Signature: 
<pre lang=swift>
ForEach(objectIn: [ObjectSnapshot&lt;O&gt;])
</pre>
Closure: 
<pre lang=swift>
ObjectPublisher&lt;O&gt;
</pre>
</td>
<td><pre lang=swift>
let array: [ObjectSnapshot&lt;Person&gt;]
<br />
var body: some View {
    <br />
    List {
        <br />
        ForEach(objectIn: self.array) { objectPublisher in
            <br />
            // ...
        }
    }
}
</pre></td>
</tr>
<tr>
<td>
Signature: 
<pre lang=swift>
ForEach(sectionIn: ListSnapshot&lt;O&gt;)
</pre>
Closure: 
<pre lang=swift>
[ListSnapshot&lt;O&gt;.SectionInfo]
</pre>
</td>
<td><pre lang=swift>
let listSnapshot: ListSnapshot&lt;Person&gt;
<br />
var body: some View {
    <br />
    List {
        <br />
        ForEach(sectionIn: self.listSnapshot) { sectionInfo in
            <br />
            // ...
        }
    }
}
</pre></td>
</tr>
<tr>
<td>
Signature: 
<pre lang=swift>
ForEach(objectIn: ListSnapshot&lt;O&gt;.SectionInfo)
</pre>
Closure: 
<pre lang=swift>
ObjectPublisher&lt;O&gt;
</pre>
</td>
<td><pre lang=swift>
let listSnapshot: ListSnapshot&lt;Person&gt;
<br />
var body: some View {
    <br />
    List {
        <br />
        ForEach(sectionIn: self.listSnapshot) { sectionInfo in
            <br />
            ForEach(objectIn: sectionInfo) { objectPublisher in
               <br />
                // ...
            }
        }
    }
}
</pre></td>
</tr>
</table>


# Roadmap

### Prototyping stage
- [ ] Widget/Extensions storage-sharing support
- [ ] CloudKit support

### Under consideration
- [ ] Derived attributes
- [ ] Cross-storage relationships (via Fetched Attributes)

# Installation
- Requires:
    - iOS 10 SDK and above
    - Swift 5.2 (Xcode 11.4+)
    - For previous Swift versions: [Swift 3.2](https://github.com/JohnEstropia/CoreStore/tree/4.2.3), [Swift 4.2](https://github.com/JohnEstropia/CoreStore/tree/6.2.1), [Swift 5.0](https://github.com/JohnEstropia/CoreStore/tree/6.3.2), [Swift 5.1](https://github.com/JohnEstropia/CoreStore/tree/7.0.4)
- Dependencies:
    - *None*
- Other notes:
    - The `com.apple.CoreData.ConcurrencyDebug` debug argument should be turned off for the app. CoreStore already guarantees safety for you by making the main context read-only, and by only executing transactions serially.

### Install with CocoaPods
In your `Podfile`, add
```
pod 'CoreStore', '~> 8.0'
```
and run 
```
pod update
```
This installs CoreStore as a framework. Declare `import CoreStore` in your swift file to use the library.

### Install with Carthage
In your `Cartfile`, add
```
github "JohnEstropia/CoreStore" >= 8.0.0
```
and run 
```
carthage update
```
This installs CoreStore as a framework. Declare `import CoreStore` in your swift file to use the library.

#### Install with Swift Package Manager:
```swift
dependencies: [
    .package(url: "https://github.com/JohnEstropia/CoreStore.git", from: "8.0.1"))
]
```
Declare `import CoreStore` in your swift file to use the library.

### Install as Git Submodule
```
git submodule add https://github.com/JohnEstropia/CoreStore.git <destination directory>
```
Drag and drop **CoreStore.xcodeproj** to your project.

### Install through Xcode's Swift Package Manager
From the **File** - **Swift Packages** - **Add Package Dependency…** menu, search for 
```
CoreStore
```
where `JohnEstropia` is the *Owner* (forks may appear as well). Then add to your project


# Changesets

For the full Changelog, refer to the [Releases](https://github.com/JohnEstropia/CoreStore/releases) page. 


# Contact
You can reach me on Twitter [@JohnEstropia](https://twitter.com/JohnEstropia)

or join our Slack team at [swift-corestore.slack.com](http://swift-corestore-slack.herokuapp.com/)

日本語の対応も可能なので是非！


# Who uses CoreStore?
I'd love to hear about apps using CoreStore. Send me a message and I'll welcome any feedback!


# License
CoreStore is released under an MIT license. See the [LICENSE](https://raw.githubusercontent.com/JohnEstropia/CoreStore/master/LICENSE) file for more information

