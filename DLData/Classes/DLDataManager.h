//
//  DLDataManager.h
//  DataStoreLib
//
//  Created by Andrew Hannon on 11/29/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DLDataStore;
@class DLDataManager;

extern NSString *const DLDataStoreFetchException;

@protocol DLDataManagerDelegate<NSObject>
@optional
- (BOOL)dataManagerSupportsUndo:(DLDataManager*)dataManager;
- (BOOL)dataManagerSupportsLightweightMigration:(DLDataManager*)dataManager;
- (void)dataManager:(DLDataManager*)dataManager
     createdObjects:(NSSet*)createdObjects
     updatedObjects:(NSSet*)updatedObjects
     deletedObjects:(NSSet*)deletedObjects;
@end

// Use this to subclass instead of the DLDataStore!

@interface DLDataManager : NSObject<DLDataStoreDelegate> {
  DLDataStore *dataStore;
  id<DLDataManagerDelegate> dataDelegate;
}

@property (nonatomic, assign) id<DLDataManagerDelegate> dataDelegate;

- (id)initWithDataStoreModelName:(NSString*)modelName;
- (id)initWithDataStoreModelName:(NSString*)modelName 
                   andStoreAlias:(NSString*)storeAlias;

- (id)entityWithName:(NSString*)entityName;

- (NSArray*)fetchAll:(NSString*)entityName 
            matching:(NSPredicate*)predicate
            sortedBy:(NSArray*)sortDescriptors;
- (id)fetchOne:(NSString*)entityName 
      matching:(NSPredicate*)predicate
      sortedBy:(NSArray*)sortDescriptors;

- (NSUInteger)fetchCount:(NSString*)entityName
                matching:(NSPredicate*)predicate;
- (NSUInteger)countForRequestNamed:(NSString*)templateName;
- (NSUInteger)countForRequestNamed:(NSString*)templateName
             substitutionVariables:(NSDictionary *)variables;

- (NSArray*)executeFetchRequest:(NSFetchRequest*)fetchRequest
                          error:(NSError**)error;

- (NSFetchRequest*)fetchRequestNamed:(NSString*)templateName;
- (NSFetchRequest*)fetchRequestNamed:(NSString*)templateName
               substitutionVariables:(NSDictionary *)variables;
- (NSArray*)executeFetchRequestNamed:(NSString*)templateName
                               error:(NSError**)error;
- (NSArray*)executeFetchRequestNamed:(NSString*)templateName
               substitutionVariables:(NSDictionary *)variables
                               error:(NSError**)error;

- (void)deleteEntity:(NSManagedObject*)entity;

- (void)seedDataStore:(NSURL*)seedURL;

- (void)beginUndoGroup;
- (void)endUndoGroup;
- (void)undoGroup;
- (void)redoGroup;

- (void)undo;
- (void)redo;

- (void)rollback;
- (void)commit;

- (void)flushPendingData;

- (void)purgeDataStore;

@end
