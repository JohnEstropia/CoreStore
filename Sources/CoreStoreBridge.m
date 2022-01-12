//
//  CoreStoreBridge.m
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


#import "CoreStoreBridge.h"

#import <CoreStore/CoreStore-Swift.h>


#pragma mark - Clauses

#pragma mark CSFrom

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSNull *_Nonnull configuration) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSString *_Nonnull configuration) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSArray<id> *_Nonnull configurations) CORESTORE_RETURNS_RETAINED {

    abort();
}


#pragma mark CSGroupBy

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSGroupBy *_Nonnull CSGroupByKeyPath(NSString *_Nonnull keyPath) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSString *_Nonnull keyPath, ...) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSArray<NSString *> *_Nonnull keyPaths) CORESTORE_RETURNS_RETAINED {

    abort();
}


#pragma mark CSInto

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass, NSNull *_Nonnull configuration) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass, NSString *_Nonnull configuration) CORESTORE_RETURNS_RETAINED {

    abort();
}


#pragma mark CSOrderBy

@class CSOrderBy;

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
NSSortDescriptor *_Nonnull CSSortAscending(NSString *_Nonnull key) {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
NSSortDescriptor *_Nonnull CSSortDescending(NSString *_Nonnull key) {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSOrderBy *_Nonnull CSOrderByKey(NSSortDescriptor *_Nonnull sortDescriptor) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderByKeys(NSSortDescriptor *_Nonnull sortDescriptor, ...) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderByKeys(NSArray<NSSortDescriptor *> *_Nonnull sortDescriptors) CORESTORE_RETURNS_RETAINED {

    abort();
}


#pragma mark CSSelect

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSSelect *_Nonnull CSSelectNumber(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSSelect *_Nonnull CSSelectDecimal(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSSelect *_Nonnull CSSelectString(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSSelect *_Nonnull CSSelectDate(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSSelect *_Nonnull CSSelectData(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSSelect *_Nonnull CSSelectObjectID() CORESTORE_RETURNS_RETAINED {

    abort();
}


#pragma mark CSTweak

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CORESTORE_OVERLOADABLE
CSTweak *_Nonnull CSTweakRequest(void (^_Nonnull block)(NSFetchRequest *_Nonnull fetchRequest)) CORESTORE_RETURNS_RETAINED {

    abort();
}


#pragma mark CSWhere

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSWhere *_Nonnull CSWhereValue(BOOL value) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSWhere *_Nonnull CSWhereFormat(NSString *_Nonnull format, ...) CORESTORE_RETURNS_RETAINED {

    abort();
}

NS_UNAVAILABLE // CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.
CSWhere *_Nonnull CSWherePredicate(NSPredicate *_Nonnull predicate) CORESTORE_RETURNS_RETAINED {

    abort();
}
