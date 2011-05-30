//
//  DLDataSeeder.m
//  DLData
//
//  Created by Andrew Hannon on 11/12/10.
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

#import <SBJson/SBJson.h>
#import "DLUniqueIDGenerator.h"
#import "DLDataSeeder.h"

NSURL *resourceSpecToUrl(NSString *resourceURLSpec) {
  NSString *resource = [resourceURLSpec stringByDeletingPathExtension];
  return [[NSBundle mainBundle] URLForResource:resource 
                                 withExtension:[resourceURLSpec pathExtension]];
}

typedef NSManagedObject *(^DLNewEntityBlock)(DLDataStore *dataStore,
                                             NSDictionary *properties);

NSString *const DLDataSeederException=@"DLDataSeederException";

@interface DLDataSeeder()
+ (NSDictionary*)jsonToSeedDictionary:(NSURL*)seedJSONURL;
@end

@implementation DLDataSeeder

+ (NSDictionary*)jsonToSeedDictionary:(NSURL*)seedJSONURL {
  NSError *jsonError=nil;
  NSData *jsonData = [NSData dataWithContentsOfURL:seedJSONURL
                                           options:0
                                             error:&jsonError];
  if (jsonError) {
    NSLog(@"JSON error seeding data store: %@", [jsonError description]);
    @throw [NSException exceptionWithName:DLDataSeederException
                                   reason:@"Unable to retrieve JSON"
                                 userInfo:[jsonError userInfo]];
  }
  SBJsonParser *parser = [SBJsonParser new];
  id parsedObject = [parser objectWithData:jsonData];
  [parser release];
  NSDictionary *jsonDict = (NSDictionary*)parsedObject;
  if (! jsonDict) {
    NSLog(@"Unable to parse JSON");
    @throw [NSException exceptionWithName:DLDataSeederException
                                   reason:@"Unable to parse JSON"
                                 userInfo:nil];
  }
  return jsonDict;
}

+ (NSManagedObject*)entityForStore:(DLDataStore*)store
                         withClass:(NSString*)className
                     andProperties:(NSDictionary*)properties {
  Class entityClass = NSClassFromString(className);
  NSManagedObjectContext *moc = store.managedObjectContext;
  NSEntityDescription *desc = [NSEntityDescription entityForName:className 
                                          inManagedObjectContext:moc];
  NSManagedObject *entityInstance = [[entityClass alloc] initWithEntity:desc 
                                         insertIntoManagedObjectContext:moc];
  for (NSString *property in properties) {
    id val = [properties objectForKey:property];
    if ([val isKindOfClass:[NSDictionary class]]) {
      NSMutableSet *vals = [NSMutableSet set];
      // A list of seedlings:
      for (NSDictionary *seedDict in [val objectForKey:@"seedlings"]) {
        NSString *seedURL = [seedDict objectForKey:@"seedUrl"];
        if (seedURL) {
          NSURL *resourceURL = resourceSpecToUrl(seedURL);
          [vals unionSet:[self seedDataStore:store fromSeedURL:resourceURL]];
        }
      }
      [entityInstance setValue:vals forKey:property];
    } else if ([val isKindOfClass:[NSString class]] && [val isEqualToString:@"<uniqueID>"]) {
      [entityInstance setValue:[DLUniqueIDGenerator generateUniqueNumber]
                        forKey:property];
    } else {
      [entityInstance setValue:val forKey:property];
    }
  }
  return [entityInstance autorelease];
}

+ (NSSet*)seedDataStore:(DLDataStore*)dataStore
            fromSeedURL:(NSURL*)seedURL {
  if (! seedURL) return nil;
  
  NSDictionary *jsonDict = [self jsonToSeedDictionary:seedURL];
  
  NSMutableSet *entities = [NSMutableSet set];
  // Root seeding (top-level):
  NSArray *seedlings = [jsonDict objectForKey:@"seedlings"];
  if (seedlings) {
    for (NSDictionary *seedURLDict in seedlings) {
      NSString *seedURLString = [seedURLDict objectForKey:@"seedUrl"];
      if (seedURLString) {
        NSSet *r = [self seedDataStore:dataStore 
                           fromSeedURL:resourceSpecToUrl(seedURLString)];
        [entities unionSet:r];
      }
    }
  } else {
    if ([jsonDict count] != 1) {
      NSLog(@"Malformed seed");
      @throw [NSException exceptionWithName:DLDataSeederException
                                     reason:@"Seed top level must specifiy only entity Class"
                                   userInfo:nil];
    }
    NSString *className = [[jsonDict allKeys] lastObject];
    id entitySpecification = [jsonDict objectForKey:className];
    if ([entitySpecification isKindOfClass:[NSArray class]]) {
      // Check to see if an entity specification is a dictionary:
      if ([[entitySpecification lastObject] isKindOfClass:[NSDictionary class]]) {
        for (NSDictionary *eSpec in entitySpecification) {
          [entities addObject:[self entityForStore:dataStore 
                                       withClass:className
                                   andProperties:eSpec]];
        }
      }
    } else if ([entitySpecification isKindOfClass:[NSDictionary class]]) {
      [entities addObject:[self entityForStore:dataStore
                                   withClass:className
                               andProperties:entitySpecification]];
    } else {
      NSLog(@"Unable to parse seed object");
      @throw [NSException exceptionWithName:DLDataSeederException
                                     reason:@"Unknown seed specification type (must be NSDictionary or NSArray)"
                                   userInfo:nil];
    }
  }
  return entities;
}

@end
