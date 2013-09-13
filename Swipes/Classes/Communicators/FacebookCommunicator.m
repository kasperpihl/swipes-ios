//
//  FacebookCommunicator.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import "FacebookCommunicator.h"
#import <Parse/PFFacebookUtils.h>
#import "DEFacebookComposeViewController.h"
#import <Social/Social.h>

@interface FacebookCommunicator () <FBDialogDelegate>
@property (nonatomic,strong) FBRequestConnection *connection;
@property (copy) FacebookRequestBlock block;
@end
@implementation FacebookCommunicator
static FacebookCommunicator *sharedObject;
+(FacebookCommunicator *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[FacebookCommunicator allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(FBRequestConnection *)connection{
    if(!_connection) _connection = [[FBRequestConnection alloc] init];
    return _connection;
}
-(BOOL)handleError:(NSError*)error{
    if(!error) return NO;
    
    return NO;
}
-(void)share:(NSString*)text image:(UIImage*)image url:(NSString*)url inViewController:(UIViewController*)viewController block:(FacebookRequestBlock)completionBlock{
    BOOL isAvailable = ([[UIDevice currentDevice].systemVersion floatValue] >= 6 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]);
    if (isAvailable) {
        SLComposeViewController *shareVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        if(text) [shareVC setInitialText:text];
        if(image) [shareVC addImage:image];
        if(url) [shareVC addURL:[NSURL URLWithString:url]];
        
        [viewController presentModalViewController:shareVC animated:YES];
    }
   
    FacebookRequestBlock internResBlock = ^BOOL(FBReturnType status, id result, NSError *error){
        
        if(!error) [viewController dismissModalViewControllerAnimated:YES];
        BOOL hasHandled = completionBlock(status,result,error);
        return hasHandled;
    };
    DEFacebookComposeViewController *facebookViewComposer = [[DEFacebookComposeViewController alloc] initForceUseCustomController:YES];
    viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    if(text)[facebookViewComposer setInitialText:text forced:NO];
    if(image) [facebookViewComposer addImage:image];
    if(url) [facebookViewComposer addURL:url];
    facebookViewComposer.completionHandler = internResBlock;
    [viewController presentModalViewController:facebookViewComposer animated:YES];
}
-(void)shareToFriend:(NSDictionary*)friend name:(NSString*)name caption:(NSString*)caption description:(NSString*)description imageURLString:(NSString*)imageString link:(NSString*)link block:(FacebookRequestBlock)block{
    
    
    
    self.block = block;
    
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   name,@"name",
                                   [friend objectForKey:@"id"],@"to",
                                   nil];
    
    if(description) [params setObject:description forKey:@"description"];
    if(caption) [params setObject:caption forKey:@"caption"];
    if(imageString) [params setObject:imageString forKey:@"picture"];
    if(link) [params setObject:link forKey:@"link"];
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:[PFFacebookUtils session]
     message:@"Learn how to make your iOS apps social."
     title:@"Test title"
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             NSLog(@"dialog swithError:%@",[error localizedDescription]);
             BOOL hasHandled;
             if(block){
                 hasHandled = block(FBReturnTypeError,nil,error);
             }
             else hasHandled = NO;
             if([self.delegate respondsToSelector:@selector(communicator:requestFailedWithError:hasHandled:)])
                 [self.delegate communicator:self requestFailedWithError:error hasHandled:hasHandled];
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 if(block) block(FBReturnTypeCancelled,nil,nil);
             } else {
                 // Case C: Dialog shown and the user clicks Cancel or Send
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     if(block) block(FBReturnTypeCancelled,nil,nil);
                 } else {
                     if(block) block(FBReturnTypeSuccess,urlParams,nil);
                     if([self.delegate respondsToSelector:@selector(communicator:receivedRequestWithResult:)])
                         [self.delegate communicator:self receivedRequestWithResult:urlParams];
                 }
             }
         }
     }];
}
-(void)addRequest:(FBRequest *)request write:(BOOL)write permissions:(NSArray *)permissions block:(FacebookRequestBlock)block{
    NSArray *approvedPermissions = PFFacebookUtils.session.permissions;
    BOOL updatePermissions = NO;
    if(permissions){
        for(int i = 0 ; i < permissions.count ; i++){
            NSString *permission = [permissions objectAtIndex:i];
            if(![approvedPermissions containsObject:permission]){
                updatePermissions = YES;
            }
        }
    }
    if (updatePermissions && write) {
        if([PFFacebookUtils isLinkedWithUser:kCurrent]){
            [PFFacebookUtils reauthorizeUser:kCurrent  withPublishPermissions:FACEBOOK_WRITE_PERMISSIONS audience:FBSessionDefaultAudienceFriends block:^(BOOL succeeded, NSError *error) {
                if(succeeded) [self runRequest:request block:block];
                else block(FBReturnTypeCancelled, nil,error);
            }];
        }
        else{
            [PFFacebookUtils linkUser:kCurrent permissions:FACEBOOK_WRITE_PERMISSIONS block:^(BOOL succeeded, NSError *error) {
                if(succeeded) [self runRequest:request block:block];
                else block(FBReturnTypeCancelled, nil,error);
            }];
        }
        return;
    }
    else [self runRequest:request block:block];
    
}
-(void)addRequest:(FBRequest *)request index:(NSInteger)index write:(BOOL)write permissions:(NSArray *)permissions block:(FBReqIndexBlock)block{
    [self addRequest:request write:write permissions:permissions block:^BOOL(FBReturnType status, id result, NSError *error) {
        if(block) block(status,index,result,error);
        return NO;
    }];
}
-(void)addRequests:(NSArray*)requests write:(BOOL)write permissions:(NSArray*)permissions block:(ArrayBlock)block{
    __block NSInteger counter = 0;
    __block BOOL hasReturned = NO;
    __block NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:requests.count];
    for(int i = 0 ; i < requests.count ; i++){
        [returnArray insertObject:@"empty" atIndex:i];
        FBRequest *request = [FBRequest requestForGraphPath:[requests objectAtIndex:i]];
        [self addRequest:request index:i write:write permissions:nil block:^(FBReturnType status, NSInteger index, id result, NSError *error) {
            if(error){
                if(!hasReturned) block(nil,error);
                hasReturned = YES;
                return;
            }
            counter++;
            [returnArray replaceObjectAtIndex:index withObject:result];
            if(counter == requests.count && !hasReturned) block(returnArray,nil);
        }];
    }
}
-(void)runRequest:(FBRequest*)request block:(FacebookRequestBlock)block{
    __weak FacebookCommunicator *weakSelf = self;
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        FBReturnType status = error ? FBReturnTypeError : FBReturnTypeSuccess;
        
        BOOL hasHandled = NO;
        if(block) hasHandled = block(status,result,error);
        if(error && [weakSelf.delegate respondsToSelector:@selector(communicator:requestFailedWithError:hasHandled:)]) [weakSelf.delegate communicator:weakSelf requestFailedWithError:error hasHandled:hasHandled];
        else if(result && [weakSelf.delegate respondsToSelector:@selector(communicator:receivedRequestWithResult:)]) [weakSelf.delegate communicator:weakSelf receivedRequestWithResult:result];
        if(error){
            //NSString *errorString = [NSString stringWithFormat:@"iOS Code: %i FBCode: %i Message: %@",error.code,FB_ERROR_CODE,FB_ERROR_MESSAGE];
        }
    }];
}
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *key = [[kv objectAtIndex:0]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:key];
    }
    return params;
}


@end
