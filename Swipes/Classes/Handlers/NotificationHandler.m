//
//  NotificationHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <KitLocate/KitLocate.h>
#import "NotificationHandler.h"
#import "UtilityClass.h"
#import "NSDate-Utilities.h"
#import "KPToDo.h"
#import "SettingsHandler.h"
#import "UserHandler.h"
#import "KPTopClock.h"
#import "Intercom.h"

#define kMaxNotifications 25
@interface NotificationHandler () <KitLocateSingleDelegate, KitLocateDelegate>
@property (nonatomic) BOOL fencing;
@property (nonatomic) BOOL startedLocationServices;
@end

@implementation NotificationHandler
@synthesize latestLocation = _latestLocation;
static NotificationHandler *sharedObject;

+(NotificationHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[super allocWithZone:NULL] init];
        //[sharedObject setStartedLocationServices:YES];
        [sharedObject initialize];
    }
    return sharedObject;
}
-(void)initialize{
    notify(@"showNotification", sendNotification:);
    notify(NH_UpdateLocalNotifications, onUpdateLocalNotifications:);
}

-(void)sendNotification:(NSNotification*)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *title = [userInfo objectForKey:@"title"];
    CGFloat duration = [[userInfo objectForKey:@"duration"] floatValue];
    [kTopClock showNotificationWithMessage:title forSeconds:duration];
}

-(void)onUpdateLocalNotifications:(NSNotification*)notification{
    [self updateLocalNotifications];
}

-(CLLocation *)latestLocation
{
    if (!_latestLocation) {
        CGFloat latitude = [USER_DEFAULTS floatForKey:@"latestLocationLatitude"];
        CGFloat longitude = [USER_DEFAULTS floatForKey:@"latestLocationLongitude"];
        if (latitude && longitude)
            _latestLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    }
    return _latestLocation;
}

-(void)setLatestLocation:(CLLocation *)latestLocation
{
    _latestLocation = latestLocation;
    [USER_DEFAULTS setFloat:latestLocation.coordinate.latitude forKey:@"latestLocationLatitude"];
    [USER_DEFAULTS setFloat:latestLocation.coordinate.longitude forKey:@"latestLocationLongitude"];
    [USER_DEFAULTS synchronize];
}

-(void)setFencing:(BOOL)fencing
{
    if(_fencing != fencing){
        if(fencing && !self.startedLocationServices)
            [self startLocationServices];
        if (!fencing)
            [KLLocation unregisterGeofencing];
        else
            [KLLocation registerGeofencing];
        _fencing = fencing;
    }
}
-(StartLocationResult)startLocationServices{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self setStartedLocationServices:YES];
        return LocationNeededPermission;
    }
    else if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized){
        [UTILITY alertWithTitle:LOCALIZE_STRING(@"Location Permissions") andMessage:LOCALIZE_STRING(@"You need to turn on location permissions for Swipes in Settings > Privacy")];
        return LocationNotAuthorized;
    }
    else if(self.startedLocationServices)
        return LocationStarted;
    else {
        [self setStartedLocationServices:YES];
        return LocationStarted;
    }
}

-(void)stopLocationServices
{
    self.startedLocationServices = NO;
}

- (void)gotSingleLocation:(KLLocationValue*)location
{
    self.latestLocation = [[CLLocation alloc] initWithLatitude:[location fLatitude] longitude:[location fLongitude]];
}

-(void)setStartedLocationServices:(BOOL)startedLocationServices
{
    if (_startedLocationServices != startedLocationServices) {
        _startedLocationServices = startedLocationServices;
        if (startedLocationServices) {
            NSString *kitLocateKey = @"ebeea91e-563e-4b32-acf3-6505d9857789";
            
            [KitLocate initKitLocateWithDelegate:NOTIHANDLER APIKey:kitLocateKey];
            [KLLocation startSingleLocationWithDelegate:self andParams:@{KL_SP_INT_MAX_SECONDS_WAIT:@(4)}];
        }
        else [KitLocate shutKitLocate];
    }
}
-(void)addSound:(NSString*)soundName forNotification:(UILocalNotification**)notifcation{
    if(OSVER > 7){
        UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if ( (currentSettings.types & UIUserNotificationTypeSound) == UIUserNotificationTypeSound ){
            [*notifcation setSoundName:soundName];
        }
    }
    else{
        [*notifcation setSoundName:soundName];
    }
}
-(UILocalNotification*)notificationForDate:(NSDate *)date badgeCounter:(NSInteger)badgeCount title:(NSString *)title userInfo:(NSDictionary*)userInfo{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertAction = NSLocalizedString(@"Open Swipes", nil);
    if(title.length > 80) title = [title substringToIndex:80];
    localNotif.alertBody = title;
    if(badgeCount > 0)
        localNotif.applicationIconBadgeNumber = badgeCount;
    [self addSound:@"swipes-notification.aif"  forNotification:&localNotif];
    localNotif.userInfo = userInfo;
    return localNotif;
}

