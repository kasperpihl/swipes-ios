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
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *notifications = [app scheduledLocalNotifications];
    for(UILocalNotification *localNotification in notifications){
        if([localNotification.fireDate compare:date] != NSOrderedSame) continue;
        if(![[localNotification.userInfo objectForKey:@"type"] isEqualToString:@"schedule"]) continue;
        if(numberOfTasks == 0){
            [app cancelLocalNotification:localNotification];
            return;
        }
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"schedule",@"type",[NSNumber numberWithInteger:numberOfTasks],@"number",nil];
        localNotification.userInfo= infoDict;
        localNotification.alertBody = [NSString stringWithFormat:@"You have %i tasks today",numberOfTasks];
        return;
    }
    if(numberOfTasks < 1) return;
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    localNotif.alertBody = [NSString stringWithFormat:@"You have %i tasks today",numberOfTasks];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = numberOfTasks;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"schedule",@"type",[NSNumber numberWithInteger:numberOfTasks],@"number",nil];
    localNotif.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}
@end
