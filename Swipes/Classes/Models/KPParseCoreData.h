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
@property (nonatomic,strong) NSManagedObjectContext *context;
@property (nonatomic) NSMutableDictionary *updateObjects;
+(KPParseCoreData *)sharedInstance;
-(void)cleanUp;
-(void)seedObjects;
-(void)saveInContext:(NSManagedObjectContext*)context;
-(void)synchronizeForce:(BOOL)force;
-(void)update;
@end
