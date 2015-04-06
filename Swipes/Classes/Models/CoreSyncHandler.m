//
//  CoreSyncHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "UtilityClass.h"
#import "GlobalApp.h"
#import "KPToDo.h"
#import "KPAttachment.h"
#import "KPTag.h"
#import "NSDate-Utilities.h"
#import "Reachability.h"
#import "AnalyticsHandler.h"
#import "UserHandler.h"

#ifndef NOT_APPLICATION
#import "RootViewController.h"
#import "DejalActivityView.h"
#endif

#import "EvernoteIntegration.h"
#import "EvernoteSyncHandler.h"

#import "GmailIntegration.h"
#import "GmailSyncHandler.h"

#import "CoreSyncHandler.h"

#define kSyncTime 3
#define kUpdateLimit 200
#define kBatchSize 50

#define kTMPUpdateObjects @"tmpUpdateObjects"
#define kUpdateObjects @"updateObjects"
#define kLastSyncLocalDate @"lastSyncLocalDate"
#define kLastSyncServerString @"lastSync"

#define kDeleteObjectsKey @"deleteObjects"

#ifdef DEBUG
#define DUMPDB //[self dumpLocalDb];
#else
#define DUMPDB
#endif
/*

*/
@interface CoreSyncHandler ()

@property (nonatomic, strong) Reachability *_reach;

@property (nonatomic, strong) NSMutableDictionary *_attributeChangesOnObjects;
@property (nonatomic, strong) NSMutableDictionary *_attributeChangesOnNewObjectsWhileSyncing;
@property (nonatomic, strong) NSMutableDictionary *_tempIdsThatGotObjectIds;

@property (nonatomic, assign) BOOL outdated;
@property (nonatomic, assign) BOOL _needSync;
@property (nonatomic, assign) BOOL _isSyncing;
@property (nonatomic, assign) BOOL _didHardSync;
@property (nonatomic, assign) BOOL _showSuccessOnce;
@property (nonatomic, assign) BOOL showErrorOnce;

@property (nonatomic) dispatch_queue_t isolationQueue;

@property (nonatomic, strong) NSTimer *_syncTimer;
@property (nonatomic, strong) NSDate *lastTry;
@property (nonatomic, assign) NSInteger tryCounter;
@property (nonatomic, assign) BOOL isAuthingEvernote;
@property (nonatomic, assign) BOOL isAuthingGmail;

@property (nonatomic, strong) EvernoteSyncHandler *evernoteSyncHandler;
@property (nonatomic, strong) GmailSyncHandler *gmailSyncHandler;

@property (nonatomic, strong) NSMutableSet *_deletedObjectsForSyncNotification;
@property (nonatomic, strong) NSMutableSet *_updatedObjectsForSyncNotification;

@end

@implementation CoreSyncHandler

- (EvernoteSyncHandler *)evernoteSyncHandler {
    if (!_evernoteSyncHandler)
        _evernoteSyncHandler = [[EvernoteSyncHandler alloc] init];
    return _evernoteSyncHandler;
}

- (GmailSyncHandler *)gmailSyncHandler {
    if (!_gmailSyncHandler)
        _gmailSyncHandler = [[GmailSyncHandler alloc] init];
    return _gmailSyncHandler;
}

#pragma mark - public handlers of changes
-(void)tempId:(NSString *)tempId gotObjectId:(NSString *)objectId{
    if(!tempId || !objectId) return;
    [self._tempIdsThatGotObjectIds setObject:objectId forKey:tempId];
}

/* 
 Thread safe handling of attribute changes
*/
-(NSMutableDictionary*)copyChangesAndFlushForTemp:(BOOL)isTemp{
    __block NSMutableDictionary *copyOfChanges;
    __block BOOL blockIsTemp = isTemp;
    dispatch_sync(self.isolationQueue, ^(){
        NSMutableDictionary *target = blockIsTemp ? self._attributeChangesOnNewObjectsWhileSyncing : self._attributeChangesOnObjects;
        copyOfChanges = [target mutableCopy];
        [target removeAllObjects];
    });
    return copyOfChanges;
}

-(NSArray*)lookupTemporaryChangedAttributesForTempId:(NSString *)tempId{
    __block NSArray *attributeArray;
    dispatch_sync(self.isolationQueue, ^(){
        attributeArray = self._attributeChangesOnNewObjectsWhileSyncing[tempId];
    });
    return attributeArray;
}

-(NSArray*)lookupTemporaryChangedAttributesForObject:(NSString*)objectId{
    __block NSArray *attributeArray;
    dispatch_sync(self.isolationQueue, ^(){
        attributeArray = self._attributeChangesOnObjects[objectId];
    });
    return attributeArray;
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
            [USER_DEFAULTS setObject:self._attributeChangesOnObjects forKey:kTMPUpdateObjects];
            [USER_DEFAULTS synchronize];
        }
    });
}

-(void)onCoreDataRecreated
{
    [self hardSync];
}

