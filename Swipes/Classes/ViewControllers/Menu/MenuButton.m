//
//  MenuButton.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define SCHEDULE_IMAGE_CENTER_SPACING 13
#define kLampSize 18
#define kLampBorderRadius (kLampSize/2)
#define kLampBorderWidth 1
#define kLampY 7
#define kLampX 7
#import "MenuButton.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>
@interface MenuButton ()
@property (nonatomic) UIImageView *iconImageView;
@property (nonatomic) UIView *lampView;
@end
@implementation MenuButton
-(void)highlightedButton:(UIButton *)sender{
    self.iconImageView.highlighted = YES;
}
-(void)deHighlightedButton:(UIButton *)sender{
    self.iconImageView.highlighted = NO;
}
-(void)setLampColor:(UIColor*)lampColor{
    _lampColor = lampColor;
    self.lampView.hidden = (!lampColor);
    self.lampView.backgroundColor = lampColor;
}
-(id)initWithFrame:(CGRect)frame title:(NSString*)title image:(UIImage*)image{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *highlightedColor = tbackground(TaskCellBackground);
        self.titleLabel.font = SCHEDULE_BUTTON_FONT;
        [self setTitle:title forState:UIControlStateNormal];
        
        
        [self addTarget:self action:@selector(deHighlightedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(highlightedButton:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(highlightedButton:) forControlEvents:UIControlEventTouchDragInside];
        [self addTarget:self action:@selector(deHighlightedButton:) forControlEvents:UIControlEventTouchCancel];
        [self addTarget:self action:@selector(deHighlightedButton:) forControlEvents:UIControlEventTouchDragOutside];
        
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
        
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:highlightedColor forState:UIControlStateHighlighted];
        
        
        
        self.iconImageView = [[UIImageView alloc] initWithImage:image];
        self.iconImageView.highlightedImage = [UtilityClass image:image withColor:highlightedColor multiply:YES];
        
        CGFloat imageHeight = self.iconImageView.frame.size.height;
        CGFloat textHeight = [@"Kasjper" sizeWithFont:SCHEDULE_BUTTON_FONT].height;
        NSInteger dividor = (SCHEDULE_IMAGE_CENTER_SPACING == 0) ? 3 : 2;
        CGFloat spacing = (self.frame.size.height-imageHeight-textHeight-SCHEDULE_IMAGE_CENTER_SPACING)/dividor;
        
        self.iconImageView.frame = CGRectSetPos(self.iconImageView.frame, (self.frame.size.width-image.size.width)/2,spacing);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, spacing, 0);
        [self addSubview:self.iconImageView];
        
        self.lampView = [[UIView alloc] initWithFrame:CGRectMake(kLampX, kLampY, kLampSize, kLampSize)];
        self.lampView.hidden = YES;
        self.lampView.layer.borderWidth = kLampBorderWidth;
        self.lampView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.lampView.layer.masksToBounds = YES;
        self.lampView.layer.cornerRadius = kLampBorderRadius;
        [self addSubview:self.lampView];
    }
    return self;
}
-(void)dealloc{
    self.iconImageView = nil;
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
