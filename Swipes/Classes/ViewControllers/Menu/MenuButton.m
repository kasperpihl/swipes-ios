//
//  MenuButton.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define SCHEDULE_IMAGE_CENTER_SPACING 8//13
#define kLampSize 14
#define kLampBorderRadius (kLampSize/2)
#define kLampBorderWidth 1
#define kLampY 3
#define kLampX 5
#import "MenuButton.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>
@interface MenuButton ()
@property (nonatomic) UIView *lampView;
@end
@implementation MenuButton
-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    [UIView transitionWithView:self.iconImageView
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ if(highlighted != self.iconImageView.highlighted) self.iconImageView.highlighted = highlighted; }
                    completion:nil];
}
-(void)setLampColor:(UIColor*)lampColor{
    _lampColor = lampColor;
    self.lampView.hidden = (!lampColor);
    self.lampView.backgroundColor = lampColor;
}
-(id)initWithFrame:(CGRect)frame title:(NSString*)title image:(UIImage*)image highlightedImage:(UIImage *)highlightedImage{
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenHighlighted = NO;
        UIColor *highlightedColor = alpha(tcolor(TextColor),0.5);
        self.titleLabel.font = SCHEDULE_BUTTON_FONT;
        [self setTitle:title forState:UIControlStateNormal];
        
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
        
        [self setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        //[self setTitleColor:alpha(tcolor(TextColor),0.6) forState:UIControlStateHighlighted];
        
        self.iconImageView = [[UIImageView alloc] initWithImage:image];
        if(!highlightedImage)self.iconImageView.highlightedImage = [UtilityClass image:image withColor:highlightedColor multiply:YES];
        else self.iconImageView.highlightedImage = highlightedImage;
        CGFloat imageHeight = self.iconImageView.frame.size.height;
        CGFloat textHeight = sizeWithFont(@"Kasjper",SCHEDULE_BUTTON_FONT).height;
        NSInteger dividor = (SCHEDULE_IMAGE_CENTER_SPACING == 0) ? 3 : 2;
        CGFloat spacing = (self.frame.size.height-imageHeight-textHeight-SCHEDULE_IMAGE_CENTER_SPACING)/dividor;
        
        self.iconImageView.frame = CGRectSetPos(self.iconImageView.frame, (self.frame.size.width-image.size.width)/2,spacing);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, spacing, 0);
        [self addSubview:self.iconImageView];
        
        self.lampView = [[UIView alloc] initWithFrame:CGRectMake(kLampX, kLampY, kLampSize, kLampSize)];
        self.lampView.hidden = YES;
        self.lampView.layer.borderWidth = kLampBorderWidth;
        self.lampView.layer.borderColor = tcolor(TextColor).CGColor;
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
