//
//  BridgingTests.m
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

#import "BridgingTests.h"
#import <CoreStore/CoreStore.h>
#import <CoreStore/CoreStore-Swift.h>
#import "CoreStoreTests-Swift.h"

@import CoreData;

// MARK: - BridgingTests

@implementation BridgingTests

- (void)test_ThatFlags_HaveCorrectValues {
    
    XCTAssertEqual(CSLocalStorageOptionsNone, 0);
    XCTAssertEqual(CSLocalStorageOptionsRecreateStoreOnModelMismatch, 1);
    XCTAssertEqual(CSLocalStorageOptionsPreventProgressiveMigration, 2);
    XCTAssertEqual(CSLocalStorageOptionsAllowSynchronousLightweightMigration, 4);
}

- (void)test_ThatKeyPaths_AreCorrect {
    
    XCTAssertEqualObjects(CSKeyPath(TestEntity1, testNumber), @"testNumber");
    XCTAssertEqualObjects(CSKeyPath(TestEntity1, testString), @"testString");
    XCTAssertEqualObjects(CSKeyPathOperator(count, TestEntity1, testString), @"@count.testString");
    XCTAssertEqualObjects(CSKeyPathOperator(max, TestEntity1, testNumber), @"@max.testNumber");
}

- (void)test_ThatFromClauses_BridgeCorrectly {
    
    {
        CSFrom *from = CSFromClass([TestEntity1 class]);
        XCTAssertEqualObjects(from.entityClass, [TestEntity1 class]);
        XCTAssertNil(from.configurations);
    }
    {
        CSFrom *from = CSFromClass([TestEntity1 class], [NSNull null]);
        XCTAssertEqualObjects(from.entityClass, [TestEntity1 class]);
        
        NSArray *configurations = @[[NSNull null]];
        XCTAssertEqualObjects(from.configurations, configurations);
    }
    {
        CSFrom *from = CSFromClass([TestEntity1 class], @"Config1");
        XCTAssertEqualObjects(from.entityClass, [TestEntity1 class]);
        
        NSArray *configurations = @[@"Config1"];
        XCTAssertEqualObjects(from.configurations, configurations);
    }
    {
        CSFrom *from = CSFromClass([TestEntity1 class], @[[NSNull null], @"Config2"]);
        XCTAssertEqualObjects(from.entityClass, [TestEntity1 class]);
        
        NSArray *configurations = @[[NSNull null], @"Config2"];
        XCTAssertEqualObjects(from.configurations, configurations);
    }
}

- (void)test_ThatWhereClauses_BridgeCorrectly {
    
    {
        CSWhere *where = CSWhereFormat(@"%K == %@", @"key", @"value");
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"key", @"value"];
        XCTAssertEqualObjects(where.predicate, predicate);
    }
    {
        CSWhere *where = CSWhereValue(YES);
        NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
        XCTAssertEqualObjects(where.predicate, predicate);
    }
    {
        CSWhere *where = CSWherePredicate([NSPredicate predicateWithFormat:@"%K == %@", @"key", @"value"]);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"key", @"value"];
        XCTAssertEqualObjects(where.predicate, predicate);
    }
}

- (void)test_ThatOrderByClauses_BridgeCorrectly {
    
    {
        CSOrderBy *orderBy = CSOrderByKey(CSSortAscending(@"key"));
        XCTAssertEqualObjects(orderBy.sortDescriptors, @[[NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES]]);
    }
    {
        CSOrderBy *orderBy = CSOrderByKey(CSSortDescending(@"key"));
        XCTAssertEqualObjects(orderBy.sortDescriptors, @[[NSSortDescriptor sortDescriptorWithKey:@"key" ascending:NO]]);
    }
    {
        CSOrderBy *orderBy = CSOrderByKeys(CSSortAscending(@"key1"), CSSortDescending(@"key2"), nil);
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"key1" ascending:YES],
                                     [NSSortDescriptor sortDescriptorWithKey:@"key2" ascending:NO]];
        XCTAssertEqualObjects(orderBy.sortDescriptors, sortDescriptors);
    }
}

- (void)test_ThatGroupByClauses_BridgeCorrectly {
    
    {
        CSGroupBy *groupBy = CSGroupByKeyPath(@"key");
        XCTAssertEqualObjects(groupBy.keyPaths, @[@"key"]);
    }
    {
        CSGroupBy *groupBy = CSGroupByKeyPaths(@[@"key1", @"key2"]);
        
        NSArray *keyPaths = @[@"key1", @"key2"];
        XCTAssertEqualObjects(groupBy.keyPaths, keyPaths);
    }
}

- (void)test_ThatTweakClauses_BridgeCorrectly {
    
    CSTweak *tweak = CSTweakRequest(^(NSFetchRequest * _Nonnull fetchRequest) {
        
        fetchRequest.fetchLimit = 100;
    });
    NSFetchRequest *request = [NSFetchRequest new];
    tweak.block(request);
    XCTAssertEqual(request.fetchLimit, 100);
}

- (void)test_ThatIntoClauses_BridgeCorrectly {
    
    {
        CSInto *into = CSIntoClass([TestEntity1 class]);
        XCTAssertEqualObjects(into.entityClass, [TestEntity1 class]);
    }
    {
        CSInto *into = CSIntoClass([TestEntity1 class], [NSNull null]);
        XCTAssertEqualObjects(into.entityClass, [TestEntity1 class]);
        XCTAssertNil(into.configuration);
    }
    {
        CSInto *into = CSIntoClass([TestEntity1 class], @"Config1");
        XCTAssertEqualObjects(into.entityClass, [TestEntity1 class]);
        XCTAssertEqualObjects(into.configuration, @"Config1");
    }
}

