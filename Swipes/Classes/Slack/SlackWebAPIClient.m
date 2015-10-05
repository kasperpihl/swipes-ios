//
//  SlackWebAPIClient.m
//  Swipes
//
//  Created by demosten on 9/28/15.
//  Copyright © 2015 Swipes Incorporated. All rights reserved.
//

#import <SSKeychain/SSKeychain.h>
#import "NSURL+QueryDictionary.h"
#import "SlackWebAPIClient.h"

NSString* const kNotificationUserData = @"slack_user_data";

static NSString* const kSlackAPIURL = @"https://slack.com/api/";

static NSString* const kKeychainAccount = @"swipesteam";
static NSString* const kKeychainService = @"slack_token";

static NSString* const kKeyOk = @"ok";
static NSString* const kKeyError = @"error";
static NSString* const kKeyToken = @"token";
static NSString* const kKeyURL = @"url";
static NSString* const kKeyTeam = @"team";
static NSString* const kKeyTeamId = @"team_id";
static NSString* const kKeyUser = @"user";
static NSString* const kKeyUserId = @"user_id";
static NSString* const kKeyName = @"name";
static NSString* const kKeyId = @"id";
static NSString* const kKeyChannel = @"channel";
static NSString* const kKeyGroup = @"group";

static NSTimeInterval const kTimeoutInterval = 35;

#define SETTINGS_KEY(key) [NSString stringWithFormat:@"slack_%@", key]

@interface SlackWebAPIClient ()

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* teamURL;
@property (nonatomic, strong) NSString* teamName;
@property (nonatomic, strong) NSString* teamId;
@property (nonatomic, strong) NSCache* idCache;

@end

@implementation SlackWebAPIClient {
    dispatch_queue_t _workQueue;
    NSString* _token;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
        if (self.token) {
            [self reloadCaches];
        }
    }
    return self;
}

- (instancetype)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        self.token = token; // reset and reloadCaches are done when setting the token
    }
    return self;
}

- (void)reset
{
    _token = nil;
    _userId = nil;
    _userName = nil;
    _teamId = nil;
    _teamName = nil;
    _teamURL = nil;
    _idCache = [[NSCache alloc] init];
    if (!_workQueue) {
        _workQueue = dispatch_queue_create("SlackWebAPI worker", DISPATCH_QUEUE_SERIAL);
    }
}

- (void)logout
{
    self.token = nil;
    NSUserDefaults* ud = USER_DEFAULTS;
    [ud removeObjectForKey:SETTINGS_KEY(kKeyURL)];
    [ud removeObjectForKey:SETTINGS_KEY(kKeyTeam)];
    [ud removeObjectForKey:SETTINGS_KEY(kKeyTeamId)];
    [ud removeObjectForKey:SETTINGS_KEY(kKeyUser)];
    [ud removeObjectForKey:SETTINGS_KEY(kKeyUserId)];
    [ud synchronize];
}

- (void)setToken:(NSString *)token
{
    [self reset];
    _token = token;
    
    NSError* error;
    if (token) {
        if (![SSKeychain setPassword:token forService:kKeychainService account:kKeychainAccount error:&error]) {
            NSLog(@"Error setting password: %@", error);
        }
        // reinit caches and data for the new token
        [self reloadCaches];
    }
    else {
        if (![SSKeychain deletePasswordForService:kKeychainService account:kKeychainAccount error:&error]) {
            NSLog(@"Error deleting password: %@", error);
        }
    }
}

- (NSString *)token
{
    NSError* error;
    _token = [SSKeychain passwordForService:kKeychainService account:kKeychainAccount error:&error];
    if (error) {
        NSLog(@"Error getting password: %@", error);
    }
    return _token;
}

- (void)reloadCaches
{
    dispatch_async(_workQueue, ^{
        if (_token) {
            [self authTest];
            [self cacheUsersListWithError:nil];
            [self cacheChannelListWithError:nil];
            [self cacheGroupsWithError:nil];
            [self cacheDirectMessagesWithError:nil];
        }
    });
}

- (BOOL)isDirectMessageId:(NSString *)slackId
{
    return ('D' == [slackId characterAtIndex:0]);
}

- (NSString *)userId
{
    if (nil == _userId && _token) {
        _userId = [USER_DEFAULTS objectForKey:SETTINGS_KEY(kKeyUserId)];
        if (nil == _userId)
            [self authTest];
    }
    return _userId;
}

- (NSString *)userName
{
    if (nil == _userName && _token) {
        _userName = [USER_DEFAULTS objectForKey:SETTINGS_KEY(kKeyUser)];
        if (nil == _userName)
            [self authTest];
    }
    return _userName;
}

- (NSString *)teamURL
{
    if (nil == _teamURL && _token) {
        _teamURL = [USER_DEFAULTS objectForKey:SETTINGS_KEY(kKeyURL)];
        if (nil == _teamURL)
            [self authTest];
    }
    return _teamURL;
}

- (NSString *)teamName
{
    if (nil == _teamName && _token) {
        _teamName = [USER_DEFAULTS objectForKey:SETTINGS_KEY(kKeyTeam)];
        if (nil == _teamName)
            [self authTest];
    }
    return _teamName;
}

