//
//  RootViewController2.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 25/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#define SIDE_MENU_WIDTH 250
#import <UIKit/UIKit.h>

#define ROOT_CONTROLLER [RootViewController sharedInstance]
#define ERROR_MESSAGE [[error userInfo] objectForKey:@"error"]
#define FB_ERROR_CODE [error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"code"] integerValue]
#define FB_ERROR_MESSAGE error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"message"]

@interface RootViewController : UINavigationController
+(RootViewController*)sharedInstance;
@end
