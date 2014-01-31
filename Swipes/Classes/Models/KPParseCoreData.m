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
#import "Reachability.h"
#import "UserHandler.h"

#define kSyncTime 5
#define kUpdateLimit 200


#ifdef DEBUG
#define DUMPDB //[self dumpLocalDb];
#else
#define DUMPDB
#endif
/*

*/
@interface KPParseCoreData ()

@property (nonatomic) Reachability *_reach;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) NSTimer *_syncTimer;

@property (nonatomic) NSMutableDictionary *_attributeChangesOnObjects;
@property (nonatomic) NSMutableDictionary *_attributeChangesOnNewObjectsWhileSyncing;
@property (nonatomic) NSMutableDictionary *_tempIdsThatGotObjectIds;

@property (nonatomic) NSMutableDictionary *_objectsToDeleteOnServer;
@property (nonatomic) NSMutableDictionary *_objectAttributesToUpdateOnServer;

@property (nonatomic) NSMutableSet *_deletedObjectsForSyncNotification;
@property (nonatomic) NSMutableSet *_updatedObjectsForSyncNotification;

@property BOOL _needSync;
@property BOOL _isSyncing;

@end

@implementation KPParseCoreData

/*
    This save should be called if data should be synced
*/
- (void)saveContextForSynchronization:(NSManagedObjectContext*)context
{
    if (!context)
        context = [self context];
    
    DUMPDB;
    
    [context performBlockAndWait:^{
        //NSSet *insertedObjects = [context insertedObjects];
        NSSet *updatedObjects = [context updatedObjects];
        NSSet *deletedObjects = [context deletedObjects];
        /* Iterate all updated objects and add their changed attributes to tmpUpdating */
        for(KPParseObject *object in updatedObjects){
            /* If the object doesn't have an objectId - it's not saved on the server and will automatically include all keys */
            if(!object.objectId && !self._isSyncing)
                continue;
            NSString *targetKey = object.objectId ? object.objectId : object.tempId;
            BOOL isTemp = object.objectId ? NO : YES;
            if(object.changedValues) [self sync:NO attributes:[object.changedValues allKeys] forIdentifier:targetKey isTemp:isTemp];
            
        }
        /* Add all deleted objects with objectId to be deleted*/
        for(KPParseObject *object in deletedObjects){
            if(object.objectId)
                [self._objectsToDeleteOnServer setObject:[object getParseClassName] forKey:object.objectId];
        }
        [self saveUpdatingObjects];
    }];
    [context MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronously completion:^(BOOL success, NSError *error) {
        DUMPDB;
        [self synchronizeForce:NO async:YES];
    }];
    
}



- (void)forceSync
{
    [self synchronizeForce:YES async:YES];
}
- (UIBackgroundFetchResult)synchronizeForce:(BOOL)force async:(BOOL)async
{
    if (!kCurrent) {
        return UIBackgroundFetchResultNoData;
    }
    
    if (self._isSyncing) {
        self._needSync = YES;
        return UIBackgroundFetchResultNoData;
    }
    if (!kUserHandler.isPlus) {
        NSDate *now = [NSDate date];
        NSDate *lastUpdatedDay = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncLocalDate"];
        if (lastUpdatedDay && now.dayOfYear == lastUpdatedDay.dayOfYear)
            return UIBackgroundFetchResultNoData;
    }
    
    // Testing for timing
    if (!force) {
        if (self._syncTimer && self._syncTimer.isValid)
            [self._syncTimer invalidate];
        self._syncTimer = [NSTimer scheduledTimerWithTimeInterval:kSyncTime target:self selector:@selector(forceSync) userInfo:nil repeats:NO];
        return UIBackgroundFetchResultNoData;
    }
    
    // Testing for network connection
    if (self._needSync)
        self._needSync = NO;
    
    if (!self._reach.isReachable) {
        self._needSync = YES;
        return UIBackgroundFetchResultFailed;
    }
    
    DUMPDB;
    
    // when we are using async synchronization the return type doen't matter
    if (async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self synchronizeWithParseAsync:async];
        });
        return UIBackgroundFetchResultNewData;
    }
    else {
        return [self synchronizeWithParseAsync:async];
    }
}
/*
 
 */

