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
#import "KPToDo.h"
#import "SettingsHandler.h"
#define kMaxNotifications 25
@implementation NotificationHandler
static NotificationHandler *sharedObject;
+(NotificationHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(UILocalNotification*)notificationForDate:(NSDate *)date badgeCounter:(NSInteger)badgeCount title:(NSString *)title userInfo:(NSDictionary*)userInfo{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertAction = NSLocalizedString(@"Open Swipes", nil);
    if(title.length > 80) title = [title substringToIndex:80];
    localNotif.alertBody = title;
    localNotif.applicationIconBadgeNumber = badgeCount;
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.userInfo = userInfo;
    return localNotif;
}
-(void)updateLocalNotifications{
    
    BOOL hasNotificationsOn = [(NSNumber*)[kSettings valueForSetting:SettingNotifications] boolValue];
    UIApplication *app = [UIApplication sharedApplication];
    if(!hasNotificationsOn){
        [app cancelAllLocalNotifications];
        return;
    }
    
    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil)", [NSDate date]];
    NSInteger todayCount = [KPToDo MR_countOfEntitiesWithPredicate:todayPredicate];
    NSPredicate *schedulePredicate = [NSPredicate predicateWithFormat:@"(schedule > %@) AND completionDate = nil", [NSDate date]];
    NSArray *scheduleArray = [KPToDo MR_findAllSortedBy:@"schedule" ascending:YES withPredicate:schedulePredicate];
    NSInteger scheduleCount = scheduleArray.count;
    NSInteger totalBadgeCount = todayCount;
    NSInteger numberOfDates = 0;
    NSDate *currentDate;
    NSInteger numberOfNotificationsForDate = 0;
    KPToDo *lastTodo;
    NSMutableArray *notificationsArray = [NSMutableArray array];
    for(NSInteger i = 0 ; i < scheduleCount ; i++){
        KPToDo *toDo = [scheduleArray objectAtIndex:i];
        
        BOOL isLastObject = (i == scheduleCount-1);
        if(!currentDate) currentDate = toDo.schedule;
        NSInteger numberOfNotificationsToAdd = [toDo.schedule isEqualToDate:currentDate] ? 0 : 1;
        if(isLastObject) numberOfNotificationsToAdd++;
        
        while (numberOfNotificationsToAdd > 0){
            if(numberOfNotificationsToAdd == 1 && isLastObject){
                currentDate = toDo.schedule;
                totalBadgeCount++;
                numberOfNotificationsForDate++;
                lastTodo = toDo;
            }
            NSString *title;
            NSDictionary *userInfo;
            if(numberOfNotificationsForDate == 1){
                title = lastTodo.title;
                userInfo = @{@"type": @"schedule",@"identifier": [[lastTodo.objectID URIRepresentation] absoluteString]};
            }
            else{
                title = [NSString stringWithFormat:@"You have %i new tasks.",numberOfNotificationsForDate];
                userInfo = @{@"type": @"schedule"};
            }
            UILocalNotification *notification = [self notificationForDate:currentDate badgeCounter:totalBadgeCount title:title userInfo:userInfo];
            [notificationsArray addObject:notification];
            currentDate = toDo.schedule;
            
            
            
            
            numberOfNotificationsForDate = 0;
            numberOfDates++;
            numberOfNotificationsToAdd--;
        }
        if(numberOfDates > kMaxNotifications) break;
        
        totalBadgeCount++;
        numberOfNotificationsForDate++;
        
        lastTodo = toDo;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:todayCount];
    [app cancelAllLocalNotifications];
    for(UILocalNotification *notification in notificationsArray){
        [app scheduleLocalNotification:notification];
    }
}

@end
