//
//  DLEntityDeletionTest.m
//  DLData
//
//  Created by Andrew Hannon on 4/19/11.
//  Copyright 2011 Diabolical Labs, LLC. All rights reserved.
//

#import <GHUnitIOS/GHUnitIOS.h>
#import <DLData/DLData.h>
#import "Employee.h"
#import "Company.h"
#import "CorporateStore.h"

@interface DLEntityDeletionTest : GHTestCase {
  CorporateStore *corporateStore;
}
@end

@implementation DLEntityDeletionTest

- (void)setUp {
  [corporateStore release];
  corporateStore = [[CorporateStore alloc] init];
  // Seed the data store to ensure that we have something to test against other than "empty"
  NSURL *seedURL = [[NSBundle mainBundle] URLForResource:@"Main.seed" withExtension:@"json"];
  [corporateStore seedDataStore:seedURL];
}

- (void)tearDown {
  [corporateStore rollback];
  [corporateStore release];
  corporateStore = nil;
}

- (void)testEntityDeletion {
  NSArray *companies = [corporateStore fetchAll:@"Company" matching:nil sortedBy:nil];
  NSUInteger expectedCompanyCount = 2;
  GHAssertEquals([companies count], expectedCompanyCount, 
                 @"Unexpected number of companies!");
  [corporateStore deleteEntity:[companies lastObject]];
  companies = [corporateStore fetchAll:@"Company" matching:nil sortedBy:nil];
  expectedCompanyCount = 1;
  GHAssertEquals([companies count], expectedCompanyCount, 
                 @"Unexpected number of companies!");
}

- (void)testCascadingDeletion {
  NSArray *allCompanies = [corporateStore fetchAll:@"Company" matching:nil sortedBy:nil];
  NSArray *allEmployees = [corporateStore fetchAll:@"Employee" matching:nil sortedBy:nil];
  NSUInteger employeeCount = [allEmployees count];
  Company *companyToDelete = [allCompanies lastObject];
  NSUInteger companyToDeleteEmployeeCount = [companyToDelete.employees count];
  [corporateStore deleteEntity:companyToDelete];
  allEmployees = [corporateStore fetchAll:@"Employee" matching:nil sortedBy:nil];
  GHAssertEquals([allEmployees count], employeeCount - companyToDeleteEmployeeCount,
                 @"Unexpected number of employees deleted!");
}

@end