- (NSString *)teamId
{
    if (nil == _teamId && _token) {
        _teamId = [USER_DEFAULTS objectForKey:SETTINGS_KEY(kKeyTeamId)];
        if (nil == _teamId)
            [self authTest];
    }
    return _teamId;
}

- (NSDictionary *)callWebAPIMethod:(NSString *)method params:(NSDictionary *)params error:(NSError **)errorOut
{
    if (errorOut) {
        *errorOut = nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kSlackAPIURL stringByAppendingString:method]]];
    [request setTimeoutInterval:kTimeoutInterval];
    [request setHTTPMethod:@"POST"];
    NSString* paramsString = params ? [params uq_URLQueryString] : nil;
    [request setHTTPBody:[paramsString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *response;
    NSError* error;
    NSData *resData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (200 != response.statusCode || error){
        DLog(@"status code: %li error %@", (long)response.statusCode, error);
        if (error){
            NSLog(@"error: %@", error);
            if (errorOut)
                *errorOut = error;
        }
        return nil;
    }
    
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingAllowFragments error:&error];
    if (!result || error) {
        if (error){
            NSLog(@"error: %@", error);
            if (errorOut)
                *errorOut = error;
        }
        return nil;
    }
    NSNumber* isOk = result[kKeyOk];
    if (isOk && (NO == isOk.boolValue)) {
        *errorOut = [NSError errorWithDomain:result[kKeyError] code:1 userInfo:result];
        return nil;
    }
    
    return result;
}

- (BOOL)testCall
{
    NSError* error;
    NSDictionary* res = [self callWebAPIMethod:@"api.test" params:@{@"error" : @"some error", @"foo" : @"some bar"} error:&error];
    DLog(@"result: %@, error: %@", res, error);

    res = [self callWebAPIMethod:@"api.test" params:@{@"foo" : @"some bar"} error:&error];
    DLog(@"result: %@, error: %@", res, error);
    
    return error || (nil == res) ? NO : YES;
}

- (NSString *)settingsKeyForKey:(NSString *)key
{
    return [NSString stringWithFormat:@"slack_%@", key];
}

- (BOOL)authTest
{
    if (!_token)
        return NO;
    NSError* error;
    NSDictionary* res = [self callWebAPIMethod:@"auth.test" params:@{kKeyToken: _token} error:&error];
    if (!error) {
        _teamURL = res[kKeyURL];
        _teamName = res[kKeyTeam];
        _teamId = res[kKeyTeamId];
        _userName = res[kKeyUser];
        _userId = res[kKeyUserId];
        NSUserDefaults* ud = USER_DEFAULTS;
        [ud setObject:_teamURL forKey:SETTINGS_KEY(kKeyURL)];
        [ud setObject:_teamName forKey:SETTINGS_KEY(kKeyTeam)];
        [ud setObject:_teamId forKey:SETTINGS_KEY(kKeyTeamId)];
        [ud setObject:_userName forKey:SETTINGS_KEY(kKeyUser)];
        [ud setObject:_userId forKey:SETTINGS_KEY(kKeyUserId)];
        [ud synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationUserData object:nil]];
        });
    }
    return error == nil;
}

- (void)oauthAccess:(NSString *)clientId clientSecret:(NSString *)clientSecret code:(NSString *)code redirectURI:(NSString *)redirectURI callback:(SlackCallbackBlockDictionary)callback
{
    dispatch_queue_t currentQueue = [NSOperationQueue currentQueue].underlyingQueue;
    dispatch_async(_workQueue, ^{
        NSError* error;
        NSDictionary* res = [self callWebAPIMethod:@"oauth.access"
                                            params:@{@"client_id": clientId, @"client_secret": clientSecret, @"code": code, @"redirect_uri": redirectURI}
                                             error:&error];
        dispatch_async(currentQueue, ^{
            callback(res, error);
        });
    });
    
}

- (NSString *)userNameFromUserId:(NSString *)userId error:(NSError **)error
{
    if (!userId) {
        if (error)
            *error = [NSError errorWithDomain:@"userId cannot be nil" code:1 userInfo:nil];
        return nil;
    }
    
    *error = nil;
    NSDictionary* res = [_idCache objectForKey:userId];
    if (!res) {
        res = [self callWebAPIMethod:@"users.info" params:@{kKeyToken: _token, kKeyUser: userId} error:error];
        if (!*error) {
            [_idCache setObject:res[kKeyUser] forKey:userId];
        }
        else {
            return nil;
        }
    }
    return res[kKeyName];
}

- (NSString *)channelNameFromChannelId:(NSString *)channelId error:(NSError **)error
{
    if (!channelId) {
        if (error)
            *error = [NSError errorWithDomain:@"channelId cannot be nil" code:1 userInfo:nil];
        return nil;
    }
    
    *error = nil;
    NSDictionary* res = [_idCache objectForKey:channelId];
    if (!res) {
        res = [self callWebAPIMethod:@"channels.info" params:@{kKeyToken: _token, kKeyChannel: channelId} error:error];
        if (!*error) {
            [_idCache setObject:res[kKeyChannel] forKey:channelId];
        }
        else {
            return nil;
        }
    }
    return res[kKeyName];
}

