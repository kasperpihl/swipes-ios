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
    }
    return sharedObject;
}
-(void)setIsPlus:(BOOL)isPlus{
    if(_isPlus != isPlus){
        _isPlus = isPlus;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changed isPlus" object:self];
    }
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
    }
    return string;
}
-(void)setUserLevel:(UserLevel)userLevel{
    if(_userLevel != userLevel){
        _userLevel = userLevel;
    }
    NSString *userLevelString = [self stringForUserLevel:userLevel];
    if(![[ANALYTICS customDimension:kCusDimUserLevel] isEqualToString:userLevelString]){
        [ANALYTICS setCustomDimension:kCusDimUserLevel value:userLevelString];
    }
}
-(void)initialize{
    self.userLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"isPlus"];
    self.isPlus = (self.userLevel > UserLevelStandard);
    notify(@"upgrade userlevel", didUpgradeUser);
    notify(@"opened app", didOpenApp);
    notify(@"logged in", didLoginUser);
}
-(void)didLoginUser{
    [self handleUser:kCurrent];
}
-(void)didOpenApp{
    [kCurrent refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            [self handleUser:(PFUser*)object];
        }
    }];
}
-(void)didUpgradeUser{
    self.isPlus = YES;
}
-(void)handleUser:(PFUser*)user{
    if(user){
        NSInteger userLevel = 0;
        userLevel = [[kCurrent objectForKey:@"userLevel"] integerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:userLevel forKey:@"isPlus"];
        self.userLevel = userLevel;
        self.isPlus = (userLevel > UserLevelStandard);
    }
}
-(void)dealloc{
    clearNotify();
}
@end
