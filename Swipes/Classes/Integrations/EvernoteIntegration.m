//
//  EvernoteIntegration.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "UtilityClass.h"
#import "SettingsHandler.h"
#import "EvernoteIntegration.h"
#define kSwipesTagName @"swipes"



@interface EvernoteIntegration ()
@property BOOL isAuthing;
@end
@implementation EvernoteIntegration
static EvernoteIntegration *sharedObject;
+(EvernoteIntegration *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[EvernoteIntegration allocWithZone:NULL] init];
        [sharedObject initialize];
    }
    return sharedObject;
}
-(void)initialize{
    NSDictionary *currentIntegration = (NSDictionary*)[kSettings valueForSetting:IntegrationEvernote];
    [self loadEvernoteIntegrationObject:currentIntegration];
}
-(void)loadEvernoteIntegrationObject:(NSDictionary *)object{
    self.tagName = [object objectForKey:@"tagName"];
    self.tagGuid = [object objectForKey:@"tagGuid"];
    if(self.tagName || self.tagGuid)
        self.autoFindFromTag = YES;
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



-(void)getSwipesTagGuidBlock:(StringBlock)block{
    @try {
        __block NSString *swipesTagGuid;
        [[EvernoteNoteStore noteStore] listTagsWithSuccess:^(NSArray *tags) {
            for( EDAMTag *tag in tags ){
                if([tag.name isEqualToString:kSwipesTagName]){
                    swipesTagGuid = tag.guid;
                }
            }
            if(!swipesTagGuid){
                [self createSwipesTagBlock:block];
            }
            else block(swipesTagGuid, nil);
        } failure:^(NSError *error) {
            if(error)
                [UtilityClass sendError:error type:@"Evernote Get Tags Error"];
            block(nil, error);
        }];
    }
    @catch (NSException *exception) {
        DLog(@"%@",exception);
        [UtilityClass sendException:exception type:@"Evernote Get Tags Exception"];
        //[UtilityClass sendException:exception type:@"Evernote Update Note Exception"];
    }
}


-(void)createSwipesTagBlock:(StringBlock)block{
    @try {
        EDAMTag *swipesTag = [[EDAMTag alloc] init];
        swipesTag.name = kSwipesTagName;
        [[EvernoteNoteStore noteStore] createTag:swipesTag success:^(EDAMTag *tag) {
            block(swipesTag.guid, nil);
        } failure:^(NSError *error) {
            if(error)
                [UtilityClass sendError:error type:@"Evernote Create Tag Error"];
            block(nil, error);
        }];
    }
    @catch (NSException *exception) {
        DLog(@"%@",exception);
        [UtilityClass sendException:exception type:@"Evernote Create Tag Exception"];
    }
}

-(BOOL)handleError:(NSError*)error{
    if(error.code == 19){
        DLog(@"%@",[error.userInfo objectForKey:@"rateLimitDuration"]);
    }
    return NO;
}

@end
