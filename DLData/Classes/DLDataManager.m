//
//  DLDataManager.m
//  DLData
//
//  Created by Andrew Hannon on 11/29/10.
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

#import "DLDataSeeder.h"
#import "DLDataStore.h"
#import "DLDataManager.h"

NSString *const DLDataStoreFetchException=@"DLDataStoreFetchException";

@interface DLDataManager()
- (void)contextUpdated:(NSNotification*)notification;
- (void)generateDataStore:(NSString*)modelName 
                withAlias:(NSString*)storeAlias;
@end

@implementation DLDataManager

@dynamic dataDelegate;

- (id)initWithDataStoreModelName:(NSString*)modelName 
                   andStoreAlias:(NSString*)storeAlias {
  self = [super init];
  if (self) {
    [self generateDataStore:modelName withAlias:storeAlias];
  }
  return self;
}

- (id)initWithDataStoreModelName:(NSString*)modelName {
  return [self initWithDataStoreModelName:modelName andStoreAlias:nil];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [dataStore release];
  [super dealloc];
}

- (void)setDataDelegate:(id<DLDataManagerDelegate>)delegate {
  dataDelegate = delegate;
  if ([delegate respondsToSelector:@selector(dataManager:createdObjects:updatedObjects:deletedObjects:)]) {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(contextUpdated:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:dataStore.managedObjectContext];
  } else {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:dataStore.managedObjectContext];
  }
}

- (id<DLDataManagerDelegate>)dataDelegate { 
  return dataDelegate;
}

- (void)contextUpdated:(NSNotification*)notification {
  // Given the notification observe condition above, this should always be true,
  // but better safe than sorry in the meantime... !!!:ACH:2011-01-21 
  if ([dataDelegate respondsToSelector:@selector(dataManager:createdObjects:updatedObjects:deletedObjects:)]) {
    NSDictionary *info = [notification userInfo];
    [dataDelegate dataManager:self 
               createdObjects:[info objectForKey:NSInsertedObjectsKey]
               updatedObjects:[info objectForKey:NSUpdatedObjectsKey]
               deletedObjects:[info objectForKey:NSDeletedObjectsKey]];
  }
}

////////////////////////////////////////////////////////////////////////////////
// Entity Creation
////////////////////////////////////////////////////////////////////////////////

- (id)entityWithName:(NSString*)entityName {
  NSManagedObjectContext *moc = dataStore.managedObjectContext;
  NSEntityDescription *desc = [NSEntityDescription entityForName:entityName 
                                          inManagedObjectContext:moc];
  return [[[NSClassFromString(entityName) alloc] initWithEntity:desc 
                                 insertIntoManagedObjectContext:moc] autorelease];
}

////////////////////////////////////////
// Fetching
////////////////////////////////////////

- (NSArray*)executeFetchRequest:(NSFetchRequest*)fetchRequest
                          error:(NSError**)error {
  NSManagedObjectContext *moc = dataStore.managedObjectContext;
  return [moc executeFetchRequest:fetchRequest error:error];
}

- (NSArray*)executeFetchRequestNamed:(NSString*)templateName
                               error:(NSError**)error {
  return [self executeFetchRequest:[self fetchRequestNamed:templateName] error:error]; 
}

- (NSArray*)executeFetchRequestNamed:(NSString*)templateName
               substitutionVariables:(NSDictionary *)variables
                               error:(NSError**)error {
  NSFetchRequest *request = [self fetchRequestNamed:templateName substitutionVariables:variables];
  return [self executeFetchRequest:request error:error];
}

- (NSFetchRequest*)fetchRequestForEntity:(NSString*)entityName
                                matching:(NSPredicate*)predicate
                                sortedBy:(NSArray*)sortDescriptors {
  NSManagedObjectContext *moc = dataStore.managedObjectContext;
  NSEntityDescription *desc = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:desc];
  [request setPredicate:predicate];
  [request setSortDescriptors:sortDescriptors];
  return [request autorelease];
}

