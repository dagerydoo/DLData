//
//  DLDataStore.h
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
