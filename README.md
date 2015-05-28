# CoreStore
[![Version](https://img.shields.io/cocoapods/v/CoreStore.svg?style=flat)](http://cocoadocs.org/docsets/CoreStore)
[![Platform](https://img.shields.io/cocoapods/p/CoreStore.svg?style=flat)](http://cocoadocs.org/docsets/CoreStore)
[![License](https://img.shields.io/cocoapods/l/CoreStore.svg?style=flat)](http://cocoadocs.org/docsets/CoreStore)

Simple, elegant, and smart Core Data programming with Swift
(Swift, iOS 8+)



## Features
- Supports multiple persistent stores per *data stack*, just the way .xcdatamodeld files are supposed to. CoreStore will also manage one *data stack* by default, but you can create and manage as many as you need.
- Ability to plug-in your own logging framework (or any of your favorite 3rd-party logger)
- Gets around a limitation with other Core Data wrappers where the entity name should be the same as the `NSManagedObject` subclass name. CoreStore loads entity-to-class mappings from the .xcdatamodeld file, so you are free to name them independently.
- Observe a list of `NSManagedObject`'s using `ManagedObjectListController`, a clean wrapper for `NSFetchedResultsController`. Another controller, `ManagedObjectController`, lets you observe changes for a single object without using KVO. Both controllers can have multiple observers as well, so there is no extra overhead when sharing the same data source for multiple screens.
- Makes it hard to fall into common concurrency mistakes. All `NSManagedObjectContext` tasks are encapsulated into safer, higher-level abstractions without sacrificing flexibility and customizability.
- Provides convenient API for common use cases.
- Clean API designed around Swift’s code elegance and type safety.

#### TL;DR sample codes

Quick-setup:
```swift
CoreStore.addSQLiteStore("MyStore.sqlite")
```

Simple transactions:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let object = transaction.create(Into(MyEntity))
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
let objects = CoreStore.fetchAll(From(MyEntity))
```
```swift
let objects = CoreStore.fetchAll(
    From(MyEntity),
    Where("entityID", isEqualTo: 1),
    OrderBy(.Ascending("entityID"), .Descending("name")),
    Tweak { (fetchRequest) -> Void in
        fetchRequest.includesPendingChanges = true
    }
)
```

Simple queries:
```swift
let count = CoreStore.queryValue(
    From(MyEntity),
    Select<Int>(.Count("entityID"))
)
```


## Quick jumps

- [Architecture](#architecture)
- [Setting up](#setup)
- [Saving and processing transactions](#transactions)
- [Fetching and querying](#fetch_query)
- [Logging and error handling](#logging)
- [Observing changes and notifications](#observing)
- [Importing data](#importing)



## <a name="architecture"></a>Architecture
For maximum safety and performance, CoreStore will enforce coding patterns and practices it was designed for. (Don't worry, it's not as scary as it sounds.) But it is advisable to understand the "magic" of CoreStore before you use it in your apps.

If you are already familiar with the inner workings of CoreData, here is a mapping of `CoreStore` abstractions:

| *Core Data* | *CoreStore* |
| --- | --- |
| `NSManagedObjectModel` / `NSPersistentStoreCoordinator`<br />(.xcdatamodeld file) | `DataStack` |
| `NSPersistentStore`<br />("Configuration"s in the .xcdatamodeld file) | `DataStack` configuration<br />(multiple sqlite / in-memory stores per stack) |
| `NSManagedObjectContext` | `BaseDataTransaction` subclasses<br />(`SynchronousDataTransaction`, `AsynchronousDataTransaction`, `DetachedDataTransaction`) |

Popular libraries [RestKit](https://github.com/RestKit/RestKit) and [MagicalRecord](https://github.com/magicalpanda/MagicalRecord) set up their `NSManagedObjectContext`s this way:

<img src="https://cloud.githubusercontent.com/assets/3029684/6734049/40579660-ce99-11e4-9d38-829877386afb.png" alt="nested contexts" height=271 />

This ensures maximum data integrity between contexts without blocking the main queue. But as <a href="http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/">Florian Kugler's investigation</a> found out, merging contexts is still by far faster than saving nested contexts. CoreStore's `DataStack` takes the best of both worlds by treating the main `NSManagedObjectContext` as a read-only context, and only allows changes to be made within *transactions*:

<img src="https://cloud.githubusercontent.com/assets/3029684/6734050/4078b642-ce99-11e4-95ea-c0c1d24fbe80.png" alt="nested contexts and merge hybrid" height=212 />

This allows for a butter-smooth main thread, while still taking advantage of safe nested contexts.



## <a name="setup"></a>Setting up
The simplest way to initialize CoreStore is to add a default store to the default stack:
```swift
CoreStore.defaultStack.addSQLiteStore()
```
This one-liner does the following:
- Triggers the lazy-initialization of `CoreStore.defaultStack` with a default `DataStack`
- Sets up the stack's `NSPersistentStoreCoordinator`, the root saving `NSManagedObjectContext`, and the read-only main `NSManagedObjectContext`
- Adds an automigrating SQLite store in the *"Application Support"* directory with the file name *"[App bundle name].sqlite"*
- Creates and returns the `NSPersistentStore` instance on success, or an `NSError` on failure

For most cases, this configuration is usable as it is. But for more hardcore settings, refer to this extensive example:
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

CoreStore.defaultStack = dataStack // pass the dataStack to CoreStore for easier access later on
```

Note that you dont need to do the `CoreStore.defaultStack = dataStack` line. You can just as well hold a stack like below and call all methods directly from the `DataStack` instance:
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
The difference is when you set the stack as the `CoreStore.defaultStack`, you can call the stack's methods directly from `CoreStore` itself:
```swift

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreStore.addSQLiteStore()
    }
    func methodToBeCalledLaterOn() {
        let objects = CoreStore.fetchAll(From(MyEntity))
        println(objects)
    }
}
```

Check out the *CoreStore.swift* and *DataStack.swift files* if you want to explore the inner workings of the data stack.



## <a name="transactions">Saving and processing transactions</a>
(implemented; README pending)
To ensure deterministic state for objects in the read-only `NSManagedObjectContext`, CoreStore does not expose API's for updating and saving directly from the main context (or any other context for that matter.) Instead, you spawn *transactions* from `DataStack` instances:

    let dataStack = self.dataStack
    dataStack.beginAsynchronous { (transaction) -> Void in
        // make changes
        transaction.commit()
    }

or for the default stack, directly from `CoreStore`:

    CoreStore.beginAsynchronous { (transaction) -> Void in
        // make changes
        transaction.commit()
    }

The `commit()` method saves the changes to the persistent store.

The examples above use `beginAsynchronous(...)`, but there are actually 3 types of transactions at you disposal: *asynchronous*, *synchronous*, and *detached*.

**Asynchronous transactions** are spawned from `beginAsynchronous(...)`. This method returns immediately and executes its closure from a background serial queue:

    CoreStore.beginAsynchronous { (transaction) -> Void in
        // make changes
        transaction.commit()
    }

`transaction`'s created from `beginAsynchronous(...)` are instances of `AsynchronousDataTransaction`.

**Synchronous transactions** are created from `beginSynchronous(...)`. While the syntax is similar to its asynchronous counterpart, `beginSynchronous(...)` waits for its transaction block to complete before returning:

    CoreStore.beginSynchronous { (transaction) -> Void in
        // make changes
        transaction.commit()
    } 

`transaction` above is a `SynchronousDataTransaction` instance. Since `beginSynchronous(...)` technically blocks two queues (the caller's queue and the transaction's background queue), it is considered less safe as it's more prone to deadlock. Take special care that the closure does not block on any other external queues.

**Detached transactions** are special in that they do not enclose updates within a closure:

    let transaction = CoreStore.beginDetached()
    // make changes
    downloadJSONWithCompletion({ (json) -> Void in

        // make other changes
        transaction.commit()
    })
    downloadAnotherJSONWithCompletion({ (json) -> Void in

        // make some other changes
        transaction.commit()
    })
    
This allows for non-contiguous updates. As the above example also shows, only detached transactions are allowed to call `commit()` multiple times (doing so with synchronous and asynchronous transactions will trigger an assert).  



## <a name="fetch_query"></a>Fetching and querying
(implemented; README pending)



## <a name="logging"></a>Logging and error handling
(implemented; README pending)



## <a name="observing"></a>Observing changes and notifications
(implemented; README pending)



## <a name="importing"></a>Importing data
(currently implementing)