- (BOOL)synchronizeWithParseAsync:(BOOL)async
{
    self._isSyncing = YES;
    
    
    if (async)
        [self startBackgroundHandler];
    /* Prepare all the objects to be send */
    
    NSManagedObjectContext *context = [KPCORE context];
    NSPredicate *newObjectsPredicate = [NSPredicate predicateWithFormat:@"(objectId = nil)"];
    NSArray *newObjects = [KPParseObject MR_findAllWithPredicate:newObjectsPredicate inContext:context];
    NSInteger numberOfNewObjects = newObjects.count;
    NSInteger totalNumberOfObjectsToSave = numberOfNewObjects;
    
    __block NSMutableDictionary *updateObjectsToServer = [NSMutableDictionary dictionary];
    BOOL (^handleObject)(KPParseObject *object) = ^BOOL (KPParseObject *object){
        NSDictionary *pfObject = [object objectToSaveInContext:context];
        /* It will return nil if no changes should be made - */
        if (!pfObject) {
            if (object && object.objectId) {
                [self._objectAttributesToUpdateOnServer removeObjectForKey:object.objectId];
            }
            return NO;
        }
        [self addObject:pfObject toClass:object.getParseClassName inCollection:&updateObjectsToServer];
        return YES;
    };
    for(KPParseObject *object in newObjects) handleObject(object);
    
    NSInteger remainingObjectsInBatch = kUpdateLimit - numberOfNewObjects;
    if(remainingObjectsInBatch <= 0){
        
        NSMutableArray *newTags = [updateObjectsToServer objectForKey:@"Tag"];
        NSMutableArray *newToDos = [updateObjectsToServer objectForKey:@"ToDo"];
        
        NSInteger limitForTodos = kUpdateLimit - newTags.count;
        if(newToDos.count > limitForTodos)
            [newToDos removeObjectsInRange:NSMakeRange(limitForTodos, newToDos.count-limitForTodos)];
        totalNumberOfObjectsToSave = newToDos.count + newTags.count;
        self._needSync = YES;
    }
    else{
        /* Move all the updated objects */
        [self prepareUpdatedObjectsToBeSavedOnServerWithLimit:remainingObjectsInBatch];
        NSPredicate *updatedObjectsPredicate = [NSPredicate predicateWithFormat:@"(objectId IN %@)",[self._objectAttributesToUpdateOnServer allKeys]];
        NSArray *changedObjects = [KPParseObject MR_findAllWithPredicate:updatedObjectsPredicate inContext:context];
        totalNumberOfObjectsToSave += changedObjects.count;
        for (KPParseObject *object in changedObjects) {
            handleObject(object);
        }
    }
    
    
    
    NSMutableDictionary *syncData = [NSMutableDictionary dictionary];
    
    /* This will consist of tempId's to objects that did not have one already */
    if([context hasChanges]) [context MR_saveOnlySelfAndWait];
    
    /* The last update time - saved and received from the sync response */
    NSString *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSync"];
    if (lastUpdate)
        [syncData setObject:lastUpdate forKey:@"lastUpdate"];
    
    /* Sending the user session to verify on the server */
    [syncData setObject:[kCurrent sessionToken] forKey:@"sessionToken"];
    
    /* Indicates that it will only receive and response with changes since lastUpdate */
    [syncData setObject:@YES forKey:@"changesOnly"];
    
    /* Include all deleted objects to be saved */
    for(NSString *objectId in self._objectsToDeleteOnServer) [self addObject:@{@"deleted":@YES,@"objectId":objectId} toClass:[self._objectsToDeleteOnServer objectForKey:objectId] inCollection:&updateObjectsToServer];
    
    [syncData setObject:updateObjectsToServer forKey:@"objects"];
    
    /* Preparing request */
    NSError *error;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.swipesapp.com/sync"]];
    [request setTimeoutInterval:50];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:syncData
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                        error:&error];
    if(error){
        [UtilityClass sendError:error type:@"Sync JSON prepare parse"];
        self._isSyncing = NO;
        return NO;
    }
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    /* Performing request */
    NSURLResponse *response;
    //NSLog(@"sending %i objects",totalNumberOfObjectsToSave);
    NSData *resData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
