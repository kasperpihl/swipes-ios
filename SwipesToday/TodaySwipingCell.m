//
//  TodaySwipeableTableViewCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 18/09/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define color(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a]
//#define alpha(c,a) [c colorWithAlphaComponent:a]
#define kActionThreshold 50
#define kRegretThreshold 10

#define kPreventNotificationTimeThreshold 0.4
#define kPreventNotificationDistanceThreshold -30
#import "TodaySwipingCell.h"
#import "ThemeHandler.h"
#import "SwipingOverlayView.h"
@interface TodaySwipingCell () <SwipingOverlayViewDelegate>
@property (nonatomic) IBOutlet UILabel *movingIcon;
@property (nonatomic) IBOutlet UIButton *completeButton;
@property (nonatomic) IBOutlet UILabel *taskTitle;
@property (nonatomic) CGFloat lastX;
@property CGFloat relativeCounter;
@property CGFloat regretCounter;
@property BOOL didRegret;
@property BOOL lock;
@property CGFloat startTime;
@property BOOL didCancel;

@end
@implementation TodaySwipingCell
-(void)swipingDidStartOverlay:(SwipingOverlayView *)overlay{
    self.didRegret = NO;
    self.didCancel = NO;
    self.startTime = CACurrentMediaTime();
}
-(void)swipingOverlay:(SwipingOverlayView *)overlay didTapInPoint:(CGPoint)point{
    if([self.delegate respondsToSelector:@selector(didTapCell:)])
        [self.delegate didTapCell:self];
}
-(void)swipingOverlay:(SwipingOverlayView *)overlay didMoveDistance:(CGPoint)point relative:(CGPoint)relative{
    if(self.lock)
        return;
    if(point.x < kPreventNotificationDistanceThreshold && (CACurrentMediaTime()-self.startTime)<kPreventNotificationTimeThreshold){
        NSLog(@"did cancel");
        self.didCancel = YES;
    }
    if(!self.didRegret){
        if( relative.x < 0 )
            self.regretCounter += ABS(relative.x);
        else if(relative.x > 0)
            self.regretCounter = 0;
        if(self.regretCounter > kRegretThreshold){
            self.didRegret = YES;
            self.regretCounter = 0;
        }
    }
    if(self.didRegret){
        if( relative.x > 0 )
            self.regretCounter += ABS(relative.x);
        else if(relative.x < 0)
            self.regretCounter = 0;
        if(self.regretCounter > kRegretThreshold){
            self.didRegret = NO;
            self.regretCounter = 0;
        }
    }
    CGFloat x = MAX(point.x,0);
    self.lastX = point.x;
    self.colorIndicatorView.backgroundColor = alpha(self.colorIndicatorView.backgroundColor, (x > kActionThreshold && !self.didRegret) ? 1.0 : 0.4 );
    self.movingIcon.textColor = alpha(self.movingIcon.textColor, (x > kActionThreshold && !self.didRegret) ? 1.0 : 0.4 );
    CGRectSetX(self.colorIndicatorView, MIN(-self.bounds.size.width+x,0));
    CGFloat contentX = MIN(x,self.bounds.size.width);
    CGRectSetX(self.contentView, MIN(x,self.bounds.size.width));
    CGRectSetX(self.movingIcon, contentX-self.movingIcon.frame.size.width);
}
-(void)swipingOverlay:(SwipingOverlayView *)overlay didEndWithDistance:(CGPoint)point relative:(CGPoint)relative{
    if(self.lock)
        return;
    NSLog(@"l - %f - %f",CACurrentMediaTime()-self.startTime,point.x);
    //NSLog(@"l - relative %f last %f",relative.x,self.lastX);
    [self finalizeAnimationAndComplete:(point.x > kActionThreshold && !self.didRegret && !self.didCancel)];
}
-(void)swipingDidCancelOverlay:(SwipingOverlayView *)overlay{
    if(self.lock)
        return;
    [self finalizeAnimationAndComplete:NO];
}

-(void)finalizeAnimationAndComplete:(BOOL)completed{
    if(completed && self.delegate && [self.delegate respondsToSelector:@selector(willCompleteCell:)])
        [self.delegate willCompleteCell:self];
    self.lock = YES;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRectSetX(self.colorIndicatorView, completed ? 0 : -self.bounds.size.width);
        CGRectSetX(self.contentView, completed ? self.bounds.size.width : 0);
        CGRectSetX(self.movingIcon, completed ? self.bounds.size.width-self.movingIcon.frame.size.width : 0-self.movingIcon.frame.size.width);
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
    UILabel *movingIcon = [[UILabel alloc] initWithFrame:CGRectMake(-self.bounds.size.height, 0, self.bounds.size.height, self.frame.size.height)];
    movingIcon.font = iconFont(20);
    movingIcon.textAlignment = NSTextAlignmentCenter;
    [movingIcon setText:@"done"];
    [movingIcon setTextColor:tcolorF(TextColor, ThemeDark)];
    [self insertSubview:movingIcon aboveSubview:_colorIndicatorView];
    self.movingIcon = movingIcon;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];//CGRectMake((CELL_LABEL_X/2),0, LINE_SIZE,CELL_HEIGHT)]; //];
    selectionView.backgroundColor = color(0, 0, 0, 0.15);
    selectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.selectedBackgroundView = selectionView;
    
    self.dotView = [[DotView alloc] init];

    self.dotView.dotColor = tcolor(TasksColor);
    CGFloat titleX = 35;
    CGFloat extra = 2;
    [self.dotView setScale:0.85];
    CGRectSetCenter(self.dotView, titleX/2+extra, self.frame.size.height/2);
    [self.contentView addSubview:self.dotView];
    
    

    self.taskTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 0, self.frame.size.height)];
    self.taskTitle.font = [UIFont systemFontOfSize:16];
    self.taskTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.taskTitle.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.taskTitle];
    
    SwipingOverlayView *swipingOverlayView = [[SwipingOverlayView alloc] initWithFrame:self.bounds];
    swipingOverlayView.delegate = self;
    [self addSubview:swipingOverlayView];
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
}

-(void)resetAndSetTaskTitle:(NSString *)title{
    CGRectSetX(self.colorIndicatorView, -self.bounds.size.width);
    CGRectSetX(self.contentView, 0);
    CGRectSetX(self.movingIcon, 0-self.movingIcon.frame.size.width);
    self.completeButton.hidden = NO;
    self.taskTitle.hidden = NO;
    self.taskTitle.text = [@"        " stringByAppendingString:title];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
