//
//  EvernoteViewerView.h
//  Swipes
//
//  Created by demosten on 1/20/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EvernoteViewerView;

@protocol EvernoteViewerViewDelegate <NSObject>

- (void)onGetBack;
- (void)onAttach;

@end

@interface EvernoteViewerView : UIView

- (id)initWithFrame:(CGRect)frame andGuid:(NSString *)guid;

@property (nonatomic, weak) id<EvernoteViewerViewDelegate> delegate;

@end
