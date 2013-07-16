//
//  KPAlert.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define TITLE_LABEL_TAG 1
#define MESSAGE_LABEL_TAG 2

#define DEFAULT_ALERTWIDTH 300
#define DEFAULT_TITLE_HEIGHT 44

#import "KPAlert.h"
@interface KPAlert ()
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *messageLabel;
@property (nonatomic,copy) SuccessfulBlock block;
@end

@implementation KPAlert
+(void)confirmInView:(UIView *)view title:(NSString *)title message:(NSString *)message block:(SuccessfulBlock)block{
    
    KPAlert *alertView = [[KPAlert alloc] initWithFrame:view.bounds];
    alertView.block = block;
    alertView.titleLabel.text = title;
    alertView.messageLabel.text = message;
    [view addSubview:alertView];
    [alertView show:YES completed:^(BOOL succeeded, NSError *error) {
        
    }];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
        contentView.backgroundColor = tbackground(MenuBackground);
        [self setContainerSize:contentView.frame.size];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, DEFAULT_TITLE_HEIGHT)];
        titleLabel.backgroundColor = TEXTFIELD_BACKGROUND;
        titleLabel.tag = TITLE_LABEL_TAG;
        titleLabel.textColor = BUTTON_COLOR;
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.font = BUTTON_FONT;
        [contentView addSubview:titleLabel];
        self.titleLabel = (UILabel*)[contentView viewWithTag:TITLE_LABEL_TAG];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, DEFAULT_TITLE_HEIGHT, contentView.frame.size.width, contentView.frame.size.height-DEFAULT_TITLE_HEIGHT-BUTTON_HEIGHT-COLOR_SEPERATOR_HEIGHT)];
        messageLabel.font = TEXT_FIELD_FONT;
        messageLabel.tag = MESSAGE_LABEL_TAG;
        messageLabel.textColor = BUTTON_COLOR;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textAlignment = UITextAlignmentCenter;
        [contentView addSubview:messageLabel];
        self.messageLabel = (UILabel*)[contentView viewWithTag:MESSAGE_LABEL_TAG];
        
        CGFloat buttonY = contentView.frame.size.height-COLOR_SEPERATOR_HEIGHT-BUTTON_HEIGHT;
        CGFloat buttonWidth = contentView.frame.size.width/2;
        
        UIView *buttonSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, buttonY-COLOR_SEPERATOR_HEIGHT, contentView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        buttonSeperator.backgroundColor = tbackground(MenuSelectedBackground);
        [contentView addSubview:buttonSeperator];
        
        
        UIButton *noButton = [UIButton buttonWithType:UIButtonTypeCustom];
        noButton.titleLabel.font = BUTTON_FONT;
        noButton.frame = CGRectMake(0, buttonY , buttonWidth , BUTTON_HEIGHT);
        [noButton addTarget:self action:@selector(pressedNo:) forControlEvents:UIControlEventTouchUpInside];
        [noButton setTitle:@"NO" forState:UIControlStateNormal];
        [contentView addSubview:noButton];
        
        
        UIView *buttonSpecificSeperator = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth-SEPERATOR_WIDTH/2, buttonY, SEPERATOR_WIDTH, BUTTON_HEIGHT)];
        buttonSpecificSeperator.backgroundColor = tbackground(MenuSelectedBackground);
        [contentView addSubview:buttonSpecificSeperator];
        
        UIButton *yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        yesButton.titleLabel.font = BUTTON_FONT;
        yesButton.frame = CGRectMake(buttonWidth, buttonY,buttonWidth , BUTTON_HEIGHT);
        [yesButton setTitle:@"YES" forState:UIControlStateNormal];
        [yesButton addTarget:self action:@selector(pressedYes:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:yesButton];
        
        
        UIView *colorBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.frame.size.height-COLOR_SEPERATOR_HEIGHT, contentView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        colorBottomSeperator.backgroundColor = tcolor(ColoredSeperator);
        [contentView addSubview:colorBottomSeperator];
        [self.containerView addSubview:contentView];
    }
    return self;
}
-(void)cancelled{
    if(self.block) self.block(NO,nil);
}
-(void)pressedNo:(id)sender{
    [self show:NO completed:^(BOOL succeeded, NSError *error) {
        if(self.block) self.block(NO,nil);
    }];
}
-(void)pressedYes:(id)sender{
    
    [self show:NO completed:^(BOOL succeeded, NSError *error) {
        if(self.block) self.block(YES,nil);
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