-(void)hardSync{
    NSArray* objects = [KPParseObject MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"objectId != nil"] inContext:[self context]];
    NSMutableDictionary *changesToCommit = [NSMutableDictionary dictionary];
    self._didHardSync = YES;
    for (KPParseObject* obj in objects) {
        if ( [obj isKindOfClass:[KPTag class]])
            [obj moveObjectIdToTemp];
        else
            [changesToCommit setObject:@[@"all"] forKey:obj.objectId];
        
    }
    [self.context MR_saveOnlySelfAndWait];
    [self commitAttributeChanges:changesToCommit toTemp:NO];
    [USER_DEFAULTS removeObjectForKey:kLastSyncServerString];
    [USER_DEFAULTS synchronize];
    [self synchronizeForce:YES async:YES];

}

-(CGFloat)durationForStatus:(SyncStatus)status{
    CGFloat duration = 0;
    switch (status) {
        case SyncStatusSuccess:
            duration = 2.5;
            break;
        case SyncStatusError:{
            duration = 3.5;
            break;
        }
        default:
            break;
    }
    return duration;
}

-(NSString*)titleForStatus:(SyncStatus)status{
    NSString *title;
    switch (status) {
        case SyncStatusStarted:{
            break;
        }
        case SyncStatusSuccess:{
            if(self._showSuccessOnce){
                title = LOCALIZE_STRING(@"Synchronized");
                self._showSuccessOnce = NO;
                self.showErrorOnce = NO;
            }
            //
            break;
        }
        case SyncStatusError:{
            title = LOCALIZE_STRING(@"Error synchronizing");
            self._showSuccessOnce = YES;
            self.showErrorOnce = YES;
            break;
        }
        default:
            break;
    }
    return title;
}

-(void)sendStatus:(SyncStatus)status userInfo:(NSDictionary*)userInfo error:(NSError*)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL showErrorOnce = self.showErrorOnce;
        NSString *title = [self titleForStatus:status];
        CGFloat duration = [self durationForStatus:status];
        if( title && ((SyncStatusError != status) || ((SyncStatusError == status) && !showErrorOnce))) {
            NSDictionary *userInfoToNotification = @{ @"title": title, @"duration": @( duration ) };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showNotification" object:nil userInfo:userInfoToNotification];
        }
        
        if([self.delegate respondsToSelector:@selector(syncHandler:status:userInfo:error:)])
            [self.delegate syncHandler:self status:status userInfo:userInfo error:error];
        
#ifndef NOT_APPLICATION
        if (SyncStatusStarted == status) {
            [GlobalApp activityIndicatorVisible:YES];
        }
        else {
            [GlobalApp activityIndicatorVisible:NO];
        }
