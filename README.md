<p align="center">
<img alt="CoreStore" src="https://cloud.githubusercontent.com/assets/3029684/13373932/84daee2a-ddb8-11e5-99db-fdf415620102.png" width=614 />
<br />
<br />
Unleashing the real power of Core Data with the elegance and safety of Swift
<br />
<br />
<a href="https://travis-ci.org/JohnEstropia/CoreStore"><img alt="Build Status" src="https://img.shields.io/travis/JohnEstropia/CoreStore/master.svg?style=flat" /></a>
<a href="http://cocoadocs.org/docsets/CoreStore"><img alt="Platform" src="https://img.shields.io/cocoapods/p/CoreStore.svg?style=flat" /></a>
<a href="https://raw.githubusercontent.com/JohnEstropia/CoreStore/master/LICENSE"><img alt="License" src="https://img.shields.io/cocoapods/l/CoreStore.svg?style=flat" /></a>
<br /><br />Dependency managers<br />
<a href="https://cocoapods.org/pods/CoreStore"><img alt="Cocoapods compatible" src="https://img.shields.io/cocoapods/v/CoreStore.svg?style=flat&label=Cocoapods" /></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage compatible" src="https://img.shields.io/badge/Carthage-compatible-16a085.svg?style=flat" /></a>
<a href="https://swiftpkgs.ng.bluemix.net/package/JohnEstropia/CoreStore"><img alt="Swift Package Manager compatible" src="https://img.shields.io/badge/Swift_Package_Manager-compatible-orange.svg?style=flat" /></a>
<br /><br />Contact<br />
<a href="http://swift-corestore-slack.herokuapp.com/"><img alt="Join us on Slack!" src="http://swift-corestore-slack.herokuapp.com/badge.svg" /></a>
<a href="https://twitter.com/JohnEstropia"><img alt="Reach me on Twitter!" src="https://img.shields.io/badge/twitter-%40JohnEstropia-3498db.svg" /></a>
<br />
</p>
* Swift 2.2 (Xcode 7.3)
* iOS 7+ / macOS 10.10+ / watchOS 2.0+ / tvOS 9.0+
* **New in CoreStore 2.0:** Objective-C support! All CoreStore types now have their corresponding Objective-C "bridging classes". Perfect for projects transitioning from Objective-C to Swift!

