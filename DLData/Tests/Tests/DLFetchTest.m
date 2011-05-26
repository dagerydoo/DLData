//
//  DLFetchTests.m
//  DataStoreLib
//
//  Created by Andrew Hannon on 12/21/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <GHUnitIOS/GHUnitIOS.h>
#import <DLData/DLData.h>
#import "Employee.h"
#import "Company.h"
#import "CorporateStore.h"


@interface DLFetchTests : GHTestCase {
  CorporateStore *corporateStore;
}

@end

@implementation DLFetchTests

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

- (void)testFetchOne {
  Company *company = [corporateStore fetchOne:@"Company" matching:nil sortedBy:nil];
  GHAssertNotNil(company, @"Company is nil");
  GHAssertTrue([company.companyName isEqualToString:@"Foo Inc."] ||
               [company.companyName isEqualToString:@"Diabolical Labs, LLC"],
               @"Unexpected company name!");
}

- (void)testFetchSansPredicateAndSort {
  NSArray *employees = [corporateStore fetchAll:@"Employee" matching:nil sortedBy:nil];
  NSUInteger expectedEmployees=6;
  GHAssertEquals([employees count], expectedEmployees, @"Unexpected number of employees");
}

- (void)testFetchWithPredicateSansSort {
  NSString *filteredCompany = @"Foo Inc.";
  NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"company.companyName == %@",
                                  filteredCompany];
  NSArray *employees = [corporateStore fetchAll:@"Employee" 
                                       matching:filterPredicate sortedBy:nil];
  NSUInteger expectedEmployees=5;
  GHAssertEquals([employees count], expectedEmployees, @"Unexpected number of employees");
  for (Employee *employee in employees) {
    GHAssertEqualStrings(employee.company.companyName, filteredCompany, @"Company name incorrect");
  }
}

- (void)testFetchWithPredicateAndSort {
  NSString *filteredCompany = @"Foo Inc.";
  NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"company.companyName == %@",
                                  filteredCompany];
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"employeeName" ascending:NO];
  NSArray *employees = [corporateStore fetchAll:@"Employee" 
                                       matching:filterPredicate
                                       sortedBy:[NSArray arrayWithObject:sortDescriptor]];
  NSUInteger expectedEmployees=5;
  GHAssertEquals([employees count], expectedEmployees, @"Unexpected number of employees");
  NSString *lastEmployeeName=nil;
  for (Employee *employee in employees) {
    GHAssertEqualStrings(employee.company.companyName, filteredCompany, @"Company name incorrect");
    if (lastEmployeeName) {
      GHAssertTrue([lastEmployeeName compare:employee.employeeName] == NSOrderedDescending,
                   @"Sort order not honored");
    }
    lastEmployeeName = employee.employeeName;
  }
}

- (void)testUnqualifiedFetchCount {
  NSUInteger employeeCount = [corporateStore fetchCount:@"Employee" matching:nil];
  NSUInteger expectedEmployees=6;
  GHAssertEquals(employeeCount, expectedEmployees, @"Unexpected number of employees");    
}

- (void)testQualifiedFetchCount {
  NSString *filteredCompany = @"Foo Inc.";
  NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"company.companyName == %@",
                                  filteredCompany];
  NSUInteger employeeCount = [corporateStore fetchCount:@"Employee" matching:filterPredicate];
  NSUInteger expectedEmployees=5;
  GHAssertEquals(employeeCount, expectedEmployees, @"Unexpected number of employees");  
}

- (void)testFetchTemplates {
  NSFetchRequest *request = [corporateStore fetchRequestNamed:@"wellPaidEmployees"];
  NSError *error=nil;
  NSArray *employees = [corporateStore executeFetchRequest:request error:&error];
  GHAssertNil(error, @"Error executing template request: %@", error);
  NSUInteger expectedEmployeeCount = 2;
  GHAssertEquals([employees count], expectedEmployeeCount, 
                 @"Unexpected number of well paid employees!");
  
  request = [corporateStore fetchRequestNamed:@"ridiculouslySalariedEmployees"];
  employees = [corporateStore executeFetchRequest:request error:&error];
  GHAssertNil(error, @"Error executing template request: %@", error);
  expectedEmployeeCount = 1;
  GHAssertEquals([employees count], expectedEmployeeCount,
                 @"Unexpected number of ridiculously salaried employees!");
}

- (void)testFetchTemplateCounts {
  NSUInteger expectedEmployeeCount = 2;
  GHAssertEquals([corporateStore countForRequestNamed:@"wellPaidEmployees"], 
                 expectedEmployeeCount,
                 @"Unexpected number of well paid employees!");

  expectedEmployeeCount = 1;
  GHAssertEquals([corporateStore countForRequestNamed:@"ridiculouslySalariedEmployees"],
                 expectedEmployeeCount,
                 @"Unexpected number of ridiculously salaried employees!");
}

- (void)testFetchByName {
  NSError *error=nil;
  NSArray *employees = [corporateStore executeFetchRequestNamed:@"wellPaidEmployees" error:&error];
  GHAssertNil(error, @"Error executing template request: %@", error);
  NSUInteger expectedEmployeeCount = 2;
  GHAssertEquals([employees count], expectedEmployeeCount, 
                 @"Unexpected number of well paid employees!");
}

- (void)testFetchWithSubstituteByName {
  NSError *error=nil;
  NSString *companyName = @"Foo Inc.";
  NSPredicate *p = [NSPredicate predicateWithFormat:@"companyName == %@", companyName];
  Company *company = [corporateStore fetchOne:@"Company" matching:p sortedBy:nil];
  NSDictionary *subs = [NSDictionary dictionaryWithObject:company
                                                   forKey:@"company"];
  NSArray *employees = [corporateStore executeFetchRequestNamed:@"companyWellPaidEmployees" 
                                          substitutionVariables:subs 
                                                          error:&error];
  GHAssertNil(error, @"Error executing template request: %@", error);
  NSUInteger expectedEmployeeCount = 1;
  GHAssertEquals([employees count], expectedEmployeeCount, 
                 @"Unexpected number of well paid employees!");  
}

@end
