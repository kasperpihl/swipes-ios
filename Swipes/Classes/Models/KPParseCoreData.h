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
@property (nonatomic) NSMutableDictionary *updateObjects;

-(void)cleanUp;
-(void)seedObjectsSave:(BOOL)save;


-(void)sync:(BOOL)sync attribute:(NSString*)attribute forObject:(NSString*)objectId;
-(NSArray*)lookupChangedAttributesForTempId:(NSString *)tempId;
-(NSArray*)lookupChangedAttributesForObject:(NSString*)objectId;



-(void)saveContextForSynchronization:(NSManagedObjectContext*)context;

- (UIBackgroundFetchResult)synchronizeForce:(BOOL)force async:(BOOL)async;

#ifdef DEBUG
- (void)dumpLocalDb;
#endif

@end
