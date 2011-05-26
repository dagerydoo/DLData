//
//  DLDataStore.h
//  DiaPad
//
//  Created by Andrew Hannon on 9/16/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DLDataStore;

@protocol DLDataStoreDelegate<NSObject>
@optional
// If this is not implemented, the data store is purged and retried.
// If this returns true, an attempt is made to retry with the data store
// intact. If that fails, the data store is expunged and the attempt is retried.
- (BOOL)dataStoreAttemptSoftRetry:(DLDataStore*)dataStore
                       afterError:(NSError*)error;
- (BOOL)dataStoreSupportsUndo:(DLDataStore*)dataStore;
- (BOOL)dataStoreSupportsLightweightMigration:(DLDataStore*)dataStore;
@end

@interface DLDataStore : NSObject {
  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;
  NSPersistentStoreCoordinator *persistentStoreCoordinator;
  NSString *dataStoreModelName;
  NSString *dataStoreAlias;
  id<DLDataStoreDelegate> dataDelegate;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSString *dataStoreModelName;
@property (nonatomic, retain, readonly) NSString *dataStoreAlias;
@property (nonatomic, assign) id<DLDataStoreDelegate> dataDelegate;

- (void)beginUndoGroup;
- (void)endUndoGroup;
- (void)undoGroup;
- (void)redoGroup;

- (void)undo;
- (void)redo;
- (void)commit;
- (void)rollback;

+ (DLDataStore*)coreDataStore;
+ (DLDataStore*)sharedDataStoreWithModelName:(NSString*)modelName
                                    andAlias:(NSString*)storeAlias;
+ (DLDataStore*)dataStoreWithModelName:(NSString*)modelName;

+ (void)commitAllStores;
+ (void)rollbackAllStores;
+ (void)purgeStoreNamed:(NSString*)dataStoreName;

@end
