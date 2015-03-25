//
//  UserHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UserHandler.h"
#import <Parse/PFUser.h>
#import "PFFacebookUtils.h"
#import "AnalyticsHandler.h"
#import "IntegrationHandler.h"
#import "SettingsHandler.h"
#import "UtilityClass.h"

@interface UserHandler ()
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL needSave;
@property (nonatomic) BOOL isSaving;
@property (nonatomic) UserLevel userLevel;
@end
@implementation UserHandler
static UserHandler *sharedObject;
+(UserHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[UserHandler allocWithZone:NULL] init];
        [sharedObject initialize];
        [sharedObject handleUser:kCurrent];
    }
    return sharedObject;
}
-(BOOL)isLoggedIn{
    return (kCurrent) ? YES : NO;
}
-(void)setIsPlus:(BOOL)isPlus{
    if(_isPlus != isPlus){
        _isPlus = isPlus;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changed isPlus" object:self];
    }
}
-(BOOL)isTryingOutApp{
    return [USER_DEFAULTS boolForKey:isTryingString];
}
-(NSString *)stringForUserLevel:(UserLevel)userLevel{
    NSString *string;
    switch (userLevel) {
        case UserLevelStandard:
            string = @"Standard";
            break;
        case UserLevelTrial:
            string = @"Trial";
            break;
        case UserLevelPlusMonthly:
            string = @"Plus Monthly";
            break;
        case UserLevelPlusYearly:
            string = @"Plus Yearly";
            break;
        case UserLevelAdmin:
            string = @"Admin";
            break;
        default:
            string = @"Unknown";
            break;
    }
    return string;
}
-(void)setUserLevel:(UserLevel)userLevel{
    if(_userLevel != userLevel){
        _userLevel = userLevel;
    }
}
-(void)initialize{
    self.userLevel = [USER_DEFAULTS integerForKey:@"isPlus"];
    self.isPlus = (self.userLevel > UserLevelStandard);
    notify(@"upgrade userlevel", didUpgradeUser);
    notify(@"opened app", didOpenApp);
    notify(@"logged in", didLoginUser);
}
-(void)didLoginUser{
    [self handleUser:kCurrent];
}
-(void)didLogout{
    self.isPlus = NO;
    self.userLevel = 0;
    self.isLoggedIn = NO;
    self.needRefresh = NO;
}
-(NSString*)getUserLevelString{
    return [self stringForUserLevel:self.userLevel];
}
-(void)didOpenApp{
    if(!kCurrent)
        return;
    [kCurrent fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            [self handleUser:(PFUser*)object];
        }
        else NSLog(@"t%@",error);
    }];
}
-(NSString *)emailOrFacebookString{
    NSString *email = @"User: ";
    if([UtilityClass validateEmail:kCurrent.username]){
        email = [email stringByAppendingString:kCurrent.username];
    }
    if([PFFacebookUtils isLinkedWithUser:kCurrent]){
        email = [email stringByAppendingString:@" (Facebook)"];
    }
    return email;
}
-(void)saveSettings:(NSDictionary *)settings{
    if(settings)
        [kCurrent setObject:settings forKey:@"settings"];
    if(self.isSaving){
        self.needSave = YES;
        return;
    }
    self.isSaving = YES;
    [kCurrent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isSaving = NO;
        if(self.needSave){
            self.needSave = NO;
            [self saveSettings:nil];
        }
        else if(error)
            [kCurrent saveEventually];
    }];
}

-(void)didUpgradeUser{
    self.isPlus = YES;
}
-(void)handleUser:(PFUser*)user{
    if(user){
        NSInteger userLevel = 0;
        userLevel = [[kCurrent objectForKey:@"userLevel"] integerValue];
        [USER_DEFAULTS setInteger:userLevel forKey:@"isPlus"];
        [USER_DEFAULTS synchronize];
        self.userLevel = userLevel;
        self.isPlus = (userLevel > UserLevelStandard);
        [ANALYTICS checkForUpdatesOnIdentity];
        NSDictionary *settings = [user objectForKey:@"settings"];
        [kSettings updateSettingsFromServer:settings];
    }
}
-(void)dealloc{
    clearNotify();
}
@end
