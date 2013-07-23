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
#import "KPToolbar.h"
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
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
        contentView.backgroundColor = tbackground(MenuBackground);
        self.frame = contentView.bounds;
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, DEFAULT_TITLE_HEIGHT)];
        titleLabel.backgroundColor = tbackground(AlertBackground);
        titleLabel.tag = TITLE_LABEL_TAG;
        titleLabel.textColor = tcolor(TagColor);
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.font = BUTTON_FONT;
        [contentView addSubview:titleLabel];
        self.titleLabel = (UILabel*)[contentView viewWithTag:TITLE_LABEL_TAG];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, DEFAULT_TITLE_HEIGHT, contentView.frame.size.width, contentView.frame.size.height-DEFAULT_TITLE_HEIGHT-BUTTON_HEIGHT-COLOR_SEPERATOR_HEIGHT)];
        messageLabel.font = TEXT_FIELD_FONT;
        messageLabel.tag = MESSAGE_LABEL_TAG;
        messageLabel.textColor = tcolor(TagColor);
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textAlignment = UITextAlignmentCenter;
        [contentView addSubview:messageLabel];
        self.messageLabel = (UILabel*)[contentView viewWithTag:MESSAGE_LABEL_TAG];
        
        KPToolbar *toolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 60) items:@[@"toolbar_back_icon",@"toolbar_check_icon"]];
        [contentView addSubview:toolbar];
        [self addSubview:contentView];
    }
    return self;
}
-(void)cancelled{
    if(self.block) self.block(NO,nil);
}
/*-(void)pressedNo:(id)sender{
    [self show:NO completed:^(BOOL succeeded, NSError *error) {
        if(self.block) self.block(NO,nil);
    }];
}
-(void)pressedYes:(id)sender{
    
    [self show:NO completed:^(BOOL succeeded, NSError *error) {
        if(self.block) self.block(YES,nil);
    }];
}*/
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
