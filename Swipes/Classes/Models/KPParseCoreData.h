//
//  CoreDataClass.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

@class NSManagedObject,NSManagedObjectContext;
#import <Foundation/Foundation.h>
#define KPCORE [KPParseCoreData sharedInstance]

@interface KPParseCoreData : NSObject

+(KPParseCoreData *)sharedInstance;

@property (nonatomic,strong) NSManagedObjectContext *context;


-(void)logOutAndDeleteData;
-(void)seedObjectsSave:(BOOL)save;


-(void)sync:(BOOL)sync attributes:(NSArray*)attributes forIdentifier:(NSString*)identifier isTemp:(BOOL)isTemp;

-(NSArray*)lookupChangedAttributesToSaveForObject:(NSString*)objectId;

-(NSArray*)lookupTemporaryChangedAttributesForTempId:(NSString *)tempId;
-(NSArray*)lookupTemporaryChangedAttributesForObject:(NSString*)objectId;
-(void)tempId:(NSString*)tempId gotObjectId:(NSString*)objectId;


-(void)saveContextForSynchronization:(NSManagedObjectContext*)context;

- (UIBackgroundFetchResult)synchronizeForce:(BOOL)force async:(BOOL)async;

#ifdef DEBUG
- (void)dumpLocalDb;
#endif

@end