#warning how should server error be handled?
    if(error || !resData){
        [UtilityClass sendError:error type:@"Sync request error"];
        self._isSyncing = NO;
        return NO;
    }
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingAllowFragments error:&error];
    //NSLog(@"respo:%@ error:%@",result,error);
    if(error){
        [UtilityClass sendError:error type:@"Sync JSON handle parse"];
        self._isSyncing = NO;
        return NO;
    }
    
    
    
    /* Handling response - Tags first due to relation */
    NSArray *tags = [result objectForKey:@"Tag"] ? [result objectForKey:@"Tag"] : @[];
    NSArray *tasks = [result objectForKey:@"ToDo"] ? [result objectForKey:@"ToDo"] : @[];
    NSArray *allObjects = [tags arrayByAddingObjectsFromArray:tasks];
    lastUpdate = [result objectForKey:@"updateTime"];
    [result objectForKey:@"serverTime"];
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    for(NSDictionary *object in allObjects){
        [self handleCDObject:nil withObject:object inContext:localContext];
    }
    
    [localContext MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronously completion:^(BOOL success, NSError *error) {
        self._isSyncing = NO;
        /* Save the sync to server */
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastSyncLocalDate"];
        if (lastUpdate)
            [[NSUserDefaults standardUserDefaults] setObject:lastUpdate forKey:@"lastSync"];
        [self cleanUpAfterSync];
        DUMPDB;
        if(self._needSync) [self synchronizeForce:YES async:async];
    }];
    
    return (0 < totalNumberOfObjectsToSave);
}
#pragma mark Sync flow helpers
- (void)prepareUpdatedObjectsToBeSavedOnServerWithLimit:(NSInteger)limit
{
    NSInteger counter = 0;
    NSArray *tagArray = [self._objectAttributesToUpdateOnServer objectForKey:@"Tag"];
    if(tagArray.count > 0) counter += tagArray.count;
    NSArray *toDoArray = [self._objectAttributesToUpdateOnServer objectForKey:@"ToDo"];
    if(toDoArray.count > 0) counter += toDoArray.count;
    
    NSMutableArray *keysToRemove = [NSMutableArray array];
    for (NSString *identifier in self._attributeChangesOnObjects) {
        counter++;
        if(counter >= limit){
            self._needSync = YES;
            break;
        }
        [keysToRemove addObject:identifier];
        NSArray *attributeArray = [self._objectAttributesToUpdateOnServer objectForKey:identifier];
        NSArray *newAttributeArray = [self._attributeChangesOnObjects objectForKey:identifier];
        NSMutableSet *newAttributeSet = [NSMutableSet set];
        
        if(attributeArray)
            [newAttributeSet addObjectsFromArray:attributeArray];
        
        if(newAttributeArray)
            [newAttributeSet addObjectsFromArray:newAttributeArray];
        
        [self._objectAttributesToUpdateOnServer setObject:[newAttributeSet allObjects] forKey:identifier];
        
    }
    if(keysToRemove.count > 0) [self._attributeChangesOnObjects removeObjectsForKeys:keysToRemove];
    [self saveUpdatingObjects];
}

- (void)addObject:(NSDictionary*)object toClass:(NSString*)className inCollection:(NSMutableDictionary**)collection{
    if(!collection || !className || !object) return;
    NSMutableArray *classArray = [*collection objectForKey:className];
    if(!classArray) [*collection setObject:[NSMutableArray arrayWithObject:object] forKey:className];
    else [classArray addObject:object];
}


- (void)handleCDObject:(KPParseObject*)cdObject withObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context
{
    BOOL shouldDelete = NO;
    if([[object allKeys] containsObject:@"deleted"]){
        shouldDelete = [[object objectForKey:@"deleted"] boolValue];
    }
    
    Class class;
    if (!cdObject)
        class = NSClassFromString([KPParseCoreData classNameFromParseName:[object objectForKey:@"parseClassName"]]);
    else
        class = [cdObject class];
    
    if (shouldDelete) {
        NSLog(@"deleting");
        [class deleteObject:object context:context];
        if ([self._objectsToDeleteOnServer objectForKey:[object objectForKey:@"objectId"]])
            [self._objectsToDeleteOnServer removeObjectForKey:[object objectForKey:@"objectId"]];
        [self._deletedObjectsForSyncNotification addObject:[object objectForKey:@"objectId"]];
    }
    else{
        [self._updatedObjectsForSyncNotification addObject:[object objectForKey:@"objectId"]];
        if (!cdObject)
            cdObject = [class getCDObjectFromObject:object context:context];
        [cdObject updateWithObject:object context:context];
    }
}