#endif
    });
    
}
/*
    This is called everytime data is saved and will persist all the changed attributes for syncing.
*/
- (void)saveContextForSynchronization:(NSManagedObjectContext*)context
{
    if (!context)
        context = [self context];

    @synchronized(self){
        [context performBlockAndWait:^{
            //NSSet *insertedObjects = [context insertedObjects];
            NSSet *updatedObjects = [context updatedObjects];
            NSSet *deletedObjects = [context deletedObjects];
            /* Iterate all updated objects and add their changed attributes to tmpUpdating */
            NSMutableDictionary *changesToCommit = [NSMutableDictionary dictionary];
            NSMutableDictionary *tempChangesToCommit = [NSMutableDictionary dictionary];

            for (KPParseObject *objectToSave in updatedObjects) {
                KPParseObject *object = objectToSave;
                NSArray *keysToSaveForUpdate = [object.changedValues allKeys];
                if (![object isKindOfClass:KPParseObject.class]) {
                    if ([object isKindOfClass:KPAttachment.class]) {
                        KPAttachment *savedAttachment = (KPAttachment*)object;
                        object = savedAttachment.todo;
                        if (nil == object)
                            continue;
                        keysToSaveForUpdate = @[@"attachments"];
                    }
                    else
                        continue;
                }
                /* If the object doesn't have an objectId - it's not saved on the server and will automatically include all keys */
                if(!object.objectId && !self._isSyncing)
                    continue;
                
                NSString *targetKey = object.objectId ? object.objectId : object.tempId;
                NSMutableDictionary *collection = object.objectId ? changesToCommit : tempChangesToCommit;
                if(keysToSaveForUpdate) {
                    NSArray* currentValue = [collection objectForKey:targetKey];
                    if (currentValue && (0 < currentValue.count)) {
                        keysToSaveForUpdate = [currentValue arrayByAddingObjectsFromArray:keysToSaveForUpdate];
                    }
                    [collection setObject:keysToSaveForUpdate forKey:targetKey];
                }
                
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
        
        [context MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronously completion:^(BOOL success, NSError *error) {
            DUMPDB;
            if(!self.disableSync)
                [self synchronizeForce:NO async:YES];
        }];
    }
    
}



- (void)forceSync
{
    [self synchronizeForce:YES async:YES];
}


- (UIBackgroundFetchResult)synchronizeForce:(BOOL)force async:(BOOL)async
{
    if(self.outdated){
        if(async && force) {
            [UTILITY alertWithTitle:LOCALIZE_STRING(@"New version required") andMessage:LOCALIZE_STRING(@"For sync to work - please update Swipes from the App Store")];
        }
        return UIBackgroundFetchResultNoData;
    }
    
    if (!kCurrent || !kCurrent.sessionToken) {
        
        return UIBackgroundFetchResultNoData;
    }
    
    if (self._isSyncing) {
        self._needSync = YES;
        return UIBackgroundFetchResultNoData;
    }
    /*if (!kUserHandler.isPlus) {
        NSDate *now = [NSDate date];
        NSDate *lastUpdatedDay = [USER_DEFAULTS objectForKey:kLastSyncLocalDate];
        if (lastUpdatedDay && now.dayOfYear == lastUpdatedDay.dayOfYear)
            return UIBackgroundFetchResultNoData;
    }*/
    
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

- (void)showErrorNotificationOnce:(NSString *)errorString
{
    if (!self.showErrorOnce) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showNotification" object:nil userInfo:@{ @"title": errorString, @"duration": @(3.5)}];
        self.showErrorOnce = YES;
        self._showSuccessOnce = YES;
    }
}

-(void)finalizeSyncWithUserInfo:(NSDictionary*)coreUserInfo error:(NSError*)error {
#ifndef NOT_APPLICATION
    dispatch_async(dispatch_get_main_queue(), ^{
        [DejalBezelActivityView removeViewAnimated:YES];
    });
#endif
    if ( error ){
        //NSLog(@"error:%@",error);
        self._isSyncing = NO;
        [self sendStatus:SyncStatusError userInfo:coreUserInfo error:error];
        NSDate *now = [NSDate date];
        if(!self.lastTry || [now timeIntervalSinceDate:self.lastTry] > 60){
            self.lastTry = now;
            self.tryCounter = 0;
        }
        self.tryCounter++;
        if( self.tryCounter > 5 )
            return;
        else
            self._needSync = YES;
    }
    if (self._needSync) {
        self._isSyncing = NO;
        [self synchronizeForce:YES async:YES];
        return;
    }
    self._isSyncing = NO;
    
    [self sendStatus:SyncStatusSuccess userInfo:coreUserInfo error:nil];
    
    
    
    if ((!kEnInt.isAuthenticated && (!kEnInt.isAuthenticationInProgress)) &&
        !kEnInt.hasAskedForPermissions && [self.evernoteSyncHandler hasObjectsSyncedWithEvernote]) {
        
        [UTILITY alertWithTitle:LOCALIZE_STRING(@"Evernote Authorization") andMessage:LOCALIZE_STRING(@"To sync with Evernote on this device, please authorize") buttonTitles:@[LOCALIZE_STRING(@"Don't sync this device"),LOCALIZE_STRING(@"Authorize now")] block:^(NSInteger number, NSError *error) {
            if(number == 1){
                [self evernoteAuthenticateUsingSelector:@selector(forceSync) withObject:nil];
            }
        }];
        kEnInt.hasAskedForPermissions = YES;
    }
    if (kEnInt.enableSync && !self.evernoteSyncHandler.isSyncing && ![EvernoteIntegration isAPILimitReached]) {
        
        [self.evernoteSyncHandler synchronizeWithBlock:^(SyncStatus status, NSDictionary *userInfo, NSError *error) {
            //NSLog(@"returned %lu",(long)status);
            if (error) {
                [EvernoteIntegration updateAPILimitIfNeeded:error];
            }
            if (status == SyncStatusSuccess){
                DLog(@"Evernote sync successfully ended: %@", userInfo);
                self.evernoteSyncHandler.isSyncing = NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == SyncStatusStarted){
                }
                else if( status == SyncStatusError ){
                    self.evernoteSyncHandler.isSyncing = NO;
                    
                    if (!kEnInt.isAuthenticated && (!kEnInt.isAuthenticationInProgress)) {
                        kEnInt.enableSync = NO;
                        [UTILITY alertWithTitle:LOCALIZE_STRING(@"Evernote Authorization") andMessage:LOCALIZE_STRING(@"To sync with Evernote on this device, please authorize") buttonTitles:@[LOCALIZE_STRING(@"Don't sync this device"),LOCALIZE_STRING(@"Authorize now")] block:^(NSInteger number, NSError *error) {
                            if(number == 1){
                                [self evernoteAuthenticateUsingSelector:@selector(forceSync) withObject:nil];
                            }
                        }];
                    }
                    else {
                        [self showErrorNotificationOnce:LOCALIZE_STRING(@"Error syncing Evernote")];
                    }
                }
            });
        }];
    }

    if (kGmInt.isAuthenticated && !self.gmailSyncHandler.isSyncing) {
        [self.gmailSyncHandler synchronizeWithBlock:^(SyncStatus status, NSDictionary *userInfo, NSError *error) {
            //NSLog(@"returned %lu",(long)status);
            if (status == SyncStatusSuccess){
                DLog(@"Gmail sync successfully ended: %@", userInfo);
                self.gmailSyncHandler.isSyncing = NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == SyncStatusStarted){
                }
                else if( status == SyncStatusError ){
                    self.gmailSyncHandler.isSyncing = NO;
                    
                    if (!kGmInt.isAuthenticated) {
                        // kGmInt.enableSync = NO;
                        [UTILITY alertWithTitle:LOCALIZE_STRING(@"Gmail Authorization") andMessage:LOCALIZE_STRING(@"To sync with Gmail on this device, please authorize") buttonTitles:@[LOCALIZE_STRING(@"Don't sync this device"),LOCALIZE_STRING(@"Authorize now")] block:^(NSInteger number, NSError *error) {
                            if (number == 1){
                                [self gmailAuthenticateUsingSelector:@selector(forceSync) withObject:nil];
                            }
                        }];
                    }
                    else {
                        [self showErrorNotificationOnce:LOCALIZE_STRING(@"Error syncing Gmail")];
                    }
                }
            });
        }];
    }
}

