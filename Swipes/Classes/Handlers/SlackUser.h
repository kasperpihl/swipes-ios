//
//  SlackUser.h
//  Swipes
//
//  Created by demosten on 9/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlackUser : NSObject

+ (KP_NULLABLE instancetype)currentUser;

@property (KP_NULLABLE_PROPERTY nonatomic, copy, readonly) NSString *sessionToken;

@property (KP_NULLABLE_PROPERTY nonatomic, strong) NSString *username;

@property (KP_NULLABLE_PROPERTY nonatomic, strong) NSString *email;

@property (KP_NULLABLE_PROPERTY nonatomic, copy, readwrite) NSString *objectId;

@end
