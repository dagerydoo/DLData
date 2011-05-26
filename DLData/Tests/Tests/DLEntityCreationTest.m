//
//  DLEntityCreationTest.m
//  DLData
//
//  Created by Andrew Hannon on 3/25/11.
//  Copyright 2011 Diabolical Labs, LLC. All rights reserved.
//

#import <GHUnitIOS/GHUnitIOS.h>
#import <DLData/DLData.h>
#import "Employee.h"
#import "Company.h"
#import "CorporateStore.h"

@interface DLEntityCreationTest : GHTestCase {
  CorporateStore *corporateStore;
}
@end

@implementation DLEntityCreationTest

- (void)setUp {
  [corporateStore release];
  corporateStore = [[CorporateStore alloc] init];
}

- (void)tearDown {
  [corporateStore rollback];
  [corporateStore release];
  corporateStore = nil;
}

- (void)testEntityCreation {
  Employee *employee = [corporateStore entityWithName:@"Employee"];
  GHAssertNotNil(employee, @"Employee is nil!");
}

@end
