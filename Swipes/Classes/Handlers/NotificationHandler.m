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
@interface NotificationHandler ()
@property (nonatomic) BOOL fencing;
@end
@implementation NotificationHandler
static NotificationHandler *sharedObject;
+(NotificationHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)setFencing:(BOOL)fencing{
    if(_fencing != fencing){
        if(!fencing) [KLLocation unregisterGeofencing];
        else [KLLocation registerGeofencing];
        _fencing = fencing;
    }
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
    
    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil)", [NSDate date]];
    NSInteger todayCount = [KPToDo MR_countOfEntitiesWithPredicate:todayPredicate];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:todayCount];
    if(!hasNotificationsOn){
        [app cancelAllLocalNotifications];
        return;
    }
    
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
    [app cancelAllLocalNotifications];
    for(UILocalNotification *notification in notificationsArray){
        [app scheduleLocalNotification:notification];
    }
}
-(void)updateLocationUpdates{
    [KLLocation deleteAllGeofences];
    NSPredicate *locationPredicate = [NSPredicate predicateWithFormat:@"(location != nil)"];
    NSArray *tasksWithLocation = [KPToDo MR_findAllWithPredicate:locationPredicate];
    if(tasksWithLocation && tasksWithLocation.count > 0){
        for(KPToDo *toDo in tasksWithLocation){
            NSArray *location = [toDo.location componentsSeparatedByString:kLocationSplitStr];
            NSString *identifier = [location objectAtIndex:0];
            float latitude = [[location objectAtIndex:1] floatValue];
            float longitude = [[location objectAtIndex:2] floatValue];
            NSString *typeString = [location objectAtIndex:3];
            klGeofenceType type = KL_GEOFENCE_TYPE_IN;
            if([typeString isEqualToString:@"OUT"]) type = KL_GEOFENCE_TYPE_OUT;
            KLGeofence *geoFence = [KLGeofence createNewGeofenceWithLatitude:latitude Longitude:longitude PushRadius:kLocationPushRadius Type:type];
            [geoFence setIDUser:identifier];
            [KLLocation addGeofence:geoFence];
        }
        self.fencing = YES;
    }
    else self.fencing = NO;
}
-(void)handleGeofences:(NSArray*)arrGeofenceList{
    UIApplication *app = [UIApplication sharedApplication];
    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil)", [NSDate date]];
    NSInteger todayCount = [KPToDo MR_countOfEntitiesWithPredicate:todayPredicate];
    
    for(KLGeofence *fence in arrGeofenceList){
        
        NSString *identifier = [[fence getIDUser] stringByAppendingString:kLocationSplitStr];
        NSPredicate *taskPredicate = [NSPredicate predicateWithFormat:@"ANY location BEGINSWITH[c] %@",identifier];
        KPToDo *toDo = [KPToDo MR_findFirstWithPredicate:taskPredicate];
        if(toDo){
            NSDictionary *userInfo = @{@"type": @"location",@"identifier": [[toDo.objectID URIRepresentation] absoluteString]};
            NSDate *fireDate = [NSDate date];
            UILocalNotification *notification = [self notificationForDate:fireDate badgeCounter:++todayCount title:toDo.title userInfo:userInfo];
            toDo.schedule = fireDate;
            toDo.location = nil;
            
            [app scheduleLocalNotification:notification];
            [KLLocation deleteGeofenceWithUserID:[fence getIDUser]];
        }
    }
    [KPToDo save];
    [self updateLocalNotifications];
}
- (void)geofencesIn:(NSArray*)arrGeofenceList{
    [self handleGeofences:arrGeofenceList];
}
- (void)geofencesOut:(NSArray*)arrGeofenceList{
    [self handleGeofences:arrGeofenceList];
}
@end
