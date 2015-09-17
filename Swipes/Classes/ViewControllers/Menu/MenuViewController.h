//
//  MenuViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSettingsBlurColor retColor(gray(230, 0.5),gray(50, 0.4))
typedef NS_ENUM(NSUInteger, KPMenuButtons){
    KPMenuButtonSettings = 1,
    KPMenuButtonScheme,
    //KPMenuButtonUpgrade,
    //KPMenuButtonSnoozes,
    KPMenuButtonHelp,
    //KPMenuButtonIntegrations,
    KPMenuButtonLogout,
    KPMenuButtonSync,
    //KPMenuButtonLocation,
};
@interface MenuViewController : UIViewController
-(void)renderSubviews;
-(void)reset;
@end
