//
//  TodaySwipeableTableViewCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 18/09/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define color(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a]
#define kTapThreshold 0.4
#define kTapMovementMaximum 10

#import "TodayTableViewCell.h"
#import "ThemeHandler.h"
#import "SwipingOverlayView.h"
@interface TodayTableViewCell () <UIGestureRecognizerDelegate,SwipingOverlayViewDelegate>
@property (nonatomic) IBOutlet UIButton *completeButton;
@property (nonatomic) IBOutlet UILabel *taskTitle;
@property BOOL lock;
@property BOOL notATap;
@property BOOL measureClick;
@property CGFloat startX;
@property CGFloat startY;
@property CGFloat lastX;
@property CGFloat lastY;
@property CGFloat startTime;

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
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];//CGRectMake((CELL_LABEL_X/2),0, LINE_SIZE,CELL_HEIGHT)]; //];
    selectionView.backgroundColor = color(0, 0, 0, 0.15);
    selectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.selectedBackgroundView = selectionView;
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    CGFloat titleX = 50;
    CGFloat xButtonHack = 2;
    CGFloat yButtonHack = 0;
    CGFloat buttonWidth = 20;
    UIButton *completeDesignButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,buttonWidth,buttonWidth)];
    completeDesignButton.layer.cornerRadius = buttonWidth/2;
    completeDesignButton.layer.borderColor = tcolorF(TextColor, ThemeDark).CGColor;
    completeDesignButton.layer.borderWidth = 1;
    [completeDesignButton setTitle:iconString(@"widgetDone") forState:UIControlStateNormal];
    [completeDesignButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];//tcolor(DoneColor)
    completeDesignButton.titleLabel.font = [UIFont fontWithName:@"swipes" size:8];
    CGRectSetCenter(completeDesignButton, titleX/2+xButtonHack, self.frame.size.height/2+yButtonHack);
    completeDesignButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:completeDesignButton];
    
    
    UIButton *completeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,  titleX, self.frame.size.height)];
    [completeButton setTitle:iconString(@"checkmarkThick") forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(pressedComplete:) forControlEvents:UIControlEventTouchUpInside];
    //[completeButton addTarget:self action:@selector(touchedComplete:) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
    //[completeButton addTarget:self action:@selector(cancelledComplete:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchDragExit];
    completeButton.alpha = 0.01;
    [completeButton setTitleColor:tcolorF(TextColor,ThemeLight) forState:UIControlStateNormal];//tcolor(DoneColor)
    
    completeButton.titleLabel.font = [UIFont fontWithName:@"swipes" size:40];
    completeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubview:completeButton];
    [self bringSubviewToFront:completeButton];
    self.completeButton = completeButton;
    
    self.taskTitle = [[UILabel alloc] initWithFrame:CGRectMake(titleX, 0, self.frame.size.width- titleX, self.frame.size.height)];
    self.taskTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.taskTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.taskTitle.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.taskTitle.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.taskTitle];
    
    SwipingOverlayView *swipingOverlayView = [[SwipingOverlayView alloc] initWithFrame:self.bounds];
    swipingOverlayView.delegate = self;
    CGRectSetWidth(swipingOverlayView, self.taskTitle.frame.origin.x);
    [self addSubview:swipingOverlayView];
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

-(void)swipingOverlay:(SwipingOverlayView *)overlay didTapInPoint:(CGPoint)point{
    NSLog(@"pressed in point %f",point.x);
    if(point.x < self.taskTitle.frame.origin.x)
        [self pressedComplete:self.completeButton];
}

/*-(void)cancelledComplete:(UIButton*)sender{
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
 }*/
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