- (void)clearCache{
    [self.evernoteSyncHandler clearCache];
}

- (void)evernoteAuthenticateUsingSelector:(SEL)selector withObject:(id)object
{
    if (self.isAuthingEvernote || kEnInt.isAuthenticationInProgress)
        return;
    self.isAuthingEvernote = YES;
    
    [kEnInt authenticateEvernoteInViewController:self.rootController withBlock:^(NSError *error) {
        self.isAuthingEvernote = NO;

        if (error || !kEnInt.isAuthenticated) {
            // TODO show message to the user
            //NSLog(@"Session authentication failed: %@", [error localizedDescription]);
        }
        else {
            [self performSelectorOnMainThread:selector withObject:object waitUntilDone:NO];
        }
    }];
}

- (void)gmailAuthenticateUsingSelector:(SEL)selector withObject:(id)object
{
    if (self.isAuthingGmail)
        return;
    self.isAuthingGmail = YES;
    
    [kGmInt authenticateInViewController:self.rootController withBlock:^(NSError *error) {
        self.isAuthingGmail = NO;
        
        if (error || !kGmInt.isAuthenticated) {
            // TODO show message to the user
            //NSLog(@"Session authentication failed: %@", [error localizedDescription]);
        }
        else {
            [self performSelectorOnMainThread:selector withObject:object waitUntilDone:NO];
        }
    }];
}

- (BOOL)synchronizeWithParseAsync:(BOOL)async
{
    self._isSyncing = YES;
    
    if (async)
        [self startBackgroundHandler];
    /* Prepare all the objects to be send */
    [self sendStatus:SyncStatusStarted userInfo:nil error:nil];
    NSManagedObjectContext *context = [KPCORE context];
    NSPredicate *newObjectsPredicate = [NSPredicate predicateWithFormat:@"(objectId = nil)"];
    NSArray *newObjects = [KPParseObject MR_findAllWithPredicate:newObjectsPredicate inContext:context];
    NSInteger numberOfNewObjects = newObjects.count;
    NSInteger totalNumberOfObjectsToSave = numberOfNewObjects;
    
    __block NSMutableDictionary *updateObjectsToServer = [NSMutableDictionary dictionary];
    BOOL (^handleObject)(KPParseObject *object, NSArray *changedAttributes) = ^BOOL (KPParseObject *object, NSArray *changedAttributes){
        NSDictionary *pfObject = [object objectToSaveInContext:context changedAttributes:changedAttributes];
        /* It will return nil if no changes should be made to the server - */
        if (!pfObject)
            return NO;
        [self addObject:pfObject toClass:object.getParseClassName inCollection:&updateObjectsToServer];
        return YES;
    };
    for ( KPParseObject *object in newObjects )
        handleObject(object, nil);
    
    NSInteger remainingObjectsInBatch = kUpdateLimit - numberOfNewObjects;
    if (remainingObjectsInBatch <= 0 ){
        
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
        NSDictionary *objectAttributesToUpdateOnServer = [self prepareUpdatedObjectsToBeSavedOnServerWithLimit:remainingObjectsInBatch];
        NSArray *objectsToDelete = [objectAttributesToUpdateOnServer objectForKey:kDeleteObjectsKey];
        /* Include all deleted objects to be saved */
        for(NSDictionary *deleteObject in objectsToDelete)
            [self addObject:@{@"deleted":@YES,@"objectId":[deleteObject objectForKey:@"objectId"]} toClass:[deleteObject objectForKey:@"className"] inCollection:&updateObjectsToServer];
        NSPredicate *updatedObjectsPredicate = [NSPredicate predicateWithFormat:@"(objectId IN %@)",[objectAttributesToUpdateOnServer allKeys]];
        NSArray *changedObjects = [KPParseObject MR_findAllWithPredicate:updatedObjectsPredicate inContext:context];
        totalNumberOfObjectsToSave += changedObjects.count;
        for (KPParseObject *object in changedObjects) {
            handleObject(object,[objectAttributesToUpdateOnServer objectForKey:object.objectId]);
        }
    }
    
    NSMutableDictionary *syncData = [@{
                                       @"changesOnly" : @YES,
                                       @"sessionToken": [kCurrent sessionToken],
                                       @"platform" : @"ios",
                                       @"hasMoreToSave": @(self._needSync),
                                       @"sendLogs": @(NO),
                                       @"batchSize": @(kBatchSize),
                                       @"version": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]}
                                     mutableCopy];

    
    /* The last update time - saved and received from the sync response */
    NSString *lastUpdate = [USER_DEFAULTS objectForKey:kLastSyncServerString];
    if (lastUpdate)
        [syncData setObject:lastUpdate forKey:@"lastUpdate"];
    else {
#ifndef NOT_APPLICATION
        dispatch_async(dispatch_get_main_queue(), ^{
            [DejalBezelActivityView activityViewForView:[GlobalApp topView] withLabel:LOCALIZE_STRING(@"Synchronizing...")];
        });
#endif
    }
    
    
    
    [syncData setObject:updateObjectsToServer forKey:@"objects"];
    
    /* Preparing request */
    NSError *error;
