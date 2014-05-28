//
//  CheckmarkButton.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/05/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "CheckmarkButton.h"
#define kDefaultSquareSize 25
#define kCornerRadius 5
@interface CheckmarkButton ()
@property (nonatomic) UIView *squareView;
@end

@implementation CheckmarkButton
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CLEAR;
        self.squareSize = kDefaultSquareSize;
        self.squareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.squareSize, self.squareSize)];
        self.squareView.layer.borderColor = tcolorF(TextColor,ThemeDark).CGColor;
        self.squareView.layer.borderWidth = LINE_SIZE;
        self.squareView.layer.cornerRadius = kCornerRadius;
        [self addSubview:self.squareView];
        CGRectSetCenter(self.squareView, CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
        [self sendSubviewToBack:self.squareView];
        self.squareView.userInteractionEnabled = NO;

        self.titleLabel.font = iconFont(12);
        [self setTitle:iconString(@"checkmarkThick") forState:UIControlStateHighlighted];
        [self setTitle:@"" forState:UIControlStateNormal];
        [self setTitle:iconString(@"checkmarkThick") forState:UIControlStateSelected];
        [self setTitle:@"" forState:UIControlStateSelected | UIControlStateHighlighted];
        [self addTarget:self action:@selector(pressedCheck:) forControlEvents:UIControlEventTouchUpInside];
        // Initialization code
    }
    return self;
}

-( void )pressedCheck:(UIButton*)sender{
    self.selected = !self.selected;
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
