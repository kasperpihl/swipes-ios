//
//  KPOverlay.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define OVERLAY [KPOverlay sharedInstance]
@class KPOverlay;

@interface KPOverlay : UIViewController
// Show the menu
+ (KPOverlay*)sharedInstance;
-(void)pushView:(UIView*)view animated:(BOOL)animated;
-(void)popViewAnimated:(BOOL)animated;
-(void)popAllViewsAnimated:(BOOL)animated;
@end
