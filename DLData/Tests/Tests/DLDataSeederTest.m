//
//  DLDataSeederTest.m
//  DataStoreLib
//
//  Created by Andrew Hannon on 11/15/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <GHUnitIOS/GHUnitIOS.h>
#import <DLData/DLData.h>
#import "Company.h"
#import "Employee.h"
#import "CorporateStore.h"

@interface DLDataSeederTest : GHTestCase {
  CorporateStore *corporateStore;
}
@end

@implementation DLDataSeederTest

- (void)setUp {
  [corporateStore release];
  corporateStore = [[CorporateStore alloc] init];
}

- (void)tearDown {
  [corporateStore rollback];
  [corporateStore release];
  corporateStore = nil;
}

- (void)testDataSeeding {
  NSURL *seedURL = [[NSBundle mainBundle] URLForResource:@"Main.seed" withExtension:@"json"];
  [corporateStore seedDataStore:seedURL];
  
  NSMutableSet *allIDs = [NSMutableSet set];

  NSArray *employees = [corporateStore allEmployees];
  NSArray *companies = [corporateStore allCompanies];
  NSMutableDictionary *employeesByCompany = [NSMutableDictionary dictionary];
  for (Company *company in companies) {
    [allIDs addObject:company.companyID];
    [employeesByCompany setObject:[corporateStore allEmployeesForCompanyNamed:company.companyName]
                           forKey:company.companyName];
  }
  for (Employee *employee in employees) {
    [allIDs addObject:employee.employeeID];
  }
  NSUInteger expectedCompanyCount = 2;
  NSUInteger expectedEmployeeCount = 6;
  NSUInteger expectedDiabolicalEmployeedCount = 1;
  
  // Verify the seeding
  GHAssertEquals([employees count], expectedEmployeeCount, @"Unexpected number of employees!");
  GHAssertEquals([companies count], expectedCompanyCount, @"Unexpected number of companies!");
  GHAssertEquals([employeesByCompany count], expectedCompanyCount, @"Unexpected number of companies!");
  GHAssertEquals([[employeesByCompany objectForKey:@"Diabolical Labs, LLC"] count],
                 expectedDiabolicalEmployeedCount,
                 @"Unexpected number of Diabolical employees");
  GHAssertEquals([[employeesByCompany objectForKey:@"Foo Inc."] count],
                 expectedEmployeeCount - expectedDiabolicalEmployeedCount,
                 @"Unexpected number of Foo Inc. employees");

  for (NSString *companyName in employeesByCompany) {
    Company *company = [corporateStore companyNamed:companyName];
    GHAssertEquals([[employeesByCompany objectForKey:companyName] count],
                   [company.employees count],
                   @"Company employee count is wrong!");
    for (Employee *e in company.employees) {
      GHAssertEqualObjects(company, e.company, @"Employee company is wrong!");
    }
  }
  
  GHAssertEquals([allIDs count], expectedCompanyCount+expectedEmployeeCount,
                 @"Not all IDs are unique!");
}

@end