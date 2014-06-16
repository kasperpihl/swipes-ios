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

#import "CWStatusBarNotification.h"

#define kMaxNotifications 25
@interface NotificationHandler () <KitLocateSingleDelegate>
@property (nonatomic) BOOL fencing;
@property (nonatomic) BOOL startedLocationServices;
@property (nonatomic) CWStatusBarNotification *notification;
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
    NSLog(@"initializing");
    notify(@"showNotification", sendNotification:);
}

-(void)sendNotification:(NSNotification*)notification{
    if(OSVER < 7) return;
    if(!self.notification){
        self.notification = [CWStatusBarNotification new];
        self.notification.notificationTappedBlock = nil;
        self.notification.notificationAnimationType = CWNotificationAnimationTypeOverlay;
        self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    }
    self.notification.notificationLabelBackgroundColor = tcolor(BackgroundColor);
    self.notification.notificationLabelTextColor = tcolor(TextColor);
    NSLog(@"notif %@",notification.userInfo);
    NSDictionary *userInfo = notification.userInfo;
    NSString *title = [userInfo objectForKey:@"title"];
    CGFloat duration = [[userInfo objectForKey:@"duration"] floatValue];
    if( duration ){
        [self.notification displayNotificationWithMessage:title forDuration:duration];
        NSLog(@"had duration: %f", duration);
    }else
        [self.notification displayNotificationWithMessage:title completion:nil];
}


-(CLLocation *)latestLocation
{
    if (!_latestLocation) {
        CGFloat latitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"latestLocationLatitude"];
        CGFloat longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"latestLocationLongitude"];
        if (latitude && longitude)
            _latestLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    }
    return _latestLocation;
}

-(void)setLatestLocation:(CLLocation *)latestLocation
{
    _latestLocation = latestLocation;
    [[NSUserDefaults standardUserDefaults] setFloat:latestLocation.coordinate.latitude forKey:@"latestLocationLatitude"];
    [[NSUserDefaults standardUserDefaults] setFloat:latestLocation.coordinate.longitude forKey:@"latestLocationLongitude"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Permissions" message:@"You need to turn on location permissions for Swipes in Settings > Privacy" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
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
-(UILocalNotification*)notificationForDate:(NSDate *)date badgeCounter:(NSInteger)badgeCount title:(NSString *)title userInfo:(NSDictionary*)userInfo{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertAction = NSLocalizedString(@"Open Swipes", nil);
    if(title.length > 80) title = [title substringToIndex:80];
    localNotif.alertBody = title;
    localNotif.applicationIconBadgeNumber = badgeCount;
    localNotif.soundName = @"swipes-notification.aif";
    localNotif.userInfo = userInfo;
    return localNotif;
}
-(void)updateLocalNotifications{
    /* Check for settings */
    BOOL hasNotificationsOn = [(NSNumber*)[kSettings valueForSetting:SettingNotifications] boolValue];
    [self updateLocationUpdates];
    UIApplication *app = [UIApplication sharedApplication];
    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil)", [NSDate date]];
    NSInteger todayCount = [KPToDo MR_countOfEntitiesWithPredicate:todayPredicate];
#warning iOS 8 remove
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:todayCount];
    /**
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    if ( notificationSettings.types == UIUserNotificationTypeBadge )
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:todayCount];
    else
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    */
    
    
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
    for (NSInteger i = 0 ; i < scheduleCount ; i++) {
        KPToDo *toDo = [scheduleArray objectAtIndex:i];
        
        BOOL isLastObject = (i == scheduleCount-1);
        if (!currentDate)
            currentDate = toDo.schedule;
        NSInteger numberOfNotificationsToAdd = [toDo.schedule isEqualToDate:currentDate] ? 0 : 1;
        if (isLastObject)
            numberOfNotificationsToAdd++;
        
        while (numberOfNotificationsToAdd > 0){
            if(numberOfNotificationsToAdd == 1 && isLastObject){
                currentDate = toDo.schedule;
                totalBadgeCount++;
                numberOfNotificationsForDate++;
                lastTodo = toDo;
            }
            NSString *title;
            NSDictionary *userInfo;
            if (numberOfNotificationsForDate == 1) {
                title = lastTodo.title;
                userInfo = @{@"type": @"schedule",@"identifier": [[lastTodo.objectID URIRepresentation] absoluteString]};
            }
            else {
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
        
        if(numberOfDates > kMaxNotifications)
            break;
        
        totalBadgeCount++;
        numberOfNotificationsForDate++;
        
        lastTodo = toDo;
    }
    [app cancelAllLocalNotifications];
    for(UILocalNotification *notification in notificationsArray){
        [app scheduleLocalNotification:notification];
    }
}

- (void)updateLocationUpdates
{
    BOOL hasLocationOn = [(NSNumber*)[kSettings valueForSetting:SettingLocation] boolValue];
    if(!hasLocationOn) [self stopLocationServices];
    NSPredicate *locationPredicate = [NSPredicate predicateWithFormat:@"(location != nil)"];
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
    UIApplication *app = [UIApplication sharedApplication];
    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil)", [NSDate date]];
    NSInteger todayCount = [KPToDo MR_countOfEntitiesWithPredicate:todayPredicate];
    NSLog(@"got location :%@",arrGeofenceList);
    for (KLGeofence *fence in arrGeofenceList) {
        
        NSString *identifier = [[fence getIDUser] stringByAppendingString:kLocationSplitStr];
        NSPredicate *taskPredicate = [NSPredicate predicateWithFormat:@"ANY location BEGINSWITH[c] %@",identifier];
        KPToDo *toDo = [KPToDo MR_findFirstWithPredicate:taskPredicate];
        if(toDo){
            NSDictionary *userInfo = @{@"type": @"location",@"identifier": [[toDo.objectID URIRepresentation] absoluteString]};
            NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
            UILocalNotification *notification = [self notificationForDate:fireDate badgeCounter:++todayCount title:toDo.title userInfo:userInfo];
            toDo.schedule = fireDate;
            toDo.location = nil;
            if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive){
                [app scheduleLocalNotification:notification];
            }
            else{
                NSString *title = (fence.getTypeGeofence == KL_GEOFENCE_TYPE_IN) ? @"Arrived at Location" : @"Left Location";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:toDo.title delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alert show];
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

-(void)dealloc{
    clearNotify();
}

@end
