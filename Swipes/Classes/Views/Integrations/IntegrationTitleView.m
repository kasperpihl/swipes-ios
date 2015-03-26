//
//  IntegrationTitleView.m
//  Swipes
//
//  Created by demosten on 2/26/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "IntegrationTitleView.h"

static CGFloat const kLineMarginX = 26;
static CGFloat const kLineMarginY = 50;

@interface IntegrationTitleView ()

@property (nonatomic, strong) UIView* lineView;
@property (nonatomic, strong) UILabel* titleLabel;

@end

@implementation IntegrationTitleView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    if (!_lightColor)
        _lightColor = [UIColor clearColor];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLineMarginX, 20, self.frame.size.width - kLineMarginX * 2, 25)];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];

    _lineView = [[UIView alloc] initWithFrame:CGRectMake(kLineMarginX, kLineMarginY, self.frame.size.width - kLineMarginX * 2, 1.5)];
    _lineView.backgroundColor = tcolor(TextColor);
    _lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_lineView];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self updateTitle];
}

- (void)setLightColor:(UIColor *)lightColor
{
    _lightColor = lightColor;
    [self updateTitle];
}

- (void)setupWithTitle:(NSString *)title lightColor:(UIColor *)lightColor
{
    _title = title;
    _lightColor = lightColor ? lightColor : [UIColor clearColor];
    [self updateTitle];
}

- (void)setupWithTitle:(NSString *)title
{
    [self setupWithTitle:title lightColor:nil];
}

- (void)updateTitle
{
    if (_title) {
        // Create the attributed string
        NSString* indicator = @"indicator";
        NSMutableAttributedString *myString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@ %@", indicator, self.title, indicator]];
        
        // Declare the fonts
        UIFont *fontIcon = iconFont(10);
        UIFont *fontTitle = KP_SEMIBOLD(10);
        
        NSRange rangeFirst = NSMakeRange(0, indicator.length);
        NSRange rangeLast = NSMakeRange(myString.length - indicator.length, indicator.length);
        NSRange rangeTitle = NSMakeRange(indicator.length, myString.length - indicator.length * 2);
        
        // Declare the paragraph styles
        NSMutableParagraphStyle *myStringParaStyle1 = [[NSMutableParagraphStyle alloc] init];
        myStringParaStyle1.alignment = 1;
        
        // Create the attributes and add them to the string
        [myString addAttribute:NSForegroundColorAttributeName value:_lightColor range:rangeFirst];
        [myString addAttribute:NSParagraphStyleAttributeName value:myStringParaStyle1 range:rangeFirst];
        [myString addAttribute:NSFontAttributeName value:fontIcon range:rangeFirst];
        
        [myString addAttribute:NSFontAttributeName value:fontTitle range:rangeTitle];
        [myString addAttribute:NSParagraphStyleAttributeName value:myStringParaStyle1 range:rangeTitle];
        [myString addAttribute:NSForegroundColorAttributeName value:tcolor(TextColor) range:rangeTitle];
        
        [myString addAttribute:NSForegroundColorAttributeName value:_lightColor range:rangeLast];
        [myString addAttribute:NSParagraphStyleAttributeName value:myStringParaStyle1 range:rangeLast];
        [myString addAttribute:NSFontAttributeName value:fontIcon range:rangeLast];
        
        [myString addAttribute:NSKernAttributeName value:@(1.5) range:NSMakeRange(0, myString.length)];
        
        self.titleLabel.attributedText = [[NSAttributedString alloc]initWithAttributedString: myString];
    }
}

@end