-(void)updateUpcomingNotifications{
    BOOL weeklyReminders = [[kSettings valueForSetting:SettingWeeklyReminders] boolValue];
    BOOL dailyReminders = [[kSettings valueForSetting:SettingDailyReminders] boolValue];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    for( UILocalNotification *notification in [app scheduledLocalNotifications]){
        NSDictionary *userInfo = notification.userInfo;
        if( [[userInfo objectForKey:@"type"] isEqualToString:@"upcoming"] ){
            [app cancelLocalNotification:notification];
        }
    }
    
    if(!weeklyReminders && !dailyReminders)
        return;
    
    
    __block NSMutableArray *localNotifications = [NSMutableArray array];
    void (^addLocalNotificationBlock)(NSString*, NSDate*, NSString*) = ^void (NSString *title, NSDate *fireDate, NSString *identifier)
    {
        UILocalNotification *notification = [self notificationForDate:fireDate badgeCounter:0 title:title userInfo:@{@"type":@"upcoming",@"identifier": identifier}];
        [localNotifications addObject:notification];
    };
    
    // If a user is neither logged in nor trying out
    if(!kUserHandler.isLoggedIn && !kUserHandler.isTryingOutApp){
        addLocalNotificationBlock(@"You can try Swipes without registration. Plan your day now.",[NSDate dateWithHoursFromNow:24],@"pre-account");
    }
    else{
        NSDate *now = [NSDate date];
        
        NSNumber *dayStart = (NSNumber*)[kSettings valueForSetting:SettingWeekendStartTime];
        NSInteger dayHours = dayStart.integerValue/D_HOUR;
        NSInteger dayMinutes = (dayStart.integerValue % D_HOUR) / D_MINUTE;
        NSNumber *eveningStart = (NSNumber*)[kSettings valueForSetting:SettingEveningStartTime];
        NSInteger eveningHours = eveningStart.integerValue/D_HOUR;
        NSInteger eveningMinutes = (eveningStart.integerValue % D_HOUR) / D_MINUTE;
        NSNumber *weekStart = (NSNumber *)[kSettings valueForSetting:SettingWeekStart];
        NSInteger lastDayBeforeStartOfWeek = (weekStart.integerValue - 1) == 0 ? 7 : weekStart.integerValue-1;
        NSDate *sundayEvening = [NSDate dateThisOrNextWeekWithDay:lastDayBeforeStartOfWeek hours:eveningHours minutes:eveningMinutes];
        NSDate *mondayStart = [NSDate dateThisOrNextWeekWithDay:weekStart.integerValue hours:0 minutes:0];
        NSDate *mondayEnd = [[mondayStart dateByAddingDays:1] dateAtStartOfDay];
        
        NSPredicate *leftForNowPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES)", [NSDate date] ];
        NSPredicate *leftForTodayPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES)", [[NSDate dateTomorrow] dateAtStartOfDay]];
        NSPredicate *tomorrowPredicate = [NSPredicate predicateWithFormat:@"(schedule > %@ AND schedule < %@ AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES)", [[NSDate dateTomorrow] dateAtStartOfDay],[[[NSDate dateTomorrow] dateByAddingDays:1] dateAtStartOfDay]];
        NSPredicate *mondayPredicate = [NSPredicate predicateWithFormat:@"(schedule > %@ AND schedule < %@ AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES)", mondayStart, mondayEnd];
        
        NSInteger numberOfTasksLeftNow = [KPToDo MR_countOfEntitiesWithPredicate:leftForNowPredicate];
        NSInteger numberOfTasksLeftToday = [KPToDo MR_countOfEntitiesWithPredicate:leftForTodayPredicate];
        NSInteger numberOfTasksForTomorrow = [KPToDo MR_countOfEntitiesWithPredicate:tomorrowPredicate];
        NSInteger numberOfTasksForMonday = [KPToDo MR_countOfEntitiesWithPredicate:mondayPredicate];
        
        
        // Check if time is before the evening starts
        if( dailyReminders && numberOfTasksLeftNow > 0 && numberOfTasksLeftNow == numberOfTasksLeftToday){
            NSString *title = [NSString stringWithFormat:@"You have %lu task%@ left for today. Anything important?",(long)numberOfTasksLeftToday, (numberOfTasksLeftToday == 1) ? @"" : @"s" ];
            addLocalNotificationBlock(title,[NSDate dateThisOrTheNextDayWithHours:eveningHours minutes:eveningMinutes],@"remind-remaining-tasks");
        }
        
        // Check whether or not the next morning event is today or tomorrow
        NSDate *dateToCheckForMorning = [NSDate dateTomorrow];
        NSInteger numberToCheckForMorning = numberOfTasksForTomorrow;
        
        // Check whether or not the next morning event is today or tomorrow
        if ( now.hour < dayHours || ( now.hour == dayHours && now.minute < dayMinutes ) ){
            dateToCheckForMorning = [NSDate date];
            numberToCheckForMorning = numberOfTasksLeftToday;
        }
        // Check how many tasks is schedule for the next morning and see if it's a weekday
        if( dailyReminders && numberToCheckForMorning <= 1 && dateToCheckForMorning.isTypicallyWorkday){
            // Notify to make a plan from the morning
            addLocalNotificationBlock(@"Good morning! Start your productive day with a plan.",[dateToCheckForMorning dateAtHours:dayHours minutes:dayMinutes],@"make-a-plan-for-the-day");
        }
        
        // Check
        if( weeklyReminders && numberOfTasksForMonday <= 1 ){
            addLocalNotificationBlock(@"Good evening! Start your productive week with a plan tonight.", sundayEvening, @"weekly-plan-reminder");
        }
        
        
    }
    
    [self scheduleNotifications:localNotifications];
    
    
}

