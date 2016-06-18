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

- (void)test_ThatFromClauses_BridgeCorrectly {
    
    {
        CSFrom *from = From([TestEntity1 class]);
        XCTAssertEqualObjects(from.entityClass, [TestEntity1 class]);
        XCTAssertNil(from.configurations);
    }
    {
        CSFrom *from = From([TestEntity1 class], @[[NSNull null], @"Config2"]);
        XCTAssertEqualObjects(from.entityClass, [TestEntity1 class]);
        
        NSArray *configurations = @[[NSNull null], @"Config2"];
        XCTAssertEqualObjects(from.configurations, configurations);
    }
}

- (void)test_ThatWhereClauses_BridgeCorrectly {
    
    {
        CSWhere *where = Where(@"%K == %@", @"key", @"value");
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"key", @"value"];
        XCTAssertEqualObjects(where.predicate, predicate);
    }
    {
        CSWhere *where = Where(YES);
        NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
        XCTAssertEqualObjects(where.predicate, predicate);
    }
    {
        CSWhere *where = Where([NSPredicate predicateWithFormat:@"%K == %@", @"key", @"value"]);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"key", @"value"];
        XCTAssertEqualObjects(where.predicate, predicate);
    }
}

- (void)test_ThatGroupByClauses_BridgeCorrectly {
    
    CSGroupBy *groupBy = GroupBy(@[@"key"]);
    XCTAssertEqualObjects(groupBy.keyPaths, @[@"key"]);
}

- (void)test_ThatDataStacks_BridgeCorrectly {
    
    CSDataStack *dataStack = [[CSDataStack alloc]
                              initWithModelName:@"Model"
                              bundle:[NSBundle bundleForClass:[self class]]
                              versionChain:nil];
    XCTAssertNotNil(dataStack);
    
    [CSCoreStore setDefaultStack:dataStack];
    XCTAssertTrue([dataStack isEqual:[CSCoreStore defaultStack]]);
    
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

@end
