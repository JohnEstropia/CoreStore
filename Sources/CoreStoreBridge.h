//
//  CoreStoreBridge.h
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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

#define CORESTORE_EXTERN                    extern __deprecated_msg("CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
#define CORESTORE_OVERLOADABLE              __attribute__((__overloadable__))
#define CORESTORE_REQUIRES_NIL_TERMINATION  __attribute__((sentinel(0, 1)))
#define CORESTORE_RETURNS_RETAINED          __attribute__((ns_returns_retained))


#pragma mark - KeyPathString Utilities

#define CSKeyPath(type, property) ({ \
    CORESTORE_OBJC_OBSOLETE; \
    type *_je_keypath_dummy __attribute__((unused)); \
    typeof(_je_keypath_dummy.property) _je_keypath_dummy_property __attribute__((unused)); \
    @#property; \
})

#define CSKeyPathOperator(operator, type, property) ({ \
    CORESTORE_OBJC_OBSOLETE; \
    type *_je_keypath_dummy __attribute__((unused)); \
    typeof(_je_keypath_dummy.property) _je_keypath_dummy_property __attribute__((unused)); \
    @"@" #operator "." #property; \
})


#pragma mark - Clauses


#pragma mark CSFrom

@class CSFrom;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSNull *_Nonnull configuration) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSString *_Nonnull configuration) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSArray<id> *_Nonnull configurations) CORESTORE_RETURNS_RETAINED;


#pragma mark CSGroupBy

@class CSGroupBy;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSGroupBy *_Nonnull CSGroupByKeyPath(NSString *_Nonnull keyPath) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSString *_Nonnull keyPath, ...) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSArray<NSString *> *_Nonnull keyPaths) CORESTORE_RETURNS_RETAINED;


#pragma mark CSInto

@class CSInto;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass, NSNull *_Nonnull configuration) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass, NSString *_Nonnull configuration) CORESTORE_RETURNS_RETAINED;


#pragma mark CSOrderBy

@class CSOrderBy;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
NSSortDescriptor *_Nonnull CSSortAscending(NSString *_Nonnull key) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
NSSortDescriptor *_Nonnull CSSortDescending(NSString *_Nonnull key)  CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSOrderBy *_Nonnull CSOrderByKey(NSSortDescriptor *_Nonnull sortDescriptor) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderByKeys(NSSortDescriptor *_Nonnull sortDescriptor, ...) CORESTORE_RETURNS_RETAINED CORESTORE_REQUIRES_NIL_TERMINATION;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderByKeys(NSArray<NSSortDescriptor *> *_Nonnull sortDescriptors) CORESTORE_RETURNS_RETAINED;


#pragma mark CSSelect

@class CSSelect;
@class CSSelectTerm;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectNumber(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectDecimal(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectString(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectDate(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectData(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSSelect *_Nonnull CSSelectObjectID(void) CORESTORE_RETURNS_RETAINED;


#pragma mark CSTweak

@class CSTweak;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN CORESTORE_OVERLOADABLE
CSTweak *_Nonnull CSTweakRequest(void (^_Nonnull block)(NSFetchRequest *_Nonnull fetchRequest)) CORESTORE_RETURNS_RETAINED;


#pragma mark CSWhere

@class CSWhere;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSWhere *_Nonnull CSWhereValue(BOOL value) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSWhere *_Nonnull CSWhereFormat(NSString *_Nonnull format, ...) CORESTORE_RETURNS_RETAINED;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_EXTERN
CSWhere *_Nonnull CSWherePredicate(NSPredicate *_Nonnull predicate) CORESTORE_RETURNS_RETAINED;


#endif /* CoreStoreBridge_h */
