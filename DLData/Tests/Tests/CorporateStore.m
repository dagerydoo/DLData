//
//  CorporateStore.m
//  DataStoreLib
//
//  Created by Andrew Hannon on 11/15/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
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
  NSManagedObjectContext *moc = dataStore.managedObjectContext;
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:moc];
  Company *company = [[Company alloc] initWithEntity:desc insertIntoManagedObjectContext:moc];
  company.companyName = companyName;
  return company; 
}

- (Company*)companyNamed:(NSString*)companyName {
  NSManagedObjectContext *moc = dataStore.managedObjectContext;
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:moc];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyName == %@", companyName];
  
  [request setEntity:desc];
  [request setFetchLimit:1];
  [request setPredicate:predicate];
  
  NSError *error=nil;
  NSArray *result = [moc executeFetchRequest:request error:&error];
  [request release];
  if (error) {
    NSLog(@"Error fetching all companies: %@", error);
    @throw [NSException exceptionWithName:@"DLCorporateStoreException"
                                   reason:@"Unable to fetch allCompanies"
                                 userInfo:[error userInfo]];
  }
  return [result objectAtIndex:0];  
}

- (NSArray*)allCompanies {
  NSManagedObjectContext *moc = dataStore.managedObjectContext;
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:moc];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:desc];

  NSError *error=nil;
  NSArray *result = [moc executeFetchRequest:request error:&error];
  [request release];
  if (error) {
    NSLog(@"Error fetching all companies: %@", error);
    @throw [NSException exceptionWithName:@"DLCorporateStoreException"
                                   reason:@"Unable to fetch allCompanies"
                                 userInfo:[error userInfo]];
  }
  return result;
}

- (NSArray*)allEmployees {
  NSManagedObjectContext *moc = dataStore.managedObjectContext;
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:desc];
  NSError *error=nil;
  NSArray *result = [moc executeFetchRequest:request error:&error];
  [request release];
  if (error) {
    NSLog(@"Error fetching all companies: %@", error);
    @throw [NSException exceptionWithName:@"DLCorporateStoreException"
                                   reason:@"Unable to fetch allCompanies"
                                 userInfo:[error userInfo]];
  }
  return result;
}

- (NSSet*)allEmployeesForCompanyNamed:(NSString*)companyName {
  NSManagedObjectContext *moc = dataStore.managedObjectContext;
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:moc];

  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyName == %@", companyName];

  NSFetchRequest *request = [[NSFetchRequest alloc] init];  
  [request setEntity:desc];
  [request setPredicate:predicate];
  [request setFetchLimit:1];

  NSError *error=nil;
  NSArray *result = [moc executeFetchRequest:request error:&error];
  [request release];
  if (error) {
    NSLog(@"Error fetching all companies: %@", error);
    @throw [NSException exceptionWithName:@"DLCorporateStoreException"
                                   reason:@"Unable to fetch allCompanies"
                                 userInfo:[error userInfo]];
  }
  return [[result objectAtIndex:0] employees];  
}

- (Employee*)employeeNamed:(NSString*)employeeName 
                forCompany:(Company*)company {
  NSPredicate *p = [NSPredicate predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) {
    Employee *e = (Employee*)evaluatedObject;
    return [employeeName isEqualToString:e.employeeName];
  }];
  return [[company.employees filteredSetUsingPredicate:p] anyObject];
}

@end
