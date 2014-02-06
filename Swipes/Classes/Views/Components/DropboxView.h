//
//  DropboxView.h
//  Swipes
//
//  Created by demosten on 2/5/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropboxView;

@protocol DropboxViewDelegate <NSObject>

- (void)selectedFileInView:(DropboxView *)DropboxView path:(NSString *)path;
- (void)closeDropboxView:(DropboxView *)DropboxView;

@end

@interface DropboxView : UIView

@property (nonatomic, weak) id<DropboxViewDelegate> delegate;
@property (nonatomic, weak) UIViewController* caller;
@property (nonatomic, assign) BOOL useThumbnails;

@end
