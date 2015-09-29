//
//  SlackWebAPIClient.h
//  Swipes
//
//  Created by demosten on 9/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SlackCallbackBlock)(NSDictionary* result);

@interface SlackWebAPIClient : NSObject

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

@end