Upgrading from CoreStore 1.x to 2.x? Check out the [new features](#new-in-corestore-20) and make sure to read the [Migration guide](#upgrading-from-1xx-to-2xx).


## Why use CoreStore?
I was [MagicalRecord](https://github.com/magicalpanda/MagicalRecord)'s heavy user back then, but I took the promising opportunity to create CoreStore when Swift came around. Part of the inspiration is to address the trend of developers [avoiding](http://inessential.com/2010/02/26/on_switching_away_from_core_data) [Core Data](http://bsktapp.com/blog/why-is-realm-great-and-why-are-we-not-using-it/) [for](https://www.quora.com/Why-would-you-use-Realm-over-Core-Data) [perplexing](http://sebastiandobrincu.com/blog/5-reasons-why-you-should-choose-realm-over-coredata) [reasons](https://medium.com/the-way-north/ditching-core-data-865c1bb5564c#.a5h8ou6ri). 

CoreStore was (and is) heavily shaped by real-world needs of developing data-dependent apps. It enforces safe and convenient Core Data usage while letting you take advantage of the industry's encouraged best practices. And with Core Data and Swift continuously being improved by Apple, CoreStore will just get better and better!

### Features
- **Heavy support for multiple persistent stores per data stack.** CoreStore lets you manage separate stores in a single `DataStack`, just the way *.xcdatamodeld* configurations are designed to. CoreStore will also manage one stack by default, but you can create and manage as many as you need. *(See [Setting up](#setting-up))*
- **Progressive migrations.** No need to think how to migrate from all previous model versions to your latest model. Just tell the `DataStack` the sequence of version strings (`MigrationChain`s) and CoreStore will automatically use progressive migrations when needed. *(See [Migrations](#migrations))*
- **Plug-in your own logging framework.** Although a default logger is built-in, all logging, asserting, and error reporting can be funneled to `CoreStoreLogger` protocol implementations. *(See [Logging and error reporting](#logging-and-error-reporting))*
- **Free to name entities and their class names independently.** CoreStore gets around a restriction with other Core Data wrappers where the entity name should be the same as the `NSManagedObject` subclass name. CoreStore loads entity-to-class mappings from the managed object model file, so you can assign different names for the entities and their class names.
- **Type-safe, easy to configure observers.** You don't have to deal with the burden of setting up `NSFetchedResultsController`s and KVO. As an added bonus, `ListMonitor`s and `ObjectMonitor`s can have multiple observers. This means you can have multiple view controllers efficiently share a single resource! *(See [Observing changes and notifications](#observing-changes-and-notifications))*
- **Clean fetching and querying API.** Fetching objects is easy, but querying for raw aggregates (min, max, etc.) and raw property values is now just as convenient. *(See [Fetching and querying](#fetching-and-querying))*
- **Safer concurrency architecture.** CoreStore makes it hard to fall into common concurrency mistakes. The main `NSManagedObjectContext` is strictly read-only, while all updates are done through serial *transactions*. *(See [Saving and processing transactions](#saving-and-processing-transactions))*
- **Efficient importing utilities.** Map your entities once with their corresponding import source (JSON for example), and importing from *transactions* becomes elegant. Uniquing is also done with an efficient find-and-replace algorithm. *(See [Importing data](#importing-data))*
- **Tight design around Swift’s code elegance and type safety.** CoreStore fully utilizes Swift's community-driven language features.
- **Full Documentation.** No magic here; all public classes, functions, properties, etc. have detailed *Apple Docs*. This *README* also introduces a lot of concepts and explains a lot of CoreStore's behavior.

### New in CoreStore 2.0
- **Informative (and pretty) logs.** All CoreStore and Core Data-related types now have very informative and pretty print outputs! *(See [Logging and error reporting](#logging-and-error-reporting))*
- **Objective-C support!** Is your project transitioning from Objective-C to Swift but still can't quite fully convert some huge classes to Swift yet? CoreStore 2.0 is the answer to the ever-increasing Swift adoption. While still written in pure Swift, all CoreStore types now have their corresponding Objective-C-visible "bridging classes". *(See [Objective-C support](#objective-c-support))*
- **iCloud storage (beta) support.** CoreStore now allows creation of iCloud persistent stores, as well as observing of iCloud-related events through the `ICloudStoreObserver`. *(See [iCloud storage](#icloud-storages))*
- **More extensive Unit Tests.** Extending CoreStore is now safer without having to worry about breaking old behavior.

*Have ideas that may benefit other Core Data users? [Feature Request](https://github.com/JohnEstropia/CoreStore/issues)s are welcome!*

## Contents

- [TL;DR (a.k.a. sample codes)](#tldr-aka-sample-codes)
- [Architecture](#architecture)
- CoreStore Tutorials (All of these have demos in the **CoreStoreDemo** app project!)
    - [Setting up](#setting-up)
        - [In-memory store](#in-memory-store)
        - [Local store](#local-store)
        - [iCloud store](#icloud-store)
    - [Migrations](#migrations)
        - [Progressive migrations](#progressive-migrations)
        - [Forecasting migrations](#forecasting-migrations)
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
    - [Observing changes and notifications](#observing-changes-and-notifications) (unavailable on macOS)
        - [Observe a single object](#observe-a-single-object)
        - [Observe a list of objects](#observe-a-list-of-objects)
    - [Objective-C support](#objective-c-support)
- [Roadmap](#roadmap)
- [Installation](#installation)
- [Changesets](#changesets)
    - [Upgrading from 1.x.x to 2.x.x](#upgrading-from-1xx-to-2xx)
- [Contact](#contact)
- [Who uses CoreStore?](#who-uses-corestore)
- [License](#license)



## TL;DR (a.k.a. sample codes)

Setting-up with progressive migration support:
```swift
CoreStore.defaultStack = DataStack(
    modelName: "MyStore",
    migrationChain: ["MyStore", "MyStoreV2", "MyStoreV3"]
)
```

Adding a store:
```swift
CoreStore.addStorage(
    SQLiteStore(fileName: "MyStore.sqlite"),
    completion: { (result) -> Void in
        // ...
    }
)
```

Starting transactions:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let person = transaction.create(Into(MyPersonEntity))
    person.name = "John Smith"
    person.age = 42

    transaction.commit { (result) -> Void in
        switch result {
            case .Success(let hasChanges): print("success!")
            case .Failure(let error): print(error)
        }
    }
}
```

Fetching objects (simple):
```swift
let people = CoreStore.fetchAll(From(MyPersonEntity))
```

Fetching objects (complex):
```swift
let people = CoreStore.fetchAll(
    From(MyPersonEntity),
    Where("age > 30"),
    OrderBy(.Ascending("name"), .Descending("age")),
    Tweak { (fetchRequest) -> Void in
        fetchRequest.includesPendingChanges = false
    }
)
```

Querying values:
```swift
let maxAge = CoreStore.queryValue(
    From(MyPersonEntity),
    Select<Int>(.Maximum("age"))
)
```

But really, there's a reason I wrote this huge *README*. Read up on the details!

Check out the **CoreStoreDemo** app project for sample codes as well!



## Architecture
For maximum safety and performance, CoreStore will enforce coding patterns and practices it was designed for. (Don't worry, it's not as scary as it sounds.) But it is advisable to understand the "magic" of CoreStore before you use it in your apps.

If you are already familiar with the inner workings of CoreData, here is a mapping of `CoreStore` abstractions:

| *Core Data* | *CoreStore* |
| --- | --- |
| `NSManagedObjectModel` / `NSPersistentStoreCoordinator`<br />(.xcdatamodeld file) | `DataStack` |
| `NSPersistentStore`<br />("Configuration"s in the .xcdatamodeld file) | `StorageInterface` implementations<br />(`InMemoryStore`, `SQLiteStore`, `ICloudStore`) |
| `NSManagedObjectContext` | `BaseDataTransaction` subclasses<br />(`SynchronousDataTransaction`, `AsynchronousDataTransaction`, `UnsafeDataTransaction`) |

A lot of Core Data wrapper libraries set up their `NSManagedObjectContext`s this way:

<img src="https://cloud.githubusercontent.com/assets/3029684/16707160/984ef25c-4600-11e6-869f-8db7d2c63668.png" alt="nested contexts" height=380 />

Nesting saves from child context to the root context ensures maximum data integrity between contexts without blocking the main queue. But <a href="http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/">in reality</a>, merging contexts is still by far faster than saving contexts. CoreStore's `DataStack` takes the best of both worlds by treating the main `NSManagedObjectContext` as a read-only context, and only allows changes to be made within *transactions* on the child context:

<img src="https://cloud.githubusercontent.com/assets/3029684/16707161/9adeb962-4600-11e6-8bc8-4ec85764dba4.png" alt="nested contexts and merge hybrid" height=292 />

This allows for a butter-smooth main thread, while still taking advantage of safe nested contexts.



## Setting up
The simplest way to initialize CoreStore is to add a default store to the default stack:
```swift
try CoreStore.addStorageAndWait()
```
This one-liner does the following:
- Triggers the lazy-initialization of `CoreStore.defaultStack` with a default `DataStack`
- Sets up the stack's `NSPersistentStoreCoordinator`, the root saving `NSManagedObjectContext`, and the read-only main `NSManagedObjectContext`
- Adds an `SQLiteStore` in the *"Application Support/<bundle id>"* directory (or the *"Caches/<bundle id>"* directory on tvOS) with the file name *"[App bundle name].sqlite"*
- Creates and returns the `NSPersistentStore` instance on success, or an `NSError` on failure

For most cases, this configuration is enough as it is. But for more hardcore settings, refer to this extensive example:
```swift
let dataStack = DataStack(
    modelName: "MyModel", // loads from the "MyModel.xcdatamodeld" file
    migrationChain: ["MyStore", "MyStoreV2", "MyStoreV3"] // model versions for progressive migrations
)
let migrationProgress = dataStack.addStorage(
    SQLiteStore(
        fileURL: sqliteFileURL, // set the target file URL for the sqlite file
        configuration: "Config2", // use entities from the "Config2" configuration in the .xcdatamodeld file
        localStorageOptions: .RecreateStoreOnModelMismatch // if migration paths cannot be resolved, recreate the sqlite file
    ),
    completion: { (result) -> Void in
        switch result {
        case .Success(let storage):
            print("Successfully added sqlite store: \(storage)"
        case .Failure(let error):
            print("Failed adding sqlite store with error: \(error)"
        }
    }
)

CoreStore.defaultStack = dataStack // pass the dataStack to CoreStore for easier access later on
```

(If you have never heard of "Configurations", you'll find them in your *.xcdatamodeld* file)
<img src="https://cloud.githubusercontent.com/assets/3029684/8333192/e52cfaac-1acc-11e5-9902-08724f9f1324.png" alt="xcode configurations screenshot" height=212 />

In our sample code above, note that you don't need to do the `CoreStore.defaultStack = dataStack` line. You can just as well hold a reference to the `DataStack` like below and call all its instance methods directly:
```swift
class MyViewController: UIViewController {
    let dataStack = DataStack(modelName: "MyModel") // keep reference to the stack
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try self.dataStack.addStorageAndWait(SQLiteStore)
        }
        catch { // ...
        }
    }
    func methodToBeCalledLaterOn() {
        let objects = self.dataStack.fetchAll(From(MyEntity))
        print(objects)
    }
}
```
The difference is when you set the stack as the `CoreStore.defaultStack`, you can call the stack's methods directly from `CoreStore` itself:
```swift
class MyViewController: UIViewController {
    // elsewhere: CoreStore.defaultStack = DataStack(modelName: "MyModel")
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try CoreStore.addStorageAndWait(SQLiteStore)
        }
        catch { // ...
        }
    }
    func methodToBeCalledLaterOn() {
        let objects = CoreStore.fetchAll(From(MyEntity))
        print(objects)
    }
}
```

Notice that in our previous examples, `addStorageAndWait(_:)` and `addStorage(_:completion:)` both accept either `InMemoryStore`, `SQLiteStore`, or `ICloudStore`. These implement the `StorageInterface` protocol.

### In-memory store
The most basic `StorageInterface` concrete type is the `InMemoryStore`, which just stores objects in memory. Since `InMemoryStore`s always start with a fresh empty data, they do not need any migration information.
```swift
try CoreStore.addStorageAndWait(
    InMemoryStore(
        configuration: "Config2" // optional. Use entities from the "Config2" configuration in the .xcdatamodeld file
    )
)
```
`InMemoryStore`s also implement the `DefaultInitializableStore` sugar protocol which tells CoreStore that this store can initialize without any arguments (`init()`). This lets us provide just the type instead of an instance:
```swift
try CoreStore.addStorageAndWait(InMemoryStore)
```

### Local Store
The most common `StorageInterface` you will probably use is the `SQLiteStore`, which saves data in a local SQLite file.
```swift
let migrationProgress = CoreStore.addStorage(
    SQLiteStore(
        fileName: "MyStore.sqlite",
        configuration: "Config2", // optional. Use entities from the "Config2" configuration in the .xcdatamodeld file
        mappingModelBundles: [NSBundle.mainBundle()], // optional. The bundles that contain required .xcmappingmodel files, if any
        localStorageOptions: .RecreateStoreOnModelMismatch // optional. Provides settings that tells the DataStack how to setup the persistent store
    ),
    completion: { /* ... */ }
)
```
Refer to the *SQLiteStore.swift* source documentation for detailed explanations for each of the default values.

CoreStore can decide the default values for these properties, so `SQLiteStore`s also implement the `DefaultInitializableStore` sugar protocol which lets us write:
```swift
try CoreStore.addStorageAndWait(SQLiteStore)
```
or
```swift
let migrationProgress = CoreStore.addStorage(SQLiteStore.self, completion: { /* ... */ })
```

The file-related properties above are actually requirements of another protocol that `SQLiteStore` implements, the `LocalStorage` protocol:
```swift
public protocol LocalStorage: StorageInterface {
    var fileURL: NSURL { get }
    var mappingModelBundles: [NSBundle] { get }
    var localStorageOptions: LocalStorageOptions { get }
    func storeOptionsForOptions(options: LocalStorageOptions) -> [String: AnyObject]?
    func eraseStorageAndWait(soureModel soureModel: NSManagedObjectModel) throws
}
```
If you have custom `NSIncrementalStore` or `NSAtomicStore` subclasses, you can implement this protocol and use it similarly to `SQLiteStore`.

### iCloud Store
> The iCloud Store is currently in beta. Please use with caution. If you have any concerns please do send me a message on [Twitter](https://twitter.com/JohnEstropia) or on the [CoreStore Slack Team](http://swift-corestore-slack.herokuapp.com/)

As a counterpart to `LocalStorage`, the `CloudStorage` protocol abstracts stores managed in the cloud. CoreStore currently provides the concrete class `ICloudStore`. Unlike `InMemoryStore` and `SQLiteStore` though, the `ICloudStore`'s initializer may return `nil` if the iCloud container could not be located or if iCloud is not available on the device:
```swift
guard let storage = ICloudStore(
    ubiquitousContentName: "MyAppCloudData", // the name of the store in iCloud
    ubiquitousContentTransactionLogsSubdirectory: "logs/config1", // optional. Subdirectory path for the transaction logs
    ubiquitousContainerID: "iCloud.com.mycompany.myapp.containername", // optional. The container if your app has multiple ubiquity container identifiers in its entitlements
    ubiquitousPeerToken: "9614d658014f4151a95d8048fb717cf0", // optional. A per-application salt to allow multiple apps on the same device to share a Core Data store integrated with iCloud
    configuration: "Config1", // optional. Use entities from the "Config1" configuration in the .xcdatamodeld file
    cloudStorageOptions: .RecreateLocalStoreOnModelMismatch // optional. Provides settings that tells the DataStack how to setup the persistent store
) else {
    // The iCloud container could not be located or if iCloud is not available on the device.
    // Handle appropriately
    return    
}
CoreStore.addStorage(,
    storage,
    completion: { result in
        switch result {
        case .Success(let storage): // ...
        case .Failure(let error): // ...
        }
    }
)
```

If your app is using iCloud stores, you may want to be notified of particular iCloud events. The `ICloudStoreObserver` functions are all optional, so you may implement only the ones your app is interested in:
```swift
public protocol ICloudStoreObserver: class {
    func iCloudStoreWillFinishUbiquitousStoreInitialImport(storage storage: ICloudStore, dataStack: DataStack)
    func iCloudStoreDidFinishUbiquitousStoreInitialImport(storage storage: ICloudStore, dataStack: DataStack)
    func iCloudStoreWillAddAccount(storage storage: ICloudStore, dataStack: DataStack)
    func iCloudStoreDidAddAccount(storage storage: ICloudStore, dataStack: DataStack)
    func iCloudStoreWillRemoveAccount(storage storage: ICloudStore, dataStack: DataStack)
    func iCloudStoreDidRemoveAccount(storage storage: ICloudStore, dataStack: DataStack)
    func iCloudStoreWillRemoveContent(storage storage: ICloudStore, dataStack: DataStack)
    func iCloudStoreDidRemoveContent(storage storage: ICloudStore, dataStack: DataStack)
}
```
To register your `ICloudStoreObserver`, call `addObserver(_:)` on the `ICloudStore` instance:

```swift
guard let storage = ICloudStore(/* ... */) else {
    return    
}
storage.addObserver(self) // assuming self implements ICloudStoreObserver
CoreStore.addStorage(,
    storage,
    completion: { result in
        switch result {
        case .Success(let storage): // ... You may also call storage.addObserver(_:) here
        case .Failure(let error): // ...
        }
    }
)
```
The `ICloudStore` only keeps weak references of the registered observers. You may call `removeObserver(_:)` for precise deregistration, but `ICloudStore` automatically removes deallocated observers.


## Migrations
We have seen `addStorageAndWait(...)` used to initialize our persistent store. As the method name's "AndWait" suffix suggests though, this method blocks so it should not do long tasks such as store migrations. In fact CoreStore will only attempt a synchronous **lightweight** migration if you explicitly provide the `.AllowSynchronousLightweightMigration` option:
```swift
try dataStack.addStorageAndWait(
    SQLiteStore(
        fileURL: sqliteFileURL,
        localStorageOptions: .AllowSynchronousLightweightMigration
    )
}
```
if you do so, any model mismatch will be thrown as an error. 

In general though, if migrations are expected the asynchronous variant `addStorage(_:completion:)` method is recommended instead:
```swift
let migrationProgress: NSProgress? = try dataStack.addStorage(
    SQLiteStore(
        fileName: "MyStore.sqlite",
        configuration: "Config2"
    ),
    completion: { (result) -> Void in
        switch result {
        case .Success(let storage):
            print("Successfully added sqlite store: \(storage)")
        case .Failure(let error):
            print("Failed adding sqlite store with error: \(error)")
        }
    }
)
```
The `completion` block reports a `SetupResult` that indicates success or failure.

Notice that this method also returns an optional `NSProgress`. If `nil`, no migrations are needed, thus progress reporting is unnecessary as well. If not `nil`, you can use this to track migration progress by using standard KVO on the `"fractionCompleted"` key, or by using a closure-based utility exposed in *NSProgress+Convenience.swift*:
```swift
migrationProgress?.setProgressHandler { [weak self] (progress) -> Void in
    self?.progressView?.setProgress(Float(progress.fractionCompleted), animated: true)
    self?.percentLabel?.text = progress.localizedDescription // "50% completed"
    self?.stepLabel?.text = progress.localizedAdditionalDescription // "0 of 2"
}
```
This closure is executed on the main thread so UIKit and AppKit calls can be done safely.


### Progressive migrations
By default, CoreStore uses Core Data's default automatic migration mechanism. In other words, CoreStore will try to migrate the existing persistent store to the *.xcdatamodeld* file's current model version. If no mapping model is found from the store's version to the data model's version, CoreStore gives up and reports an error.

The `DataStack` lets you specify hints on how to break a migration into several sub-migrations using a `MigrationChain`. This is typically passed to the `DataStack` initializer and will be applied to all stores added to the `DataStack` with `addSQLiteStore(...)` and its variants:
```swift
let dataStack = DataStack(migrationChain: 
    ["MyAppModel", "MyAppModelV2", "MyAppModelV3", "MyAppModelV4"])
```
The most common usage is to pass in the *.xcdatamodeld* version names in increasing order as above.

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

Initializing with empty values (either `nil`, `[]`, or `[:]`) instructs the `DataStack` to disable progressive migrations and revert to the default migration behavior (i.e. use the .xcdatamodel's current version as the final version):
```swift
let dataStack = DataStack(migrationChain: nil)
```

The `MigrationChain` is validated when passed to the `DataStack` and unless it is empty, will raise an assertion if any of the following conditions are met:
- a version appears twice in an array
- a version appears twice as a key in a dictionary literal
- a loop is found in any of the paths

One important thing to remember is that **if a `MigrationChain` is specified, the *.xcdatamodeld*'s "Current Version" will be bypassed** and the `MigrationChain`'s leafmost version will be the `DataStack`'s base model version.


### Forecasting migrations

Sometimes migrations are huge and you may want prior information so your app could display a loading screen, or to display a confirmation dialog to the user. For this, CoreStore provides a `requiredMigrationsForStorage(_:)` method you can use to inspect a persistent store before you actually call `addStorageAndWait(_:)` or `addStorage(_:completion:)`:
```swift
do {
    let storage = SQLiteStorage(fileName: "MyStore.sqlite")
    let migrationTypes: [MigrationType] = try CoreStore.requiredMigrationsForStorage(storage)
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
    CoreStore.addStorage(storage, completion: { /* ... */ })
}
catch {
    // ... either inspection of the store failed, or if no mapping model was found/inferred
}
```
`requiredMigrationsForStorage(_:)` returns an array of `MigrationType`s, where each item in the array may be either of the following values:
```swift
case Lightweight(sourceVersion: String, destinationVersion: String)
case Heavyweight(sourceVersion: String, destinationVersion: String)
```
Each `MigrationType` indicates the migration type for each step in the `MigrationChain`. Use these information as fit for your app.



## Saving and processing transactions
To ensure deterministic state for objects in the read-only `NSManagedObjectContext`, CoreStore does not expose API's for updating and saving directly from the main context (or any other context for that matter.) Instead, you spawn *transactions* from `DataStack` instances:
```swift
let dataStack = self.dataStack
dataStack.beginAsynchronous { (transaction) -> Void in
    // make changes
    transaction.commit()
}
```
or for the default stack, directly from `CoreStore`:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    // make changes
    transaction.commit()
}
```
The `commit()` method saves the changes to the persistent store. If `commit()` is not called when the transaction block completes, all changes within the transaction is discarded.

The examples above use `beginAsynchronous(...)`, but there are actually 3 types of transactions at your disposal: *asynchronous*, *synchronous*, and *unsafe*.

### Transaction types

#### Asynchronous transactions
are spawned from `beginAsynchronous(...)`. This method returns immediately and executes its closure from a background serial queue:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    // make changes
    transaction.commit()
}
```
Transactions created from `beginAsynchronous(...)` are instances of `AsynchronousDataTransaction`.

#### Synchronous transactions
are created from `beginSynchronous(...)`. While the syntax is similar to its asynchronous counterpart, `beginSynchronous(...)` waits for its transaction block to complete before returning:
```swift
CoreStore.beginSynchronous { (transaction) -> Void in
    // make changes
    transaction.commit()
} 
```
`transaction` above is a `SynchronousDataTransaction` instance.

Since `beginSynchronous(...)` technically blocks two queues (the caller's queue and the transaction's background queue), it is considered less safe as it's more prone to deadlock. Take special care that the closure does not block on any other external queues.

#### Unsafe transactions
are special in that they do not enclose updates within a closure:
```swift
let transaction = CoreStore.beginUnsafe()
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

As the above example also shows, only unsafe transactions are allowed to call `commit()` multiple times; doing so with synchronous and asynchronous transactions will trigger an assert. 


You've seen how to create transactions, but we have yet to see how to make *creates*, *updates*, and *deletes*. The 3 types of transactions above are all subclasses of `BaseDataTransaction`, which implements the methods shown below.

### Creating objects

The `create(...)` method accepts an `Into` clause which specifies the entity for the object you want to create:
```swift
let person = transaction.create(Into(MyPersonEntity))
```
While the syntax is straightforward, CoreStore does not just naively insert a new object. This single line does the following:
- Checks that the entity type exists in any of the transaction's parent persistent store
- If the entity belongs to only one persistent store, a new object is inserted into that store and returned from `create(...)`
- If the entity does not belong to any store, an assert will be triggered. **This is a programmer error and should never occur in production code.**
- If the entity belongs to multiple stores, an assert will be triggered. **This is also a programmer error and should never occur in production code.** Normally, with Core Data you can insert an object in this state but saving the `NSManagedObjectContext` will always fail. CoreStore checks this for you at creation time when it makes sense (not during save).

If the entity exists in multiple configurations, you need to provide the configuration name for the destination persistent store:

    let person = transaction.create(Into<MyPersonEntity>("Config1"))

or if the persistent store is the auto-generated "Default" configuration, specify `nil`:

    let person = transaction.create(Into<MyPersonEntity>(nil))

Note that if you do explicitly specify the configuration name, CoreStore will only try to insert the created object to that particular store and will fail if that store is not found; it will not fall back to any other configuration that the entity belongs to. 

### Updating objects

After creating an object from the transaction, you can simply update its properties as normal:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let person = transaction.create(Into(MyPersonEntity))
    person.name = "John Smith"
    person.age = 30
    transaction.commit()
}
```
To update an existing object, fetch the object's instance from the transaction:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let person = transaction.fetchOne(
        From(MyPersonEntity),
        Where("name", isEqualTo: "Jane Smith")
    )
    person.age = person.age + 1
    transaction.commit()
}
```
*(For more about fetching, see [Fetching and querying](#fetching-and-querying))*

**Do not update an instance that was not created/fetched from the transaction.** If you have a reference to the object already, use the transaction's `edit(...)` method to get an editable proxy instance for that object:
```swift
let jane: MyPersonEntity = // ...

CoreStore.beginAsynchronous { (transaction) -> Void in
    // WRONG: jane.age = jane.age + 1
    // RIGHT:
    let jane = transaction.edit(jane)! // using the same variable name protects us from misusing the non-transaction instance
    jane.age = jane.age + 1
    transaction.commit()
}
```
This is also true when updating an object's relationships. Make sure that the object assigned to the relationship is also created/fetched from the transaction:
```swift
let jane: MyPersonEntity = // ...
let john: MyPersonEntity = // ...

CoreStore.beginAsynchronous { (transaction) -> Void in
    // WRONG: jane.friends = [john]
    // RIGHT:
    let jane = transaction.edit(jane)!
    let john = transaction.edit(john)!
    jane.friends = NSSet(array: [john])
    transaction.commit()
}
```

### Deleting objects

Deleting an object is simpler because you can tell a transaction to delete an object directly without fetching an editable proxy (CoreStore does that for you):
```swift
let john: MyPersonEntity = // ...

CoreStore.beginAsynchronous { (transaction) -> Void in
    transaction.delete(john)
    transaction.commit()
}
```
or several objects at once:
```swift
let john: MyPersonEntity = // ...
let jane: MyPersonEntity = // ...

CoreStore.beginAsynchronous { (transaction) -> Void in
    transaction.delete(john, jane)
    // transaction.delete([john, jane]) is also allowed
    transaction.commit()
}
```
If you do not have references yet to the objects to be deleted, transactions have a `deleteAll(...)` method you can pass a query to:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    transaction.deleteAll(
        From(MyPersonEntity)
        Where("age > 30")
    )
    transaction.commit()
}
```

### Passing objects safely

Always remember that the `DataStack` and individual transactions manage different `NSManagedObjectContext`s so you cannot just use objects between them. That's why transactions have an `edit(...)` method:
```swift
let jane: MyPersonEntity = // ...

CoreStore.beginAsynchronous { (transaction) -> Void in
    let jane = transaction.edit(jane)!
    jane.age = jane.age + 1
    transaction.commit()
}
```
But `CoreStore`, `DataStack` and `BaseDataTransaction` have a very flexible `fetchExisting(...)` method that you can pass instances back and forth with:
```swift
let jane: MyPersonEntity = // ...

CoreStore.beginAsynchronous { (transaction) -> Void in
    let jane = transaction.fetchExisting(jane)! // instance for transaction
    jane.age = jane.age + 1
    transaction.commit {
        let jane = CoreStore.fetchExisting(jane)! // instance for DataStack
        print(jane.age)
    }
}
```
`fetchExisting(...)` also works with multiple `NSManagedObject`s or with `NSManagedObjectID`s:
```swift
var peopleIDs: [NSManagedObjectID] = // ...

CoreStore.beginAsynchronous { (transaction) -> Void in
    let jane = transaction.fetchOne(
        From(MyPersonEntity),
        Where("name", isEqualTo: "Jane Smith")
    )
    jane.friends = NSSet(array: transaction.fetchExisting(peopleIDs)!)
    // ...
}
```


## Importing data
Some times, if not most of the time, the data that we save to Core Data comes from external sources such as web servers or external files. Say you have a JSON dictionary, you may be extracting values as such:
```swift
let json: [String: AnyObject] = // ...
person.name = json["name"] as? NSString
person.age = json["age"] as? NSNumber
// ...
```
If you have many attributes, you don't want to keep repeating this mapping everytime you want to import data. CoreStore lets you write the data mapping code just once, and all you have to do is call `importObject(...)` or `importUniqueObject(...)` through `BaseDataTransaction` subclasses:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let json: [String: AnyObject] = // ...
    try! transaction.importObject(
        Into(MyPersonEntity),
        source: json
    )
    transaction.commit()
}
```
To support data import for an entity, implement either `ImportableObject` or `ImportableUniqueObject` on the `NSManagedObject` subclass:
- `ImportableObject`: Use this protocol if the object have no inherent uniqueness and new objects should always be added when calling `importObject(...)`.
- `ImportableUniqueObject`: Use this protocol to specify a unique ID for an object that will be used to distinguish whether a new object should be created or if an existing object should be updated when calling `importUniqueObject(...)`.

Both protocols require implementers to specify an `ImportSource` which can be set to any type that the object can extract data from:
```swift
typealias ImportSource = NSDictionary
```
```swift
typealias ImportSource = [String: AnyObject]
```
```swift
typealias ImportSource = NSData
```
You can even use external types from popular 3rd-party JSON libraries ([SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)'s `JSON` type is a personal favorite), or just simple tuples or primitives.

#### `ImportableObject`
`ImportableObject` is a very simple protocol:
```swift
public protocol ImportableObject: class {
    typealias ImportSource
    static func shouldInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool
    func didInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws
}
```
First, set `ImportSource` to the expected type of the data source:
```swift
typealias ImportSource = [String: AnyObject]
```
This lets us call `importObject(_:source:)` with any `[String: AnyObject]` type as the argument to `source`:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let json: [String: AnyObject] = // ...
    try! transaction.importObject(
        Into(MyPersonEntity),
        source: json
    )
    // ...
}
```
The actual extraction and assignment of values should be implemented in the `didInsertFromImportSource(...)` method of the `ImportableObject` protocol:
```swift
func didInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws {
    self.name = source["name"] as? NSString
    self.age = source["age"] as? NSNumber
    // ...
}
```
Transactions also let you import multiple objects at once using the `importObjects(_:sourceArray:)` method:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let jsonArray: [[String: AnyObject]] = // ...
    try! transaction.importObjects(
        Into(MyPersonEntity),
        sourceArray: jsonArray
    )
    // ...
}
```
Doing so tells the transaction to iterate through the array of import sources and calls `shouldInsertFromImportSource(...)` on the `ImportableObject` to determine which instances should be created. You can do validations and return `false` from `shouldInsertFromImportSource(...)` if you want to skip importing from a source and continue on with the other sources in the array.

If on the other hand, your validation in one of the sources failed in such a manner that all other sources should also be cancelled, you can `throw` from within `didInsertFromImportSource(...)`:
```swift
func didInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws {
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
CoreStore.beginAsynchronous { (transaction) -> Void in
    let jsonArray: [[String: AnyObject]] = // ...
    do {
        try transaction.importObjects(
            Into(MyPersonEntity),
            sourceArray: jsonArray
        )
    }
    catch {
        return // Woops, don't save
    }
    transaction.commit {
        // ...
    }
}
```

#### `ImportableUniqueObject`
Typically, we don't just keep creating objects every time we import data. Usually we also need to update already existing objects. Implementing the `ImportableUniqueObject` protocol lets you specify a "unique ID" that transactions can use to search existing objects before creating new ones:
```swift
public protocol ImportableUniqueObject: ImportableObject {
    typealias ImportSource
    typealias UniqueIDType: NSObject

    static var uniqueIDKeyPath: String { get }
    var uniqueIDValue: UniqueIDType { get set }

    static func shouldInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool
    static func shouldUpdateFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool
    static func uniqueIDFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws -> UniqueIDType?
    func didInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws
    func updateFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws
}
```
Notice that it has the same insert methods as `ImportableObject`, with additional methods for updates and for specifying the unique ID:
```swift
class var uniqueIDKeyPath: String {
    return "personID" 
}
var uniqueIDValue: NSNumber { 
    get { return self.personID }
    set { self.personID = newValue }
}
class func uniqueIDFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws -> NSNumber? {
    return source["id"] as? NSNumber
}
```
For `ImportableUniqueObject`, the extraction and assignment of values should be implemented from the `updateFromImportSource(...)` method. The `didInsertFromImportSource(...)` by default calls `updateFromImportSource(...)`, but you can separate the implementation for inserts and updates if needed.

You can then create/update an object by calling a transaction's `importUniqueObject(...)` method:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let json: [String: AnyObject] = // ...
    try! transaction.importUniqueObject(
        Into(MyPersonEntity),
        source: json
    )
    // ...
}
```
or multiple objects at once with the `importUniqueObjects(...)` method:

```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let jsonArray: [[String: AnyObject]] = // ...
    try! transaction.importUniqueObjects(
        Into(MyPersonEntity),
        sourceArray: jsonArray
    )
    // ...
}
```
As with `ImportableObject`, you can control wether to skip importing an object by implementing 
`shouldInsertFromImportSource(...)` and `shouldUpdateFromImportSource(...)`, or to cancel all objects by `throw`ing an error from the `uniqueIDFromImportSource(...)`, `didInsertFromImportSource(...)` or `updateFromImportSource(...)` methods.


## Fetching and Querying
Before we dive in, be aware that CoreStore distinguishes between *fetching* and *querying*:
- A *fetch* executes searches from a specific *transaction* or *data stack*. This means fetches can include pending objects (i.e. before a transaction calls on `commit()`.) Use fetches when:
    - results need to be `NSManagedObject` instances
    - unsaved objects should be included in the search (though fetches can be configured to exclude unsaved ones)
- A *query* pulls data straight from the persistent store. This means faster searches when computing aggregates such as *count*, *min*, *max*, etc. Use queries when:
    - you need to compute aggregate functions (see below for a list of supported functions)
    - results can be raw values like `NSString`s, `NSNumber`s, `Int`s, `NSDate`s, an `NSDictionary` of key-values, etc.
    - only values for specified attribute keys need to be included in the results
    - unsaved objects should be ignored

#### `From` clause
The search conditions for fetches and queries are specified using *clauses*. All fetches and queries require a `From` clause that indicates the target entity type:
```swift
let people = CoreStore.fetchAll(From(MyPersonEntity))
// CoreStore.fetchAll(From<MyPersonEntity>()) works as well
```
`people` in the example above will be of type `[MyPersonEntity]`. The `From(MyPersonEntity)` clause indicates a fetch to all persistent stores that `MyPersonEntity` belong to.

If the entity exists in multiple configurations and you need to only search from a particular configuration, indicate in the `From` clause the configuration name for the destination persistent store:
```swift
let people = CoreStore.fetchAll(From<MyPersonEntity>("Config1")) // ignore objects in persistent stores other than the "Config1" configuration
```
or if the persistent store is the auto-generated "Default" configuration, specify `nil`:
```swift
let person = CoreStore.fetchAll(From<MyPersonEntity>(nil))
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
var people = CoreStore.fetchAll(
    From(MyPersonEntity),
    Where("%K > %d", "age", 30) // string format initializer
)
people = CoreStore.fetchAll(
    From(MyPersonEntity),
    Where(true) // boolean initializer
)
```
If you do have an existing `NSPredicate` instance already, you can pass that to `Where` as well:
```swift
let predicate = NSPredicate(...)
var people = CoreStore.fetchAll(
    From(MyPersonEntity),
    Where(predicate) // predicate initializer
)
```
`Where` clauses also implement the `&&`, `||`, and `!` logic operators, so you can provide logical conditions without writing too much `AND`, `OR`, and `NOT` strings:
```swift
var people = CoreStore.fetchAll(
    From(MyPersonEntity),
    Where("age > %d", 30) && Where("gender == %@", "M")
)
```
If you do not provide a `Where` clause, all objects that belong to the specified `From` will be returned.

#### `OrderBy` clause

The `OrderBy` clause is CoreStore's `NSSortDescriptor` wrapper. Use it to specify attribute keys in which to sort the fetch (or query) results with.
```swift
var mostValuablePeople = CoreStore.fetchAll(
    From(MyPersonEntity),
    OrderBy(.Descending("rating"), .Ascending("surname"))
)
```
As seen above, `OrderBy` accepts a list of `SortKey` enumeration values, which can be either `.Ascending` or `.Descending`.

You can use the `+` and `+=` operator to append `OrderBy`s together. This is useful when sorting conditionally:
```swift
var orderBy = OrderBy(.Descending("rating"))
if sortFromYoungest {
    orderBy += OrderBy(.Ascending("age"))
}
var mostValuablePeople = CoreStore.fetchAll(
    From(MyPersonEntity),
    orderBy
)
```

#### `Tweak` clause

The `Tweak` clause lets you, uh, *tweak* the fetch (or query). `Tweak` exposes the `NSFetchRequest` in a closure where you can make changes to its properties:
```swift
var people = CoreStore.fetchAll(
    From(MyPersonEntity),
    Where("age > %d", 30),
    OrderBy(.Ascending("surname")),
    Tweak { (fetchRequest) -> Void in
        fetchRequest.includesPendingChanges = false
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.includesSubentities = false
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
let johnsAge = CoreStore.queryValue(
    From(MyPersonEntity),
    Select<Int>("age"),
    Where("name == %@", "John Smith")
)
```
The example above queries the "age" property for the first object that matches the `Where` condition. `johnsAge` will be bound to type `Int?`, as indicated by the `Select<Int>` generic type. For `queryValue(...)`, the following are allowed as the return type (and therefore as the generic type for `Select<T>`):
- `Bool`
- `Int8`
- `Int16`
- `Int32`
- `Int64`
- `Double`
- `Float`
- `String`
- `NSNumber`
- `NSString`
- `NSDecimalNumber`
- `NSDate`
- `NSData`
- `NSManagedObjectID`
- `NSString`

For `queryAttributes(...)`, only `NSDictionary` is valid for `Select`, thus you are allowed to omit the generic type:
```swift
let allAges = CoreStore.queryAttributes(
    From(MyPersonEntity),
    Select("age")
)
```

If you only need a value for a particular attribute, you can just specify the key name (like we did with `Select<Int>("age")`), but several aggregate functions can also be used as parameter to `Select`:
- `.Average(...)`
- `.Count(...)`
- `.Maximum(...)`
- `.Minimum(...)`
- `.Sum(...)`

```swift
let oldestAge = CoreStore.queryValue(
    From(MyPersonEntity),
    Select<Int>(.Maximum("age"))
)
```

For `queryAttributes(...)` which returns an array of dictionaries, you can specify multiple attributes/aggregates to `Select`:
```swift
let personJSON = CoreStore.queryAttributes(
    From(MyPersonEntity),
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
let personJSON = CoreStore.queryAttributes(
    From(MyPersonEntity),
    Select("name", .Count("friends"))
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
let personJSON = CoreStore.queryAttributes(
    From(MyPersonEntity),
    Select("name", .Count("friends", As: "friendsCount"))
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
let personJSON = CoreStore.queryAttributes(
    From(MyPersonEntity),
    Select("age", .Count("age", As: "count")),
    GroupBy("age")
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
Implement this protocol with your custom class then pass the instance to `CoreStore.logger`:
```swift
CoreStore.logger = MyLogger()
```
Doing so channels all logging calls to your logger.

Note that to keep the call stack information intact, all calls to these methods are **NOT** thread-managed. Therefore you have to make sure that your logger is thread-safe or you may otherwise have to dispatch your logging implementation to a serial queue.

Take special care when implementing `CoreStoreLogger`'s `assert(...)` and `abort(...)` functions:
- `assert(...)`: The behavior between `DEBUG` and release builds, or `-O` and `-Onone`, are all left to the implementers' responsibility. CoreStore calls `CoreStoreLogger.assert(...)` only for invalid but usually recoverable errors (for example, early validation failures that may cause an error thrown and handled somewhere else)
- `abort(...)`: This method is *the* last-chance for your app to *synchronously* log a fatal error within CoreStore. The app will be terminated right after this function is called (CoreStore calls `fatalError()` internally)

Starting CoreStore 2.0, all CoreStore types now have very useful (and pretty formatted!) `print(...)` outputs. 

A couple of examples, `ListMonitor`:

<img width="369" alt="screen shot 2016-07-10 at 22 56 44" src="https://cloud.githubusercontent.com/assets/3029684/16713994/ae06e702-46f1-11e6-83a8-dee48b480bab.png" />

`CoreStoreError.MappingModelNotFoundError`:

<img width="506" alt="MappingModelNotFoundError" src="https://cloud.githubusercontent.com/assets/3029684/16713962/e021f548-46f0-11e6-8100-f9b5ea6b4a08.png" />

These are all implemented with `CustomDebugStringConvertible.debugDescription`, so they work with lldb's `po` command as well.

## Observing changes and notifications (unavailable on macOS)
CoreStore provides type-safe wrappers for observing managed objects:

- `ObjectMonitor`: use to monitor changes to a single `NSManagedObject` instance (instead of Key-Value Observing)
- `ListMonitor`: use to monitor changes to a list of `NSManagedObject` instances (instead of `NSFetchedResultsController`)

### Observe a single object

To observe an object, implement the `ObjectObserver` protocol and specify the `EntityType`:
```swift
class MyViewController: UIViewController, ObjectObserver {
    func objectMonitor(monitor: ObjectMonitor<MyPersonEntity>, willUpdateObject object: MyPersonEntity) {
        // ...
    }
    
    func objectMonitor(monitor: ObjectMonitor<MyPersonEntity>, didUpdateObject object: MyPersonEntity, changedPersistentKeys: Set<KeyPath>) {
        // ...
    }
    
    func objectMonitor(monitor: ObjectMonitor<MyPersonEntity>, didDeleteObject object: MyPersonEntity) {
        // ...
    }
}
```
We then need to keep a `ObjectMonitor` instance and register our `ObjectObserver` as an observer:
```swift
let person: MyPersonEntity = // ...
self.monitor = CoreStore.monitorObject(person)
self.monitor.addObserver(self)
```
The controller will then notify our observer whenever the object's attributes change. You can add multiple `ObjectObserver`s to a single `ObjectMonitor` without any problem. This means you can just share around the `ObjectMonitor` instance to different screens without problem.

You can get `ObjectMonitor`'s object through its `object` property. If the object is deleted, the `object` property will become `nil` to prevent further access. 

While `ObjectMonitor` exposes `removeObserver(...)` as well, it only stores `weak` references of the observers and will safely unregister deallocated observers. 

### Observe a list of objects
To observe a list of objects, implement one of the `ListObserver` protocols and specify the `EntityType`:
```swift
class MyViewController: UIViewController, ListObserver {
    func listMonitorWillChange(monitor: ListMonitor<MyPersonEntity>) {
        // ...
    }
    
    func listMonitorDidChange(monitor: ListMonitor<MyPersonEntity>) {
        // ...
    }
}
```
Including `ListObserver`, there are 3 observer protocols you can implement depending on how detailed you need to handle a change notification:
- `ListObserver`: lets you handle these callback methods:
```swift
    func listMonitorWillChange(monitor: ListMonitor<MyPersonEntity>)
    func listMonitorDidChange(monitor: ListMonitor<MyPersonEntity>)
    func listMonitorWillRefetch(monitor: ListMonitor<MyPersonEntity>)
    func listMonitorDidRefetch(monitor: ListMonitor<MyPersonEntity>)
```
- `ListObjectObserver`: in addition to `ListObserver` methods, also lets you handle object inserts, updates, and deletes:
```swift
    func listMonitor(monitor: ListMonitor<MyPersonEntity>, didInsertObject object: MyPersonEntity, toIndexPath indexPath: NSIndexPath)
    func listMonitor(monitor: ListMonitor<MyPersonEntity>, didDeleteObject object: MyPersonEntity, fromIndexPath indexPath: NSIndexPath)
    func listMonitor(monitor: ListMonitor<MyPersonEntity>, didUpdateObject object: MyPersonEntity, atIndexPath indexPath: NSIndexPath)
    func listMonitor(monitor: ListMonitor<MyPersonEntity>, didMoveObject object: MyPersonEntity, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
```
- `ListSectionObserver`: in addition to `ListObjectObserver` methods, also lets you handle section inserts and deletes:
```swift
    func listMonitor(monitor: ListMonitor<MyPersonEntity>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int)
    func listMonitor(monitor: ListMonitor<MyPersonEntity>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int)
```

We then need to create a `ListMonitor` instance and register our `ListObserver` as an observer:
```swift
self.monitor = CoreStore.monitorList(
    From(MyPersonEntity),
    Where("age > 30"),
    OrderBy(.Ascending("name")),
    Tweak { (fetchRequest) -> Void in
        fetchRequest.fetchBatchSize = 20
    }
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
self.monitor = CoreStore.monitorSectionedList(
    From(MyPersonEntity),
    SectionBy("age"),
    Where("gender", isEqualTo: "M"),
    OrderBy(.Ascending("age"), .Ascending("name")),
    Tweak { (fetchRequest) -> Void in
        fetchRequest.fetchBatchSize = 20
    }
)
```
A list controller created this way will group the objects by the attribute key indicated by the `SectionBy` clause. One more thing to remember is that the `OrderBy` clause should sort the list in such a way that the `SectionBy` attribute would be sorted together (a requirement shared by `NSFetchedResultsController`.)

The `SectionBy` clause can also be passed a closure to transform the section name into a displayable string:
```swift
self.monitor = CoreStore.monitorSectionedList(
    From(MyPersonEntity),
    SectionBy("age") { (sectionName) -> String? in
        "\(sectionName) years old"
    },
    OrderBy(.Ascending("age"), .Ascending("name"))
)
```
This is useful when implementing a `UITableViewDelegate`'s section header:
```swift
func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = self.monitor.sectionInfoAtIndex(section)
    // sectionInfo is an NSFetchedResultsSectionInfo instance
    return sectionInfo.name
}
```

To access the objects of a sectioned list, use an `NSIndexPath` or a tuple:
```swift
let indexPath = NSIndexPath(forRow: 2, inSection: 1)
let person1 = self.monitor[indexPath]
let person2 = self.monitor[1, 2]
// person1 and person2 are the same object
```

## Objective-C support
CoreStore 2.0 was a big move to address the large number of apps starting to convert from Objective-C to Swift. The basic problem is this: The cost of converting all code base to Swift is very big, so most apps are forced to do undergo a *transitional* ObjC-Swift hybrid phase. This used to mean that these apps could not use the Swifty-est libraries out there yet, or that they may have to write their own bridging methods just to make new code usable in their old Objective-C code.

With 2.0, all CoreStore types are still written in pure Swift, but they now have Objective-C "bridging classes" that are visible to Objective-C code. To show a couple of usage examples:

<table>
<tr><th>Swift</th><th>Objective-C</th></tr>
<tr>
<td><pre lang=swift>
try CoreStore.addStorageAndWait(SQLiteStore)
</pre></td>
<td><pre lang=objc>
NSError *error
[CSCoreStore addSQLiteStorageAndWait:[CSSQLiteStore new] error:&error]
</pre></td>
</tr>
<tr>
<td><pre lang=swift>
CoreStore.beginAsynchronous { (transaction) in
    // ...
    transaction.commit { (result) in
        switch result {
        case .Success(let hasChanges): print(hasChanges)
        case .Failure(let error): print(error)
        }
    }
}
</pre></td>
<td><pre lang=objc>
[CSCoreStore beginAsynchronous:^(CSAsynchronousDataTransaction *transaction) {
    // ...
    [transaction commitWithCompletion:^(CSSaveResult *result) {
        if (result.isSuccess) {
            NSLog(@"hasChanges: %d", result.hasChanges);
        }
        else if (result.isFailure) {
            NSLog(@"error: %@", result.error);
        }
    }];
}];
</pre></td>
</tr>
</table>

All of these `CS`-prefixed bridging classes have very similar usage to the existing CoreStore APIs, and ironically *none of them are written in Objective-C*. The secret is all in *CoreStoreBridge.swift*, where we see the signature of these bridging classes, the `CoreStoreObjectiveCType` protocol:
```swift
public protocol CoreStoreObjectiveCType: class, AnyObject {
    associatedtype SwiftType
    var bridgeToSwift: SwiftType { get }
    init(_ swiftValue: SwiftType)
}
```
Notice that these bridging classes all hold a reference to their corresponding `SwiftType`.

Conversely, CoreStore original types implement the `CoreStoreSwiftType` protocol:
```swift
public protocol CoreStoreSwiftType {
    associatedtype ObjectiveCType
    var bridgeToObjectiveC: ObjectiveCType { get }
}
```
These two protocols let CoreStore types free to bridge instances between Objective-C and Swift.

This is very different to the common approach where apps and libraries write Objective-C APIs just to support both Objective-C and Swift. The advantage with CoreStore's approach is that your Swift codebase can already use the purely-Swift API without further changes in the future, but your "hybrid" codebase can still bridge instances back and forth from Objective-C to Swift.

For example, you may have a new, modern Swift class that holds a `ListMonitor`:
```swift
class MyViewController: UIViewController {
    let monitor = CoreStore.monitorList(From(MyEntity), ...)
    // ...
}
```
Now let's say you have a legacy Objective-C class that previously uses `NSFetchedResultsController`. It's easy to switch from `NSFetchedResultsController` to `CSListMonitor`, but converting the rest of this huge class is impractical. You end up with 
```objc
@interface MYOldViewController: UIViewController 
@property (nonatomic, readonly, strong) CSListMonitor* monitor;
- (instancetype)initWithMonitor:(CSListMonitor *)monitor;
@end
```
When you need to instantiate this class from Swift, you just call `bridgeToObjectiveC`:
```swift
class MyViewController: UIViewController {
    let monitor = CoreStore.monitorList(From(MyEntity), ...)
    func showOldController() {
        let controller = MYOldViewController(monitor: self.monitor.bridgeToObjectiveC)
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
```
Note that the `CSListMonitor` holds the exact same `ListMonitor` instance, which means that no copies and no extra fetching occur.

### Objective-C syntax sugars
Objective-C tends to be verbose, so some method calls are long and unreadable. For example, fetching looks like this:
```objc
NSArray<MYPerson *> *objects = 
[CSCoreStore
 fetchAllFrom:[[CSFrom alloc] initWithEntityClass:[MYPerson class]]
 fetchClauses:@[[[CSWhere alloc] initWithFormat:@"%K == %@", @"isHidden", @NO],
                [[CSOrderBy alloc] initWithSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
                                                             [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]]]];
```
Although it works, it looks terrible. For this, CoreStore provides *CoreStoreBridge.h* where these Objective-C calls are wrapped in readable, convenient macros and global functions. The call above becomes
```objc
NSArray<MYPerson *> *objects = 
[CSCoreStore
 fetchAllFrom:CSFromClass([MYPerson class])
 fetchClauses:@[CSWhereFormat(@"%K == %@", @"isHidden", @NO),
                CSOrderByKeys(CSSortAscending(@"lastName"),
                              CSSortAscending(@"firstName"), nil)]];
```
That's much shorter now. But we can still do better. Notice that we have strings being used as key paths. The `CSKeyPath(...)` macro gives us compile-time checking so keys that don't exist in a class will generate errors. Our key-safe code now looks like this:
```objc
NSArray<MYPerson *> *objects = 
[CSCoreStore
 fetchAllFrom:CSFromClass([MYPerson class])
 fetchClauses:@[CSWhereFormat(@"%K == %@", CSKeyPath(MYPerson, isHidden), @NO),
                CSOrderByKeys(CSSortAscending(CSKeyPath(MYPerson, lastName)),
                              CSSortAscending(CSKeyPath(MYPerson, firstName)), nil)]];
```

To use these syntax sugars, include *CoreStoreBridge.h* in your Objective-C source files. For projects that support iOS 7 (and thus cannot build CoreStore as a module), you will need to add 
```
SWIFT_OBJC_INTERFACE_HEADER_NAME=$(SWIFT_OBJC_INTERFACE_HEADER_NAME)
```
to your target's `GCC_PREPROCESSOR_DEFINITIONS` build setting.

<img width="797" alt="GCC_PREPROCESSOR_DEFINITIONS" src="https://cloud.githubusercontent.com/assets/3029684/16714547/92497fc4-4701-11e6-81db-6b1a11743cc5.png" />


# Roadmap
- Built-in "singleton objects" support
- Built-in "readonly" stores
- CoreSpotlight auto-indexing (experimenting, still some roadblocks ahead)
- Synching


# Installation
- Requires:
    - iOS 7 SDK and above
    - Swift 2.2 (Xcode 7.3)
- Dependencies:
    - [GCDKit](https://github.com/JohnEstropia/GCDKit)
- Other notes:
    - The `com.apple.CoreData.ConcurrencyDebug` debug argument should be turned off for the app. CoreStore already guarantees safety for you by making the main context read-only, and by only executing transactions serially.

### Install with CocoaPods (iOS 7 not supported)
```
pod 'CoreStore'
```
This installs CoreStore as a framework. Declare `import CoreStore` in your swift file to use the library.

### Install with Carthage
In your `Cartfile`, add
```
github "JohnEstropia/CoreStore" >= 2.0.0
github "JohnEstropia/GCDKit" >= 1.2.5
```
and run 
```
carthage update
```

### Install as Git Submodule
```
git submodule add https://github.com/JohnEstropia/CoreStore.git <destination directory>
```
Drag and drop **CoreStore.xcodeproj** to your project.

#### To install as a framework (iOS 7 not supported):
Drag and drop **CoreStore.xcodeproj** to your project.

#### To include directly in your app module:
Add all *.swift* files to your project.


### Objective-C support

To use the Objective-C syntax sugars, import *CoreStoreBridge.h* in your *.m* source files.

For projects that support iOS 7 (and thus cannot build CoreStore as a module), you will need to add 
```
SWIFT_OBJC_INTERFACE_HEADER_NAME=$(SWIFT_OBJC_INTERFACE_HEADER_NAME)
```
to your target's `GCC_PREPROCESSOR_DEFINITIONS` build setting:

<img width="797" alt="GCC_PREPROCESSOR_DEFINITIONS" src="https://cloud.githubusercontent.com/assets/3029684/16714547/92497fc4-4701-11e6-81db-6b1a11743cc5.png" />


# Changesets
### Upgrading from 1.x.x to 2.x.x
**Obsoleted**
- `AsynchronousDataTransaction.rollback()` was removed. Undo and rollback functionality are now only allowed on `UnsafeDataTransaction`s
- `DetachedDataTransaction` was renamed to `UnsafeDataTransaction`
- `beginDetached()` was renamed to `beginUnsafe()`
- `PersistentStoreResult` was removed in favor of `SetupResult<T>`
- `SynchronousDataTransaction.commit()` was renamed to `SynchronousDataTransaction.commitAndWait()`
- `From` initializers that accepted `NSURL`s and `NSPersistentStore` were removed.

**Deprecated**
The following methods are still available, but will be removed in a future update.
- `add*Store(...)` method variants. It is strongly recommended to convert to the new API. Refer to [Local store](#local-store)) usage then use `LegacySQLiteStore` instead of `SQLiteStore` to maintain the old default file names and directory values
    - `addInMemoryStoreAndWait(...)` → `addStorageAndWait(InMemoryStore(...))`
    - `addSQLiteStoreAndWait(...)` → `addStorageAndWait(LegacySQLiteStore(...))`
    - `addInMemoryStore(...)` → `addStorage(InMemoryStore(...), ...)`
    - `addSQLiteStore(...)` → `addStorage(LegacySQLiteStore(...), ...)`
    - `requiredMigrationsForSQLiteStore(...)` → `requiredMigrationsForStorage(...)`
    - `upgradeSQLiteStoreIfNeeded(...)` → `upgradeStorageIfNeeded(...)`
    - The `resetStoreOnModelMismatch: Bool` argument for the methods above are now provided to the `LegacySQLiteStore` and `SQLiteStore` initializers as a `LocalStorageOptions` option set
- `NSError` used to have a `coreStoreErrorCode` property that returns `CoreStoreErrorCode` enum, but all CoreStore errors are now guaranteed to be `CoreStoreError` enum type in swift, and `CSError` type on Objective-C.
- `CoreStoreLogger.handleError(...)` was deprecated in favor of `CoreStoreLogger.log(error:...)`. `CoreStoreLogger` may also implement `CoreStoreLogger.abort(...)`, which is called just before CoreStore executes `fatalError()` due to critical runtime errors.


# Contact
Questions? Suggestions?

Reach me on Twitter [@JohnEstropia](https://twitter.com/JohnEstropia)

or join our Slack team at [swift-corestore.slack.com](http://swift-corestore-slack.herokuapp.com/)

日本語の対応も可能なので是非！


# Who uses CoreStore?
I'd love to hear about apps using CoreStore. Send me a message and I'll feature your apps here!


# License
CoreStore is released under an MIT license. See the [LICENSE](https://raw.githubusercontent.com/JohnEstropia/CoreStore/master/LICENSE) file for more information