-(void)cleanUpAfterSync{
    [self endBackgroundHandler];
    [self._objectAttributesToUpdateOnServer removeAllObjects];
    
    
    /* Cleaning up temporary system to make sure new objects that change attributes get saved */
    for(NSString *tempId in self._tempIdsThatGotObjectIds){
        NSString *objectId = [self._tempIdsThatGotObjectIds objectForKey:tempId];
        NSArray *tempAttributesSaved = [self._attributeChangesOnNewObjectsWhileSyncing objectForKey:tempId];
        if(tempAttributesSaved && tempAttributesSaved.count > 0)
            [self sync:NO attributes:tempAttributesSaved forIdentifier:objectId isTemp:NO];
    }
    [self._tempIdsThatGotObjectIds removeAllObjects];
    [self._attributeChangesOnNewObjectsWhileSyncing removeAllObjects];
    
    [self saveUpdatingObjects];
    /* Send update notification */
    NSDictionary *updatedEvents = @{@"deleted":[self._deletedObjectsForSyncNotification copy],@"updated":[self._updatedObjectsForSyncNotification copy]};
    [self._deletedObjectsForSyncNotification removeAllObjects];
    [self._updatedObjectsForSyncNotification removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updated sync" object:self userInfo:updatedEvents];
}


#pragma mark - public handlers of changes
-(void)tempId:(NSString *)tempId gotObjectId:(NSString *)objectId{
    if(!tempId || !objectId) return;
    [self._tempIdsThatGotObjectIds setObject:objectId forKey:tempId];
}
-(NSArray *)lookupChangedAttributesToSaveForObject:(NSString *)objectId{
    return [self._objectAttributesToUpdateOnServer objectForKey:objectId];
}
-(NSArray*)lookupTemporaryChangedAttributesForTempId:(NSString *)tempId{
    return [self._attributeChangesOnNewObjectsWhileSyncing objectForKey:tempId];
}
-(NSArray*)lookupTemporaryChangedAttributesForObject:(NSString*)objectId{
    return [self._attributeChangesOnObjects objectForKey:objectId];
}
-(void)sync:(BOOL)sync attributes:(NSArray*)attributes forIdentifier:(NSString*)identifier isTemp:(BOOL)isTemp{
    NSMutableDictionary *targetDictionary = isTemp ? self._attributeChangesOnNewObjectsWhileSyncing : self._attributeChangesOnObjects;
    NSArray *attributeArray = [targetDictionary objectForKey:identifier];
    NSMutableSet *attributeSet = [NSMutableSet set];
    if(attributeArray)
        [attributeSet addObjectsFromArray:attributeArray];
    [attributeSet addObjectsFromArray:attributes];
    [targetDictionary setObject:[attributeSet allObjects] forKey:identifier];
    if(sync) [self synchronizeForce:NO async:YES];
}



#pragma mark Getters and Setters
- (NSManagedObjectContext *)context
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (NSMutableSet *)_deletedObjectsForSyncNotification
{
    if (!__deletedObjectsForSyncNotification)
        __deletedObjectsForSyncNotification = [NSMutableSet set];
    
    return __deletedObjectsForSyncNotification;
}
- (NSMutableSet *)_updatedObjectsForSyncNotification
{
    if (!__updatedObjectsForSyncNotification)
        __updatedObjectsForSyncNotification = [NSMutableSet set];
    
    return __updatedObjectsForSyncNotification;
}
-(NSMutableDictionary*)_objectAttributesToUpdateOnServer
{
    if (!__objectAttributesToUpdateOnServer) {
        __objectAttributesToUpdateOnServer = [[NSUserDefaults standardUserDefaults] objectForKey:@"updateObjects"];
        if(!__objectAttributesToUpdateOnServer)
            __objectAttributesToUpdateOnServer = [NSMutableDictionary dictionary];
    }
    return __objectAttributesToUpdateOnServer;
}
- (NSMutableDictionary *)_objectsToDeleteOnServer
{
    if (!__objectsToDeleteOnServer) {
        __objectsToDeleteOnServer = [[NSUserDefaults standardUserDefaults] objectForKey:@"deleteObjects"];
        if (!__objectsToDeleteOnServer)
            __objectsToDeleteOnServer = [NSMutableDictionary dictionary];
    }
    return __objectsToDeleteOnServer;
}
-(NSMutableDictionary *)_tempIdsThatGotObjectIds{
    if(__tempIdsThatGotObjectIds)
        __tempIdsThatGotObjectIds = [NSMutableDictionary dictionary];
    return __tempIdsThatGotObjectIds;
}
-(NSMutableDictionary *)_attributeChangesOnObjects
{
    if (!__attributeChangesOnObjects){
        __attributeChangesOnObjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"tmpUpdateObjects"];
        if(!__attributeChangesOnObjects) __attributeChangesOnObjects = [NSMutableDictionary dictionary];
    }
    return __attributeChangesOnObjects;
}
-(NSMutableDictionary *)_attributeChangesOnNewObjectsWhileSyncing{
    if(!__attributeChangesOnNewObjectsWhileSyncing)
        __attributeChangesOnNewObjectsWhileSyncing = [NSMutableDictionary dictionary];
    return __attributeChangesOnNewObjectsWhileSyncing;
}

