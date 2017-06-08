//
//  CoreStoreBridge.h
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#ifndef CoreStoreBridge_h
#define CoreStoreBridge_h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#if !__has_feature(objc_arc)
#error CoreStore Objective-C utilities require ARC be enabled
#endif

#if !__has_extension(attribute_overloadable)
#error CoreStore Objective-C utilities can only be used on platforms that support C function overloading
#endif

#define CORESTORE_EXTERN                    extern
#define CORESTORE_OVERLOADABLE              __attribute__((__overloadable__))
#define CORESTORE_REQUIRES_NIL_TERMINATION  __attribute__((sentinel(0, 1)))
#define CORESTORE_RETURNS_RETAINED          __attribute__((ns_returns_retained))


#pragma mark - RawKeyPath Utilities

#define CSKeyPath(type, property) ({ \
    type *_je_keypath_dummy __attribute__((unused)); \
    typeof(_je_keypath_dummy.property) _je_keypath_dummy_property __attribute__((unused)); \
    @#property; \
})

#define CSKeyPathOperator(operator, type, property) ({ \
    type *_je_keypath_dummy __attribute__((unused)); \
    typeof(_je_keypath_dummy.property) _je_keypath_dummy_property __attribute__((unused)); \
    @"@" #operator "." #property; \
})


#pragma mark - Clauses


#pragma mark CSFrom

@class CSFrom;

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified entity class.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:
    CSFromClass([MyPersonEntity class])];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @result
 a <tt>CSFrom</tt> clause with the specified entity class
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified configuration.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:
    CSFromClass([MyPersonEntity class], @"Configuration1")];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @param configuration
 an <tt>NSPersistentStore</tt> configuration name to associate objects from. This parameter is required if multiple configurations contain the created <tt>NSManagedObject</tt>'s entity type. Set to <tt>[NSNull null]</tt> to use the default configuration.
 
 @result
 a <tt>CSFrom</tt> clause with the specified configuration
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSNull *_Nonnull configuration) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified configuration.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:
    CSFromClass([MyPersonEntity class], @"Configuration1")];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @param configuration
 an <tt>NSPersistentStore</tt> configuration name to associate objects from. This parameter is required if multiple configurations contain the created <tt>NSManagedObject</tt>'s entity type. Set to <tt>[NSNull null]</tt> to use the default configuration.
 
 @result
 a <tt>CSFrom</tt> clause with the specified configuration
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSString *_Nonnull configuration) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified configurations.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:
    CSFromClass([MyPersonEntity class],
                @[[NSNull null], @"Configuration1"])];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @param configurations
 an array of the <tt>NSPersistentStore</tt> configuration names to associate objects from. This parameter is required if multiple configurations contain the created <tt>NSManagedObject</tt>'s entity type. Set to <tt>[NSNull null]</tt> to use the default configuration.
 
 @result
 a <tt>CSFrom</tt> clause with the specified configurations
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSArray<id> *_Nonnull configurations) CORESTORE_RETURNS_RETAINED;


#pragma mark CSGroupBy

@class CSGroupBy;

/**
 @abstract
 Initializes a <tt>CSGroupBy</tt> clause with a key path string
 
 @param keyPath
 a key path string to group results with
 
 @result
 a <tt>CSGroupBy</tt> clause with a key path string
 */
CORESTORE_EXTERN
CSGroupBy *_Nonnull CSGroupByKeyPath(NSString *_Nonnull keyPath) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSGroupBy</tt> clause with a list of key path strings
 
 @param keyPath
 a nil-terminated list of key path strings to group results with
 
 @result
 a <tt>CSGroupBy</tt> clause with a list of key path strings
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSString *_Nonnull keyPath, ...) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSGroupBy</tt> clause with a list of key path strings
 
 @param keyPaths
 a list of key path strings to group results with
 
 @result
 a <tt>CSGroupBy</tt> clause with a list of key path strings
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSArray<NSString *> *_Nonnull keyPaths) CORESTORE_RETURNS_RETAINED;


#pragma mark CSInto

@class CSInto;

/**
 @abstract
 Initializes a <tt>CSInto</tt> clause with the specified entity class.
 
 @code
 MyPersonEntity *people = [transaction createInto:
    CSIntoClass([MyPersonEntity class])];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @result
 a <tt>CSInto</tt> clause with the specified entity class
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSInto</tt> clause with the specified entity class.
 
 @code
 MyPersonEntity *people = [transaction createInto:
    CSIntoClass([MyPersonEntity class], [NSNull null])];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @param configuration
 an <tt>NSPersistentStore</tt> configuration name to associate objects from. This parameter is required if multiple configurations contain the created <tt>NSManagedObject</tt>'s entity type. Set to <tt>[NSNull null]</tt> to use the default configuration.
 
 @result
 a <tt>CSInto</tt> clause with the specified entity class
 */
CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass, NSNull *_Nonnull configuration) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSInto</tt> clause with the specified entity class.
 
 @code
 MyPersonEntity *people = [transaction createInto:
    CSIntoClass([MyPersonEntity class], @"Configuration1")];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @param configuration
 an <tt>NSPersistentStore</tt> configuration name to associate objects from. This parameter is required if multiple configurations contain the created <tt>NSManagedObject</tt>'s entity type. Set to <tt>[NSNull null]</tt> to use the default configuration.
 
 @result
 a <tt>CSInto</tt> clause with the specified entity class
 */
CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass, NSString *_Nonnull configuration) CORESTORE_RETURNS_RETAINED;


#pragma mark CSOrderBy

@class CSOrderBy;

/**
 @abstract
 Syntax sugar for initializing an ascending <tt>NSSortDescriptor</tt> for use with <tt>CSOrderBy</tt>
 
 @code
 MyPersonEntity *people = [CSCoreStore
    fetchAllFrom:CSFromClass([MyPersonEntity class])
    fetchClauses:@[CSOrderByKey(CSSortAscending(@"fullname"))]]];
 @endcode
 
 @param key
 the attribute key to sort with
 
 @result
 an <tt>NSSortDescriptor</tt> for use with <tt>CSOrderBy</tt>
 */
CORESTORE_EXTERN
NSSortDescriptor *_Nonnull CSSortAscending(NSString *_Nonnull key) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Syntax sugar for initializing a descending <tt>NSSortDescriptor</tt> for use with <tt>CSOrderBy</tt>
 
 @code
 MyPersonEntity *people = [CSCoreStore
    fetchAllFrom:CSFromClass([MyPersonEntity class])
    fetchClauses:@[CSOrderByKey(CSSortDescending(@"fullname"))]]];
 @endcode
 
 @param key
 the attribute key to sort with
 
 @result
 an <tt>NSSortDescriptor</tt> for use with <tt>CSOrderBy</tt>
 */
CORESTORE_EXTERN
NSSortDescriptor *_Nonnull CSSortDescending(NSString *_Nonnull key)  CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSOrderBy</tt> clause with a single sort descriptor
 
 @code
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromClass([MyPersonEntity class])
    fetchClauses:@[CSOrderByKey(CSSortAscending(@"fullname"))]]];
 @endcode
 
 @param sortDescriptor
 an <tt>NSSortDescriptor</tt>
 
 @result
 a <tt>CSOrderBy</tt> clause with a single sort descriptor
 */
CORESTORE_EXTERN
CSOrderBy *_Nonnull CSOrderByKey(NSSortDescriptor *_Nonnull sortDescriptor) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSOrderBy</tt> clause with a list of sort descriptors
 
 @code
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromClass([MyPersonEntity class])
    fetchClauses:@[CSOrderByKeys(CSSortAscending(@"fullname"), CSSortDescending(@"age"), nil))]]];
 @endcode
 
 @param sortDescriptor
 a nil-terminated array of <tt>NSSortDescriptor</tt>s
 
 @result
 a <tt>CSOrderBy</tt> clause with a list of sort descriptors
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderByKeys(NSSortDescriptor *_Nonnull sortDescriptor, ...) CORESTORE_RETURNS_RETAINED CORESTORE_REQUIRES_NIL_TERMINATION;

