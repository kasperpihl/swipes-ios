//
//  SlackWebAPIClient.m
//  Swipes
//
//  Created by demosten on 9/28/15.
//  Copyright © 2015 Swipes Incorporated. All rights reserved.
//

#import "SlackWebAPIClient.h"

#ifndef DLog
    #ifdef DEBUG
    #    define DLog(__FORMAT__, ...) NSLog((@"%s [Line %d]\n" __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
    #else
    #    define DLog(...) /* */
    #endif
#endif

static NSString* const kSlackAPIURL = @"https://slack.com/api/";
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
    }
    return self;
}

- (instancetype)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        self.token = token;
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

- (void)setToken:(NSString *)token
{
    [self reset];
    _token = token;
    // reinit caches and data for the new token
    [self reloadCaches];
}

- (void)reloadCaches
{
    dispatch_async(_workQueue, ^{
        [self authTest];
        [self cacheUsersListWithError:nil];
        [self cacheChannelListWithError:nil];
        [self cacheGroupsWithError:nil];
        [self cacheDirectMessagesWithError:nil];
    });
}

- (BOOL)isDirectMessageId:(NSString *)slackId
{
    return ('D' == [slackId characterAtIndex:0]);
}

- (NSString *)userId
{
    if (nil == _userId && _token) {
        [self authTest];
    }
    return _userId;
}

- (NSString *)userName
{
    if (nil == _userName && _token) {
        [self authTest];
    }
    return _userName;
}

- (NSString *)teamURL
{
    if (nil == _teamURL && _token) {
        [self authTest];
    }
    return _teamURL;
}

- (NSString *)teamName
{
    if (nil == _teamName && _token) {
        [self authTest];
    }
    return _teamName;
}

- (NSString *)teamId
{
    if (nil == _teamId && _token) {
        [self authTest];
    }
    return _teamId;
}

- (NSString *)escapeValueForURLParameter:(NSString *)valueToEscape
{
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) valueToEscape,
                                                                                  NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

- (NSString *)serializeParams:(NSDictionary *)params
{
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in params.keyEnumerator) {
        id value = params[key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            for (NSString *subKey in value) {
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, [self escapeValueForURLParameter:[value objectForKey:subKey]]]];
            }
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *subValue in value) {
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, [self escapeValueForURLParameter:subValue]]];
            }
        }
        else {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self escapeValueForURLParameter:value]]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
    
}

- (NSDictionary *)callWebAPIMethod:(NSString *)method params:(NSDictionary *)params error:(NSError **)errorOut
{
    if (errorOut) {
        *errorOut = nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kSlackAPIURL stringByAppendingString:method]]];
    [request setTimeoutInterval:kTimeoutInterval];
    [request setHTTPMethod:@"POST"];
    NSString* paramsString = params ? [self serializeParams:params] : nil;
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
    }
    return error == nil;
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
