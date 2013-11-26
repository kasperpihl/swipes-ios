//
//  UserHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
typedef NS_ENUM(NSUInteger, UserLevel) {
    UserLevelStandard,
    UserLevelTrial,
    UserLevelPlusMonthly,
    UserLevelPlusYearly
};
#import <Foundation/Foundation.h>
#define kUserHandler [UserHandler sharedInstance]
@interface UserHandler : NSObject
+(UserHandler*)sharedInstance;
@property (nonatomic) BOOL isPlus;
@end
