//
//  FacebookCommunicator.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "FacebookCommunicatorDelegate.h"
#import <Facebook.h>

@class FacebookCommunicator;
@interface FacebookCommunicator : NSObject
@property (weak) NSObject<FacebookCommunicatorDelegate> *delegate;
#define FBC [FacebookCommunicator sharedInstance]
+(FacebookCommunicator*)sharedInstance;
-(void)addRequest:(FBRequest *)request write:(BOOL)write permissions:(NSArray *)permissions block:(FacebookRequestBlock)block;
-(void)addRequests:(NSArray*)requests write:(BOOL)write permissions:(NSArray*)permissions block:(ArrayBlock)block;
-(void)share:(NSString*)text image:(UIImage*)image url:(NSString*)url inViewController:(UIViewController*)viewController block:(FacebookRequestBlock)completionBlock;
-(void)shareToFriend:(NSDictionary*)friend name:(NSString*)name caption:(NSString*)caption description:(NSString*)description imageURLString:(NSString*)imageString link:(NSString*)link block:(FacebookRequestBlock)block;
@end
