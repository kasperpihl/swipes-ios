//
//  TopMenu.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSideButtonsWidth 60
#define kTopY 20
typedef enum {
    TopMenuTop,
    TopMenuBottom,
} TopMenuPosition;
@class TopMenu;
@protocol TopMenuDelegate <NSObject>
-(void)topMenu:(TopMenu*)topMenu changedSize:(CGSize)size;
@end
@interface TopMenu : UIView
@property (nonatomic,weak) id<TopMenuDelegate> topMenuDelegate;
@property (nonatomic) TopMenuPosition position;
@end
