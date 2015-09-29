//
//  SlackUser.m
//  Swipes
//
//  Created by demosten on 9/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import "SlackUser.h"

static SlackUser* g_currentUser;

@implementation SlackUser

+ (void)initialize
{
}

+ (KP_NULLABLE instancetype)currentUser
{
    if (!g_currentUser) {
        g_currentUser = [SlackUser new];
    }
    return g_currentUser;
}

- (NSString *)sessionToken
{
    return @"xoxp-2345135970-2886072657-9831874343-485880";
}

- (BOOL)isAuthenticated
{
    return YES;
}

- (NSString *)username
{
    return @"some user";
}

- (NSString *)email
{
    return @"change_me@host.com";
}

- (NSString *)objectId
{
    return @"U02A53ZUL";
}

- (id _Nullable)objectForKey:(NSString * _Nonnull)defaultName
{
    return nil;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    
}

@end
