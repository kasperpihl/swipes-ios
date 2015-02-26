//
//  IntegrationsViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntegrationBaseViewController.h"

typedef NS_ENUM(NSUInteger, Integrations) {
    kMailboxIntegration,
    kEvernoteIntegration
};

@interface IntegrationsViewController : IntegrationBaseViewController

@end