- (void)test_ThatDataStacks_BridgeCorrectly {
    
    CSDataStack *dataStack = [[CSDataStack alloc]
                              initWithModelName:@"Model"
                              bundle:[NSBundle bundleForClass:[self class]]
                              versionChain:nil];
    XCTAssertNotNil(dataStack);
    
    [CSCoreStore setDefaultStack:dataStack];
    XCTAssertTrue([dataStack isEqual:[CSCoreStore defaultStack]]);
}

- (void)test_ThatStorages_BridgeCorrectly {
    
    NSError *memoryError;
    CSInMemoryStore *memoryStorage = [CSCoreStore
                                      addInMemoryStorageAndWait:[CSInMemoryStore new]
                                      error:&memoryError];
    XCTAssertNotNil(memoryStorage);
    XCTAssertEqualObjects([[memoryStorage class] storeType], [CSInMemoryStore storeType]);
    XCTAssertEqualObjects([[memoryStorage class] storeType], NSInMemoryStoreType);
    XCTAssertNil(memoryStorage.configuration);
    XCTAssertNil(memoryStorage.storeOptions);
    XCTAssertNil(memoryError);
    
    NSError *sqliteError;
    CSSQLiteStore *sqliteStorage = [CSCoreStore
                                    addSQLiteStorageAndWait:[CSSQLiteStore new]
                                    error:&sqliteError];
    XCTAssertNotNil(sqliteStorage);
    XCTAssertEqualObjects([[sqliteStorage class] storeType], [CSSQLiteStore storeType]);
    XCTAssertEqualObjects([[sqliteStorage class] storeType], NSSQLiteStoreType);
    XCTAssertNil(sqliteStorage.configuration);
    XCTAssertEqualObjects(sqliteStorage.storeOptions, @{ NSSQLitePragmasOption: @{ @"journal_mode": @"WAL" } });
    XCTAssertNil(sqliteError);
}

- (void)test_ThatTransactions_BridgeCorrectly {
    
    [CSCoreStore
     setDefaultStack:[[CSDataStack alloc]
                      initWithModelName:@"Model"
                      bundle:[NSBundle bundleForClass:[self class]]
                      versionChain:nil]];
    [CSCoreStore
     addInMemoryStorageAndWait:[CSInMemoryStore new]
     error:nil];
    
    {
        CSUnsafeDataTransaction *transaction = [CSCoreStore beginUnsafe];
        XCTAssertNotNil(transaction);
        XCTAssert([transaction isKindOfClass:[CSUnsafeDataTransaction class]]);
    }
    {
        XCTestExpectation *expectation = [self expectationWithDescription:@"sync"];
        [CSCoreStore beginSynchronous:^(CSSynchronousDataTransaction * _Nonnull transaction) {
            
            XCTAssertNotNil(transaction);
            XCTAssert([transaction isKindOfClass:[CSSynchronousDataTransaction class]]);
            [expectation fulfill];
        }];
    }
    {
        XCTestExpectation *expectation = [self expectationWithDescription:@"async"];
        [CSCoreStore beginAsynchronous:^(CSAsynchronousDataTransaction * _Nonnull transaction) {
            
            XCTAssertNotNil(transaction);
            XCTAssert([transaction isKindOfClass:[CSAsynchronousDataTransaction class]]);
            [expectation fulfill];
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:nil];
}
    
#if TARGET_OS_IOS || TARGET_OS_WATCHOS || TARGET_OS_TV

- (void)test_ThatDataStacks_CanCreateCustomFetchedResultsControllers {
    
    [CSCoreStore
     setDefaultStack:[[CSDataStack alloc]
                      initWithModelName:@"Model"
                      bundle:[NSBundle bundleForClass:[self class]]
                      versionChain:nil]];
    [CSCoreStore
     addInMemoryStorageAndWait:[CSInMemoryStore new]
     error:nil];
    NSFetchedResultsController *controller =
    [[CSCoreStore defaultStack]
     createFetchedResultsControllerFrom:CSFromClass([TestEntity1 class])
     sectionBy:[CSSectionBy keyPath:CSKeyPath(TestEntity1, testString)]
     fetchClauses:@[CSWhereFormat(@"%K > %d", CSKeyPath(TestEntity1, testEntityID), 100),
                    CSOrderByKeys(CSSortAscending(CSKeyPath(TestEntity1, testString)), nil),
                    CSTweakRequest(^(NSFetchRequest *fetchRequest) { fetchRequest.fetchLimit = 10; })]];
    
    XCTAssertNotNil(controller);
    XCTAssertEqualObjects(controller.fetchRequest.entity.managedObjectClassName, [[TestEntity1 class] description]);
    XCTAssertEqualObjects(controller.sectionNameKeyPath, CSKeyPath(TestEntity1, testString));
    XCTAssertEqualObjects(controller.fetchRequest.predicate,
                          CSWhereFormat(@"%K > %d", CSKeyPath(TestEntity1, testEntityID), 100).predicate);
    XCTAssertEqualObjects(controller.fetchRequest.sortDescriptors,
                   CSOrderByKeys(CSSortAscending(CSKeyPath(TestEntity1, testString)), nil).sortDescriptors);
    XCTAssertEqual(controller.fetchRequest.fetchLimit, 10);
}
    
#endif

@end