//#ifdef RELEASE
    NSString *url = @"http://api.swipesapp.com/v1/sync";
    //url = @"http://127.0.0.1:5000/v1/sync";
    //url = @"http://192.168.1.21:5000/v1/sync";
    //url = @"http://api.swipesapp.com/v1/sync";
//#endif

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:35];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:syncData
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                        error:&error];
    
    if(error){
        [UtilityClass sendError:error type:@"Sync JSON prepare parse"];
        [self finalizeSyncWithUserInfo:nil error:error];
        return NO;
    }
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:jsonData];
    //DLog(@"%@",syncData);
    
    /* Performing request */
    NSHTTPURLResponse *response;
    //DLog(@"sending %lu objects %@",(long)totalNumberOfObjectsToSave,[syncData objectForKey:@"lastUpdate"]);
    //DLog(@"objects :%@",syncData);
    //NSLog(@"need: %@", [syncData objectForKey:@"hasMoreToSave"]);
    NSData *resData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    
    if(response.statusCode != 200 || error){
        //NSLog(@"status code: %i error %@",response.statusCode,error);
        if(error){
            if(!(error.code == -1001 || error.code == -1003 || error.code == -1005 || error.code == -1009))
                [UtilityClass sendError:error type:@"Sync request error 1"];
        }
        else if(response.statusCode == 503){
            error = [NSError errorWithDomain:@"Request timed out" code:503 userInfo:nil];
            self._needSync = YES;
        }
        else if(!error){
            NSString *myString = [[NSString alloc] initWithData:resData encoding:NSUTF8StringEncoding];
            if (myString)
                error = [NSError errorWithDomain:myString code:response.statusCode userInfo:nil];
            else
                error = [NSError errorWithDomain:@"(missing data)" code:response.statusCode userInfo:nil];
            [UtilityClass sendError:error type:@"Sync request error 2"];
        }
        self._needSync = YES;
        [self finalizeSyncWithUserInfo:nil error:error];
        return NO;
    }
    
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingAllowFragments error:&error];
    //DLog(@"resulted err:%@",result);
    if([result objectForKey:@"intercom-hmac"]){
        [USER_DEFAULTS setObject:[result objectForKey:@"intercom-hmac"] forKey:@"intercom-hmac"];
        [USER_DEFAULTS synchronize];
        [ANALYTICS setHmac:[result objectForKey:@"intercom-hmac"]];
    }
    if([result objectForKey:@"hardSync"])
        [self hardSync];
    
    if(error || [result objectForKey:@"code"] || ![result objectForKey:@"serverTime"]){
        if(!error){
            NSString *message = [result objectForKey:@"message"] ? [result objectForKey:@"message"] : @"Uncaught error";
            NSInteger code = [result objectForKey:@"code"] ? [[result objectForKey:@"code"] integerValue] : 500;
            if([message isEqualToString:@"update required"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UTILITY alertWithTitle:LOCALIZE_STRING(@"New version required") andMessage:LOCALIZE_STRING(@"For sync to work - please update Swipes from the App Store")];
                    //NSLog(@"adding here");
                    self.outdated = YES;
                });
            }
            error = [NSError errorWithDomain:message code:code userInfo:result];
        }
        [UtilityClass sendError:error type:@"Sync Json Parse Error"];
        [self finalizeSyncWithUserInfo:result error:error];
        return NO;
    }
    //NSLog(@"objects:%@",result);
    
    /* Handling response - Tags first due to relation */
    NSArray *tags = [result objectForKey:@"Tag"] ? [result objectForKey:@"Tag"] : @[];
    NSArray *tasks = [result objectForKey:@"ToDo"] ? [result objectForKey:@"ToDo"] : @[];
    NSArray *allObjects = [tags arrayByAddingObjectsFromArray:tasks];
    lastUpdate = [result objectForKey:@"updateTime"];
    [result objectForKey:@"serverTime"];
    
    __block NSUndoManager* um = self.context.undoManager;
    if (um.isUndoRegistrationEnabled)
        [um disableUndoRegistration];
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_context];
    NSMutableDictionary *changesToCommit = [NSMutableDictionary dictionary];
    for(NSDictionary *object in allObjects){
        [self handleCDObject:nil withObject:object affectedChangedAttributes:&changesToCommit inContext:localContext];
    }
    if(changesToCommit.count > 0){
        [self commitAttributeChanges:changesToCommit toTemp:NO];
        self._needSync = YES;
    }
    [localContext MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronously completion:^(BOOL success, NSError *error) {
        /* Save the sync to server */
        [USER_DEFAULTS setObject:[NSDate date] forKey:kLastSyncLocalDate];
        if (lastUpdate)
            [USER_DEFAULTS setObject:lastUpdate forKey:kLastSyncServerString];
        [USER_DEFAULTS synchronize];
        [self cleanUpAfterSync];
        if (!um.isUndoRegistrationEnabled)
            [um enableUndoRegistration];
        [self finalizeSyncWithUserInfo:nil error:nil];
    }];
    
    return (0 < totalNumberOfObjectsToSave);
}