/**
 @abstract
 Initializes a <tt>CSOrderBy</tt> clause with a list of sort descriptors
 
 @code
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromClass([MyPersonEntity class])
    fetchClauses:@[CSOrderByKeys(@[CSSortAscending(@"fullname"), CSSortDescending(@"age")]))]]];
 @endcode
 
 @param sortDescriptors
 an array of <tt>NSSortDescriptor</tt>s
 
 @result
 a <tt>CSOrderBy</tt> clause with a list of sort descriptors
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderByKeys(NSArray<NSSortDescriptor *> *_Nonnull sortDescriptors) CORESTORE_RETURNS_RETAINED;


#pragma mark CSSelect

@class CSSelect;
@class CSSelectTerm;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSNumber</tt> value
 
 @code
 NSNumber *maxAge = [CSCoreStore
    queryValueFrom:CSFromClass([MyPersonEntity class])
    select:CSSelectNumber(CSAggregateMax(@"age"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSNumber</tt> value
 */
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectNumber(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSDecimalNumber</tt> value
 
 @code
 NSDecimalNumber *averagePrice = [CSCoreStore
    queryValueFrom:CSFromClass([MyPersonEntity class])
    select:CSSelectDecimal(CSAggregateAverage(@"price"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSDecimalNumber</tt> value
 */
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectDecimal(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSString</tt> value
 
 @code
 NSString *fullname = [CSCoreStore
    queryValueFrom:CSFromClass([MyPersonEntity class])
    select:CSSelectString(CSAttribute(@"fullname"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSString</tt> value
 */
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectString(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSDate</tt> value
 
 @code
 NSDate *lastUpdate = [CSCoreStore
    queryValueFrom:CSFromClass([MyPersonEntity class])
    select:CSSelectDate(CSAggregateMax(@"updatedDate"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSDate</tt> value
 */
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectDate(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSData</tt> value
 
 @code
 NSData *imageData = [CSCoreStore
    queryValueFrom:CSFromClass([MyPersonEntity class])
    select:CSSelectData(CSAttribute(@"imageData"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSData</tt> value
 */
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectData(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSManagedObjectID</tt> value
 
 @code
 NSManagedObjectID *objectID = [CSCoreStore
    queryValueFrom:CSFromClass([MyPersonEntity class])
    select:CSSelectObjectID()
    // ...
 @endcode
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSManagedObjectID</tt> value
 */
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectObjectID() CORESTORE_RETURNS_RETAINED;


#pragma mark CSTweak

@class CSTweak;

/**
 @abstract
 Initializes a <tt>CSTweak</tt> clause with a block where the <tt>NSFetchRequest</tt> may be configured.
 
 @important
 <tt>CSTweak</tt>'s closure is executed only just before the fetch occurs, so make sure that any values captured by the closure is not prone to race conditions. Also, some utilities (such as <tt>CSListMonitor</tt>s) may keep <tt>CSFetchClause</tt>s in memory and may thus introduce retain cycles if reference captures are not handled properly.
 
 @param block
 the block to customize the <tt>NSFetchRequest</tt>
 
 @result
 a <tt>CSTweak</tt> clause with the <tt>NSFetchRequest</tt> configuration block
 */
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSTweak *_Nonnull CSTweakRequest(void (^_Nonnull block)(NSFetchRequest *_Nonnull fetchRequest)) CORESTORE_RETURNS_RETAINED;


#pragma mark CSWhere

@class CSWhere;

/**
 @abstract
 Initializes a <tt>CSWhere</tt> clause with a predicate that always evaluates to the specified boolean value
 
 @code
 MyPersonEntity *people = [transaction 
    fetchAllFrom:CSFromClass([MyPersonEntity class])
    fetchClauses:@[CSWhereValue(YES)]];
 @endcode
 
 @param value
 the boolean value for the predicate
 
 @result
 a <tt>CSWhere</tt> clause with a predicate that always evaluates to the specified boolean value
 */
CORESTORE_EXTERN
CSWhere *_Nonnull CSWhereValue(BOOL value) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSWhere</tt> clause with a predicate using the specified string format and arguments
 
 @code
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromClass([MyPersonEntity class])
    fetchClauses:@[CSWhereFormat(@"%K == %@", @"key", @"value")]];
 @endcode
 
 @param format
 the format string for the predicate, followed by an optional comma-separated argument list
 
 @result
 a <tt>CSWhere</tt> clause with a predicate using the specified string format and arguments
 */
CORESTORE_EXTERN
CSWhere *_Nonnull CSWhereFormat(NSString *_Nonnull format, ...) CORESTORE_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSWhere</tt> clause with an <tt>NSPredicate</tt>
 
 @code
 NSPredicate *predicate = // ...
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromClass([MyPersonEntity class])
    fetchClauses:@[CSWherePredicate(predicate)]];
 @endcode
 
 @param predicate
 the <tt>NSPredicate</tt> for the fetch or query
 
 @result
 a <tt>CSWhere</tt> clause with an <tt>NSPredicate</tt>
 */
CORESTORE_EXTERN
CSWhere *_Nonnull CSWherePredicate(NSPredicate *_Nonnull predicate) CORESTORE_RETURNS_RETAINED;


#pragma mark CoreStoreFetchRequest

// Bugfix for NSFetchRequest messing up memory management for `affectedStores`
// http://stackoverflow.com/questions/14396375/nsfetchedresultscontroller-crashes-in-ios-6-if-affectedstores-is-specified
NS_SWIFT_NAME(CoreStoreFetchRequest)
@interface _CSFetchRequest: NSFetchRequest

@property (nullable, nonatomic, copy, readonly) NSArray<NSPersistentStore *> *safeAffectedStores;

@end


#endif /* CoreStoreBridge_h */
