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
typedef void (^ManagedObjectBlock) (NSManagedObject *object,NSManagedObjectContext *context, NSError *error);
#define KPCORE [KPParseCoreData sharedInstance]
@class ParseObject;
@interface KPParseCoreData : NSObject
@property (nonatomic,assign) BOOL isSeeded;
+(KPParseCoreData *)sharedInstance;
-(void)cleanUp;
-(void)seedObjects;
+(NSString*)classNameFromParseName:(NSString*)parseClassName;
@end
