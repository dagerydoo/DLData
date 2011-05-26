//
//  DLUniqueIDGenerator.m
//  DataStore
//
//  Created by Andrew Hannon on 9/14/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import "DLDataStore.h"
#import "DLUniqueID.h"
#import "DLUniqueIDGenerator.h"


@implementation DLUniqueIDGenerator

+ (unsigned long)generateUniqueID {
  DLDataStore *coreStore = [DLDataStore coreDataStore]; 
  NSManagedObjectContext *moc = [coreStore managedObjectContext];

  NSEntityDescription *desc = [NSEntityDescription entityForName:@"DLUniqueID" inManagedObjectContext:moc];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:desc];
  [request setFetchLimit:2];

  unsigned long uID = 0;
  @synchronized([DLUniqueIDGenerator class]) {
    NSError *error=nil;
    NSArray *result = [moc executeFetchRequest:request error:&error];
    [request release];
    if (error) {
      NSLog(@"Unique ID fetch failure with error: %@", error);
      @throw [NSException exceptionWithName:@"UniqueIDRetrievalFailure" 
                                     reason:@"Error fetching the unique ID" 
                                   userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
    }

    if ([result count] > 1) {
      @throw [NSException exceptionWithName:@"DegenerateUniqueID"
                                     reason:@"More than one unique ID generator exists!"
                                   userInfo:nil];
    } 
    
    DLUniqueID *uniqueID = nil;
    if ([result count]) {
      uniqueID = [result objectAtIndex:0];
      uniqueID.currentID = [NSNumber numberWithUnsignedLong:[uniqueID.currentID unsignedLongValue] + 1];
    } else {
      // Should only ever get called once:
      uniqueID = [[DLUniqueID alloc] initWithEntity:desc insertIntoManagedObjectContext:moc];
      uniqueID.currentID = [NSNumber numberWithUnsignedLong:1];
      [uniqueID autorelease];
    }
    uID = [uniqueID.currentID unsignedLongValue];
  }
  return uID;
}

+ (NSNumber*)generateUniqueNumber {
  return [NSNumber numberWithUnsignedLong:[DLUniqueIDGenerator generateUniqueID]];
}

@end
