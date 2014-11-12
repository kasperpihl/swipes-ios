//
//  YoureAllDoneView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#define kAnimationTime 0.5
#define kStampViewSpacing 30
#define kShareItSpace 10
#define kBottomTotal (120 + kShareItSpace) // kBottomMargin + kShareButtonSize

#define kSignatureSpacing 20
#define kSignatureRightMargin 40
#define kStampViewY valForIpad(250,valForScreen(110,130))
#define kStreakFont [UIFont fontWithName:@"NexaHeavy" size:15]
#define kReferBottom 30
#define kReferX 10
#define kShareLabelWidth 230

#define kStreakSpacing 30

#import "UIView+Utilities.h"
#import "YoureAllDoneView.h"


@interface YoureAllDoneView ()
@end
@implementation YoureAllDoneView
-(void)setAllDoneForToday:(BOOL)allDoneForToday{
    if(_allDoneForToday != allDoneForToday){
        _allDoneForToday = allDoneForToday;
        self.trompetView.image = [UIImage imageNamed:allDoneForToday ? @"alldonefortoday" : @"alldonefornow"];
        [self.trompetView setNeedsDisplay];
    }
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.trompetView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alldonefortoday"]];
        self.trompetView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.trompetView];
        [self setAllDoneForToday:YES];
        
        //self.stampView = [[DateStampView alloc] initWithDate:[NSDate date]];
        //self.stampView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        //[self addSubview:self.stampView];
        self.streakLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.streakLabel.text = @"Next task @ 16:30        ";
        self.streakLabel.backgroundColor = CLEAR;
        self.streakLabel.textColor = kColor;
        self.streakLabel.textAlignment = NSTextAlignmentCenter;
        self.streakLabel.font = kStreakFont;
        [self.streakLabel sizeToFit];
        [self addSubview:self.streakLabel];
        CGRectSetWidth(self.streakLabel,320);
        CGRectSetY(self.streakLabel, CGRectGetMaxY(self.trompetView.frame) + kStreakSpacing);
        
        
        self.shareItLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.shareItLabel.numberOfLines = 0;
        self.shareItLabel.backgroundColor = CLEAR;
        self.shareItLabel.textColor = kColor;
        self.shareItLabel.textAlignment = NSTextAlignmentCenter;
        self.shareItLabel.text = @"Good job, let everyone know!";
        self.shareItLabel.font = KP_REGULAR(13);
        //self.shareItLabel.hidden = YES;
        [self.shareItLabel sizeToFit];
        CGRectSetWidth(self.shareItLabel, self.frame.size.width);
        [self addSubview:self.shareItLabel];
        
        self.signatureView = iconLabel(@"signature", 46);
        [self.signatureView setTextColor:kColor];
        
        self.signatureView.hidden = YES;
        [self addSubview:self.signatureView];
        
        self.swipesReferLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.swipesReferLabel.text = @"swipesapp.com";
        self.swipesReferLabel.backgroundColor = CLEAR;
        self.swipesReferLabel.font = KP_LIGHT(14);
        self.swipesReferLabel.textColor = alpha(kColor,0.6);
        self.swipesReferLabel.numberOfLines = 0;
        self.swipesReferLabel.hidden = YES;
        self.swipesReferLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.swipesReferLabel sizeToFit];
        [self addSubview:self.swipesReferLabel];
        
        self.alpha = 0;
        [self setNeedsLayout];
    }
    return self;
}

-(void)setText:(NSString*)text{
    NSInteger strLength = [text length];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:10];
    [style setAlignment:NSTextAlignmentCenter];
    [attString addAttribute:NSParagraphStyleAttributeName
                      value:style
                      range:NSMakeRange(0, strLength)];
    [self.shareItLabel setAttributedText:attString];
    CGRectSetWidth(self.shareItLabel, kShareLabelWidth);
    [self.shareItLabel sizeToFit];
    CGRectSetCenterX(self.shareItLabel, self.center.x);
    //CGRectSetHeight(self, CGRectGetMaxY(self.shareItLabel.frame));
    CGRectSetY(self.signatureView,CGRectGetMaxY(self.shareItLabel.frame) + kSignatureSpacing);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.trompetView.center = CGPointMake(self.frame.size.width/2, kStampViewY);
    CGRectSetY(self.streakLabel, CGRectGetMaxY(self.trompetView.frame) + kStreakSpacing);
    self.signatureView.frame = CGRectSetPos(self.signatureView.frame, self.frame.size.width-self.signatureView.frame.size.width-kSignatureRightMargin, CGRectGetMaxY(self.shareItLabel.frame)+kSignatureSpacing);
    self.swipesReferLabel.frame = CGRectSetPos(self.swipesReferLabel.frame, self.frame.size.width-kReferX-self.swipesReferLabel.frame.size.width, self.frame.size.height-kReferBottom);
    
    CGRectSetY(self.shareItLabel, CGRectGetMaxY(self.streakLabel.frame) + kSignatureSpacing);
    CGRectSetCenterX(self.shareItLabel, self.center.x);
}

-(void)dealloc{
    self.shareItLabel = nil;
    self.trompetView = nil;
    self.streakLabel = nil;
    self.signatureView = nil;
    self.swipesReferLabel = nil;
}
@end
