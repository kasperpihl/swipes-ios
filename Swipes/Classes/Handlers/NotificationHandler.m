//
//  NotificationHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "NotificationHandler.h"
#import "UtilityClass.h"
#import "NSDate-Utilities.h"
@implementation NotificationHandler
static NotificationHandler *sharedObject;
+(NotificationHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)scheduleNumberOfTasks:(NSInteger)numberOfTasks forDate:(NSDate *)date{
    date = [[date dateAtStartOfDay] dateByAddingHours:9];
    if([date isInPast]) return;
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *notifications = [app scheduledLocalNotifications];
    for(UILocalNotification *localNotification in notifications){
        if([localNotification.fireDate compare:date] != NSOrderedSame) continue;
        if(![[localNotification.userInfo objectForKey:@"type"] isEqualToString:@"schedule"]) continue;
        [app cancelLocalNotification:localNotification];
    }
    if(numberOfTasks < 1) return;

    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertAction = NSLocalizedString(@"Open Swipes", nil);
    NSString *taskString = (numberOfTasks > 1) ? @"tasks" : @"task";
    localNotif.alertBody = [NSString stringWithFormat:@"Good morning. You have %i new %@",numberOfTasks,taskString];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"schedule",@"type",[NSNumber numberWithInteger:numberOfTasks],@"number",nil];
    localNotif.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    //NSLog(@"%@",app.scheduledLocalNotifications);
}
-(void)updateAlarm:(NSDate *)alarm identifier:(NSString*)identifier title:(NSString *)title{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *notifications = [app scheduledLocalNotifications];
    for(UILocalNotification *localNotification in notifications){
        if(![[localNotification.userInfo objectForKey:@"type"] isEqualToString:@"alarm"]) continue;
        if(![[localNotification.userInfo objectForKey:@"identifier"] isEqualToString:identifier]) continue;
        [app cancelLocalNotification:localNotification];
    }
    if(alarm){
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.fireDate = alarm;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.alertAction = NSLocalizedString(@"Open Swipes", nil);
        if(title.length > 80) title = [title substringToIndex:80];
        localNotif.alertBody = title;
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"alarm",@"type",identifier,@"identifier",nil];
        localNotif.userInfo = infoDict;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
}
@end
