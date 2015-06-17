//
//  PullToRefreshView.m
//  Swipes
//
//  Created by demosten on 5/4/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "UtilityClass.h"
#import "CoreSyncHandler.h"
#import "UserHandler.h"
#import "ThemeHandler.h"
#import "PullToRefreshView.h"

static const CGFloat kProgressMultiply = (1.0 / 0.5);

@interface PullToRefreshView ()

@property (nonatomic, strong) UILabel* title;
@property (nonatomic, strong) UILabel* subtitle;
@property (nonatomic, assign) BPRPullToRefreshState lastState;

@end

@implementation PullToRefreshView

- (instancetype)initWithLocationType:(BPRRefreshViewLocationType)locationType
{
    self = [super initWithLocationType:locationType];
    if (self) {
        self.backgroundColor = tcolor(BackgroundColor);
        _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, self.frame.size.width, 40)];
        _title.text = @"Title";
        _title.alpha = 0.f;
        _title.numberOfLines = 0;
        _title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = KP_SEMIBOLD(15);
        _title.textColor = tcolor(TextColor);
        [self addSubview:_title];
        
        _subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, 20)];
        _subtitle.text = @"Some subtitle";
        _subtitle.alpha = 0.f;
        _subtitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _subtitle.textAlignment = NSTextAlignmentCenter;
        _subtitle.font = KP_LIGHT(12);
        _subtitle.textColor = tcolor(SubTextColor);
        [self addSubview:_subtitle];
        
        _lastState = BPRPullToRefreshStateIdle;
    }
    
    return self;
}

- (CGFloat)progressToAlpha:(CGFloat)progress
{
    if (0.5f > progress) {
        return 0;
    }
    else if (1.0f <= progress) {
        return 1;
    }
    return (progress - 0.5f) * kProgressMultiply;
}

- (void)setTitleText:(NSString *)text icon:(NSString *)icon
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@", icon, text]];
    [attrString addAttribute:NSFontAttributeName value:iconFont(15) range:NSMakeRange(0, icon.length)];
    _title.attributedText = attrString;
}

-(void)updateSyncLabel
{
    NSDate *lastSync = [USER_DEFAULTS objectForKey:@"lastSyncLocalDate"];
    NSString *timeString = lastSync ? [UtilityClass readableTime:lastSync showTime:YES] : [NSLocalizedString(@"never", nil) capitalizedString];
    _subtitle.text = [NSString stringWithFormat:NSLocalizedString(@"Last sync: %@", nil),timeString];
}

- (void)updateTexts:(BPRPullToRefreshState)state
{
    if (!kUserHandler.isLoggedIn) {
        [self setTitleText:NSLocalizedString(@"Register for Swipes to safely back up your data and get Swipes Plus", nil) icon:@"settingsAccount"];
        _subtitle.hidden = YES;
    }
    else {
        BOOL isSyncing = KPCORE.isSyncing;
        if (isSyncing) {
            [self setTitleText:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@"Synchronizing...", nil)] icon:@"settingsSync"];
        }
        else {
            if (state == BPRPullToRefreshStateIdle) {
                _title.text = [NSString stringWithFormat:@"%@\n", NSLocalizedString(@"Pull to Synchronize", nil)];
            }
            else if (state == BPRPullToRefreshStateLoading) {
                if (_lastState != BPRPullToRefreshStateLoading) {
//                    DLog(@"Synchronizing");
                    [KPCORE clearCache];
                    [KPCORE synchronizeForce:YES async:YES];
                }
                [self setTitleText:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@"Synchronizing...", nil)] icon:@"settingsSync"];
            }
            else {
                _title.text = [NSString stringWithFormat:@"%@\n", NSLocalizedString(@"Release to Synchronize", nil)];
            }
        }
        _subtitle.hidden = NO;
        [self updateSyncLabel];
    }
    _lastState = state;
}

- (void)updateForProgress:(CGFloat)progress withState:(BPRPullToRefreshState)state
{
    CGFloat alpha = [self progressToAlpha:progress];
//    DLog(@"Progress %f, alpha: %f, state: %@, lastState: %@", progress, alpha, NSStringFromBPRPullToRefreshState(state), NSStringFromBPRPullToRefreshState(_lastState));
    _title.alpha = alpha;
    _subtitle.alpha = alpha;
    
    [self updateTexts:state];
}

@end
