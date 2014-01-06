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
#import "UserHandler.h"

#define kSyncTime 5
/*

*/
@interface KPParseCoreData ()
@property (nonatomic) Reachability *_reach;
@property (nonatomic) NSMutableDictionary *tmpUpdatingObjects;
@property (nonatomic) NSMutableDictionary *deleteObjects;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) NSTimer *_syncTimer;

@property (nonatomic) NSMutableSet *_deletedObjects;
@property (nonatomic) NSMutableSet *_updatedObjects;

@property BOOL _needSync;
@property BOOL _isSyncing;
@end
@implementation KPParseCoreData
-(NSManagedObjectContext *)context{
    return [NSManagedObjectContext MR_defaultContext];
}
-(NSMutableSet *)_deletedObjects{
    if(!__deletedObjects) __deletedObjects = [NSMutableSet set];
    return __deletedObjects;
}
-(NSMutableSet *)_updatedObjects{
    if(!__updatedObjects) __updatedObjects = [NSMutableSet set];
    return __updatedObjects;
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
        [sharedObject testParse];
    }
    return sharedObject;
}
-(void)testParse{
    /*PFObject *testObject = [PFObject objectWithClassName:@"Tag"];
    [testObject setObject:@"testing" forKey:@"title"];
    NSError *error;
    [testObject save:&error];
    if(error) NSLog(@"err:%@",error);*/
}
#pragma mark Core data stuff
-(void)initialize{
    self.backgroundTask = UIBackgroundTaskInvalid;
    [self loadDatabase];
    notify(@"closing app", forceSync);
    notify(@"opening app", update);
    notify(@"logged in", update);
    sharedObject._reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    // Set the blocks
    sharedObject._reach.reachableBlock = ^(Reachability*reach)
    {
        if(sharedObject._needSync) [sharedObject synchronizeForce:YES];
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [sharedObject._reach startNotifier];
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
    if(!kCurrent){
        return;
    }
    if(self._isSyncing){
        self._needSync = YES;
        return;
    }
    if(!kUserHandler.isPlus){
        NSDate *now = [NSDate date];
        NSDate *lastUpdatedDay = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncToServer"];
        if(lastUpdatedDay && now.dayOfYear == lastUpdatedDay.dayOfYear) return;
    }
    /* Testing for timing - if */
    if(!force){
        if(self._syncTimer && self._syncTimer.isValid) [self._syncTimer invalidate];
        self._syncTimer = [NSTimer scheduledTimerWithTimeInterval:kSyncTime target:self selector:@selector(forceSync) userInfo:nil repeats:NO];
        return;
    }
    /* Testing for network connection */
    if(self._needSync) self._needSync = NO;
    if(!self._reach.isReachable){
        self._needSync = YES;
        return;
    }
    
    self._isSyncing = YES;
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
                if(error.code == 100 || error.code == 124){
                    // Timed out
                }
                else [UtilityClass sendError:error type:@"Synchronization send"];
            }
            NSInteger index = 0;
            for (KPParseObject *object in updatedObjects) {
                PFObject *savedPFObject = [updatePFObjects objectAtIndex:index];
                if(savedPFObject.updatedAt){
                    [self handleCDObject:object withPFObject:savedPFObject inContext:localContext];
                    [self.updateObjects removeObjectForKey:savedPFObject.objectId];
                }
                index++;
            }
        }
        if([localContext hasChanges]){
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *localError) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastSyncToServer"];
                [self sendUpdateEvent];
                [self saveUpdatingObjects];
                [self updateForce:YES];
            }];
        }
        else [self updateForce:YES];
    });
}
-(void)handleCDObject:(KPParseObject*)cdObject withPFObject:(PFObject*)pfObject inContext:(NSManagedObjectContext*)context{
    BOOL shouldDelete = NO;
    if([[pfObject allKeys] containsObject:@"deleted"]){
        shouldDelete = [[pfObject objectForKey:@"deleted"] boolValue];
    }
    Class class;
    if(!cdObject) class = NSClassFromString([KPParseCoreData classNameFromParseName:pfObject.parseClassName]);
    else class = [cdObject class];
    if(shouldDelete){
        [class deleteObject:pfObject context:context];
        if([self.deleteObjects objectForKey:pfObject.objectId]) [self.deleteObjects removeObjectForKey:pfObject.objectId];
        [self._deletedObjects addObject:pfObject.objectId];
    }else{
        [self._updatedObjects addObject:pfObject.objectId];
        if(!cdObject) cdObject = [class getCDObjectFromObject:pfObject context:context];
        [cdObject updateWithObject:pfObject context:context];
    }
}
-(void)sendUpdateEvent{
    NSDictionary *updatedEvents = @{@"deleted":[self._deletedObjects copy],@"updated":[self._updatedObjects copy]};
    [self._deletedObjects removeAllObjects];
    [self._updatedObjects removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updated sync" object:self userInfo:updatedEvents];
}
-(void)update{
    [self updateForce:NO];
}
-(void)updateForce:(BOOL)force{
    NSLog(@"update");
    if(!kCurrent) return;
    if(self._isSyncing && !force){
        return;
    }
    if(!kUserHandler.isPlus){
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdate"]);
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdate"]){
            self._isSyncing = NO;
            [self endBackgroundHandler];
            return;
        }
    }
    
    if(!self._isSyncing) self._isSyncing = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [self startBackgroundHandler];
        NSString *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdate"];
        NSError *error;
        NSMutableDictionary *options = [@{@"changesOnly":@YES} mutableCopy];
        if(lastUpdate) [options setObject:lastUpdate forKey:@"lastUpdate"];
        NSDictionary *result = [PFCloud callFunction:@"update" withParameters:options error:&error];
        if(error){
            NSLog(@"error query:%@",error);
            self._isSyncing = NO;
            [self endBackgroundHandler];
            return;
        }
        NSArray *tags = [result objectForKey:@"Tag"];
        NSArray *tasks = [result objectForKey:@"ToDo"];
        NSArray *allObjects = [tags arrayByAddingObjectsFromArray:tasks];
        NSDate *now = [NSDate date];
        lastUpdate = [result objectForKey:@"updateTime"];
        for(PFObject *object in allObjects){
            [self handleCDObject:nil withPFObject:object inContext:localContext];
        }
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if(lastUpdate) [[NSUserDefaults standardUserDefaults] setObject:lastUpdate forKey:@"lastUpdate"];
            if(now)[[NSUserDefaults standardUserDefaults] setObject:now forKey:@"lastUpdatedFromServer"];
            [self sendUpdateEvent];
            if(error) NSLog(@"error from update");
            self._isSyncing = NO;
            [self endBackgroundHandler];
            if(self._needSync) {
                [self synchronizeForce:NO];
            }
        }];
    });
}
-(void)endBackgroundHandler{
    
    if (self.backgroundTask != UIBackgroundTaskInvalid)
    {
        //NSLog(@"Background time remaining = %f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
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
    self._isSyncing = NO;
    self._needSync = NO;
    self.tmpUpdatingObjects = nil;
    self.deleteObjects = nil;
}
-(void)dealloc{
    [MagicalRecord cleanUp];
    clearNotify();
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
                           @"Swipe right to complete a task",
                           @"Swipe left to schedule a task",
                           @"Double-tap to edit a task"
                           ];
    for(NSInteger i = toDoArray.count-1 ; i >= 0  ; i--){
        NSString *item = [toDoArray objectAtIndex:i];
        BOOL priority = (i == 0);
        KPToDo *toDo = [KPToDo addItem:item priority:priority save:NO];
        if(i <= 1)[KPToDo updateTags:@[@"work"] forToDos:@[toDo] remove:NO save:YES];
    }
    [self saveInContext:nil];
 //   NSArray *todosForTagsArray = [KPToDo MR_findAll];
//    todosForTagsArray = [todosForTagsArray subarrayWithRange:NSMakeRange(0, 3)];
    
    [UTILITY.userDefaults setBool:YES forKey:@"seeded"];
}
@end
