//
//  CoreDataClass.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPParseCoreData.h"
#import "UtilityClass.h"
#import "KPToDo.h"
#import "KPTag.h"
#import "NSDate-Utilities.h"
#import <Parse/PFCloud.h>
#import <Parse/PFRelation.h>
#import "Reachability.h"

#define kFetchLimit 0
#define kSyncTime 5
/*

*/
@interface KPParseCoreData ()
@property (nonatomic,assign) BOOL isPerformingOperation;
@property (nonatomic,assign) BOOL didLogout;
@property (nonatomic) Reachability *reach;
@property (nonatomic) NSMutableDictionary *tmpUpdatingObjects;
@property (nonatomic) NSMutableDictionary *deleteObjects;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) NSTimer *syncTimer;
@property BOOL needSync;
@property BOOL isSyncing;
@property BOOL lockSaving;
@end
@implementation KPParseCoreData
-(NSManagedObjectContext *)context{
    return [NSManagedObjectContext MR_defaultContext];
}
-(NSMutableDictionary *)deleteObjects{
    if(!_deleteObjects){
        _deleteObjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"deleteObjects"];
        if(!_deleteObjects) _deleteObjects = [NSMutableDictionary dictionary];
    }
    return _deleteObjects;
}
-(void)deleteObject:(KPParseObject*)object{
    [self.deleteObjects setObject:object.parseClassName forKey:object.objectId];
}
-(void)saveInContext:(NSManagedObjectContext*)context{
    if(!context) context = [self context];
    [context performBlockAndWait:^{
        //NSSet *insertedObjects = [context insertedObjects];
        NSSet *updatedObjects = [context updatedObjects];
        NSSet *deletedObjects = [context deletedObjects];
        for(KPParseObject *object in updatedObjects){
            if(!object.objectId) continue;
            NSArray *attributeArray = [self.tmpUpdatingObjects objectForKey:object.objectId];
            NSMutableSet *attributeSet = [NSMutableSet set];
            if(attributeArray) [attributeSet addObjectsFromArray:attributeArray];
            if(object.changedValues) [attributeSet addObjectsFromArray:[object.changedValues allKeys]];
            [self.tmpUpdatingObjects setObject:[attributeSet allObjects] forKey:object.objectId];
        }
        for(KPParseObject *object in deletedObjects){
            if(object.objectId) [self deleteObject:object];
        }
    }];
    [context MR_saveToPersistentStoreAndWait];
    [self synchronizeForce:NO];
    return;
}
+(NSString *)classNameFromParseName:(NSString *)parseClassName{
    return [NSString stringWithFormat:@"KP%@",parseClassName];
}
#pragma mark Instantiation
static KPParseCoreData *sharedObject;
+(KPParseCoreData *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[KPParseCoreData allocWithZone:NULL] init];
        [sharedObject initialize];
        
    }
    return sharedObject;
}
#pragma mark Core data stuff
-(void)initialize{
    self.backgroundTask = UIBackgroundTaskInvalid;
    [self loadDatabase];
    sharedObject.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    // Set the blocks
    sharedObject.reach.reachableBlock = ^(Reachability*reach)
    {
        if(sharedObject.needSync) [sharedObject synchronizeForce:YES];
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [sharedObject.reach startNotifier];
}
-(void)loadDatabase{
    @try {
        [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"swipes"];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
}
-(void)updateTMPObjects{
    for(NSString *identifier in self.tmpUpdatingObjects){
        NSArray *attributeArray = [self.updateObjects objectForKey:identifier];
        NSArray *newAttributeArray = [self.tmpUpdatingObjects objectForKey:identifier];
        NSMutableSet *newAttributeSet = [NSMutableSet set];
        if(attributeArray) [newAttributeSet addObjectsFromArray:attributeArray];
        if(newAttributeArray) [newAttributeSet addObjectsFromArray:newAttributeArray];
        [self.updateObjects setObject:[newAttributeSet allObjects] forKey:identifier];
    }
    [self saveUpdatingObjects];
    self.tmpUpdatingObjects = nil;
}
-(NSMutableDictionary *)tmpUpdatingObjects{
    if(!_tmpUpdatingObjects) _tmpUpdatingObjects = [NSMutableDictionary dictionary];
    return _tmpUpdatingObjects;
}
-(void)saveUpdatingObjects{
    [[NSUserDefaults standardUserDefaults] setObject:self.updateObjects forKey:@"updateObjects"];
    [[NSUserDefaults standardUserDefaults] setObject:self.deleteObjects forKey:@"deleteObjects"];
}
-(NSMutableDictionary*)updateObjects{
    if(!_updateObjects){
        _updateObjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"updateObjects"];
        if(!_updateObjects) _updateObjects = [NSMutableDictionary dictionary];
    }
    return _updateObjects;
}
-(void)forceSync{
    [self synchronizeForce:YES];
}
-(void)synchronizeForce:(BOOL)force{
    if(self.isSyncing){
        self.needSync = YES;
        return;
    }
    /* Testing for timing - if */
    if(!force){
        if(self.syncTimer && self.syncTimer.isValid) [self.syncTimer invalidate];
        self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:kSyncTime target:self selector:@selector(forceSync) userInfo:nil repeats:NO];
        return;
    }
    /* Testing for network connection */
    if(self.needSync) self.needSync = NO;
    if(!self.reach.isReachable){
        self.needSync = YES;
        return;
    }
    
    self.isSyncing = YES;
    NSLog(@"syncing");
    [self updateTMPObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self startBackgroundHandler];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(objectId IN %@) OR (objectId = nil)",[self.updateObjects allKeys]];
        NSArray *changedObjects = [KPParseObject MR_findAllWithPredicate:predicate inContext:localContext];
        __block NSMutableArray *updatePFObjects = [NSMutableArray array];
        __block NSMutableArray *updatedObjects = [NSMutableArray array];
        for(KPParseObject *object in changedObjects){
            PFObject *pfObj = [object objectToSaveInContext:localContext];
            if(!pfObj){
                if(object && object.objectId) [self.updateObjects removeObjectForKey:object.objectId];
                continue;
            }
            [updatePFObjects addObject:pfObj];
            [updatedObjects addObject:object];
        }
        for(NSString *objectIdKey in self.deleteObjects){
            NSString *className = [self.deleteObjects objectForKey:objectIdKey];
            PFObject *deleteObject = [KPParseObject objectForDeletionWithClassName:className objectId:objectIdKey];
            [updatePFObjects addObject:deleteObject];
        }
        if(updatePFObjects.count > 0){
            NSError *error;
            [PFObject saveAll:updatePFObjects error:&error];
            if(error){
                self.needSync = YES;
            }
            NSInteger index = 0;
            for (KPParseObject *object in updatedObjects) {
                PFObject *savedPFObject = [updatePFObjects objectAtIndex:index];
                if(savedPFObject.updatedAt){
                    [object updateWithObject:savedPFObject context:localContext];
                    [self.updateObjects removeObjectForKey:savedPFObject.objectId];
                }
                index++;
            }
        }
        if([localContext hasChanges]){
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *localError) {
                [self saveUpdatingObjects];
                [self update];
            }];
        }
        else [self update];
    });
        
}
-(void)sendUpdateEvent{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updated" object:self userInfo:nil];
}
-(void)saveDataToContext:(NSManagedObjectContext*)localContext{
    
}
-(void)update{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [self startBackgroundHandler];
        NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdate"];
        NSError *error;
        NSMutableDictionary *options = [@{@"changesOnly":@YES} mutableCopy];
        if(lastUpdate) [options setObject:lastUpdate forKey:@"lastUpdate"];
        NSDictionary *result = [PFCloud callFunction:@"update" withParameters:options error:&error];
        if(error){
            NSLog(@"error query:%@",error);
            [self endBackgroundHandler];
            return;
        }
        NSArray *tags = [result objectForKey:@"Tag"];
        NSArray *tasks = [result objectForKey:@"ToDo"];
        NSArray *allObjects = [tags arrayByAddingObjectsFromArray:tasks];
        lastUpdate = [result objectForKey:@"updateTime"];
        for(PFObject *object in allObjects){
            Class class = NSClassFromString([KPParseCoreData classNameFromParseName:object.parseClassName]);
            if(class && [class isSubclassOfClass:[KPParseObject class]]){
                BOOL shouldDelete = [[object objectForKey:@"deleted"] boolValue];
                if(shouldDelete){
                    [class deleteObjectById:object.objectId context:localContext];
                    if([self.deleteObjects objectForKey:object.objectId])[self.deleteObjects removeObjectForKey:object.objectId];
                }else{
                    KPParseObject *cdObject = [class getCDObjectFromObject:object context:localContext];
                    [cdObject updateWithObject:object context:localContext];
                }
            }
        }
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if(lastUpdate) [[NSUserDefaults standardUserDefaults] setObject:lastUpdate forKey:@"lastUpdate"];
            if(error) NSLog(@"error from update");
            self.isSyncing = NO;
            [self endBackgroundHandler];
            if(self.needSync) {
                [self synchronizeForce:NO];
            }
        }];
    });
}
-(void)endBackgroundHandler{
    
    if (self.backgroundTask != UIBackgroundTaskInvalid)
    {
        NSLog(@"Background time remaining = %f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}
-(void)startBackgroundHandler{
    if(self.backgroundTask == UIBackgroundTaskInvalid){
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"Background handler called. Not running background tasks anymore.");
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
    }
}
-(void)cleanUp{
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:@"swipes"];
    NSError *error;
    BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    if(removed){
        [MagicalRecord cleanUp];
        [self loadDatabase];
    }
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [self endBackgroundHandler];
}
-(void)dealloc{
    [MagicalRecord cleanUp];
}

-(void)seedObjects{
    NSArray *tagArray = @[
                        @"home",
                        @"shopping",
                        @"work"
    ];
    for(NSString *tag in tagArray){
        [KPTag addTagWithString:tag save:NO];
    }
    [self saveInContext:nil];
    NSArray *toDoArray = @[
                           @"Tap to select me",
                           @"Double-tap to edit me",
                           @"Hold to drag me up and down",
                           @"Pull down for search & filter",
                           @"Swipe the menu for settings"
                       ];
    for(NSInteger i = toDoArray.count-1 ; i >= 0  ; i--){
        NSString *item = [toDoArray objectAtIndex:i];
        KPToDo *toDo = [KPToDo addItem:item priority:NO save:NO];
        if(i == 4)[KPToDo updateTags:@[@"home"] forToDos:@[toDo] remove:NO save:YES];
        if(i == 5)[KPToDo updateTags:@[@"work"] forToDos:@[toDo] remove:NO save:YES];
    }
    [self saveInContext:nil];
 //   NSArray *todosForTagsArray = [KPToDo MR_findAll];
//    todosForTagsArray = [todosForTagsArray subarrayWithRange:NSMakeRange(0, 3)];
    
    [UTILITY.userDefaults setBool:YES forKey:@"seeded"];
}
@end