- (NSArray*)fetchAll:(NSString*)entityName 
            matching:(NSPredicate*)predicate
            sortedBy:(NSArray*)sortDescriptors {
  NSFetchRequest *request = [self fetchRequestForEntity:entityName 
                                               matching:predicate 
                                               sortedBy:sortDescriptors];
  NSError *error=nil;
  NSArray *result = [self executeFetchRequest:request error:&error];
  if (error) {
    NSLog(@"Unable to retrieve %@ due to error: %@", entityName, error);
    @throw [NSException exceptionWithName:DLDataStoreFetchException 
                                   reason:@"Unable to fetch from data store" 
                                 userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
  }
  return result;  
}

- (id)fetchOne:(NSString*)entityName 
      matching:(NSPredicate*)predicate
      sortedBy:(NSArray*)sortDescriptors {
  NSFetchRequest *request = [self fetchRequestForEntity:entityName 
                                               matching:predicate 
                                               sortedBy:sortDescriptors];
  [request setFetchLimit:1];

  NSError *error=nil;
  NSArray *result = [self executeFetchRequest:request error:&error];
  if (error) {
    NSLog(@"Unable to retrieve %@ due to error: %@", entityName, error);
    @throw [NSException exceptionWithName:DLDataStoreFetchException 
                                   reason:@"Unable to fetch from data store" 
                                 userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
  }
  return [result lastObject];  
}

- (NSUInteger)countForRequest:(NSFetchRequest*)request {
  NSManagedObjectContext *moc = dataStore.managedObjectContext;
  NSError *error=nil;
  NSUInteger count = [moc countForFetchRequest:request error:&error];
  if (error) {
    NSLog(@"Unable to count the number of entities due to error: %@", error);
    @throw [NSException exceptionWithName:DLDataStoreFetchException
                                   reason:@"Unable to count entities" 
                                 userInfo:[NSDictionary dictionaryWithObject:error
                                                                      forKey:@"error"]];
  }
  return count;
}

- (NSUInteger)fetchCount:(NSString*)entityName
                matching:(NSPredicate*)predicate {
  NSFetchRequest *request = [self fetchRequestForEntity:entityName 
                                               matching:predicate 
                                               sortedBy:nil];
  return [self countForRequest:request];
}

- (NSUInteger)countForRequestNamed:(NSString*)templateName {
  NSFetchRequest *request = [self fetchRequestNamed:templateName];
  return [self countForRequest:request];
}

- (NSUInteger)countForRequestNamed:(NSString*)templateName
             substitutionVariables:(NSDictionary *)variables {
  NSFetchRequest *request = [self fetchRequestNamed:templateName substitutionVariables:variables];
  return [self countForRequest:request];
}

////////////////////////////////////////////////////////////////////////////////
// Fetch Request Templates
////////////////////////////////////////////////////////////////////////////////

- (NSFetchRequest*)fetchRequestNamed:(NSString*)templateName {
  return [dataStore.managedObjectModel fetchRequestTemplateForName:templateName]; 
}

- (NSFetchRequest*)fetchRequestNamed:(NSString*)templateName
               substitutionVariables:(NSDictionary *)variables {
  return [dataStore.managedObjectModel fetchRequestFromTemplateWithName:templateName 
                                                  substitutionVariables:variables];
}

////////////////////////////////////////////////////////////////////////////////
// Deletion
////////////////////////////////////////////////////////////////////////////////

- (void)deleteEntity:(NSManagedObject*)entity {
  [dataStore.managedObjectContext deleteObject:entity];
}

////////////////////////////////////////
// Not Fetching
////////////////////////////////////////

- (void)generateDataStore:(NSString*)modelName 
                withAlias:(NSString*)storeAlias {
  [dataStore release];
  dataStore = [DLDataStore sharedDataStoreWithModelName:modelName andAlias:storeAlias];
  dataStore.dataDelegate = self;
  [dataStore retain];
}

- (void)seedDataStore:(NSURL*)seedURL {
  [DLDataSeeder seedDataStore:dataStore fromSeedURL:seedURL];
}

- (void)beginUndoGroup {
  [dataStore beginUndoGroup];
}

- (void)endUndoGroup {
  [dataStore endUndoGroup];
}

- (void)undoGroup {
  [dataStore undoGroup];
}

- (void)redoGroup {
  [dataStore redoGroup];
}

- (void)undo {
  [dataStore undo];
}

- (void)redo {
  [dataStore redo];
}

- (void)rollback {
  [dataStore rollback];
}

- (void)commit {
  [dataStore commit];
}

- (void)flushPendingData {
  [DLDataStore commitAllStores]; 
}

- (void)purgeDataStore {
  NSString *storeAlias = [NSString stringWithString:dataStore.dataStoreAlias];
  NSString *modelName = [NSString stringWithString:dataStore.dataStoreModelName];
  [DLDataStore purgeStoreNamed:storeAlias];
  [self generateDataStore:modelName withAlias:storeAlias];
}

////////////////////////////////////////
// DLDataStoreDelegate
////////////////////////////////////////

- (BOOL)dataStoreSupportsUndo:(DLDataStore*)store {
  return ([dataDelegate respondsToSelector:@selector(dataManagerSupportsUndo:)] &&
          [dataDelegate dataManagerSupportsUndo:self]);
}

- (BOOL)dataStoreSupportsLightweightMigration:(DLDataStore *)dataStore {
  return ([dataDelegate respondsToSelector:@selector(dataManagerSupportsLightweightMigration:)] &&
          [dataDelegate dataManagerSupportsLightweightMigration:self]);
}

@end
