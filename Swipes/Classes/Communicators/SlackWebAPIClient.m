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

static NSTimeInterval const kTimeoutInterval = 35;

@interface SlackWebAPIClient ()

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* teamURL;
@property (nonatomic, strong) NSString* teamName;
@property (nonatomic, strong) NSString* teamId;

@end

@implementation SlackWebAPIClient

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
    }
    return self;
}

- (instancetype)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}

- (void)setToken:(NSString *)token
{
    _token = token;
    _userId = nil;
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
    NSDictionary* res = [self callWebAPIMethod:@"auth.test" params:@{kKeyToken : _token} error:&error];
    if (!error) {
        _teamURL = res[kKeyURL];
        _teamName = res[kKeyTeam];
        _teamId = res[kKeyTeamId];
        _userName = res[kKeyUser];
        _userId = res[kKeyUserId];
    }
    return error == nil;
}

@end
