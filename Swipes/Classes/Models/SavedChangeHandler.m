//
//  SavedChangeHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 05/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "KPToDo.h"
#import "KPAttachment.h"
#import "KPTag.h"

#import "SavedChangeHandler.h"

#define kTMPUpdateObjects @"tmpUpdateObjects"
#define kDeleteObjectsKey @"deleteObjects"

@interface SavedChangeHandler ()
@property (nonatomic) dispatch_queue_t isolationQueue;
@property (nonatomic) NSMutableDictionary *_attributeChangesOnObjects;
@property (nonatomic) NSMutableDictionary *_attributeChangesOnNewObjectsWhileSyncing;
@end
@implementation SavedChangeHandler
-(instancetype)init{
    self = [super init];
    if(self){
        [self initialize];
    }
    return self;
}
-(void)initialize{
    self.isolationQueue = dispatch_queue_create([@"SyncAttributeQueue2" UTF8String], DISPATCH_QUEUE_CONCURRENT);
}
/*
 This is called everytime data is saved and will persist all the changed attributes for syncing.
 */
- (void)saveContextForSynchronization:(NSManagedObjectContext*)context
{
    
    @synchronized(self){
        [context performBlockAndWait:^{
            //NSSet *insertedObjects = [context insertedObjects];
            NSSet *updatedObjects = [context updatedObjects];
            NSSet *deletedObjects = [context deletedObjects];
            /* Iterate all updated objects and add their changed attributes to tmpUpdating */
            NSMutableDictionary *changesToCommit = [NSMutableDictionary dictionary];
            NSMutableDictionary *tempChangesToCommit = [NSMutableDictionary dictionary];
            for(KPParseObject *object in updatedObjects){
                if( ![object isKindOfClass:[KPParseObject class]] )
                    continue;
                /* If the object doesn't have an objectId - it's not saved on the server and will automatically include all keys */
                if(!object.objectId) // && !self._isSyncing)
                    continue;
                
                NSString *targetKey = object.objectId ? object.objectId : object.tempId;
                NSMutableDictionary *collection = object.objectId ? changesToCommit : tempChangesToCommit;
                if(object.changedValues)
                    [collection setObject:[object.changedValues allKeys] forKey:targetKey];
                
            }
            /* Add all deleted objects with objectId to be deleted*/
            NSMutableArray *deleteObjects = [NSMutableArray array];
            for(KPParseObject *object in deletedObjects){
                if(![object isKindOfClass:[KPParseObject class]])
                    continue;
                if(object.objectId)
                    [deleteObjects addObject:@{@"className":[object getParseClassName],@"objectId":object.objectId}];
            }
            if(deleteObjects.count > 0)
                [changesToCommit setObject:deleteObjects forKey:kDeleteObjectsKey];
            
            if(changesToCommit.allKeys.count > 0)
                [self commitAttributeChanges:changesToCommit toTemp:NO];
            if(tempChangesToCommit.allKeys.count > 0)
                [self commitAttributeChanges:tempChangesToCommit toTemp:YES];
            
        }];
        
        [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if(error)
                DLog(@"error: %@", error);
        }];
    }
    
}

/* Loops through a dictionary of changes to */
-(void)commitAttributeChanges:(NSDictionary *)changes toTemp:(BOOL)toTemp{
    changes = [changes copy];
    __block BOOL blockToTemp = toTemp;
    dispatch_barrier_async(self.isolationQueue, ^(){
        NSMutableDictionary *target = blockToTemp ? self._attributeChangesOnNewObjectsWhileSyncing : self._attributeChangesOnObjects;
        [changes enumerateKeysAndObjectsUsingBlock:^(NSString *objectId, NSArray *changedAttributes, BOOL *stop) {
            NSArray *existingAttributes = [target objectForKey:objectId];
            if(!existingAttributes)
                [target setObject:changedAttributes forKey:objectId];
            else{
                NSMutableSet *attributeSet = [NSMutableSet setWithArray:existingAttributes];
                [attributeSet addObjectsFromArray:changedAttributes];
                [target setObject:[attributeSet allObjects] forKey:objectId];
            }
        }];
        if(!blockToTemp){
            DLog(@"adding changes");
            [USER_DEFAULTS setObject:self._attributeChangesOnObjects forKey:kTMPUpdateObjects];
            [USER_DEFAULTS synchronize];
        }
    });
}


-(NSMutableDictionary *)_attributeChangesOnObjects
{
    if (!__attributeChangesOnObjects){
        __attributeChangesOnObjects = [USER_DEFAULTS objectForKey:kTMPUpdateObjects];
        if(!__attributeChangesOnObjects)
            __attributeChangesOnObjects = [NSMutableDictionary dictionary];
        else
            __attributeChangesOnObjects = [__attributeChangesOnObjects mutableCopy];
    }
    return __attributeChangesOnObjects;
}
-(NSMutableDictionary *)_attributeChangesOnNewObjectsWhileSyncing{
    if(!__attributeChangesOnNewObjectsWhileSyncing)
        __attributeChangesOnNewObjectsWhileSyncing = [NSMutableDictionary dictionary];
    return __attributeChangesOnNewObjectsWhileSyncing;
}

@end