#pragma mark - Sync flow helpers
- (NSDictionary*)prepareUpdatedObjectsToBeSavedOnServerWithLimit:(NSInteger)limit
{
    if ( self._didHardSync ){
        //NSLog(@"did the hard sync");
        [USER_DEFAULTS removeObjectForKey:kUpdateObjects];
        [USER_DEFAULTS synchronize];
        self._didHardSync = NO;
    }
    NSInteger counter = 0;
    NSMutableDictionary *copyOfNewAttributeChanges = [self copyChangesAndFlushForTemp:NO];
    NSMutableDictionary *objectsToUpdate = [USER_DEFAULTS objectForKey:kUpdateObjects];
    if(!objectsToUpdate)
        objectsToUpdate = [NSMutableDictionary dictionary];
    else
        objectsToUpdate = [objectsToUpdate mutableCopy];
    counter += objectsToUpdate.count;
    
    NSMutableArray *keysToRemoveInAttributeChanges = [NSMutableArray array];
    
    
    /* Handle move deleted objects from temp to server array */
    NSArray *existingObjectsToDeleteOnServer = [objectsToUpdate objectForKey:kDeleteObjectsKey];
    NSArray *newObjectsToDeleteOnServer = [copyOfNewAttributeChanges objectForKey:kDeleteObjectsKey];
    
    if(newObjectsToDeleteOnServer && newObjectsToDeleteOnServer.count > 0){
        if(existingObjectsToDeleteOnServer) newObjectsToDeleteOnServer = [newObjectsToDeleteOnServer arrayByAddingObjectsFromArray:existingObjectsToDeleteOnServer];
        [objectsToUpdate setObject:newObjectsToDeleteOnServer forKey:kDeleteObjectsKey];
        [keysToRemoveInAttributeChanges addObject:kDeleteObjectsKey];
    }
    
    if(newObjectsToDeleteOnServer)
        counter += newObjectsToDeleteOnServer.count;
    
    
    for (NSString *identifier in copyOfNewAttributeChanges) {
        if([identifier isEqualToString:kDeleteObjectsKey]) continue;
        counter++;
        if(counter > limit){
            self._needSync = YES;
            break;
        }
        [keysToRemoveInAttributeChanges addObject:identifier];
        NSArray *existingAttributesChangesToServer = [objectsToUpdate objectForKey:identifier];
        NSArray *newAttributeArray = [copyOfNewAttributeChanges objectForKey:identifier];
        NSMutableSet *newAttributeSet = [NSMutableSet set];
        
        if(existingAttributesChangesToServer)
            [newAttributeSet addObjectsFromArray:existingAttributesChangesToServer];
        
        if(newAttributeArray)
            [newAttributeSet addObjectsFromArray:newAttributeArray];
        
        [objectsToUpdate setObject:[newAttributeSet allObjects] forKey:identifier];
    }
    if(keysToRemoveInAttributeChanges.count > 0)
        [copyOfNewAttributeChanges removeObjectsForKeys:keysToRemoveInAttributeChanges];
    
    [USER_DEFAULTS setObject:objectsToUpdate forKey:kUpdateObjects];
    [self commitAttributeChanges:copyOfNewAttributeChanges toTemp:NO];
    
    return objectsToUpdate;
}

- (void)addObject:(NSDictionary*)object toClass:(NSString*)className inCollection:(NSMutableDictionary**)collection{
    if(!collection || !className || !object) return;
    NSMutableArray *classArray = [*collection objectForKey:className];
    if(!classArray) [*collection setObject:[NSMutableArray arrayWithObject:object] forKey:className];
    else [classArray addObject:object];
}


