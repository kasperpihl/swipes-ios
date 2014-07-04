//
//  EvernoteIntegration.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "EvernoteIntegration.h"
@interface EvernoteIntegration ()
@property BOOL isAuthing;
@end
@implementation EvernoteIntegration
static EvernoteIntegration *sharedObject;
+(EvernoteIntegration *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[EvernoteIntegration allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(BOOL)isAuthenticated{
    return [[EvernoteSession sharedSession] isAuthenticated];
}
-(void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block{
    @try {
        EvernoteSession *session = [EvernoteSession sharedSession];
        [session authenticateWithViewController:viewController completionHandler:block];
    }
    @catch (NSException *exception) {
        
    }
    
}
@end
