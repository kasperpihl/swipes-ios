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

#ifdef DEBUG
#define DUMPDB //[self dumpLocalDb];
#else
#define DUMPDB
#endif
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

- (NSManagedObjectContext *)context
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (NSMutableSet *)_deletedObjects
{
    if (!__deletedObjects)
        __deletedObjects = [NSMutableSet set];
    
    return __deletedObjects;
}
- (NSMutableSet *)_updatedObjects
{
    if (!__updatedObjects)
        __updatedObjects = [NSMutableSet set];
    
    return __updatedObjects;
}
-(NSMutableDictionary*)updateObjects
{
    if (!_updateObjects) {
        _updateObjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"updateObjects"];
        if(!_updateObjects)
            _updateObjects = [NSMutableDictionary dictionary];
    }
    return _updateObjects;
}
- (NSMutableDictionary *)deleteObjects
{
    if (!_deleteObjects) {
        _deleteObjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"deleteObjects"];
        if (!_deleteObjects)
            _deleteObjects = [NSMutableDictionary dictionary];
    }
    return _deleteObjects;
}


-(NSArray*)lookupChangedAttributesForObject:(NSString*)objectId{
    return [self.tmpUpdatingObjects objectForKey:objectId];
}
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
#warning If a object didn't have an objectId and currently is being saved - the new changes won't be registered (Maybe check on tempId as well)
            if(!object.objectId)
                continue;
            
            NSArray *attributeArray = [self.tmpUpdatingObjects objectForKey:object.objectId];
            
            NSMutableSet *attributeSet = [NSMutableSet set];
            if(attributeArray)
                [attributeSet addObjectsFromArray:attributeArray];
            if(object.changedValues)
                [attributeSet addObjectsFromArray:[object.changedValues allKeys]];
            
            [self.tmpUpdatingObjects setObject:[attributeSet allObjects] forKey:object.objectId];
        }
        /* Add all deleted objects with objectId to be deleted*/
        for(KPParseObject *object in deletedObjects){
            if(object.objectId)
                [self.deleteObjects setObject:[object getParseClassName] forKey:object.objectId];
        }
    }];
    [context MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronously completion:^(BOOL success, NSError *error) {
        DUMPDB;
        [self synchronizeForce:NO async:YES];
    }];
    
}

