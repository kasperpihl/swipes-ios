//
//  SlackLoginViewController.h
//  Swipes
//
//  Created by demosten on 10/1/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlackWebAPIClient.h"

@interface SlackLoginViewController : UIViewController

- (void)loginWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectURI:(NSString *)redirectURI scope:(NSString *)scope callback:(SlackCallbackBlockDictionary)callback;

@end
