# HardcoreData
[![Version](https://img.shields.io/cocoapods/v/HardcoreData.svg?style=flat)](http://cocoadocs.org/docsets/HardcoreData)
[![Platform](https://img.shields.io/cocoapods/p/HardcoreData.svg?style=flat)](http://cocoadocs.org/docsets/HardcoreData)
[![License](https://img.shields.io/cocoapods/l/HardcoreData.svg?style=flat)](http://cocoadocs.org/docsets/HardcoreData)

Simple, elegant, and smart Core Data programming with Swift

## Features
- Supports multiple persistent stores per *data stack*, just the way .xcdatamodeld files are supposed to. HardcoreData will also manage one *data stack* by default, but you can create and manage as many as you need. (see "Setting up")
- Ability to plug-in your own logging framework (or your favorite 3rd-party logger). (see "Logging and error handling")
- Makes it hard to fall into common concurrency mistakes. All Core Data tasks are encapsulated into safer, higher-level abstractions without sacrificing flexibility and customizability. (see "Saving and processing transactions")
- Provides convenient API for common use cases. (see "Fetching and querying")
- Pleasant API designed around Swift’s code elegance and type safety. (see "TL;DR sample codes")

#### TL;DR sample codes

Quick-setup:
```swift
HardcoreData.defaultStack.addSQLiteStore("MyStore.sqlite")
```

Simple transactions:
```swift
HardcoreData.beginAsynchronous { (transaction) -> Void in
    let object = transaction.create(MyEntity)
    object.entityID = 1
    object.name = "test entity"

    transaction.commit { (result) -> Void in
        switch result {
            case .Success(let hasChanges): println("success!")
            case .Failure(let error): println(error)
        }
    }
}
```

Easy fetching:
```swift
let objects = HardcoreData.fetchAll(From(MyEntity))
```
```swift
let objects = HardcoreData.fetchAll(
    From(MyEntity),
    Where("entityID", isEqualTo: 1),
    SortedBy(.Ascending("entityID"), .Descending("name")),
    CustomizeFetch { (fetchRequest) -> Void in
        fetchRequest.includesPendingChanges = true
    }
)
```

Simple queries:
```swift
let count = HardcoreData.queryValue(
    From(MyEntity),
    Select<Int>(.Count("entityID"))
)
```



## Architecture
For maximum safety and performance, HardcoreData will enforce coding patterns and practices it was designed for. (Don't worry, it's not as scary as it sounds.) But it is advisable to understand the "magic" of HardcoreData before you use it in your apps.

If you are already familiar with the inner workings of CoreData, here is a mapping of `HardcoreData` abstractions:

| *Core Data* | *HardcoreData* |
| --- | --- |
| `NSManagedObjectModel` / `NSPersistentStoreCoordinator`<br />(.xcdatamodeld file) | `DataStack` |
| `NSPersistentStore`<br />("Configuration"s in the .xcdatamodeld file) | `DataStack` configuration<br />(multiple sqlite / in-memory stores per stack) |
| `NSManagedObjectContext` | `BaseDataTransaction` subclasses<br />(`SynchronousDataTransaction`, `AsynchronousDataTransaction`, `DetachedDataTransaction`) |

RestKit and MagicalRecord set up their `NSManagedObjectContext`s this way:

<img src="https://cloud.githubusercontent.com/assets/3029684/6734049/40579660-ce99-11e4-9d38-829877386afb.png" alt="nested contexts" height=271 />

This ensures maximum data integrity between contexts without blocking the main queue. But as <a href="http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/">Florian Kugler's investigation</a> found out, merging contexts is still by far faster than saving nested contexts. HardcoreData's `DataStack` takes the best of both worlds by treating the main `NSManagedObjectContext` as a read-only context, and only allows changes to be made within *transactions*:

<img src="https://cloud.githubusercontent.com/assets/3029684/6734050/4078b642-ce99-11e4-95ea-c0c1d24fbe80.png" alt="nested contexts and merge hybrid" height=212 />

This allows for a butter-smooth main thread, while still taking advantage of safe nested contexts.



## Setting up
The simplest way to initialize HardcoreData is to add a default store to the default stack:
```swift
HardcoreData.defaultStack.addSQLiteStore()
```
This one-liner does the following:
- Triggers the lazy-initialization of `HardcoreData.defaultStack` with a default `DataStack`
- Sets up the stack's `NSPersistentStoreCoordinator`, the root saving `NSManagedObjectContext`, and the read-only main `NSManagedObjectContext`
- Adds an automigrating SQLite store in the *"Application Support"* directory with the file name *"<App bundle name>.sqlite"*
- Creates and returns the `NSPersistentStore` instance on success, or an `NSError` on failure

For most cases this, confuguration is already appropriate. For more hardcore settings, here is a semi-complete example:
```swift
let dataStack = DataStack(modelName: "MyModel") // loads from the "MyModel.xcdatamodeld" file

switch dataStack.addInMemoryStore(configuration: "Config1") { // creates an in-memory store with entities from the "Config1" configuration in the .xcdatamodeld file
case .Success(let persistentStore): // persistentStore is an NSPersistentStore instance
    println("Successfully created an in-memory store: \(persistentStore)"
case .Failure(let error): // error is an NSError instance
    println("Failed creating an in-memory store with error: \(error.description)"
}

switch dataStack.addSQLiteStore(
    fileURL: sqliteFileURL, // set the target file URL for the sqlite file
    configuration: "Config2", // use entities from the "Config2" configuration in the .xcdatamodeld file
    automigrating: true, // automatically run lightweight migrations or entity policy migrations when needed
    resetStoreOnMigrationFailure: true) { // delete and recreate the sqlite file when migration conflicts occur (useful when debugging)
case .Success(let persistentStore): // persistentStore is an NSPersistentStore instance
    println("Successfully created an sqlite store: \(persistentStore)"
case .Failure(let error): // error is an NSError instance
    println("Failed creating an sqlite store with error: \(error.description)"
}

HardcoreData.defaultStack = dataStack // pass the dataStack to HardcoreData for easier access later on
```

Note that you dont need to do the `HardcoreData.defaultStack = dataStack` line. You can just as well hold a stack like this and call all methods directly from the `DataStack` instance:
```swift
class MyViewController: UIViewController {
    let dataStack = DataStack(modelName: "MyModel")
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataStack.addSQLiteStore()
    }
    func methodToBeCalledLaterOn() {
        let objects = self.dataStack.fetchAll(From(MyEntity))
        println(objects)
    }
}
```
The difference is when you set the stack as the `HardcoreData.defaultStack`, you can call the stack's methods directly from `HardcoreData` itself:
```swift

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        HardcoreData.dataStack.addSQLiteStore()
    }
    func methodToBeCalledLaterOn() {
        let objects = HardcoreData.fetchAll(From(MyEntity))
        println(objects)
    }
}
```

Check out the *HardcoreData.swift* and *DataStack.swift files* if you want to explore the inner workings of the data stack.



## Saving and processing transactions
(implemented; README pending)


## Fetching and querying
(implemented; README pending)


## Logging and error handling
(implemented; README pending)


## Observing changes and notifications
(implemented; README pending)


## Importing data
(currently implementing)



