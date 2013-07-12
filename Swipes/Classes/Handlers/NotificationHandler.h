//
//  NotificationHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define NOTIHANDLER [NotificationHandler sharedInstance]
#import <Foundation/Foundation.h>


@interface NotificationHandler : NSObject
+(NotificationHandler*)sharedInstance;
-(void)scheduleNumberOfTasks:(NSInteger)numberOfTasks forDate:(NSDate*)date;
-(void)scheduleDate:(NSDate *)date identifier:(NSString*)identifier title:(NSString *)title;
@end