-(UIUserNotificationSettings*)settingsWithCategories{
    UIMutableUserNotificationAction *snoozeAction= [[UIMutableUserNotificationAction alloc] init];
    snoozeAction.identifier = @"Later"; // The id passed when the user selects the action
    snoozeAction.title = NSLocalizedString(@"Later",nil); // The title displayed for the action
    snoozeAction.activationMode = UIUserNotificationActivationModeBackground; // Choose whether the application is launched in foreground when the action is clicked
    snoozeAction.destructive = NO; // If YES, then the action is red
    snoozeAction.authenticationRequired = NO; // Whether the user must authenticate to execute the action
    
    UIMutableUserNotificationAction *completeAction= [[UIMutableUserNotificationAction alloc] init];
    completeAction.identifier = @"Complete"; // The id passed when the user selects the action
    completeAction.title = NSLocalizedString(@"Complete",nil); // The title displayed for the action
    completeAction.activationMode = UIUserNotificationActivationModeBackground; // Choose whether the application is launched in foreground when the action is clicked
    completeAction.destructive = NO; // If YES, then the action is red
    completeAction.authenticationRequired = NO; // Whether the user must authenticate to execute the action
    
    
    UIMutableUserNotificationCategory *oneTaskCategory= [[UIMutableUserNotificationCategory alloc] init];
    oneTaskCategory.identifier = @"OneTaskCategory"; // Identifier passed in the payload
    [oneTaskCategory setActions:@[snoozeAction,completeAction] forContext:UIUserNotificationActionContextDefault]; // The context determines the number of actions presented (see documentation)
    
    UIMutableUserNotificationCategory *batchTasksCategory= [[UIMutableUserNotificationCategory alloc] init];
    batchTasksCategory.identifier = @"BatchTasksCategory"; // Identifier passed in the payload
    [batchTasksCategory setActions:@[snoozeAction] forContext:UIUserNotificationActionContextDefault]; // The context determines the number of actions presented (see documentation)
    
    
    NSSet *categories = [NSSet setWithObjects:oneTaskCategory,batchTasksCategory,nil];
    NSUInteger types = UIUserNotificationTypeNone|UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound; // Add badge, sound, or alerts here
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    return settings;
}