#pragma mark - Helping methods

+ (NSString *)classNameFromParseName:(NSString *)parseClassName
{
    return [NSString stringWithFormat:@"KP%@",parseClassName];
}

-(void)saveUpdatingObjects
{
    [[NSUserDefaults standardUserDefaults] setObject:self._objectAttributesToUpdateOnServer forKey:@"updateObjects"];
    [[NSUserDefaults standardUserDefaults] setObject:self._objectsToDeleteOnServer forKey:@"deleteObjects"];
    [[NSUserDefaults standardUserDefaults] setObject:self._attributeChangesOnObjects forKey:@"tmpUpdateObjects"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)endBackgroundHandler
{
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        //NSLog(@"Background time remaining = %f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)startBackgroundHandler
{
    if (self.backgroundTask == UIBackgroundTaskInvalid) {
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"Background handler called. Not running background tasks anymore.");
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
    }
}

-(void)loadTest{
    NSArray *tagArray = @[
                          @"home",
                          @"shopping",
                          @"work"
                          ];
    
    for(NSString *tag in tagArray){
        [KPTag addTagWithString:tag save:NO];
    }
    [self saveContextForSynchronization:nil];
    NSInteger i = 0;
    do {
        [KPToDo addItem:[NSString stringWithFormat:@"Testing %i",i] priority:NO save:NO];
        i++;
    } while (i < 500);
    [self saveContextForSynchronization:nil];
}


- (void)logOutAndDeleteData
{
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
    
    self._attributeChangesOnObjects = nil;
    self._tempIdsThatGotObjectIds = nil;
    self._attributeChangesOnNewObjectsWhileSyncing = nil;
    
    self._objectsToDeleteOnServer = nil;
    self._objectAttributesToUpdateOnServer = nil;
    
    self._updatedObjectsForSyncNotification = nil;
    self._deletedObjectsForSyncNotification = nil;
    
}

#pragma mark Instantiation

static KPParseCoreData *sharedObject;

+ (KPParseCoreData *)sharedInstance
{
    if (!sharedObject) {
        sharedObject = [[KPParseCoreData allocWithZone:NULL] init];
        [sharedObject initialize];
    }
    return sharedObject;
}

#pragma mark Core data stuff

- (void)initialize
{
    self.backgroundTask = UIBackgroundTaskInvalid;
    [self loadDatabase];
    notify(@"closing app", forceSync);
    notify(@"opening app", forceSync);
    notify(@"logged in", forceSync);
    sharedObject._reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    // Set the blocks
    sharedObject._reach.reachableBlock = ^(Reachability*reach) {
        if (sharedObject._needSync)
            [sharedObject synchronizeForce:YES async:YES];
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [sharedObject._reach startNotifier];
}

- (void)loadDatabase
{
    @try {
        [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"swipes"];
        //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(loadTest) userInfo:nil repeats:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
    }
}

- (void)seedObjectsSave:(BOOL)save
{
    NSArray *tagArray = @[
                            @"home",
                            @"shopping",
                            @"work"
                        ];
    
    for(NSString *tag in tagArray){
        [KPTag addTagWithString:tag save:NO];
    }
    [self saveContextForSynchronization:nil];
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

    [self saveContextForSynchronization:nil];
//   NSArray *todosForTagsArray = [KPToDo MR_findAll];
//    todosForTagsArray = [todosForTagsArray subarrayWithRange:NSMakeRange(0, 3)];
    
    [UTILITY.userDefaults setBool:YES forKey:@"seeded"];
}

- (void)dealloc
{
    [MagicalRecord cleanUp];
    clearNotify();
}

#ifdef DEBUG

- (void)dumpLocalDb
{
    NSLog(@"==== Dumping local DB");
    NSArray* objects = [KPParseObject MR_findAll];
    for (KPParseObject* obj in objects) {
        NSLog(@"KPParseObject: %@", obj);
    }

    objects = [KPTag MR_findAll];
    for (KPTag* obj in objects) {
        NSLog(@"KPTag: %@", obj);
    }
    
    objects = [KPToDo MR_findAll];
    for (KPToDo* obj in objects) {
        NSLog(@"KPToDo: %@", obj);
    }
    
    NSLog(@"==== Dumping local DB end");
}

#endif

@end
