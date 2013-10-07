//
//  CoreDataClass.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

@class NSManagedObject,NSManagedObjectContext;
#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
#define KPCORE [KPParseCoreData sharedInstance]
@class ParseObject;

@protocol ParseCoreDataDelegate <NSObject>
-(void)didUpdateParseCoreData:(KPParseObject*)parseCoreData;
@end


@interface KPParseCoreData : NSObject
@property (nonatomic,assign) BOOL isSeeded;
@property (nonatomic,strong) NSManagedObjectContext *context;
@property (nonatomic) NSMutableDictionary *updateObjects;
@property (nonatomic,weak) NSObject<ParseCoreDataDelegate> *delegate;
+(KPParseCoreData *)sharedInstance;
-(void)cleanUp;
-(void)seedObjects;
+(NSString*)classNameFromParseName:(NSString*)parseClassName;
-(void)saveInContext:(NSManagedObjectContext*)context;
-(void)synchronize;
@end
