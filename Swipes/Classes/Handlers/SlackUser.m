//
//  SlackUser.m
//  Swipes
//
//  Created by demosten on 9/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import "SlackWebAPIClient.h"
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
    return SLACKWEBAPI.token;
}

- (BOOL)isAuthenticated
{
    return SLACKWEBAPI.token != nil;
}

- (NSString *)username
{
    return SLACKWEBAPI.userName;
}

- (NSString *)email
{
    return SLACKWEBAPI.userId;
}

- (NSString *)objectId
{
    if (SLACKWEBAPI.teamId && SLACKWEBAPI.userId)
        return [NSString stringWithFormat:@"%@|%@", SLACKWEBAPI.teamId, SLACKWEBAPI.userId];
    return nil;
}

- (id _Nullable)objectForKey:(NSString * _Nonnull)defaultName
{
    return nil;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    
}

@end
