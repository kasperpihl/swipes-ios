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
    localNotif.alertBody = [NSString stringWithFormat:@"Good morning. You have %i new %@ today.",numberOfTasks,taskString];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"schedule",@"type",[NSNumber numberWithInteger:numberOfTasks],@"number",nil];
    localNotif.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}
-(void)scheduleDate:(NSDate *)date identifier:(NSString*)identifier title:(NSString *)title{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *notifications = [app scheduledLocalNotifications];
    BOOL foundNew = NO;
    for(UILocalNotification *localNotification in notifications){
        UILocalNotification *oldNotification, *newNotification;
        if(![[localNotification.userInfo objectForKey:@"type"] isEqualToString:@"schedule"]) continue;
        NSMutableDictionary *mutableUserInfoCopy = [localNotification.userInfo mutableCopy];
        NSArray *objectsInNotification = [mutableUserInfoCopy objectForKey:@"identifiers"];
        if(objectsInNotification && [objectsInNotification containsObject:identifier]){
            oldNotification = localNotification;
        }
        if(date && [localNotification.fireDate isEqualToDate:date]){
            newNotification = localNotification;
            foundNew = YES;
        }
        if(oldNotification || newNotification){
            NSArray *newIdentifiers;
            NSInteger counter = objectsInNotification.count;
            if(!newNotification){
                [app cancelLocalNotification:oldNotification];
                if(counter > 1){
                    NSMutableArray *mutableIdentifiers = [objectsInNotification mutableCopy];
                    [mutableIdentifiers removeObject:identifier];
                    newIdentifiers = [mutableIdentifiers copy];
                    [mutableUserInfoCopy setObject:newIdentifiers forKey:@"identifiers"];
                    [oldNotification setUserInfo:[mutableUserInfoCopy copy]];
                    NSString *notificationTitle;
                    if(newIdentifiers.count == 1){
                        NSString *lastObjectIdentifier = [newIdentifiers lastObject];
                        NSManagedObjectID *managedObjectID = [[NSPersistentStoreCoordinator MR_defaultStoreCoordinator] managedObjectIDForURIRepresentation:[NSURL URLWithString:lastObjectIdentifier]];
                        NSError *error;
                        KPToDo *remainingObject = (KPToDo*)[[NSManagedObjectContext MR_defaultContext] existingObjectWithID:managedObjectID error:&error];
                        if(error) NSLog(@"error %@",error);
                        else{
                            notificationTitle = (remainingObject.title.length > 80) ? [remainingObject.title substringToIndex:80] : remainingObject.title;
                        }
                    }
                    else{
                        notificationTitle = [NSString stringWithFormat:@"You have %i new tasks.",newIdentifiers.count];
                    }
                    oldNotification.alertBody = notificationTitle;
                    [app scheduleLocalNotification:oldNotification];
                }
            }
            else if(!oldNotification){
                [app cancelLocalNotification:newNotification];
                newIdentifiers = [objectsInNotification arrayByAddingObject:identifier];
                [mutableUserInfoCopy setObject:newIdentifiers forKey:@"identifiers"];
                [newNotification setUserInfo:[mutableUserInfoCopy copy]];
                newNotification.alertBody = [NSString stringWithFormat:@"You have %i new tasks.",newIdentifiers.count];
                
                [app scheduleLocalNotification:newNotification];
            }
        }
        
    }
    /* If no notification is found, create a new for the task */
    if(!foundNew && date){
        [self newNotificationDate:date title:title identifier:identifier];
    }
}
-(void)newNotificationDate:(NSDate *)date title:(NSString*)title identifier:(NSString*)identifier{
    NSArray *identifiers = @[identifier];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertAction = NSLocalizedString(@"Open Swipes", nil);
    if(title.length > 80) title = [title substringToIndex:80];
    localNotif.alertBody = title;
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"schedule",@"type",identifiers,@"identifiers",nil];
    localNotif.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}
@end
