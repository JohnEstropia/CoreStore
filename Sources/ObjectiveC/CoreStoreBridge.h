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

#define CS_OBJC_EXTERN                      extern
#define CS_OBJC_OVERLOADABLE                __attribute__((__overloadable__))
#define CS_OBJC_REQUIRES_NIL_TERMINATION    __attribute__((sentinel(0, 1)))
#define CS_OBJC_RETURNS_RETAINED            __attribute__((ns_returns_retained))


// MARK: - From

@class CSFrom;

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified entity class.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:
    CSFromCreate([MyPersonEntity class])];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @result
 a <tt>CSFrom</tt> clause with the specified entity class
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSFrom *_Nonnull CSFromCreate(Class _Nonnull entityClass) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified configuration.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:
    CSFromCreate([MyPersonEntity class], @"Configuration1")];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @param configuration
 an <tt>NSPersistentStore</tt> configuration name to associate objects from. This parameter is required if multiple configurations contain the created <tt>NSManagedObject</tt>'s entity type. Set to <tt>[NSNull null]</tt> to use the default configuration.
 
 @result
 a <tt>CSFrom</tt> clause with the specified configuration
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSFrom *_Nonnull CSFromCreate(Class _Nonnull entityClass, NSNull *_Nonnull configuration) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified configuration.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:
    CSFromCreate([MyPersonEntity class], @"Configuration1")];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @param configuration
 an <tt>NSPersistentStore</tt> configuration name to associate objects from. This parameter is required if multiple configurations contain the created <tt>NSManagedObject</tt>'s entity type. Set to <tt>[NSNull null]</tt> to use the default configuration.
 
 @result
 a <tt>CSFrom</tt> clause with the specified configuration
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSFrom *_Nonnull CSFromCreate(Class _Nonnull entityClass, NSString *_Nonnull configuration) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified configurations.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:
    CSFromCreate([MyPersonEntity class],
                 @[[NSNull null], @"Configuration1"])];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @param configurations
 an array of the <tt>NSPersistentStore</tt> configuration names to associate objects from. This parameter is required if multiple configurations contain the created <tt>NSManagedObject</tt>'s entity type. Set to <tt>[NSNull null]</tt> to use the default configuration.
 
 @result
 a <tt>CSFrom</tt> clause with the specified configurations
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSFrom *_Nonnull CSFromCreate(Class _Nonnull entityClass, NSArray<id> *_Nonnull configurations) CS_OBJC_RETURNS_RETAINED;


// MARK: - Select