- (BOOL) pushNotificationOnOrOff
{
    if ([UIApplication instancesRespondToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        return ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        return (types & UIRemoteNotificationTypeAlert);
    }
}


-(void)scheduleNotifications:(NSArray*)notifications{
    if(!notifications || notifications.count == 0)
        return;
    UIApplication *app = [UIApplication sharedApplication];
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationSettings *currentSettings = [app currentUserNotificationSettings];
        BOOL userNotifications = NO;
        BOOL remoteNotifications = NO;
        
        if ( (currentSettings.types & UIUserNotificationTypeAlert) != UIUserNotificationTypeAlert && ![USER_DEFAULTS boolForKey:@"hasAddedCategories"]){
            userNotifications = YES;
        }
        
        if([self pushNotificationOnOrOff] && ![USER_DEFAULTS boolForKey:@"hasAddedRemoteNotification"])
            remoteNotifications = YES;
        
        if(userNotifications | remoteNotifications){
            voidBlock registerBlock = ^{
                if(userNotifications){
                    UIUserNotificationSettings *settings = [self settingsWithCategories];
                    [app registerUserNotificationSettings:settings];
                    [Intercom registerForRemoteNotifications];
                    [USER_DEFAULTS setBool:YES forKey:@"hasAddedCategories"];
                    
                }
                if(remoteNotifications){
                    [Intercom registerForRemoteNotifications];
                    [USER_DEFAULTS setBool:YES forKey:@"hasAddedRemoteNotification"];
                }
                
                [USER_DEFAULTS setBool:YES forKey:@"hasAskedNotificationPermissions"];
                [USER_DEFAULTS synchronize];
            };
            
            if(![USER_DEFAULTS boolForKey:@"hasAskedNotificationPermissions"]){
                [UTILITY alertWithTitle:@"Better experience!" andMessage:@"For a better experience we need your permission to send notifications when tasks are due." buttonTitles:@[@"Okay"] block:^(NSInteger number, NSError *error) {
                    registerBlock();
                }];
            }
            else{
                registerBlock();
            }
            if(userNotifications)
                return;
        }
        
        
    }
    for(UILocalNotification *notification in notifications){
        [app scheduleLocalNotification:notification];
    }
}

-(void)updateLocalNotifications{
    /* Check for settings */
    BOOL hasNotificationsOn = [(NSNumber*)[kSettings valueForSetting:SettingNotifications] boolValue];
    [self updateLocationUpdates];
    UIApplication *app = [UIApplication sharedApplication];
    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES)", [NSDate date]];
    NSInteger todayCount = [KPToDo MR_countOfEntitiesWithPredicate:todayPredicate];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationSettings *currentSettings = [app currentUserNotificationSettings];
        if ( (currentSettings.types & UIUserNotificationTypeBadge) == UIUserNotificationTypeBadge ){
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:todayCount];
        }
    }
    else
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:todayCount];
    
    
    if(!hasNotificationsOn){
        [app cancelAllLocalNotifications];
        return;
    }
    
    NSPredicate *schedulePredicate = [NSPredicate predicateWithFormat:@"(schedule > %@) AND completionDate = nil AND isLocallyDeleted <> YES", [NSDate date]];
    
    NSArray *scheduleArray = [KPToDo MR_findAllSortedBy:@"schedule" ascending:YES withPredicate:schedulePredicate];
    
    NSSortDescriptor *scheduleDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"schedule" ascending:YES];
    NSSortDescriptor *priorityDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
    scheduleArray = [scheduleArray sortedArrayUsingDescriptors:@[scheduleDescriptor,priorityDescriptor]];
    
    
    NSInteger scheduleCount = scheduleArray.count;
    NSInteger totalBadgeCount = todayCount;
    NSInteger numberOfScheduledNotificiations = 0;
    NSInteger numberOfNotificationsForDate = 0;
    NSMutableArray *identifierArray = [NSMutableArray array];
    NSMutableArray *notificationsArray = [NSMutableArray array];
    for (NSInteger i = 0 ; i < scheduleCount ; i++) {
        if(i == 35)
            break;
        KPToDo *toDo = [scheduleArray objectAtIndex:i];
        [identifierArray addObject:[toDo getTempId]];
        BOOL isLastObject = (i == MIN(scheduleCount-1,34));
        
        BOOL isNextRelated = NO;
        if(!isLastObject){
            KPToDo *nextToDo = [scheduleArray objectAtIndex:MIN(i+1,scheduleCount)];
            if((toDo.priorityValue < 1) && [nextToDo.schedule isEqualToDate:[toDo schedule]])
                isNextRelated = YES;
        }
        
        totalBadgeCount++;
        numberOfNotificationsForDate++;


        if (!isNextRelated){
            
            NSString *title;
            NSDictionary *userInfo = @{@"type": @"schedule",@"identifiers":identifierArray};
            if (numberOfNotificationsForDate == 1) {
                title = toDo.title;
                //userInfo = @{@"type": @"schedule",@"identifier": [lastTodo getTempId]};
            }
            else {
                title = [NSString stringWithFormat:@"You have %li new tasks.",(long)numberOfNotificationsForDate];
            }
            UILocalNotification *notification = [self notificationForDate:toDo.schedule badgeCounter:totalBadgeCount title:title userInfo:userInfo];
            if(toDo.priorityValue > 0){
                [self addSound:@"Priority notification three repetitions.m4a"  forNotification:&notification];
            }
            if(OSVER >= 8){
                notification.category = (numberOfNotificationsForDate == 1) ? @"OneTaskCategory" : @"BatchTasksCategory";
            }
            [notificationsArray addObject:notification];
            
            
            [identifierArray removeAllObjects];
            numberOfNotificationsForDate = 0;
            numberOfScheduledNotificiations++;
        }
        
        if(numberOfScheduledNotificiations > kMaxNotifications)
            break;
        
        
    }
    [app cancelAllLocalNotifications];
    [self scheduleNotifications:notificationsArray];
}

