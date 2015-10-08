//
//  SlackWebAPIClient.h
//  Swipes
//
//  Created by demosten on 9/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

//#ifndef DLog
//    #ifdef DEBUG
//    #    define DLog(__FORMAT__, ...) NSLog((@"%s [Line %d]\n" __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//    #else
//    #    define DLog(...) /* */
//    #endif
//#endif
//
//#ifndef USER_DEFAULTS
//#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]
//#endif

extern NSString* const kNotificationUserData;

typedef void (^SlackCallbackBlock)(NSError* error);
typedef void (^SlackCallbackBlockDictionary)(NSDictionary* result, NSError* error);
typedef void (^SlackCallbackBlockString)(NSString* result, NSError* error);

#define SLACKWEBAPI [SlackWebAPIClient sharedInstance]

@interface SlackWebAPIClient : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init;
- (instancetype)initWithToken:(NSString *)token;
- (void)logout;

@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong, readonly) NSString* userId;
@property (nonatomic, strong, readonly) NSString* userName;
@property (nonatomic, strong, readonly) NSString* teamURL;
@property (nonatomic, strong, readonly) NSString* teamName;
@property (nonatomic, strong, readonly) NSString* teamId;

- (BOOL)authTest;

#pragma mark - Async methods

- (void)oauthAccess:(NSString *)clientId clientSecret:(NSString *)clientSecret code:(NSString *)code redirectURI:(NSString *)redirectURI callback:(SlackCallbackBlockDictionary)callback;
- (void)nameFromId:(NSString *)slackId callback:(SlackCallbackBlockString)callback;

@end
