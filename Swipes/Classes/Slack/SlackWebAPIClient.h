//
//  SlackWebAPIClient.h
//  Swipes
//
//  Created by demosten on 9/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SlackCallbackBlock)(NSError* error);
typedef void (^SlackCallbackBlockDictionary)(NSDictionary* result, NSError* error);
typedef void (^SlackCallbackBlockString)(NSString* result, NSError* error);

#define SLACKWEBAPI [SlackWebAPIClient sharedInstance]

@interface SlackWebAPIClient : NSObject

+ (instancetype)sharedInstance;
+ (NSString *)escapeValueForURLParameter:(NSString *)valueToEscape;
+ (NSString *)unescapeValueForURLParameter:(NSString *)valueToUnescape;
+ (NSString *)serializeParams:(NSDictionary *)params;

- (instancetype)init;
- (instancetype)initWithToken:(NSString *)token;

@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong, readonly) NSString* userId;
@property (nonatomic, strong, readonly) NSString* userName;
@property (nonatomic, strong, readonly) NSString* teamURL;
@property (nonatomic, strong, readonly) NSString* teamName;
@property (nonatomic, strong, readonly) NSString* teamId;

- (BOOL)testCall;

- (BOOL)authTest;

#pragma mark - Async methods

- (void)oauthAccess:(NSString *)clientId clientSecret:(NSString *)clientSecret code:(NSString *)code redirectURI:(NSString *)redirectURI callback:(SlackCallbackBlockDictionary)callback;
- (void)nameFromId:(NSString *)slackId callback:(SlackCallbackBlockString)callback;

@end
