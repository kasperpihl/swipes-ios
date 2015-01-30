//
//  AttachmentEditView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/01/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//
#define LABEL_X CELL_LABEL_X

#import "UIColor+Utilities.h"
#import "SyncLabel.h"
#import "AttachmentEditView.h"
@interface AttachmentEditView ()
@property (nonatomic) UIButton *overlayButton;
@property (nonatomic) UILabel *iconLabel;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) SyncLabel *syncLabel;
@end

@implementation AttachmentEditView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        // Add icon
        self.iconLabel = [[UILabel alloc] init];
        self.iconLabel.font = iconFont(15);
        self.iconLabel.backgroundColor = CLEAR;
        self.iconLabel.textAlignment = NSTextAlignmentCenter;
        self.iconLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        self.iconLabel.textColor = tcolor(TextColor);
        [self addSubview:self.iconLabel];
        
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, self.frame.size.width - LABEL_X, self.frame.size.height)];
        self.titleLabel.font = EDIT_TASK_TEXT_FONT;
        self.titleLabel.backgroundColor = CLEAR;
        self.titleLabel.textColor = tcolor(TextColor);
        
        [self addSubview:self.titleLabel];
        
        self.syncLabel = [[SyncLabel alloc] init];
        self.syncLabel.hidden = YES;
        [self addSubview:self.syncLabel];
        
        self.overlayButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.overlayButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        self.overlayButton.backgroundColor = CLEAR;
        [self.overlayButton setBackgroundImage:[color(55,55,55,0.1) image] forState:UIControlStateHighlighted];
        [self.overlayButton addTarget:self action:@selector(pressedAttachment:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.overlayButton];
    }
    return self;
}
-(void)setIconString:(NSString *)iconString{
    [self.iconLabel setText:iconString(iconString)];
    [self.iconLabel sizeToFit];
    self.iconLabel.frame = CGRectSetPos(self.iconLabel.frame,(LABEL_X-self.iconLabel.frame.size.width)/2, (self.frame.size.height-self.iconLabel.frame.size.height)/2);
}
-(void)setTitleString:(NSString*)titleString{
    self.titleLabel.text = titleString;
}
-(void)setSyncString:(NSString *)syncString{
    self.syncLabel.hidden = (!syncString);
    [self.syncLabel setTitle:syncString];
    self.syncLabel.frame = CGRectSetPos(self.syncLabel.frame, LABEL_X, CGRectGetMidY(self.frame)+10);
}
-(void)pressedAttachment:(UIButton*)sender{
    if([self.delegate respondsToSelector:@selector(clickedAttachment:)])
        [self.delegate clickedAttachment:self];
        
}
-(void)dealloc{
    self.iconLabel = nil;
    self.titleLabel = nil;
    self.overlayButton = nil;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
