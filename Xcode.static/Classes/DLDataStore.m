//
//  DLDataStore.m
//  DLData
//
//  Created by Andrew Hannon on 9/16/10.
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

@interface DLDataStore()
@property (nonatomic, retain) NSString *dataStoreModelName;
@property (nonatomic, retain) NSString *dataStoreAlias;

+ (NSURL*)storeDocumentsDirectory;
+ (NSURL*)storeURL:(NSString*)dataStoreName;

@end


@implementation DLDataStore

@dynamic managedObjectModel;
@dynamic managedObjectContext;
@dynamic persistentStoreCoordinator;
@synthesize dataStoreModelName;
@synthesize dataStoreAlias;
@synthesize dataDelegate;

- (void)dealloc {
  [dataStoreModelName release];
  [dataStoreAlias release];
  [managedObjectContext release];
  [managedObjectModel release];
  [persistentStoreCoordinator release];
  [super dealloc];
}

+ (NSURL*)storeDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL*)storeURL:(NSString*)dataStoreReference {
  NSString *pStoreName = [NSString stringWithFormat:@"%@.sqlite", dataStoreReference];
  return [[self storeDocumentsDirectory] URLByAppendingPathComponent:pStoreName];
}

#pragma mark -
#pragma mark Core Data Structures

- (NSManagedObjectContext*)managedObjectContext {
  if (managedObjectContext != nil) {
    return managedObjectContext;
  }
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    managedObjectContext = [[NSManagedObjectContext alloc] init];

    if ([dataDelegate respondsToSelector:@selector(dataStoreSupportsUndo:)] &&
        [dataDelegate dataStoreSupportsUndo:self]) {
      NSUndoManager *undoManager = [[NSUndoManager alloc] init];
      [managedObjectContext setUndoManager:undoManager];
      [undoManager release];
    }
    
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel {
  if (managedObjectModel != nil) {
    return managedObjectModel;
  }

  NSString *path = [[NSBundle mainBundle] pathForResource:dataStoreModelName ofType:@"momd"];
  if (! path) {
    NSLog(@"Could not find momd, trying mom!");
    path = [[NSBundle mainBundle] pathForResource:dataStoreModelName ofType:@"mom"];
  }
  NSURL *momURL = [NSURL fileURLWithPath:path];
  managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
  
  return managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
  if (persistentStoreCoordinator != nil) {
    return persistentStoreCoordinator;
  }
  
  NSURL *storeURL = [DLDataStore storeURL:self.dataStoreAlias];
  NSError *error = nil;
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                initWithManagedObjectModel:[self managedObjectModel]];
  
  NSDictionary *options = nil;
  if ([dataDelegate dataStoreSupportsLightweightMigration:self]) {
    options = [NSDictionary dictionaryWithObjectsAndKeys:
               [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
               [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
  }
  
  if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                               configuration:nil URL:storeURL 
                                                     options:options error:&error]) {
    static BOOL attemptedGracefulRetry = NO;
    NSLog(@"Serious error encountered opening data store at URL: %@; %@", 
          storeURL, error);
    BOOL retryGracefully = NO;
    if ((! attemptedGracefulRetry) && 
        [dataDelegate respondsToSelector:@selector(dataStoreAttemptSoftRetry:afterError:)]) {
      retryGracefully = [dataDelegate dataStoreAttemptSoftRetry:self afterError:error];
    }
    [persistentStoreCoordinator release];
    persistentStoreCoordinator = nil;
    if (! retryGracefully) {
      NSLog(@"Expunging store at URL: %@", storeURL);
      [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]; 
    } else {
      attemptedGracefulRetry = YES;
    }
    return [self persistentStoreCoordinator];         
  }
  return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Undo Redo

- (void)beginUndoGroup {
  [[managedObjectContext undoManager] beginUndoGrouping];
}

- (void)endUndoGroup {
  [[managedObjectContext undoManager] endUndoGrouping];
}

- (void)undoGroup {
  [[managedObjectContext undoManager] undoNestedGroup];
}
  
- (void)redoGroup {
  [[managedObjectContext undoManager] redo];
}

- (void)undo {
  [managedObjectContext undo];
}

- (void)redo {
  [managedObjectContext redo];
}

#pragma mark -
#pragma mark Commit Rollback

- (void)commit {
  NSError *commitError=nil; 
  if ([managedObjectContext hasChanges] && ![self.managedObjectContext save:&commitError]) {
    NSLog(@"Error commiting managedObjectContext: %@", commitError);
    @throw [NSException exceptionWithName:@"CommitFailure" 
                                   reason:@"Error saving managedObjectContext" 
                                 userInfo:[NSDictionary dictionaryWithObject:commitError forKey:@"error"]];
  }
}

- (void)rollback {
  // We must always commit the core data store,
  // even if we rollback other stores:
  [[DLDataStore coreDataStore] commit];
  [self.managedObjectContext rollback];
}

#pragma mark -
#pragma mark Singleton

+ (DLDataStore*)coreDataStore {
  return [self dataStoreWithModelName:@"DLDataStore"];
}

static NSMutableDictionary *dataStoreByName = nil;

+ (DLDataStore*)sharedDataStoreWithModelName:(NSString*)modelName
                                    andAlias:(NSString*)storeAlias {
  DLDataStore *store = nil;

  if (! storeAlias) {
    storeAlias = modelName;
  }
  
  @synchronized([DLDataStore class]) {
    if (! dataStoreByName) {
      dataStoreByName = [[NSMutableDictionary alloc] init];
    }
    store = [dataStoreByName objectForKey:storeAlias];
    if (! store) {
      store = [[DLDataStore alloc] init];
      store.dataStoreModelName = modelName;
      store.dataStoreAlias = storeAlias;
      [dataStoreByName setObject:store forKey:storeAlias];
      [store release];
    }
  }
  return store;
}

+ (DLDataStore*)dataStoreWithModelName:(NSString*)modelName {
  return [self sharedDataStoreWithModelName:modelName andAlias:nil];
}

+ (void)commitAllStores {
  @synchronized([DLDataStore class]) {
    for (DLDataStore *dataStore in [dataStoreByName allValues]) {
      [dataStore commit];
    }
  }
}

+ (void)rollbackAllStores {
  @synchronized([DLDataStore class]) {
    for (DLDataStore *dataStore in [dataStoreByName allValues]) {
      [dataStore rollback];
    }
  }
}

+ (void)purgeStoreNamed:(NSString*)storeName {
  [dataStoreByName removeObjectForKey:storeName];
  NSURL *dataStoreURL = [self storeURL:storeName];
  if ([[NSFileManager defaultManager] fileExistsAtPath:[dataStoreURL path]]) {
    NSError *purgeError=nil;
    if (! [[NSFileManager defaultManager] removeItemAtURL:dataStoreURL error:&purgeError]) {
      NSLog(@"Problem purging store: %@", purgeError);
    } else {
      NSLog(@"Purged store: %@", storeName);
    }
  }
}

@end
