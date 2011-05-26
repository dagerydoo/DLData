//
//  DLUndoRedoTests.m
//  DLData
//
//  Created by Andrew Hannon on 11/29/10.
//  Copyright (C) 2011 by Andrew Hannon
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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