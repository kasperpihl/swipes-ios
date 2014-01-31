//
//  KPAlert.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define TITLE_LABEL_TAG 1
#define MESSAGE_LABEL_TAG 2

#define DEFAULT_ALERTWIDTH 310
#define DEFAULT_TITLE_HEIGHT 60
#define kToolbarHack -20

#import "KPAlert.h"
#import <QuartzCore/QuartzCore.h>
#import "KPToolbar.h"
@interface KPAlert () <ToolbarDelegate>
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *messageLabel;
@property (nonatomic,copy) SuccessfulBlock block;
@property (nonatomic) BOOL shouldRemove;
@end

@implementation KPAlert
+(void)alertInView:(UIView *)view title:(NSString *)title message:(NSString *)message block:(SuccessfulBlock)block{
    KPAlert *alertView = [[KPAlert alloc] initWithFrame:view.bounds];
    alertView.block = block;
    alertView.titleLabel.text = title;
    alertView.messageLabel.text = message;
    alertView.shouldRemove = YES;
    [view addSubview:alertView];
}
+(KPAlert*)alertWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message block:(SuccessfulBlock)block{
    KPAlert *alertView = [[KPAlert alloc] initWithFrame:frame];
    alertView.block = block;
    alertView.titleLabel.text = title;
    alertView.messageLabel.text = message;
    return alertView;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 240)];
        //self.frame = contentView.bounds;
        contentView.center = self.center;
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        contentView.backgroundColor = tbackground(BackgroundColor);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, DEFAULT_TITLE_HEIGHT)];
        titleLabel.backgroundColor = CLEAR;
        titleLabel.tag = TITLE_LABEL_TAG;
        titleLabel.textColor = tcolor(TagColor);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = KP_BOLD(20);
        [contentView addSubview:titleLabel];
        self.titleLabel = (UILabel*)[contentView viewWithTag:TITLE_LABEL_TAG];
        
        NSInteger spacing = 10;
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(spacing, DEFAULT_TITLE_HEIGHT, contentView.frame.size.width-2*spacing, 2*DEFAULT_TITLE_HEIGHT)];
        messageLabel.font = KP_LIGHT(20);
        messageLabel.tag = MESSAGE_LABEL_TAG;
        messageLabel.textColor = tcolor(TagColor);
        messageLabel.numberOfLines = 0;
        messageLabel.backgroundColor = CLEAR;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:messageLabel];
        self.messageLabel = (UILabel*)[contentView viewWithTag:MESSAGE_LABEL_TAG];
        
        KPToolbar *toolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, contentView.frame.size.height-DEFAULT_TITLE_HEIGHT, contentView.frame.size.width, DEFAULT_TITLE_HEIGHT) items:@[@"round_backarrow_big",@"round_checkmark_big"] delegate:self];
        [toolbar setTopInset:kToolbarHack];
        [contentView addSubview:toolbar];
        [self addSubview:contentView];
    }
    return self;
}
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(item == 0 && self.block) self.block(NO,nil);
    else if(item == 1 && self.block) self.block(YES,nil);
    if(self.shouldRemove) [self removeFromSuperview];
}

@end
