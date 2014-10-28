//
//  UserHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UserHandler.h"
#import <Parse/PFUser.h>
#import "AnalyticsHandler.h"
#import "IntegrationHandler.h"

@interface UserHandler ()
@property (nonatomic) BOOL needRefresh;
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
        //[self save];
        if(!error){
            [self handleUser:(PFUser*)object];
        }
        else NSLog(@"t%@",error);
    }];
}

-(void)save{
    [kCurrent setObject:[kIntHandle getAllIntegrations] forKey:@"integrations"];
    [kCurrent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        DLog(@"save error: %@",error);
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
        [ANALYTICS updateIdentity];
    }
}
-(void)dealloc{
    clearNotify();
}
@end
