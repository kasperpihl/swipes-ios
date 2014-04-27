//
//  SettingsHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefWeekStartTime 9
#define kDefWeekendStartTime 10
#define kDefEveningStartTime 19

#define kSettingsDictionaryKey @"SettingsDictionary"

#import "SettingsHandler.h"
#import "NSDate-Utilities.h"
#import "NotificationHandler.h"
#import <Parse/PFQuery.h>
#import <Parse/PFFile.h>
@interface SettingsHandler ()
@property (nonatomic,copy) ImageBlock block;
@property BOOL isFetchingSettings;
@property BOOL isFetchingImage;
@property NSMutableDictionary *settings;
@end
@implementation SettingsHandler
static SettingsHandler *sharedObject;
+(SettingsHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[self allocWithZone:NULL] init];
        [sharedObject initialize];
    }
    return sharedObject;
}
-(NSString*)indexForSettings:(KPSettings)setting{
    NSString *index;
    switch (setting) {
        case SettingLaterToday:
            index = @"SettingLaterToday";
            break;
        case SettingEveningStartTime:
            index = @"SettingEveningStartTime";
            break;
        case SettingWeekStart:
            index = @"SettingWeekStart";
            break;
        case SettingWeekStartTime:
            index = @"SettingWeekStartTime";
            break;
        case SettingWeekendStart:
            index = @"SettingWeekendStart";
            break;
        case SettingWeekendStartTime:
            index = @"SettingWeekendStartTime";
            break;
        case SettingNotifications:
            index = @"SettingNotifications";
            break;
        case SettingLocation:
            index = @"SettingLocation";
    }
    return index;
}
-(UIImage *)getDailyImage{
    NSString *existingFileName = [[NSUserDefaults standardUserDefaults] stringForKey:@"dailyImageFileName"];
    if(existingFileName){
        NSString *fullPath = parseFileCachePath(existingFileName);
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
        {
            NSData *returnData =[NSData dataWithContentsOfFile:fullPath];
            return [UIImage imageWithData:returnData];
        }
    }
    else [self refreshDailyImage:YES];
    return [UIImage imageNamed:@"default-background.jpg"];
}
-(void)refreshDailyImage:(BOOL)force{
    if(self.isFetchingImage) return;
    NSDate *now = [NSDate date];
    NSInteger lastUpdatedDay = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUpdatedDailyImage"];
    if(now.dayOfYear != lastUpdatedDay || force){
        self.isFetchingImage = YES;
        PFQuery *query = [PFQuery queryWithClassName:@"DailyImage"];
        [query whereKey:@"device" equalTo:@"iphone"];
        [query whereKey:@"dayOfYear" equalTo:@(now.dayOfYear)];
        [query whereKey:@"year" equalTo:@(now.year)];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(error || !object){
                if(!object && !error) [[NSUserDefaults standardUserDefaults] setInteger:now.dayOfYear forKey:@"lastUpdatedDailyImage"];
                self.isFetchingImage = NO;
                return;
            }
            PFFile *file = [object objectForKey:@"image"];
            if(!file){ self.isFetchingImage = NO; return; }
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.isFetchingImage = NO;
                if(data){
                    [[NSUserDefaults standardUserDefaults] setObject:file.name forKey:@"dailyImageFileName"];
                    [[NSUserDefaults standardUserDefaults] setInteger:now.dayOfYear forKey:@"lastUpdatedDailyImage"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updated daily image" object:self];
                }
            }];
        }];
    }
}
-(void)refreshGlobalSettingsForce:(BOOL)force{
    [self refreshDailyImage:force];
    if(self.isFetchingSettings) return;
}
-(id)defaultValueForSettings:(KPSettings)setting{
    //NSLog(@"defaultval for:%i",setting);
    switch (setting) {
        case SettingLaterToday:
            return [[NSDate date] dateAtHours:3 minutes:0];
        case SettingWeekStart:
            return [NSDate dateThisOrNextWeekWithDay:2 hours:8 minutes:0];
        case SettingWeekStartTime:
            return [[NSDate date] dateAtHours:kDefWeekStartTime minutes:0];
        case SettingEveningStartTime:
            return [[NSDate date] dateAtHours:kDefEveningStartTime minutes:0];
        case SettingWeekendStart:
            return [NSDate dateThisOrNextWeekWithDay:7 hours:8 minutes:0];
        case SettingWeekendStartTime:
            return [[NSDate date] dateAtHours:kDefWeekendStartTime minutes:0];
        case SettingNotifications:
            return @YES;
        case SettingLocation:
            return @NO;
    }
}
-(id)valueForSetting:(KPSettings)setting{
    NSString *index = [self indexForSettings:setting];
    if(!index) return nil;
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:index];
    if(!value) value = [self defaultValueForSettings:setting];
    return value;
}
-(void)setValue:(id)value forSetting:(KPSettings)setting{
    NSString *index = [self indexForSettings:setting];
    if(!index) return;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:index];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(setting == SettingNotifications)
        [NOTIHANDLER updateLocalNotifications];
}

-(BOOL)settingForKey:(NSString *)key{
    BOOL hasAlreadyCompletedHint = [[self.settings objectForKey:key] boolValue];
    return hasAlreadyCompletedHint;
}
-(void)setSetting:(BOOL)setting forKey:(NSString *)key{
    [self.settings setObject:@(setting) forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:self.settings forKey:kSettingsDictionaryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)initialize{
    self.settings = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsDictionaryKey];
    if(!self.settings)
        self.settings = [NSMutableDictionary dictionary];
    NSLog(@"settings %@",self.settings);
}
@end