- (void)handleCDObject:(KPParseObject*)cdObject withObject:(NSDictionary*)object affectedChangedAttributes:(NSMutableDictionary **)affectedChangedAttributes inContext:(NSManagedObjectContext*)context
{
    BOOL shouldDelete = NO;
    if([[object allKeys] containsObject:@"deleted"]){
        shouldDelete = [[object objectForKey:@"deleted"] boolValue];
    }
    
    Class class;
    if (!cdObject)
        class = NSClassFromString([CoreSyncHandler classNameFromParseName:[object objectForKey:@"parseClassName"]]);
    else
        class = [cdObject class];
    
    
    // If object has parent - send update notification
    if([object objectForKey:@"parentLocalId"]){
        [self._updatedObjectsForSyncNotification addObject:[object objectForKey:@"parentLocalId"]];
    }
    
    if (shouldDelete) {
        [class deleteObject:object context:context];
        [self._deletedObjectsForSyncNotification addObject:[object objectForKey:@"objectId"]];
    }
    else{
        [self._updatedObjectsForSyncNotification addObject:[object objectForKey:@"objectId"]];
        if (!cdObject)
            cdObject = [class getCDObjectFromObject:object context:context];
        
        NSArray *affectedChanges = [cdObject updateWithObjectFromServer:object context:context];
        if(affectedChanges)
            [*affectedChangedAttributes setObject:affectedChanges forKey:cdObject.objectId];
    }
}


-(void)cleanUpAfterSync{
    [USER_DEFAULTS setObject:[NSMutableDictionary dictionary] forKey:kUpdateObjects];
    
    NSMutableDictionary *changesToCommit = [NSMutableDictionary dictionary];
    
    /* Cleaning up temporary system to make sure new objects that change attributes get saved */
    NSMutableDictionary *tempChanges = [self copyChangesAndFlushForTemp:YES];
    for(NSString *tempId in self._tempIdsThatGotObjectIds){
        NSString *objectId = [self._tempIdsThatGotObjectIds objectForKey:tempId];
        NSArray *tempAttributesSaved = [tempChanges objectForKey:tempId];
        if(tempAttributesSaved && tempAttributesSaved.count > 0)
            [changesToCommit setObject:tempAttributesSaved forKey:objectId];
    }
    [self._tempIdsThatGotObjectIds removeAllObjects];
    [self commitAttributeChanges:changesToCommit toTemp:NO];
    
    
    
    /* Send update notification */
    NSMutableDictionary *updatedEvents = [[NSMutableDictionary alloc] init]; //@{@"deleted":[self._deletedObjectsForSyncNotification copy],@"updated":[self._updatedObjectsForSyncNotification copy]};
    NSSet* set = nil;
    @try {
        set = [self._deletedObjectsForSyncNotification copy];
        if (set)
            updatedEvents[@"deleted"] = set;
    }
    @catch (NSException *exception) { }

    @try {
        set = [self._updatedObjectsForSyncNotification copy];
        if (set)
            updatedEvents[@"updated"] = set;
    }
    @catch (NSException *exception) { }
    //#warning The above code can crash because of an insert nil into one of the copies // crash #892 & #940
    
    [self._deletedObjectsForSyncNotification removeAllObjects];
    [self._updatedObjectsForSyncNotification removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updated sync" object:self userInfo:updatedEvents];
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

-(NSMutableDictionary *)_tempIdsThatGotObjectIds{
    if(__tempIdsThatGotObjectIds)
        __tempIdsThatGotObjectIds = [NSMutableDictionary dictionary];
    return __tempIdsThatGotObjectIds;
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

#pragma mark - Helping methods

+ (NSString *)classNameFromParseName:(NSString *)parseClassName
{
    return [NSString stringWithFormat:@"KP%@",parseClassName];
}

- (void)startBackgroundHandler
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_StartBackgroundHandler object:nil];
}

- (void)endBackgroundHandler
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_EndBackgroundHandler object:nil];
}

- (void)clearAndDeleteData
{
    NSURL *storeURL = [Global coreDataUrl];
    NSError *error;
    BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    if(removed){
        [MagicalRecord cleanUp];
        [self loadDatabase];
    }
    [Global clearUserDefaults];
    [self endBackgroundHandler];
    self._isSyncing = NO;
    self._needSync = NO;
    
    self._attributeChangesOnObjects = nil;
    self._tempIdsThatGotObjectIds = nil;
    self._attributeChangesOnNewObjectsWhileSyncing = nil;
    
    self._updatedObjectsForSyncNotification = nil;
    self._deletedObjectsForSyncNotification = nil;
    
    if (kEnInt.isAuthenticated)
        [kEnInt logout];
    if (kGmInt.isAuthenticated)
        [kGmInt logout];
}

#pragma mark Instantiation

static CoreSyncHandler *sharedObject;

+ (CoreSyncHandler *)sharedInstance
{
    if (!sharedObject) {
        sharedObject = [[CoreSyncHandler allocWithZone:NULL] init];
        [sharedObject initialize];
        //[sharedObject loadTest];
    }
    return sharedObject;
}

#pragma mark Core data stuff

- (void)initialize
{
    [self loadDatabase];
    notify(@"closing app", forceSync);
    notify(@"opened app", forceSync);
    notify(@"logged in", forceSync);
    notify(kMagicalRecordPSCMismatchDidRecreateStore, onCoreDataRecreated);
    sharedObject._reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    // Set the blocks
    sharedObject._reach.reachableBlock = ^(Reachability*reach) {
        if (sharedObject._needSync)
            [sharedObject synchronizeForce:YES async:YES];
    };
    self.isolationQueue = dispatch_queue_create([@"SyncAttributeQueue" UTF8String], DISPATCH_QUEUE_CONCURRENT);
    // Start the notifier, which will cause the reachability object to retain itself!
    [sharedObject._reach startNotifier];
    
}

