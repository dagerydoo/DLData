//
//  DLDataManager.h
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
