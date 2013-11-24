//
//  UserHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UserHandler.h"
#import <Parse/PFUser.h>
@implementation UserHandler
static UserHandler *sharedObject;
+(UserHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[UserHandler allocWithZone:NULL] init];
        [sharedObject initialize];
    }
    return sharedObject;
}
-(void)initialize{
    if(kCurrent && [kCurrent objectForKey:@"userLevel"]){
        NSInteger userLevel = [[kCurrent objectForKey:@"userLevel"] integerValue];
        if(userLevel > 0) self.isPlus = YES;
    }
}
@end
