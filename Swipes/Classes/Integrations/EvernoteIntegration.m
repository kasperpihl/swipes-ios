//
//  EvernoteIntegration.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "UtilityClass.h"
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
-(void)loadEvernoteIntegrationObject:(NSDictionary *)object{
    self.tagName = [object objectForKey:@"tagName"];
    self.tagGuid = [object objectForKey:@"tagGuid"];
}
-(BOOL)isAuthenticated{
    return [[EvernoteSession sharedSession] isAuthenticated];
}
-(void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block{
    @try {
        EvernoteSession *session = [EvernoteSession sharedSession];
        [session authenticateWithViewController:viewController completionHandler:^(NSError *error) {
            if(error)
                [UtilityClass sendError:error type:@"Evernote Auth Error"];
            block(error);
        }];
    }
    @catch (NSException *exception) {
        [UtilityClass sendException:exception type:@"Evernote Auth Exception"];
    }
    
}
@end
