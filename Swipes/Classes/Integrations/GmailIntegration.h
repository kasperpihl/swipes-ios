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

extern NSString* const kSwipesMailboxLabelName; // label name for Mailbox
extern NSString* const kSwipesLabelName; // label name for normal Gmail integration

@interface GmailIntegration : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign, readonly) BOOL isAuthenticated;
@property (nonatomic, assign, readonly) BOOL isUsingMailbox;
@property (nonatomic, strong) NSString* labelName;

- (NSString *)threadIdToNSString:(NSString *)threadId;
- (NSString *)NSStringToThreadId:(NSString *)string;
- (NSString *)NSStringToEmail:(NSString *)string;

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block;
- (void)logout;

- (void)listThreads:(NSString *)query withBlock:(ThreadListBlock)block;
- (void)getThread:(NSString *)threadId format:(NSString*)format withBlock:(ThreadGetBlock)block;
- (void)removeSwipesLabelFromThreadAndArchive:(NSString *)threadId withBlock:(ErrorBlock)block;
- (void)checkArchievedThread:(NSString *)threadId block:(SuccessfulBlock)block;

@end
