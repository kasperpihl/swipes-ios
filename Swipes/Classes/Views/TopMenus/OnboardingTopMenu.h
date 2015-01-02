//
//  OnboardingTopMenu.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/12/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "TopMenu.h"
@class OnboardingTopMenu;
@protocol OnboardingTopMenuDelegate <NSObject>
-(NSArray*)itemsForTopMenu:(OnboardingTopMenu*)topMenu;
-(void)topMenu:(OnboardingTopMenu*)topMenu didSelectItem:(NSInteger)itemIndex;
@optional
-(BOOL)topMenu:(OnboardingTopMenu*)topMenu hasCompletedItem:(NSInteger)itemIndex;
-(void)didPressCloseInOnboardingTopMenu:(OnboardingTopMenu*)topMenu;
@end

@interface OnboardingTopMenu : TopMenu
@property (nonatomic,weak) NSObject<OnboardingTopMenuDelegate> *delegate;
-(void)setDone:(BOOL)done animated:(BOOL)animated itemIndex:(NSInteger)itemIndex;
-(void)setItems:(NSArray*)items;

@end