- (void)updateLocationUpdates
{
    BOOL hasLocationOn = [(NSNumber*)[kSettings valueForSetting:SettingLocation] boolValue];
    if(!hasLocationOn) [self stopLocationServices];
    NSPredicate *locationPredicate = [NSPredicate predicateWithFormat:@"(location != nil) AND isLocallyDeleted <> YES"];
    NSArray *tasksWithLocation = [KPToDo MR_findAllWithPredicate:locationPredicate];
    if(tasksWithLocation && tasksWithLocation.count > 0){
        [KLLocation deleteAllGeofences];
        for(KPToDo *toDo in tasksWithLocation){
            NSArray *location = [toDo.location componentsSeparatedByString:kLocationSplitStr];
            NSString *identifier = [location objectAtIndex:0];
            float latitude = [[location objectAtIndex:2] floatValue];
            float longitude = [[location objectAtIndex:3] floatValue];
            NSString *typeString = [location objectAtIndex:4];
            klGeofenceType type = KL_GEOFENCE_TYPE_IN;
            if ([typeString isEqualToString:@"OUT"])
                type = KL_GEOFENCE_TYPE_OUT;
            KLGeofence *geoFence = [KLGeofence createNewGeofenceWithLatitude:latitude Longitude:longitude PushRadius:kLocationPushRadius Type:type];
            [geoFence setIDUser:identifier];
            [KLLocation addGeofence:geoFence];
        }
        self.fencing = YES;
    }
    else
        self.fencing = NO;
}

-(void)handleGeofences:(NSArray*)arrGeofenceList
{
    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND isLocallyDeleted <> YES)", [NSDate date]];
    NSInteger todayCount = [KPToDo MR_countOfEntitiesWithPredicate:todayPredicate];
    for (KLGeofence *fence in arrGeofenceList) {
        
        NSString *identifier = [[fence getIDUser] stringByAppendingString:kLocationSplitStr];
        NSPredicate *taskPredicate = [NSPredicate predicateWithFormat:@"ANY location BEGINSWITH[c] %@ AND isLocallyDeleted <> YES",identifier];
        KPToDo *toDo = [KPToDo MR_findFirstWithPredicate:taskPredicate];
        if(toDo){
            NSDictionary *userInfo = @{@"type": @"location",@"identifier": [toDo tempId]};
            NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
            UILocalNotification *notification = [self notificationForDate:fireDate badgeCounter:++todayCount title:toDo.title userInfo:userInfo];
            toDo.schedule = fireDate;
            toDo.location = nil;
            if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive){
                [self scheduleNotifications:@[notification]];
            }
            else{
                NSString *title = (fence.getTypeGeofence == KL_GEOFENCE_TYPE_IN) ? @"Arrived at Location" : @"Left Location";
                [UTILITY alertWithTitle:title andMessage:toDo.title];
            }
            [KLLocation deleteGeofenceWithUserID:[fence getIDUser]];
        }
    }
    [KPToDo saveToSync];
    [self updateLocalNotifications];
}

- (void)geofencesIn:(NSArray*)arrGeofenceList
{
    [self handleGeofences:arrGeofenceList];
}

- (void)geofencesOut:(NSArray*)arrGeofenceList
{
    [self handleGeofences:arrGeofenceList];
}

- (void)clearLocalNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

-(void)dealloc{
    clearNotify();
}

@end