@class CSSelect;
@class CSSelectTerm;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSNumber</tt> value
 
 @code
 NSNumber *maxAge = [CSCoreStore
    queryValueFrom:CSFromCreate([MyPersonEntity class])
    select:CSSelectNumber(CSAggregateMax(@"age"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSNumber</tt> value
 */
CS_OBJC_EXTERN
CSSelect *_Nonnull CSSelectNumber(CSSelectTerm *_Nonnull selectTerm) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSDecimalNumber</tt> value
 
 @code
 NSDecimalNumber *averagePrice = [CSCoreStore
    queryValueFrom:CSFromCreate([MyPersonEntity class])
    select:CSSelectDecimal(CSAggregateAverage(@"price"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSDecimalNumber</tt> value
 */
CS_OBJC_EXTERN
CSSelect *_Nonnull CSSelectDecimal(CSSelectTerm *_Nonnull selectTerm) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSString</tt> value
 
 @code
 NSString *fullname = [CSCoreStore
    queryValueFrom:CSFromCreate([MyPersonEntity class])
    select:CSSelectString(CSAttribute(@"fullname"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSString</tt> value
 */
CS_OBJC_EXTERN
CSSelect *_Nonnull CSSelectString(CSSelectTerm *_Nonnull selectTerm) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSDate</tt> value
 
 @code
 NSDate *lastUpdate = [CSCoreStore
    queryValueFrom:CSFromCreate([MyPersonEntity class])
    select:CSSelectDate(CSAggregateMax(@"updatedDate"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSDate</tt> value
 */
CS_OBJC_EXTERN
CSSelect *_Nonnull CSSelectDate(CSSelectTerm *_Nonnull selectTerm) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSData</tt> value
 
 @code
 NSData *imageData = [CSCoreStore
    queryValueFrom:CSFromCreate([MyPersonEntity class])
    select:CSSelectData(CSAttribute(@"imageData"))
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSData</tt> value
 */
CS_OBJC_EXTERN
CSSelect *_Nonnull CSSelectData(CSSelectTerm *_Nonnull selectTerm) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Creates a <tt>CSSelect</tt> clause for querying an <tt>NSManagedObjectID</tt> value
 
 @code
 NSManagedObjectID *objectID = [CSCoreStore
    queryValueFrom:CSFromCreate([MyPersonEntity class])
    select:CSSelectObjectID()
    // ...
 @endcode
 
 @param selectTerm
 the <tt>CSSelectTerm</tt> specifying the attribute/aggregate value to query
 
 @result
 a <tt>CSSelect</tt> clause for querying an <tt>NSManagedObjectID</tt> value
 */
CS_OBJC_EXTERN
CSSelect *_Nonnull CSSelectObjectID() CS_OBJC_RETURNS_RETAINED;


// MARK: - Where

@class CSWhere;

/**
 @abstract
 Initializes a <tt>CSWhere</tt> clause with a predicate that always evaluates to the specified boolean value
 
 @code
 MyPersonEntity *people = [transaction 
    fetchAllFrom:CSFromCreate([MyPersonEntity class])
    fetchClauses:@[CSWhereValue(YES)]];
 @endcode
 
 @param value
 the boolean value for the predicate
 
 @result
 a <tt>CSWhere</tt> clause with a predicate that always evaluates to the specified boolean value
 */
CS_OBJC_EXTERN
CSWhere *_Nonnull CSWhereValue(BOOL value) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSWhere</tt> clause with a predicate using the specified string format and arguments
 
 @code
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromCreate([MyPersonEntity class])
    fetchClauses:@[CSWhereFormat(@"%K == %@", @"key", @"value")]];
 @endcode
 
 @param format
 the format string for the predicate
 
 @param argumentArray
 the arguments for <tt>format</tt>
 
 @result
 a <tt>CSWhere</tt> clause with a predicate using the specified string format and arguments
 */
CS_OBJC_EXTERN
CSWhere *_Nonnull CSWhereFormat(NSString *_Nonnull format, ...) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSWhere</tt> clause with an <tt>NSPredicate</tt>
 
 @code
 NSPredicate *predicate = // ...
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromCreate([MyPersonEntity class])
    fetchClauses:@[CSWherePredicate(predicate)]];
 @endcode
 
 @param predicate
 the <tt>NSPredicate</tt> for the fetch or query
 
 @result
 a <tt>CSWhere</tt> clause with an <tt>NSPredicate</tt>
 */
CS_OBJC_EXTERN
CSWhere *_Nonnull CSWherePredicate(NSPredicate *_Nonnull predicate) CS_OBJC_RETURNS_RETAINED;


// MARK: - OrderBy

@class CSOrderBy;

/**
 @abstract
 Syntax sugar for initializing an ascending <tt>NSSortDescriptor</tt> for use with <tt>CSOrderBy</tt>
 
 @code
 MyPersonEntity *people = [CSCoreStore
    fetchAllFrom:CSFromCreate([MyPersonEntity class])
    fetchClauses:@[CSOrderBySortKey(CSSortAscending(@"fullname"))]]];
 @endcode
 
 @param key
 the attribute key to sort with
 
 @result
 an <tt>NSSortDescriptor</tt> for use with <tt>CSOrderBy</tt>
 */
CS_OBJC_EXTERN
NSSortDescriptor *_Nonnull CSSortAscending(NSString *_Nonnull key) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Syntax sugar for initializing a descending <tt>NSSortDescriptor</tt> for use with <tt>CSOrderBy</tt>
 
 @code
 MyPersonEntity *people = [CSCoreStore
        fetchAllFrom:CSFromCreate([MyPersonEntity class])
 fetchClauses:@[CSOrderBySortKey(CSSortDescending(@"fullname"))]]];
 @endcode
 
 @param key
 the attribute key to sort with
 
 @result
 an <tt>NSSortDescriptor</tt> for use with <tt>CSOrderBy</tt>
 */
CS_OBJC_EXTERN
NSSortDescriptor *_Nonnull CSSortDescending(NSString *_Nonnull key)  CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSOrderBy</tt> clause with a single sort descriptor
 
 @code
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromCreate([MyPersonEntity class])
    fetchClauses:@[CSOrderBySortKey(CSSortAscending(@"fullname"))]]];
 @endcode
 
 @param sortDescriptor
 an <tt>NSSortDescriptor</tt>
 
 @result
 a <tt>CSOrderBy</tt> clause with a single sort descriptor
 */
CS_OBJC_EXTERN
CSOrderBy *_Nonnull CSOrderBySortKey(NSSortDescriptor *_Nonnull sortDescriptor) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSOrderBy</tt> clause with a list of sort descriptors
 
 @code
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromCreate([MyPersonEntity class])
    fetchClauses:@[CSOrderBySortKeys(CSSortAscending(@"fullname"), CSSortDescending(@"age"), nil))]]];
 @endcode
 
 @param sortDescriptors
 a nil-terminated array of <tt>NSSortDescriptor</tt>s
 
 @result
 a <tt>CSOrderBy</tt> clause with a list of sort descriptors
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderBySortKeys(NSSortDescriptor *_Nonnull sortDescriptor, ...) CS_OBJC_RETURNS_RETAINED CS_OBJC_REQUIRES_NIL_TERMINATION;

/**
 @abstract
 Initializes a <tt>CSOrderBy</tt> clause with a list of sort descriptors
 
 @code
 MyPersonEntity *people = [transaction
    fetchAllFrom:CSFromCreate([MyPersonEntity class])
    fetchClauses:@[CSOrderBySortKeys(@[CSSortAscending(@"fullname"), CSSortDescending(@"age")]))]]];
 @endcode
 
 @param sortDescriptors
 an array of <tt>NSSortDescriptor</tt>s
 
 @result
 a <tt>CSOrderBy</tt> clause with a list of sort descriptors
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderBySortKeys(NSArray<NSSortDescriptor *> *_Nonnull sortDescriptors) CS_OBJC_RETURNS_RETAINED;


// MARK: - GroupBy

@class CSGroupBy;

/**
 @abstract
 Initializes a <tt>CSGroupBy</tt> clause with a key path string
 
 @param keyPaths
 a key path string to group results with
 
 @result
 a <tt>CSGroupBy</tt> clause with a key path string
 */
CS_OBJC_EXTERN
CSGroupBy *_Nonnull CSGroupByKeyPath(NSString *_Nonnull keyPath) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSGroupBy</tt> clause with a list of key path strings
 
 @param keyPaths
 a nil-terminated list of key path strings to group results with
 
 @result
 a <tt>CSGroupBy</tt> clause with a list of key path strings
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSString *_Nonnull keyPath, ...) CS_OBJC_RETURNS_RETAINED;

/**
 @abstract
 Initializes a <tt>CSGroupBy</tt> clause with a list of key path strings
 
 @param keyPaths
 a list of key path strings to group results with
 
 @result
 a <tt>CSGroupBy</tt> clause with a list of key path strings
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSArray<NSString *> *_Nonnull keyPaths) CS_OBJC_RETURNS_RETAINED;


// MARK: - Tweak

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
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSTweak *_Nonnull CSTweakCreate(void (^_Nonnull block)(NSFetchRequest *_Nonnull fetchRequest)) CS_OBJC_RETURNS_RETAINED;


#endif /* CoreStoreBridge_h */
