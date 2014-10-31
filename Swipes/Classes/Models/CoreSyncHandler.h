//
//  CoreDataClass.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

@class NSManagedObject, NSManagedObjectContext, CoreSyncHandler, EvernoteSyncHandler;

#import "ParentSyncHandler.h"

#define kTMPUpdateObjects @"tmpUpdateObjects"
#define kUpdateObjects @"updateObjects"
#define kLastSyncLocalDate @"lastSyncLocalDate"
#define kLastSyncServerString @"lastSync"
#define KPCORE [CoreSyncHandler sharedInstance]

@protocol SyncDelegate <NSObject>

-(void)syncHandler:(CoreSyncHandler *)handler status:(SyncStatus)status userInfo:(NSDictionary *)userInfo error:(NSError*)error;
@end

@interface CoreSyncHandler : ParentSyncHandler

+(CoreSyncHandler *)sharedInstance;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, weak) id<SyncDelegate> delegate;
@property (nonatomic, weak) UIViewController* rootController;

// Used by widget to avoid syncing.
@property (nonatomic) BOOL disableSync;

-(EvernoteSyncHandler *)evernoteSyncHandler;

-(void)clearAndDeleteData;
-(void)seedObjectsSave:(BOOL)save;


-(NSArray*)lookupTemporaryChangedAttributesForTempId:(NSString *)tempId;
-(NSArray*)lookupTemporaryChangedAttributesForObject:(NSString*)objectId;
-(void)tempId:(NSString*)tempId gotObjectId:(NSString*)objectId;


-(void)saveContextForSynchronization:(NSManagedObjectContext*)context;

-(void)hardSync;
- (UIBackgroundFetchResult)synchronizeForce:(BOOL)force async:(BOOL)async;

- (void)undo;
-(void)clearCache;

#ifdef DEBUG
- (void)dumpLocalDb;
#endif

@end
