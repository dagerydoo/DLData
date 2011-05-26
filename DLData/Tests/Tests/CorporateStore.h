//
//  CorporateStore.h
//  DataStoreLib
//
//  Created by Andrew Hannon on 11/15/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DLData/DLData.h>

@interface CorporateStore : DLDataManager {
}

- (id)initWithModelName:(NSString*)modelName;

- (Company*)addCompanyNamed:(NSString*)companyName;

- (Company*)companyNamed:(NSString*)companyName;

- (NSArray*)allCompanies;
- (NSArray*)allEmployees;

- (Employee*)employeeNamed:(NSString*)employeeName 
                forCompany:(Company*)company;
- (NSSet*)allEmployeesForCompanyNamed:(NSString*)companyName;

@end