+ (NSString *)classNameFromParseName:(NSString *)parseClassName
{
    return [NSString stringWithFormat:@"KP%@",parseClassName];
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
/*
 
*/
- (void)prepareUpdatingObjects
{
    for (NSString *identifier in self.tmpUpdatingObjects) {
        NSArray *attributeArray = [self.updateObjects objectForKey:identifier];
        NSArray *newAttributeArray = [self.tmpUpdatingObjects objectForKey:identifier];
        NSMutableSet *newAttributeSet = [NSMutableSet set];
        
        if(attributeArray)
            [newAttributeSet addObjectsFromArray:attributeArray];
        
        if(newAttributeArray)
            [newAttributeSet addObjectsFromArray:newAttributeArray];
        
        [self.updateObjects setObject:[newAttributeSet allObjects] forKey:identifier];
    }
    [self saveUpdatingObjects];
    [self.tmpUpdatingObjects removeAllObjects];
}

-(NSMutableDictionary *)tmpUpdatingObjects
{
    if (!_tmpUpdatingObjects)
        _tmpUpdatingObjects = [NSMutableDictionary dictionary];
    return _tmpUpdatingObjects;
}

-(void)saveUpdatingObjects
{
    [[NSUserDefaults standardUserDefaults] setObject:self.updateObjects forKey:@"updateObjects"];
    [[NSUserDefaults standardUserDefaults] setObject:self.deleteObjects forKey:@"deleteObjects"];
}



- (void)forceSync
{
    [self synchronizeForce:YES async:YES];
}
- (void)addObject:(NSDictionary*)object toClass:(NSString*)className inCollection:(NSMutableDictionary**)collection{
    if(!collection || !className || !object) return;
    NSMutableArray *classArray = [*collection objectForKey:className];
    if(!classArray) [*collection setObject:[NSMutableArray arrayWithObject:object] forKey:className];
    else [classArray addObject:object];
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
#warning Test out if this is working properly
    if (!kUserHandler.isPlus) {
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [Global isoDateFormatter];
        NSString *lastUpdatedString = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSync"];
        NSDate *lastUpdatedDay;
        if(lastUpdatedString) lastUpdatedDay = [dateFormatter dateFromString:lastUpdatedString];
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
- (BOOL)synchronizeWithParseAsync:(BOOL)async
{
    self._isSyncing = YES;
    /* Move all the updated objects */
    [self prepareUpdatingObjects];
    
    if (async)
        [self startBackgroundHandler];
    
    
    NSManagedObjectContext *context = [KPCORE context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(objectId IN %@) OR (objectId = nil)",[self.updateObjects allKeys]];
    NSArray *changedObjects = [KPParseObject MR_findAllWithPredicate:predicate inContext:context];
    NSMutableDictionary *syncData = [NSMutableDictionary dictionary];
    NSMutableDictionary *updateObjectsToServer = [NSMutableDictionary dictionary];
    for (KPParseObject *object in changedObjects) {
        NSDictionary *pfObject = [object objectToSaveInContext:context];
        /* It will return nil if no changes should be made - */
        if (!pfObject) {
            if (object && object.objectId) {
                [self.updateObjects removeObjectForKey:object.objectId];
            }
            continue;
        }
        [self addObject:pfObject toClass:object.getParseClassName inCollection:&updateObjectsToServer];
    }
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
    
    /* Batch the sync with new, updated and deleted objects */
    for(NSString *objectId in self.deleteObjects) [self addObject:@{@"deleted":@YES,@"objectId":objectId} toClass:[self.deleteObjects objectForKey:objectId] inCollection:&updateObjectsToServer];
    
    [syncData setObject:updateObjectsToServer forKey:@"objects"];
    
    NSError *error;
    NSLog(@"before:%@",syncData);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.swipesapp.com/sync"]];
    [request setTimeoutInterval:120];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:syncData
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if(error){
        NSLog(@"error:%@",error);
        self._isSyncing = NO;
        return NO;
    }
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse *response;
    
    NSData *resData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"response");
    if(error || !resData){
        NSLog(@"didn't return");
        self._isSyncing = NO;
        return NO;
    }
#warning test what happens on corrupted data
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"respo:%@ error:%@",result,error);
    if(error){
        self._isSyncing = NO;
        return NO;
    }
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
        [self endBackgroundHandler];
        [self.updateObjects removeAllObjects];
        [self saveUpdatingObjects];
        [self sendUpdateEvent];
        if (lastUpdate)
            [[NSUserDefaults standardUserDefaults] setObject:lastUpdate forKey:@"lastSync"];
        DUMPDB;
        if(self._needSync) [self synchronizeForce:NO async:async];
    }];
    
    return (0 < changedObjects);
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
        [class deleteObject:object context:context];
        if ([self.deleteObjects objectForKey:[object objectForKey:@"objectId"]])
            [self.deleteObjects removeObjectForKey:[object objectForKey:@"objectId"]];
        [self._deletedObjects addObject:[object objectForKey:@"objectId"]];
    }
    else{
        [self._updatedObjects addObject:[object objectForKey:@"objectId"]];
        if (!cdObject)
            cdObject = [class getCDObjectFromObject:object context:context];
        [cdObject updateWithObject:object context:context];
    }
}
-(void)sendUpdateEvent
{
    NSDictionary *updatedEvents = @{@"deleted":[self._deletedObjects copy],@"updated":[self._updatedObjects copy]};
    [self._deletedObjects removeAllObjects];
    [self._updatedObjects removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updated sync" object:self userInfo:updatedEvents];
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


- (void)cleanUp
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
    self.tmpUpdatingObjects = nil;
    self.deleteObjects = nil;
}

- (void)dealloc
{
    [MagicalRecord cleanUp];
    clearNotify();
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
