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
#import "SwipeTestingView.h"
@interface TodayTableViewCell () <UIGestureRecognizerDelegate>
@property (nonatomic) IBOutlet UIButton *completeButton;
@property (nonatomic) IBOutlet UILabel *taskTitle;
@property (nonatomic) CGFloat startX;
@property BOOL lock;

@end
@implementation TodayTableViewCell
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.lock = YES;
    UITouch *touch = [touches anyObject];
    CGPoint translation = [touch locationInView:self];
    self.startX = translation.x;
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint translation = [touch locationInView:self];
    CGFloat relative = MAX(translation.x-self.startX,0);
    CGRectSetX(self.colorIndicatorView, MIN(-self.bounds.size.width+relative,0));
    CGRectSetX(self.contentView, MIN(relative,self.bounds.size.width));
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint translation = [touch locationInView:self];
    CGFloat relative = MAX(translation.x-self.startX,0);
    [self finalizeAnimation:NO];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self finalizeAnimation:NO];
}

-(void)finalizeAnimation:(BOOL)completed{
    if(self.delegate && [self.delegate respondsToSelector:@selector(willCompleteCell:)])
        [self.delegate willCompleteCell:self];
    
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRectSetX(self.colorIndicatorView, completed ? 0 : -self.bounds.size.width);
        CGRectSetX(self.contentView, completed ? self.bounds.size.width : 0);
    } completion:^(BOOL finished) {
        self.lock = NO;
        if(completed)
            self.taskTitle.hidden = YES;
        if(completed && self.delegate && [self.delegate respondsToSelector:@selector(didCompleteCell:)])
            [self.delegate didCompleteCell:self];
    }];
}

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
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];//CGRectMake((CELL_LABEL_X/2),0, LINE_SIZE,CELL_HEIGHT)]; //];
    selectionView.backgroundColor = color(0, 0, 0, 0.15);
    selectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.selectedBackgroundView = selectionView;
    
    CGFloat titleX = 3;
    CGFloat buttonWidth = 40;
    
    CGFloat notificationX = 6;
    /*UIButton *completeButton = [[UIButton alloc] initWithFrame:CGRectMake(notificationX, 0,  buttonWidth, self.bounds.size.height)];
    [completeButton setTitle:@"roundedBox" forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(pressedComplete:) forControlEvents:UIControlEventTouchUpInside];
    //[completeButton addTarget:self action:@selector(touchedComplete:) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
    //[completeButton addTarget:self action:@selector(cancelledComplete:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchDragExit];
    
    [completeButton setTitle:@"" forState:UIControlStateHighlighted];
    [completeButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];//tcolor(DoneColor)
    completeButton.titleLabel.font = [UIFont fontWithName:@"swipes" size:30];
    completeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubview:completeButton];
    [self bringSubviewToFront:completeButton];
    self.completeButton = completeButton;*/
    
    self.taskTitle = [[UILabel alloc] initWithFrame:CGRectMake(notificationX + titleX, 0, self.frame.size.width - titleX -notificationX, self.frame.size.height)];
    self.taskTitle.font = [UIFont systemFontOfSize:16];
    self.taskTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.taskTitle.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.taskTitle];
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
}

-(void)resetAndSetTaskTitle:(NSString *)title{
    CGRectSetX(self.colorIndicatorView, -self.bounds.size.width);
    CGRectSetX(self.contentView, 0);
    self.completeButton.hidden = NO;
    self.taskTitle.hidden = NO;
    self.taskTitle.text = title;
}

-(void)pressedComplete:(UIButton*)sender{
    if(self.lock)
        return;
    if(self.delegate && [self.delegate respondsToSelector:@selector(willCompleteCell:)])
        [self.delegate willCompleteCell:self];
    self.lock = YES;
    self.completeButton.hidden = YES;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRectSetX(self.colorIndicatorView, 0);
        CGRectSetX(self.contentView, self.bounds.size.width);
    } completion:^(BOOL finished) {
        self.lock = NO;
        self.taskTitle.hidden = YES;
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