- (void)loadDatabase
{
    @try {
        [Global initCoreData];
        [[NSManagedObjectContext MR_defaultContext] setUndoManager:[[NSUndoManager alloc] init]];
    }
    @catch (NSException *exception) {
        [UtilityClass sendException:exception type:@"Load Database Exception"];
    }
}

#pragma mark - Undo support

- (void)undo
{
    // TODO
    // 1. There is a problem with evernote, swipe 2 subtasks and then undo them, first undo work for first task, there is a second undo
    // I don't know what it does, and the third undoes second task. Am I missing something? Probably some core data update?
    // 2. when you are in ToDo editor UI update notification does not work
    if (!self._isSyncing) {
        NSUndoManager* um = self.context.undoManager;
        if (um && um.canUndo && (!um.isUndoing)) {
            DLog(@"UNDO !!!");
            @try {
                [um undo];
                [self saveContextForSynchronization:nil];
                [self synchronizeForce:NO async:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updated sync" object:self userInfo:nil];
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            @catch (NSException *exception) {
                [UtilityClass sendException:exception type:@"Undo exception"];
                [um removeAllActions];
            }
        }
    }
}

#pragma mark -

-(void)performTestForSyncing{
    /*[self.evernoteSyncHandler getSwipesTagGuidBlock:^(NSString *string, NSError *error) {
        DLog(@"%@",string);
        DLog(@"%@",error);
    }];*/
    if(![USER_DEFAULTS boolForKey:@"hasSwitchedToNewAPI"]){
        [self hardSync];
        
        [USER_DEFAULTS setBool:YES forKey:@"hasSwitchedToNewAPI"];
        [USER_DEFAULTS synchronize];
    }
}

- (void)seedObjectsSave:(BOOL)save
{
    ANALYTICS.analyticsOff = YES;
    NSArray *tagArray = @[
                            LOCALIZE_STRING(@"home"),
                            LOCALIZE_STRING(@"work")
                        ];
    
    for(NSString *tag in tagArray){
        [KPTag addTagWithString:tag save:NO from:@"Start Objects"];
    }
    [self saveContextForSynchronization:nil];
    NSArray *toDoArray = @[
                               LOCALIZE_STRING(@"Swipe right to complete"),
                               LOCALIZE_STRING(@"Swipe left to snooze for later"),
                               LOCALIZE_STRING(@"Access your tasks on web.swipesapp.com")
 
                            ];
    
    for(NSInteger i = toDoArray.count-1 ; i >= 0  ; i--){
        NSString *item = [toDoArray objectAtIndex:i];
        BOOL priority = (i == 0);
        KPToDo *toDo = [KPToDo addItem:item priority:priority tags:nil save:NO from:@"Start Objects"];
        if(i <= 1)[KPToDo updateTags:@[LOCALIZE_STRING(@"work")] forToDos:@[toDo] remove:NO save:YES from:@"Start Objects"];
        /*if ( i == 2 ) {
            [KPToDo scheduleToDos:@[toDo] forDate:[[NSDate date] dateByAddingDays:1] save:NO];
        }*/
    }

    [self saveContextForSynchronization:nil];
//   NSArray *todosForTagsArray = [KPToDo MR_findAll];
//    todosForTagsArray = [todosForTagsArray subarrayWithRange:NSMakeRange(0, 3)];
    ANALYTICS.analyticsOff = NO;
    
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
    NSArray* objects;/* = [KPParseObject MR_findAll];
    for (KPParseObject* obj in objects) {
        NSLog(@"KPParseObject: %@", obj);
    }*/

    objects = [KPTag MR_findAll];
    for (KPTag* obj in objects) {
        NSLog(@"KPTag: %@", obj);
    }
    
    objects = [KPToDo MR_findAll];
    for (KPToDo* obj in objects) {
        NSLog(@"KPToDo: %@", obj);
    }
    
    objects = [KPAttachment MR_findAll];
    for(KPAttachment *obj in objects){
        NSLog(@"KPAttachment: %@",obj);
    }
    NSLog(@"==== Dumping local DB end");
}

-(void)loadTest{
    /*NSArray *tagArray = @[
     @"home",
     @"shopping",
     @"work"
     ];
     */
    /*for(NSString *tag in tagArray){
     [KPTag addTagWithString:tag save:NO];
     }
     [self saveContextForSynchronization:nil];*/
    NSInteger i = 0;
    do {
        [KPToDo addItem:[NSString stringWithFormat:@"Testing %li",(long)i] priority:NO tags:nil save:NO from:@"Load Test"];
        i++;
    } while (i < 500);
    //NSLog(@"saving");
    [self saveContextForSynchronization:nil];
}

#endif

@end
