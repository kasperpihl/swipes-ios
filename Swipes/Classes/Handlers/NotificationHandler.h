//
//  NotificationHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define NOTIHANDLER [NotificationHandler sharedInstance]
#import <Foundation/Foundation.h>
#import <KitLocate/KitLocate.h>

#define kLocationPushRadius 250

typedef enum {
    LocationNotAuthorized = 0,
    LocationNeededPermission = 1,
    LocationStarted = 2
} StartLocationResult;

@interface NotificationHandler : NSObject <KitLocateDelegate>
@property (nonatomic) CLLocation *latestLocation;
+(NotificationHandler*)sharedInstance;
-(void)updateUpcomingNotifications;
-(void)updateLocalNotifications;
-(void)updateLocationUpdates;
-(StartLocationResult)startLocationServices;
-(void)stopLocationServices;
@end