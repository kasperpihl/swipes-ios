//
//  UserHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
typedef NS_ENUM(NSUInteger, UserLevel) {
    UserLevelStandard = 0,
    UserLevelTrial = 1,
    UserLevelPlusMonthly = 2,
    UserLevelPlusYearly = 3,
    UserLevelAdmin = 5
};
#import <Foundation/Foundation.h>
#define kUserHandler [UserHandler sharedInstance]
@interface UserHandler : NSObject
+(UserHandler*)sharedInstance;
-(NSString*)getUserLevelString;
-(void)didLogout;
@property (nonatomic) BOOL isPlus;
@property (nonatomic) BOOL isLoggedIn;
@end
