//
//  Company.h
//  DataStoreLib
//
//  Created by Andrew Hannon on 11/15/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Employee;

@interface Company : NSManagedObject
@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, retain) NSNumber *companyID;
@property (nonatomic, retain) NSSet *employees;
@end


@interface Company (CoreDataGeneratedAccessors)
- (void)addEmployeesObject:(Employee *)value;
- (void)removeEmployeesObject:(Employee *)value;
- (void)addEmployees:(NSSet *)value;
- (void)removeEmployees:(NSSet *)value;
@end
