//
//  YoureAllDoneView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#define kColor alpha([UIColor whiteColor],0.8)

#define kAnimationTime 0.5
#define kStampViewSpacing 30
#define kShareItSpace 10
#define kBottomTotal (120 + kShareItSpace) // kBottomMargin + kShareButtonSize

#define kSignatureSpacing 20
#define kSignatureRightMargin 40
#define kStampViewY valForScreen(110,130)

#define kReferBottom 74
#define kReferX 10

#import "YoureAllDoneView.h"


@interface YoureAllDoneView ()
@end
@implementation YoureAllDoneView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.stampView = [[DateStampView alloc] initWithDate:[NSDate date]];
        //self.stampView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.stampView];
        
        
        self.shareItLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.shareItLabel.numberOfLines = 0;
        self.shareItLabel.backgroundColor = CLEAR;
        self.shareItLabel.textColor = kColor;
        self.shareItLabel.textAlignment = NSTextAlignmentCenter;
        self.shareItLabel.text = @"Good job, let everyone know!";
        self.shareItLabel.font = KP_LIGHT(16);
        //self.shareItLabel.hidden = YES;
        [self.shareItLabel sizeToFit];
        CGRectSetWidth(self.shareItLabel, self.frame.size.width);
        [self addSubview:self.shareItLabel];
        
        self.signatureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_white_signate"]];
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
        [self layout];
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
    CGRectSetWidth(self.shareItLabel, 290);
    [self.shareItLabel sizeToFit];
    CGRectSetCenterX(self.shareItLabel, [self.shareItLabel superview].center.x);
    CGRectSetHeight(self, CGRectGetMaxY(self.shareItLabel.frame));
    CGRectSetY(self.signatureView,CGRectGetMaxY(self.shareItLabel.frame)+kSignatureSpacing);
}
-(void)layout{
    self.stampView.center = CGPointMake(self.frame.size.width/2, kStampViewY);
    self.signatureView.frame = CGRectSetPos(self.signatureView.frame, self.frame.size.width-self.signatureView.frame.size.width-kSignatureRightMargin, CGRectGetMaxY(self.shareItLabel.frame)+kSignatureSpacing);
    self.swipesReferLabel.frame = CGRectSetPos(self.swipesReferLabel.frame, self.frame.size.width-kReferX-self.swipesReferLabel.frame.size.width, self.frame.size.height-kReferBottom);
    
    CGRectSetY(self.shareItLabel, CGRectGetMaxY(self.stampView.frame) + kSignatureSpacing * 2);
}

-(void)dealloc{
    self.shareItLabel = nil;
    self.stampView = nil;
    self.signatureView = nil;
    self.swipesReferLabel = nil;
}
@end
