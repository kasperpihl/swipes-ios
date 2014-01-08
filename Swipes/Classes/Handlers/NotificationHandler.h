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
#define kLocationSplitStr @"_-_"
#define kLocationPushRadius 250

@interface NotificationHandler : NSObject <KitLocateDelegate>
+(NotificationHandler*)sharedInstance;
-(void)updateLocalNotifications;
-(void)updateLocationUpdates;
@end