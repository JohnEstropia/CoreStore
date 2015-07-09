# CoreStore
[![Version](https://img.shields.io/cocoapods/v/CoreStore.svg?style=flat)](http://cocoadocs.org/docsets/CoreStore)
[![Platform](https://img.shields.io/cocoapods/p/CoreStore.svg?style=flat)](http://cocoadocs.org/docsets/CoreStore)
[![License](https://img.shields.io/cocoapods/l/CoreStore.svg?style=flat)](https://raw.githubusercontent.com/JohnEstropia/CoreStore/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Simple, elegant, and smart Core Data programming with Swift
(Swift, iOS 8+)

[Click here for a wiki version of this README](https://github.com/JohnEstropia/CoreStore/wiki)


## What CoreStore does better:
- Heavily supports multiple persistent stores per data stack, just the way .xcdatamodeld files are designed to. CoreStore will also manage one data stack by default, but you can create and manage as many as you need.
- Ability to plug-in your own logging framework
- Gets around a limitation with other Core Data wrappers where the entity name should be the same as the `NSManagedObject` subclass name. CoreStore loads entity-to-class mappings from the managed object model file, so you are free to name them independently.
- Provides type-safe, easy to configure observers to replace `NSFetchedResultsController` and KVO
- Exposes API not just for fetching, but also for querying aggregates and property values
- Makes it hard to fall into common concurrency mistakes. All `NSManagedObjectContext` tasks are encapsulated into safer, higher-level abstractions without sacrificing flexibility and customizability.
- Provides convenient API for common use cases.
- Clean API designed around Swift’s code elegance and type safety.

**CoreStore's goal is not to expose shorter, magical syntax, but to provide an API that prioritizes readability, consistency, and safety.**

#### TL;DR sample codes

Quick-setup:
```swift
CoreStore.addSQLiteStoreAndWait("MyStore.sqlite")
```

Simple transactions:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    let person = transaction.create(Into(MyPersonEntity))
    person.name = "John Smith"
    person.age = 42

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
let people = CoreStore.fetchAll(From(MyPersonEntity))
```
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

Simple queries:
```swift
let maxAge = CoreStore.queryValue(
    From(MyPersonEntity),
    Select<Int>(.Maximum("age"))
)
```

Check out the **CoreStoreDemo** app as well!


## Contents

- [Architecture](#architecture)
- [Setting up](#setup)
- [Saving and processing transactions](#transactions)
- [Fetching and querying](#fetch_query)
- [Logging and error handling](#logging)
- [Observing changes and notifications](#observing)



## <a id="architecture"></a>Architecture
For maximum safety and performance, CoreStore will enforce coding patterns and practices it was designed for. (Don't worry, it's not as scary as it sounds.) But it is advisable to understand the "magic" of CoreStore before you use it in your apps.

If you are already familiar with the inner workings of CoreData, here is a mapping of `CoreStore` abstractions:

| *Core Data* | *CoreStore* |
| --- | --- |
| `NSManagedObjectModel` / `NSPersistentStoreCoordinator`<br />(.xcdatamodeld file) | `DataStack` |
| `NSPersistentStore`<br />("Configuration"s in the .xcdatamodeld file) | `DataStack` configuration<br />(multiple sqlite / in-memory stores per stack) |
| `NSManagedObjectContext` | `BaseDataTransaction` subclasses<br />(`SynchronousDataTransaction`, `AsynchronousDataTransaction`, `DetachedDataTransaction`) |

Popular libraries [RestKit](https://github.com/RestKit/RestKit) and [MagicalRecord](https://github.com/magicalpanda/MagicalRecord) set up their `NSManagedObjectContext`s this way:

<img src="https://cloud.githubusercontent.com/assets/3029684/6734049/40579660-ce99-11e4-9d38-829877386afb.png" alt="nested contexts" height=271 />

Nesting context saves from child context to the root context ensures maximum data integrity between contexts without blocking the main queue. But as <a href="http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/">Florian Kugler's investigation</a> found out, merging contexts is still by far faster than saving nested contexts. CoreStore's `DataStack` takes the best of both worlds by treating the main `NSManagedObjectContext` as a read-only context, and only allows changes to be made within *transactions* on the child context:

<img src="https://cloud.githubusercontent.com/assets/3029684/6734050/4078b642-ce99-11e4-95ea-c0c1d24fbe80.png" alt="nested contexts and merge hybrid" height=212 />

This allows for a butter-smooth main thread, while still taking advantage of safe nested contexts.



## <a id="setup"></a>Setting up
The simplest way to initialize CoreStore is to add a default store to the default stack:
```swift
CoreStore.addSQLiteStoreAndWait()
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

switch dataStack.addSQLiteStoreAndWait(
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
        self.dataStack.addSQLiteStoreAndWait()
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
        CoreStore.addSQLiteStoreAndWait()
    }
    func methodToBeCalledLaterOn() {
        let objects = CoreStore.fetchAll(From(MyEntity))
        println(objects)
    }
}
```



## <a id="transactions">Saving and processing transactions</a>
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

The examples above use `beginAsynchronous(...)`, but there are actually 3 types of transactions at you disposal: *asynchronous*, *synchronous*, and *detached*.

**Asynchronous transactions** are spawned from `beginAsynchronous(...)`. This method returns immediately and executes its closure from a background serial queue:
```swift
CoreStore.beginAsynchronous { (transaction) -> Void in
    // make changes
    transaction.commit()
}
```
Transactions created from `beginAsynchronous(...)` are instances of `AsynchronousDataTransaction`.

**Synchronous transactions** are created from `beginSynchronous(...)`. While the syntax is similar to its asynchronous counterpart, `beginSynchronous(...)` waits for its transaction block to complete before returning:
```swift
CoreStore.beginSynchronous { (transaction) -> Void in
    // make changes
    transaction.commit()
} 
```
`transaction` above is a `SynchronousDataTransaction` instance.

Since `beginSynchronous(...)` technically blocks two queues (the caller's queue and the transaction's background queue), it is considered less safe as it's more prone to deadlock. Take special care that the closure does not block on any other external queues.

**Detached transactions** are special in that they do not enclose updates within a closure:
```swift
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
```
This allows for non-contiguous updates. Do note that this flexibility comes with a price: you are now responsible for managing concurrency for the transaction. As uncle Ben said, "with great power comes great race conditions."

As the above example also shows, only detached transactions are allowed to call `commit()` multiple times; doing so with synchronous and asynchronous transactions will trigger an assert. 


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
- If the entity belongs to multiple stores, an assert will be triggered. **This is also a programmer error and should never occur in production code.** Normally, with Core Data you can insert an object in this state but saving the `NSManagedObjectContext` will always fail. CoreStore checks this for you at creation time where it makes sense (not during save).

If the entity exists in multiple configurations, you need to provide the configuration name for the destination persistent store:

    let person = transaction.create(Into<MyPersonEntity>("Config1"))

or if the persistent store is the auto-generated "Default" configuration, specify `nil`:

    let person = transaction.create(Into<MyPersonEntity>(nil))

Note that if you do explicitly specify the configuration name, CoreStore will only try to insert the created object to that particular store and will fail if that store is not found; it will not fall back to any other store the entity belongs to. 

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
*(For more about fetching, read [Fetching and querying](#fetch_query))*

**Do not update an instance that was not created/fetched from the transaction.** If you have a reference to the object already, use the transaction's `edit(...)` method to get an editable proxy instance for that object:
```swift
let jane: MyPersonEntity = // ...

CoreStore.beginAsynchronous { (transaction) -> Void in
    // WRONG: jane.age = jane.age + 1
    // RIGHT:
    let jane = transaction.edit(jane) // using the same variable name protects us from misusing the non-transaction instance
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
    let jane = transaction.edit(jane)
    let john = transaction.edit(john)
    jane.friends = [john]
    transaction.commit()
}
```
### Deleting objects

Deleting an object is simpler as you can tell a transaction to delete an object directly without fetching an editable proxy (CoreStore does that for you):
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
## <a id="fetch_query"></a>Fetching and querying
Before we dive in, be aware that CoreStore distinguishes between *fetching* and *querying*:
- A *fetch* executes searches from a specific *transaction* or *data stack*. This means fetches can include pending objects (i.e. before a transaction calls on `commit()`.) Use fetches when:
    - results need to be `NSManagedObject` instances
    - unsaved objects should be included in the search (though fetches can be configured to exclude unsaved ones)
- A *query* pulls data straight from the persistent store. This means faster searches when computing aggregates such as *count*, *min*, *max*, etc. Use queries when:
    - you need to compute aggregate functions (see below for a list of supported functions)
    - results can be raw values like `NSString`s, `NSNumber`s, `Int`s, `NSDate`s, an `NSDictionary` of key-values, etc.
    - only specific attribute keys need to be included in the results
    - unsaved objects should be ignored

The search conditions for fetches and queries are specified using *clauses*. All fetches and queries require a `From` clause that indicates the target entity type:
```swift
let people = CoreStore.fetchAll(From(MyPersonEntity))
// CoreStore.fetchAll(From<MyPersonEntity>()) works as well
```
`people` in the example above will be of type `[MyPersonEntity]`. The `From(MyPersonEntity)` clause indicates a fetch to all persistent stores that `MyPersonEntity` belong to.

If the entity exists in multiple configurations and you need to only search from a particular configuration, provide the `From` clause the configuration name for the destination persistent store:
```swift
let people = CoreStore.fetchAll(From<MyPersonEntity>("Config1")) // ignore objects in persistent stores other than the "Config1" configuration
```
or if the persistent store is the auto-generated "Default" configuration, specify `nil`:
```swift
let person = CoreStore.fetchAll(From<MyPersonEntity>(nil))
```
Now we know how to use a `From` clause, let's move on to fetching and querying.

#### Fetching

There are currently 5 fetch methods you can call from `CoreStore`, from a `DataStack` instance, or from a `BaseDataTransaction` instance. All of the methods below accept the same parameters: a required `From` clause, and an optional series of `Where`, `OrderBy`, and/or `Tweak` clauses.

- `fetchAll(_:_:)` - returns an array of all objects that match the criteria.
- `fetchOne(_:_:)` - returns the first object that match the criteria.
- `fetchCount(_:_:)` - returns the number of objects that match the criteria.
- `fetchObjectIDs(_:_:)`` - returns an array of `NSManagedObjectID`s for all objects that match the criteria.
- `fetchObjectID(_:_:)` - returns the `NSManagedObjectID`s for the first objects that match the criteria.

Each method's purpose is straightforward, but we need to understand how to set the clauses for the fetch.

**`Where` clause**

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
`Where` clauses also implement the `&&`, `||`, and `!` logic operators, so you can provide logical conditions without writing too much `AND`, `OR`, and `NOT` strings in the conditions:
```swift
var people = CoreStore.fetchAll(
    From(MyPersonEntity),
    Where("age > %d", 30) && Where("gender == %@", "M")
)
```
If you do not provide a `Where` clause, all objects that belong to the specified `From` will be returned.

**`OrderBy` clause**

The `OrderBy` clause is CoreStore's `NSSortDescriptor` wrapper. Use it to specify attribute keys in which to sort the fetch (or query) results with.
```swift
var mostValuablePeople = CoreStore.fetchAll(
    From(MyPersonEntity),
    OrderBy(.Descending("rating"), .Ascending("surname"))
)
```
As seen above, `OrderBy` accepts a list of `SortKey` enumeration values, which can be either `.Ascending` or `.Descending`. The associated value for the `SortKey` enumeration is the attribute key string.

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

**`Tweak` clause**

The `Tweak` clause lets you, well, *tweak* the fetch (or query). `Tweak` exposes the `NSFetchRequest` in a closure where you can make changes to its properties:
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

Do note that while `Tweak` lets you micro-configure its `NSFetchRequest`, don't forget that CoreStore already preconfigured that `NSFetchRequest` to suitable defaults. Only use `Tweak` when you know what you are doing!

#### Querying
One of the functionalities overlooked by other Core Data wrapper libraries is raw properties fetching. If you are familiar with `NSDictionaryResultType` and `-[NSFetchedRequest propertiesToFetch]`, you probably know how painful it is to setup a query for raw values and aggregate values. CoreStore makes querying easy by exposing the 2 methods below:

- `queryValue(_:_:_:)` - returns a single raw value for an attribute or for an aggregate value. If there are multiple results, `queryValue(...)` only returns the first item.
- `queryAttributes(_:_:_:)` - returns an array of dictionaries containing attribute keys with their corresponding values.

Both methods above accept the same parameters: a required `From` clause, a required `Select<T>` clause, and an optional series of `Where`, `OrderBy`, `GroupBy`, and/or `Tweak` clauses.

Setting up the `From`, `Where`, `OrderBy`, and `Tweak` clauses is similar to how you would when fetching. For querying, you also need to know how to use the `Select<T>` and `GroupBy` clauses.

**`Select<T>` clause**

The `Select<T>` clause specifies the target attribute/aggregate key and the return type: 
```swift
let johnsAge = CoreStore.queryValue(
    From(MyPersonEntity),
    Select<Int>("age"),
    Where("name == %@", "John Smith")
)
```
The example above queries the "age" property for the first object that matches the `Where` condition. `johnsAge` will be bound to type `Int?`, as indicated by the `Select<Int>` generic type. For `queryValue(...)`, the following are allowed as the return type (and as the generic type for `Select<T>`):
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

For `queryAttributes(...)`, only `NSDictionary` is valid for `Select`, thus you are allowed omit the generic type:
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
```json
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

**`GroupBy` clause**

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

## <a id="logging"></a>Logging and error handling
One unfortunate thing when using some third-party libraries is that they usually pollute the console with their own logging mechanisms. CoreStore provides its own default logging class, but you can plug-in your own favorite logger by implementing the `CoreStoreLogger` protocol.
```swift
final class MyLogger: CoreStoreLogger {
    func log(#level: LogLevel, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        // pass to your logger
    }
    
    func handleError(#error: NSError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        // pass to your logger
    }
    
    func assert(@autoclosure condition: () -> Bool, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        // pass to your logger
    }
}
```
Then pass an instance of this class to `CoreStore`:
```swift
CoreStore.logger = MyLogger()
```
Doing so channels all logging calls to your logger.

Note that to keep the call stack information intact, all calls to these methods are not thread-managed. Thus you have to make sure that your logger is thread-safe or you may otherwise have to dispatch your logging implementation to a serial queue.

## <a id="observing"></a>Observing changes and notifications
CoreStore provides type-safe wrappers for observing managed objects:

- `ManagedObjectController`: use to observe changes to a single `NSManagedObject` instance (instead of Key-Value Observing)
- `ManagedObjectListController`: use to observe changes to a list of `NSManagedObject` instances (instead of `NSFetchedResultsController`)

#### Observe a single object

To observe an object, implement the `ManagedObjectObserver` protocol and specify the `EntityType`:
```swift
class MyViewController: UIViewController, ManagedObjectObserver {
    func managedObjectWillUpdate(objectController: ManagedObjectController<MyPersonEntity>, object: MyPersonEntity) {
        // ...
    }
    
    func managedObjectWasUpdated(objectController: ManagedObjectController<MyPersonEntity>, object: MyPersonEntity, changedPersistentKeys: Set<KeyPath>) {
        // ...
    }
    
    func managedObjectWasDeleted(objectController: ManagedObjectController<MyPersonEntity>, object: MyPersonEntity) {
        // ...
    }
}
```
We then need to keep a `ManagedObjectController` instance and register our `ManagedObjectObserver` as an observer:
```swift
let person: MyPersonEntity = // ...
self.objectController = CoreStore.observeObject(person)
self.objectController.addObserver(self)
```
The controller will then notify our observer whenever the object's attributes change. You can add multiple `ManagedObjectObserver`s to a single `ManagedObjectController` without any problem. This means you can just share around the `ManagedObjectController` instance to different screens without problem.

You can get `ManagedObjectController`'s object through its `object` property. If the object is deleted, the `object` property will become `nil` to prevent further access. 

While `ManagedObjectController` exposes `removeObserver(...)` as well, it only stores `weak` references of the observers and will safely unregister deallocated observers. 

#### Observe a list of objects
To observe a list of objects, implement one of the `ManagedObjectListChangeObserver` protocols and specify the `EntityType`:
```swift
class MyViewController: UIViewController, ManagedObjectListChangeObserver {
    func managedObjectListWillChange(listController: ManagedObjectListController<MyPersonEntity>) {
        // ...
    }
    
    func managedObjectListDidChange(listController: ManagedObjectListController<MyPersonEntity>) {
        // ...
    }
}
```
Including `ManagedObjectListChangeObserver`, there are 3 observer protocols you can implement depending on how detailed you need to handle a change notification:
- `ManagedObjectListChangeObserver`: lets you handle these callback methods:
    - `func managedObjectListWillChange(listController: ManagedObjectListController<T>)`
    - `func managedObjectListDidChange(listController: ManagedObjectListController<T>)`
- `ManagedObjectListObjectObserver`: in addition to `ManagedObjectListChangeObserver` methods, also lets you handle object inserts, updates, and deletes:
    - `func managedObjectList(listController: ManagedObjectListController<T>, didInsertObject object: T, toIndexPath indexPath: NSIndexPath)`
    - `func managedObjectList(listController: ManagedObjectListController<T>, didDeleteObject object: T, fromIndexPath indexPath: NSIndexPath)`
    - `func managedObjectList(listController: ManagedObjectListController<T>, didUpdateObject object: T, atIndexPath indexPath: NSIndexPath)`
    - `func managedObjectList(listController: ManagedObjectListController<T>, didMoveObject object: T, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)`
- `ManagedObjectListSectionObserver`: in addition to `ManagedObjectListObjectObserver` methods, also lets you handle section inserts and deletes:
    - `func managedObjectList(listController: ManagedObjectListController<T>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int)`
    - `func managedObjectList(listController: ManagedObjectListController<T>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int)`

We then need to create a `ManagedObjectListController` instance and register our `ManagedObjectListChangeObserver` as an observer:
```swift
self.listController = CoreStore.observeObjectList(
    From(MyPersonEntity),
    Where("age > 30"),
    OrderBy(.Ascending("name")),
    Tweak { (fetchRequest) -> Void in
        fetchRequest.fetchBatchSize = 20
    }
)
self.listController.addObserver(self)
```
Similar to `ManagedObjectController`, a `ManagedObjectListController` can also have multiple `ManagedObjectListChangeObserver`s registered to a single `ManagedObjectListController`.

If you have noticed, the `observeObjectList(...)` method accepts `Where`, `OrderBy`, and `Tweak` clauses exactly like a fetch. As the list maintained by `ManagedObjectListController` needs to have a deterministic order, at least the `From` and `OrderBy` clauses are required.

A `ManagedObjectListController` created from `observeObjectList(...)` will maintain a single-section list. You can therefore access its contents with just an index:
```swift
let firstPerson = self.listController[0]
```

If the list needs to be grouped into sections, create the `ManagedObjectListController` instance with the `observeSectionedList(...)` method and a `SectionedBy` clause:
```swift
self.listController = CoreStore.observeSectionedList(
    From(MyPersonEntity),
    SectionedBy("age"),
    Where("gender", isEqualTo: "M"),
    OrderBy(.Ascending("age"), .Ascending("name")),
    Tweak { (fetchRequest) -> Void in
        fetchRequest.fetchBatchSize = 20
    }
)
```
A list controller created this way will group the objects by the attribute key indicated by the `SectionedBy` clause. One more thing to remember is that the `OrderBy` clause should sort the list in such a way that the `SectionedBy` attribute would be sorted together (a requirement shared by `NSFetchedResultsController`.)

The `SectionedBy` clause can also be passed a closure to transform the section name into a displayable string:
```swift
self.listController = CoreStore.observeSectionedList(
    From(MyPersonEntity),
    SectionedBy("age") { (sectionName) -> String? in
        "\(sectionName) years old"
    },
    OrderBy(.Ascending("age"), .Ascending("name"))
)
```
This is useful when implementing a `UITableViewDelegate`'s section header:
```swift
func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = self.listController.sectionInfoAtIndex(section)
    // sectionInfo is an NSFetchedResultsSectionInfo instance
    return sectionInfo.name
}
```

To access the objects of a sectioned list, use an `NSIndexPath` or a tuple:
```swift
let indexPath = NSIndexPath(forRow: 2, inSection: 1)
let person1 = self.listController[indexPath]
let person2 = self.listController[1, 2]
// person1 and person2 are the same object
```

# TODO
- Data importing utilities for transactions
- Migration utilities
- Support iCloud stores


# Installation
- Requires iOS 8 SDK and above
- Swift 1.2

### Install with Cocoapods
```
pod 'CoreStore'
```
This installs CoreStore as a framework. Declare `import CoreStore` in your swift file to use the library.

### Install with Carthage
```
github "JohnEstropia/CoreStore" >= 0.2.1
```

### Install as Git Submodule
```
git submodule add https://github.com/JohnEstropia/CoreStore.git <destination directory>
```
#### To install as a framework:
Drag and drop **CoreStore.xcodeproj** to your project.
#### To include directly in your app module:
Add all *.swift* files to your project.

# Contributions
While CoreStore's design is pretty solid and the unit test and demo app work well, CoreStore is pretty much still in its early stage. With more exposure to production code usage and criticisms from the developer community, CoreStore hopes to mature as well.
Please feel free to report any issues, suggestions, or criticisms!
日本語で連絡していただいても構いません！

## License
CoreStore is released under an MIT license. See the LICENSE file for more information

