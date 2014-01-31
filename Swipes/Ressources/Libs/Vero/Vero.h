//
//  Vero.h
//  VeroTest
//
//  Created by James Lamont on 16/04/13.
//  Copyright (c) 2013 James Lamont. All rights reserved.
//
typedef void (^VeroBlock)(id result, NSError *error);
#import <Foundation/Foundation.h>

@interface Vero : NSObject
+(Vero*)shared;
@property BOOL developmentMode;
@property BOOL logging;
@property (strong) NSString* authToken;
- (void) eventsTrack: (NSString*)eventName identity:(NSDictionary*)userProperties data:(NSDictionary*)data completionHandler:(VeroBlock)block;
- (void) usersTrack: (NSString*)userId email:(NSString*)email data:(NSDictionary*)userProperties completionHandler:(VeroBlock)block;
- (void) usersEdit: (NSString*)userId changes:(NSDictionary*)changes completionHandler:(VeroBlock)block;
- (void) usersTagsEdit: (NSString*)userId add:(NSArray*)add remove:(NSArray*)remove completionHandler:(VeroBlock)block;
- (void) usersUnsubscribe: (NSString*)userId completionHandler:(VeroBlock)block;
@end