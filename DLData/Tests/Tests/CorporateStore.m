//
//  CorporateStore.m
//  DLData
//
//  Created by Andrew Hannon on 11/15/10.
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

#import "Employee.h"
#import "Company.h"
#import "CorporateStore.h"

@implementation CorporateStore

- (id)initWithModelName:(NSString*)modelName {
  [DLDataStore purgeStoreNamed:modelName];
  return [super initWithDataStoreModelName:modelName];  
}

- (id)init {
  return [self initWithModelName:@"CorporateMayhem"];
}

- (Company*)addCompanyNamed:(NSString*)companyName {
  Company *company = [self entityWithName:@"Company"];
  company.companyName = companyName;
  return company; 
}

- (Company*)companyNamed:(NSString*)companyName {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyName == %@", companyName];
  return [self fetchOne:@"Company" matching:predicate sortedBy:nil];
}

- (NSArray*)allCompanies {
  return [self fetchAll:@"Company" matching:nil sortedBy:nil];
}

- (NSArray*)allEmployees {
  return [self fetchAll:@"Employee" matching:nil sortedBy:nil];
}

- (NSArray*)allEmployeesForCompanyNamed:(NSString*)companyName {
  return [self executeFetchRequestNamed:@"allEmployeesByCompanyName"
                  substitutionVariables:[NSDictionary dictionaryWithObject:companyName 
                                                                    forKey:@"companyName"]
                                  error:nil];
}

- (Employee*)employeeNamed:(NSString*)employeeName 
                forCompany:(Company*)company {
  NSDictionary *subs = [NSDictionary dictionaryWithObjectsAndKeys:
                        employeeName, @"employeeName", company, @"company", nil];
  return [self executeFetchOneRequestNamed:@"companyEmployeeByName" substitutionVariables:subs error:nil];
}

@end
