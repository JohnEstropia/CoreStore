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

#import <Foundation/Foundation.h>

#ifndef CoreStoreBridge_h
#define CoreStoreBridge_h

#if !__has_feature(objc_arc)
#error CoreStore Objective-C utilities require ARC be enabled
#endif

#if !__has_extension(attribute_overloadable)
#error CoreStore Objective-C utilities can only be used on platforms that support C function overloading
#endif

#define CS_OBJC_EXTERN                          extern
#define CS_OBJC_OVERLOADABLE                    __attribute__((__overloadable__))
#define CS_OBJC_REQUIRES_NIL_TERMINATION(A, B)  __attribute__((sentinel(A, B)))


// MARK: - From

@class CSFrom;

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified entity class.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:From([MyPersonEntity class])];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @result
 a <tt>CSFrom</tt> clause with the specified entity class
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSFrom *_Nonnull From(Class _Nonnull entityClass);

/**
 @abstract
 Initializes a <tt>CSFrom</tt> clause with the specified configurations.
 
 @code
 MyPersonEntity *people = [transaction fetchAllFrom:From([MyPersonEntity class], @[@"Configuration1"])];
 @endcode
 
 @param entityClass
 the <tt>NSManagedObject</tt> class type to be created
 
 @param configurations
 an array of the <tt>NSPersistentStore</tt> configuration names to associate objects from. This parameter is required if multiple configurations contain the created <tt>NSManagedObject</tt>'s entity type. Set to <tt>[NSNull null]</tt> to use the default configuration.
 
 @result
 a <tt>CSFrom</tt> clause with the specified configurations
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSFrom *_Nonnull From(Class _Nonnull entityClass, NSArray<id> *_Nonnull configurations);



// MARK: - Where

@class CSWhere;

/**
 @abstract
 Initializes a <tt>CSWhere</tt> clause with a predicate that always evaluates to the specified boolean value
 
 @param value
 the boolean value for the predicate
 
 @result
 a <tt>CSWhere</tt> clause with a predicate that always evaluates to the specified boolean value
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSWhere *_Nonnull Where(BOOL value);

/**
 @abstract
 Initializes a <tt>CSWhere</tt> clause with a predicate using the specified string format and arguments
 
 @param format
 the format string for the predicate
 
 @param argumentArray
 the arguments for <tt>format</tt>
 
 @result
 a <tt>CSWhere</tt> clause with a predicate using the specified string format and arguments
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSWhere *_Nonnull Where(NSString *_Nonnull format, ...);

/**
 @abstract
 Initializes a <tt>CSWhere</tt> clause with an <tt>NSPredicate</tt>
 
 @param predicate
 the <tt>NSPredicate</tt> for the fetch or query
 
 @result
 a <tt>CSWhere</tt> clause with an <tt>NSPredicate</tt>
 */
CS_OBJC_EXTERN CS_OBJC_OVERLOADABLE
CSWhere *_Nonnull Where(NSPredicate *_Nonnull predicate);


// MARK: - GroupBy

@class CSGroupBy;

/**
 @abstract
 Initializes a <tt>CSGroupBy</tt> clause with a list of key path strings
 
 @param keyPaths
 a list of key path strings to group results with
 
 @result
 a <tt>CSGroupBy</tt> clause with a list of key path strings
 */
CS_OBJC_OVERLOADABLE
CSGroupBy *_Nonnull GroupBy(NSArray<NSString *> *_Nonnull keyPaths);


#endif /* CoreStoreBridge_h */
