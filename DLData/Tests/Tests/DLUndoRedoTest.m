//
//  DLUndoRedoTests.m
//  DataStoreLib
//
//  Created by Andrew Hannon on 11/29/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <GHUnitIOS/GHUnitIOS.h>
#import <DLData/DLData.h>
#import "Company.h"
#import "Employee.h"
#import "CorporateStore.h"

@interface DLUndoRedoTests : GHTestCase<DLDataManagerDelegate> {
  CorporateStore *corporateStore;
}
@end

@implementation DLUndoRedoTests

- (void)setUp {
  [corporateStore release];
  corporateStore = [[CorporateStore alloc] init];
  corporateStore.dataDelegate = self;
  // Seed the data store to ensure that we have something to test against other than "empty"
  NSURL *seedURL = [[NSBundle mainBundle] URLForResource:@"Main.seed" withExtension:@"json"];
  [corporateStore seedDataStore:seedURL];
}

- (void)tearDown {
  [corporateStore rollback];
  [corporateStore release];
  corporateStore = nil;
}

- (void)testBasicGroupUndoRedo {
  NSUInteger expectedCompanyCount = 2;
  __block BOOL undoGroupOpened=NO;
  GHAssertEquals([[corporateStore allCompanies] count], expectedCompanyCount,
                 @"Unexpected initial company count!");
  id bObs = [[NSNotificationCenter defaultCenter] addObserverForName:NSUndoManagerDidOpenUndoGroupNotification
                                                              object:nil queue:nil
                                                          usingBlock:^(NSNotification *n) {
                                                            undoGroupOpened = YES;
                                                          }];
  [corporateStore beginUndoGroup];
  GHAssertTrue(undoGroupOpened, @"Undo group not opened!");
  [corporateStore addCompanyNamed:@"The Monolith, Ltd"];
  [corporateStore endUndoGroup];
  GHAssertEquals([[corporateStore allCompanies] count], expectedCompanyCount+1,
                 @"Unexpected grouped company count!");
  [corporateStore undoGroup];
  GHAssertEquals([[corporateStore allCompanies] count], expectedCompanyCount,
                 @"Unexpected undo company count!");  
  [corporateStore redoGroup];
  GHAssertEquals([[corporateStore allCompanies] count], expectedCompanyCount+1,
                 @"Unexpected redo company count!");
  [[NSNotificationCenter defaultCenter] removeObserver:bObs];
}

////////////////////////////////////////
// DLDataManagerDelegate
////////////////////////////////////////

- (BOOL)dataManagerSupportsUndo:(DLDataManager *)dataManager {
  return YES;
}

@end