- (NSString *)groupNameFromGroupId:(NSString *)groupId error:(NSError **)error
{
    if (!groupId) {
        if (error)
            *error = [NSError errorWithDomain:@"groupId cannot be nil" code:1 userInfo:nil];
        return nil;
    }
    
    *error = nil;
    NSDictionary* res = [_idCache objectForKey:groupId];
    if (!res) {
        res = [self callWebAPIMethod:@"groups.info" params:@{kKeyToken: _token, kKeyGroup: groupId} error:error];
        if (!*error) {
            [_idCache setObject:res[kKeyGroup] forKey:groupId];
        }
        else {
            return nil;
        }
    }
    return res[kKeyName];
}

- (void)cacheUsersListWithError:(NSError **)error
{
    __autoreleasing NSError* myError;
    if (error)
        *error = nil;
    else
        error = &myError;

    NSDictionary* res = [self callWebAPIMethod:@"users.list" params:@{kKeyToken: _token} error:error];
    if (!*error) {
        NSArray* members = res[@"members"];
        for (NSDictionary* member in members) {
            NSString* userId = member[kKeyId];
            if (userId) {
                [_idCache setObject:member forKey:userId];
            }
        }
    }
}

- (void)cacheChannelListWithError:(NSError **)error
{
    __autoreleasing NSError* myError;
    if (error)
        *error = nil;
    else
        error = &myError;

    NSDictionary* res = [self callWebAPIMethod:@"channels.list" params:@{kKeyToken: _token} error:error];
    if (!*error) {
        NSArray* channels = res[@"channels"];
        for (NSDictionary* channel in channels) {
            NSString* channelId = channel[kKeyId];
            if (channelId) {
                [_idCache setObject:channel forKey:channelId];
            }
        }
    }
}

- (void)cacheGroupsWithError:(NSError **)error
{
    __autoreleasing NSError* myError;
    if (error)
        *error = nil;
    else
        error = &myError;
    
    NSDictionary* res = [self callWebAPIMethod:@"groups.list" params:@{kKeyToken: _token} error:error];
    if (!*error) {
        NSArray* groups = res[@"groups"];
        for (NSDictionary* group in groups) {
            NSString* groupId = group[kKeyId];
            if (groupId) {
                [_idCache setObject:group forKey:groupId];
            }
        }
    }
}

- (void)cacheDirectMessagesWithError:(NSError **)error
{
    __autoreleasing NSError* myError;
    if (error)
        *error = nil;
    else
        error = &myError;
    
    NSDictionary* res = [self callWebAPIMethod:@"im.list" params:@{kKeyToken: _token} error:error];
    if (!*error) {
        NSArray* ims = res[@"ims"];
        for (NSDictionary* im in ims) {
            NSString* imId = im[kKeyId];
            if (imId) {
                [_idCache setObject:im forKey:imId];
            }
        }
    }
}

- (void)nameFromId:(NSString *)slackId callback:(SlackCallbackBlockString)callback
{
    if (!slackId || 0 == slackId.length) {
        NSError* error = [NSError errorWithDomain:@"slackId cannot be nil or empty" code:3 userInfo:nil];
        callback(nil, error);
        return;
    }
    dispatch_queue_t currentQueue = [NSOperationQueue currentQueue].underlyingQueue;
    dispatch_async(_workQueue, ^{
        NSError* error;
        NSDictionary* res = [_idCache objectForKey:slackId];
        if (nil == res) {
            // not in cache (might be new)
            unichar firstLetter = [slackId characterAtIndex:0];
            NSString* strRes;
            switch (firstLetter) {
                case 'U': // user
                    strRes = [self userNameFromUserId:slackId error:&error];
                    break;
                
                case 'D':
                    [self cacheDirectMessagesWithError:&error];
                    res = [_idCache objectForKey:slackId];
                    if (nil != res) {
                        NSString* userId = res[kKeyUser];
                        strRes = [self userNameFromUserId:userId error:&error];
                    }
                    else {
                        error = [NSError errorWithDomain:[NSString stringWithFormat:@"cannot find IM with id: %@", slackId] code:4 userInfo:nil];
                    }
                    break;
                
                case 'G':
                    strRes = [self groupNameFromGroupId:slackId error:&error];
                    break;
                
                case 'C':
                    strRes = [self channelNameFromChannelId:slackId error:&error];
                    break;
                    
                default:
                    error = [NSError errorWithDomain:[NSString stringWithFormat:@"invalid slack id: %@", slackId] code:2 userInfo:nil];
            }
            
            dispatch_async(currentQueue, ^{
                callback(strRes, error);
            });
        }
        else {
            // found in cache :)
            if ([self isDirectMessageId:slackId]) {
                // now process a direct message
                NSString* strRes = [self userNameFromUserId:res[kKeyUser] error:&error];
                dispatch_async(currentQueue, ^{
                    callback(strRes, error);
                });
            }
            else {
                // just return name
                dispatch_async(currentQueue, ^{
                    callback(res[kKeyName], error);
                });
            }
        }
    });
}


@end
