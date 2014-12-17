//
//  NotificationHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define NOTIHANDLER [NotificationHandler sharedInstance]
#import <Foundation/Foundation.h>

#define kLocationPushRadius 250
#define NH_UpdateLocalNotifications @"NH_UpdateLocalNotifications"

typedef enum {
    LocationNotAuthorized = 0,
    LocationNeededPermission = 1,
    LocationStarted = 2
} StartLocationResult;

@class CLLocation;

@interface NotificationHandler : NSObject
@property (nonatomic) CLLocation *latestLocation;
+(NotificationHandler*)sharedInstance;
-(void)updateUpcomingNotifications;
-(void)updateLocalNotifications;
-(void)updateLocationUpdates;
-(StartLocationResult)startLocationServices;
-(void)stopLocationServices;
-(void)clearLocalNotifications;
@end