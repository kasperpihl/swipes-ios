//
//  GmailIntegration.h
//  Swipes
//
//  Created by demosten on 1/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLGmail.h"

#define kGmInt [GmailIntegration sharedInstance]

typedef void (^ThreadListBlock)(NSArray *threadListResults, NSError *error);
typedef void (^ThreadGetBlock)(GTLGmailThread *thread, NSError *error);

@interface GmailIntegration : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) BOOL isAuthenticated;

- (NSString *)threadIdToNSString:(NSString *)threadId;
- (NSString *)NSStringToThreadId:(NSString *)string;
- (BOOL)hasNoteWithThreadId:(NSString *)threadId;

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block;
- (void)logout;

- (void)listThreads:(NSString *)query withBlock:(ThreadListBlock)block;
- (void)getThread:(NSString *)threadId withBlock:(ThreadGetBlock)block;

@end
