//
//  DLUniqueIDGenerator.m
//  DLData
//
//  Created by Andrew Hannon on 9/14/10.
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
