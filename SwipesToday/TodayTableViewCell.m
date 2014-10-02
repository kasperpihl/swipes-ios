//
//  TodaySwipeableTableViewCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 18/09/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define color(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a]

#import "TodayTableViewCell.h"
#import "ThemeHandler.h"
@interface TodayTableViewCell () <UIGestureRecognizerDelegate>
@property (nonatomic) IBOutlet UIButton *completeButton;
@property (nonatomic) IBOutlet UILabel *taskTitle;


@end
@implementation TodayTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializer];
    }
    return self;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (void)initializer {
    _colorIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(-self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)];
    [_colorIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_colorIndicatorView setBackgroundColor:[UIColor clearColor]];
    [self insertSubview:_colorIndicatorView atIndex:0];
    
    self.taskTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-self.frame.size.height, self.frame.size.height)];
    self.taskTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.taskTitle.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.taskTitle];
    
    
    UIButton *completeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-self.frame.size.height, 0, self.frame.size.height, self.frame.size.height)];
    [completeButton setTitle:@"done" forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(pressedComplete:) forControlEvents:UIControlEventTouchUpInside];
    [completeButton addTarget:self action:@selector(touchedComplete:) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
    [completeButton addTarget:self action:@selector(cancelledComplete:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchDragExit];
    [completeButton setTitle:@"doneFull" forState:UIControlStateHighlighted];
    [completeButton setTitleColor:tcolor(DoneColor) forState:UIControlStateNormal];
    completeButton.titleLabel.font = [UIFont fontWithName:@"swipes" size:15];
    completeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:completeButton];
}
-(void)animate{
}
-(void)resetAndSetTaskTitle:(NSString *)title{
    CGRectSetX(self.colorIndicatorView, -self.bounds.size.width);
    CGRectSetX(self.contentView, 0);
    self.taskTitle.text = title;
}
-(void)cancelledComplete:(UIButton*)sender{
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRectSetX(self.colorIndicatorView, -self.bounds.size.width);
        CGRectSetX(self.contentView, 0);
    } completion:^(BOOL finished) {
    }];
}
-(void)touchedComplete:(UIButton*)sender{
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGFloat step = 10;
        CGRectSetX(self.colorIndicatorView, -self.bounds.size.width + step);
        CGRectSetX(self.contentView, step);
    } completion:^(BOOL finished) {
    }];
}
-(void)pressedComplete:(UIButton*)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(willCompleteCell:)])
        [self.delegate willCompleteCell:self];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRectSetX(self.colorIndicatorView, 0);
        CGRectSetX(self.contentView, self.bounds.size.width);
    } completion:^(BOOL finished) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didCompleteCell:)])
            [self.delegate didCompleteCell:self];
    }];

}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
