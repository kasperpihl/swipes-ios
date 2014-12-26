//
//  OnboardingTableViewCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/12/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "M13BadgeView.h"
#import "OnboardingTableViewCell.h"

#define kNotificationWidth 45
#define kNotificationActualSize 20

@interface OnboardingTableViewCell ()
@property (nonatomic) UILabel *actionLabel;
@property (nonatomic) M13BadgeView *badgeView;
@end
@implementation OnboardingTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.backgroundColor = tcolor(BackgroundColor);
        self.contentView.backgroundColor = tcolor(BackgroundColor);
        UIView *badgeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNotificationWidth, self.bounds.size.height)];
        badgeContainer.backgroundColor = CLEAR;
        
        M13BadgeView *badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, kNotificationActualSize, kNotificationActualSize)];
        badgeView.font = KP_REGULAR(11);
        badgeView.animateChanges = YES;
        badgeView.borderColor = tcolor(TextColor);
        badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentCenter;
        badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentMiddle;
        CGRectSetWidth(badgeView, kNotificationWidth);
        
        self.badgeView = badgeView;
        [badgeContainer addSubview:badgeView];
        [self.contentView addSubview:badgeContainer];
        
        self.actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kNotificationWidth, 0, self.bounds.size.width-kNotificationWidth, self.bounds.size.height)];
        self.actionLabel.font = KP_REGULAR(14);
        self.actionLabel.textColor = tcolor(TextColor);
        [self.contentView addSubview:self.actionLabel];
    }
    return self;
}
-(void)setNumber:(NSInteger)number text:(NSString*)text{
    self.badgeView.text = [NSString stringWithFormat:@"%i",number];
    self.actionLabel.text = text;
}
-(void)setDone:(BOOL)done{
    [self setDone:done animated:NO];
}
-(void)setDone:(BOOL)done animated:(BOOL)animated{
    _done = done;
    __block NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.actionLabel.text attributes:@{NSFontAttributeName: KP_REGULAR(14)}];
    voidBlock beforeBlock = ^{
        self.badgeView.borderWidth = done ? 0 : 0.5;
    };
    voidBlock showBlock = ^{
        self.badgeView.badgeBackgroundColor = done ? tcolor(DoneColor) : tcolor(BackgroundColor);
        self.badgeView.textColor = done ? [UIColor whiteColor] : tcolor(TextColor);
        if(done){
            [attrString addAttributes:@{NSStrikethroughStyleAttributeName : [NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle], NSForegroundColorAttributeName: color(161, 163, 165, 0.7)} range:NSMakeRange(0, attrString.length)];
        }
        else{
            [attrString addAttributes:@{NSForegroundColorAttributeName: tcolor(TextColor)} range:NSMakeRange(0, attrString.length)];
        }
        self.actionLabel.attributedText = attrString;
    };
    voidBlock completionBlock = ^{
    };
    if(!animated){
        beforeBlock();
        showBlock();
        completionBlock();
    }
    else{
        beforeBlock();
        [UIView animateWithDuration:0.4 animations:showBlock completion:^(BOOL finished) {
            completionBlock();
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
