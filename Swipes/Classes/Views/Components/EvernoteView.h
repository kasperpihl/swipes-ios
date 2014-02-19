//
//  EvernoteView.h
//  Swipes
//
//  Created by demosten on 1/20/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EvernoteView;

@protocol EvernoteViewDelegate <NSObject>
- (void)selectedEvernoteInView:(EvernoteView *)evernoteView guid:(NSString*)guid title:(NSString *)title;
- (void)closeEvernoteView:(EvernoteView *)evernoteView;
@end

@interface EvernoteView : UIView

@property (nonatomic, weak) id<EvernoteViewDelegate> delegate;
@property (nonatomic, weak) UIViewController* caller;

@end
