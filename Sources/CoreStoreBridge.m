//
//  CoreStoreBridge.m
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


#import "CoreStoreBridge.h"

#import <CoreStore/CoreStore-Swift.h>


#pragma mark - Clauses

#pragma mark CSFrom

CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass) CORESTORE_RETURNS_RETAINED {
    
    return [[CSFrom alloc] initWithEntityClass:entityClass];
}

CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSNull *_Nonnull configuration) CORESTORE_RETURNS_RETAINED {
    
    return [[CSFrom alloc] initWithEntityClass:entityClass configuration:configuration];
}

CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSString *_Nonnull configuration) CORESTORE_RETURNS_RETAINED {
    
    return [[CSFrom alloc] initWithEntityClass:entityClass configuration:configuration];
}

CORESTORE_OVERLOADABLE
CSFrom *_Nonnull CSFromClass(Class _Nonnull entityClass, NSArray<id> *_Nonnull configurations) CORESTORE_RETURNS_RETAINED {
    
    return [[CSFrom alloc] initWithEntityClass:entityClass configurations:configurations];
}


#pragma mark CSGroupBy

CSGroupBy *_Nonnull CSGroupByKeyPath(NSString *_Nonnull keyPath) CORESTORE_RETURNS_RETAINED {
    
    return [[CSGroupBy alloc] initWithKeyPath:keyPath];
}

CORESTORE_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSString *_Nonnull keyPath, ...) CORESTORE_RETURNS_RETAINED {
    
    va_list args;
    va_start(args, keyPath);
    
    NSMutableArray *keyPaths = [NSMutableArray new];
    [keyPaths addObject:keyPath];
    
    NSString *next;
    while ((next = va_arg(args, NSString *)) != nil) {
        
        [keyPaths addObject:next];
    }
    va_end(args);
    return [[CSGroupBy alloc] initWithKeyPaths:keyPaths];
}

CORESTORE_OVERLOADABLE
CSGroupBy *_Nonnull CSGroupByKeyPaths(NSArray<NSString *> *_Nonnull keyPaths) CORESTORE_RETURNS_RETAINED {
    
    return [[CSGroupBy alloc] initWithKeyPaths:keyPaths];
}


#pragma mark CSInto

CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass) CORESTORE_RETURNS_RETAINED {
    
    return [[CSInto alloc] initWithEntityClass:entityClass];
}

CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass, NSNull *_Nonnull configuration) CORESTORE_RETURNS_RETAINED {
    
    return [[CSInto alloc] initWithEntityClass:entityClass configuration:nil];
}

CORESTORE_OVERLOADABLE
CSInto *_Nonnull CSIntoClass(Class _Nonnull entityClass, NSString *_Nonnull configuration) CORESTORE_RETURNS_RETAINED {
    
    return [[CSInto alloc] initWithEntityClass:entityClass configuration:configuration];
}


#pragma mark CSOrderBy

@class CSOrderBy;

NSSortDescriptor *_Nonnull CSSortAscending(NSString *_Nonnull key) {
    
    return [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
}

NSSortDescriptor *_Nonnull CSSortDescending(NSString *_Nonnull key) {
    
    return [[NSSortDescriptor alloc] initWithKey:key ascending:NO];
}

CSOrderBy *_Nonnull CSOrderByKey(NSSortDescriptor *_Nonnull sortDescriptor) CORESTORE_RETURNS_RETAINED {
    
    return [[CSOrderBy alloc] initWithSortDescriptor:sortDescriptor];
}

CORESTORE_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderByKeys(NSSortDescriptor *_Nonnull sortDescriptor, ...) CORESTORE_RETURNS_RETAINED {
    
    va_list args;
    va_start(args, sortDescriptor);
    
    NSMutableArray *sortDescriptors = [NSMutableArray new];
    [sortDescriptors addObject:sortDescriptor];
    
    NSSortDescriptor *next;
    while ((next = va_arg(args, NSSortDescriptor *)) != nil) {
        
        [sortDescriptors addObject:next];
    }
    va_end(args);
    return [[CSOrderBy alloc] initWithSortDescriptors:sortDescriptors];
}

CORESTORE_OVERLOADABLE
CSOrderBy *_Nonnull CSOrderByKeys(NSArray<NSSortDescriptor *> *_Nonnull sortDescriptors) CORESTORE_RETURNS_RETAINED {
    
    return [[CSOrderBy alloc] initWithSortDescriptors:sortDescriptors];
}


#pragma mark CSSelect

CSSelect *_Nonnull CSSelectNumber(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {
    
    return [[CSSelect alloc] initWithNumberTerm:selectTerm];
}

CSSelect *_Nonnull CSSelectDecimal(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {
    
    return [[CSSelect alloc] initWithDecimalTerm:selectTerm];
}

CSSelect *_Nonnull CSSelectString(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {
    
    return [[CSSelect alloc] initWithStringTerm:selectTerm];
}

CSSelect *_Nonnull CSSelectDate(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {
    
    return [[CSSelect alloc] initWithDateTerm:selectTerm];
}

CSSelect *_Nonnull CSSelectData(CSSelectTerm *_Nonnull selectTerm) CORESTORE_RETURNS_RETAINED {
    
    return [[CSSelect alloc] initWithDataTerm:selectTerm];
}

CSSelect *_Nonnull CSSelectObjectID() CORESTORE_RETURNS_RETAINED {
    
    return [[CSSelect alloc] initWithObjectIDTerm];
}


#pragma mark CSTweak

CORESTORE_OVERLOADABLE
CSTweak *_Nonnull CSTweakRequest(void (^_Nonnull block)(NSFetchRequest *_Nonnull fetchRequest)) CORESTORE_RETURNS_RETAINED {
    
    return [[CSTweak alloc] initWithBlock:block];
}


#pragma mark CSWhere

CSWhere *_Nonnull CSWhereValue(BOOL value) CORESTORE_RETURNS_RETAINED {
    
    return [[CSWhere alloc] initWithValue:value];
}

CSWhere *_Nonnull CSWhereFormat(NSString *_Nonnull format, ...) CORESTORE_RETURNS_RETAINED {
    
    CSWhere *where;
    va_list args;
    va_start(args, format);
    where = [[CSWhere alloc] initWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
    va_end(args);
    return where;
}

CSWhere *_Nonnull CSWherePredicate(NSPredicate *_Nonnull predicate) CORESTORE_RETURNS_RETAINED {
    
    return [[CSWhere alloc] initWithPredicate:predicate];
}


#pragma mark CoreStoreFetchRequest

@interface _CSFetchRequest ()

@property (nullable, nonatomic, copy) NSArray<NSPersistentStore *> *safeAffectedStores;
@property (nullable, nonatomic, assign) CFArrayRef releaseArray;

@end

@implementation _CSFetchRequest

// MARK: NSFetchRequest

- (void)setAffectedStores:(NSArray<NSPersistentStore *> *_Nullable)affectedStores {
    
    // Bugfix for NSFetchRequest messing up memory management for `affectedStores`
    // http://stackoverflow.com/questions/14396375/nsfetchedresultscontroller-crashes-in-ios-6-if-affectedstores-is-specified
    
    if (NSFoundationVersionNumber < NSFoundationVersionNumber10_0) {
        
        self.safeAffectedStores = affectedStores;
        [super setAffectedStores:affectedStores];
        return;
    }
    if (self.releaseArray != NULL) {
        
        CFRelease(self.releaseArray);
        self.releaseArray = NULL;
    }
    self.safeAffectedStores = affectedStores;
    [super setAffectedStores:affectedStores];
    self.releaseArray = CFBridgingRetain([super affectedStores]);
}

@end
