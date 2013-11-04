//
//  MCSwipeTableViewCell.m
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//

#import "MCSwipeTableViewCell.h"

static CGFloat const kMCStop1 = 0.20; // Percentage limit to trigger the first action
static CGFloat const kMCStop2 = 0.75; // Percentage limit to trigger the second action
static CGFloat const kMCBounceAmplitude = 20.0; // Maximum bounce amplitude when using the MCSwipeTableViewCellModeSwitch mode
static NSTimeInterval const kMCBounceDuration1 = 0.2; // Duration of the first part of the bounce animation
static NSTimeInterval const kMCBounceDuration2 = 0.1; // Duration of the second part of the bounce animation
static NSTimeInterval const kMCDurationLowLimit = 0.25; // Lowest duration when swipping the cell because we try to simulate velocity
static NSTimeInterval const kMCDurationHightLimit = 0.1; // Highest duration when swipping the cell because we try to simulate velocity

@interface MCSwipeTableViewCell () <UIGestureRecognizerDelegate>
#define REGRET_VELOCITY 50
@property (nonatomic) BOOL didRegret;
@property (nonatomic) MCSwipeTableViewCellState forcedState;

@property(nonatomic, assign) MCSwipeTableViewCellDirection direction;
@property(nonatomic, assign) CGFloat currentPercentage;

@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, strong) UIImageView *slidingImageView;
@property(nonatomic, strong) NSString *currentImageName;
@property(nonatomic, strong) UIView *colorIndicatorView;
@property (nonatomic) MCSwipeTableViewCellState currentState;

@end

@implementation MCSwipeTableViewCell

#pragma mark - Initialization

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

#pragma mark Custom Initializer

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
 firstStateIconName:(NSString *)firstIconName
         firstColor:(UIColor *)firstColor
secondStateIconName:(NSString *)secondIconName
        secondColor:(UIColor *)secondColor
      thirdIconName:(NSString *)thirdIconName
         thirdColor:(UIColor *)thirdColor
     fourthIconName:(NSString *)fourthIconName
        fourthColor:(UIColor *)fourthColor {
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        
        [self setFirstStateIconName:firstIconName
                         firstColor:firstColor
                secondStateIconName:secondIconName
                        secondColor:secondColor
                      thirdIconName:thirdIconName
                         thirdColor:thirdColor
                     fourthIconName:fourthIconName
                        fourthColor:fourthColor];
    }

    return self;
}

- (void)initializer {
    _mode = MCSwipeTableViewCellModeSwitch;
    self.noneColor = tbackground(BackgroundColor);
    self.bounceAmplitude = kMCBounceAmplitude;
    _colorIndicatorView = [[UIView alloc] initWithFrame:self.bounds];
    [_colorIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_colorIndicatorView setBackgroundColor:[UIColor clearColor]];
    [self insertSubview:_colorIndicatorView atIndex:0];

    _slidingImageView = [[UIImageView alloc] init];
    [_slidingImageView setContentMode:UIViewContentModeCenter];
    [_colorIndicatorView addSubview:_slidingImageView];

    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:_panGestureRecognizer];
    [_panGestureRecognizer setDelegate:self];
}
#pragma mark - Handle Gestures
- (void)publicHandlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture withTranslation:(CGPoint)translation {
    [self privateHandlePanGestureRecognizer:gesture withTranslation:translation];
}
-(void)privateHandlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture withTranslation:(CGPoint)translation{
    
    if(self.activatedDirection == MCSwipeTableViewCellActivatedDirectionNone){
        NSLog(@"wasn't activated");
        return;
    
    }
    UIGestureRecognizerState state = [gesture state];
    CGPoint velocity = [gesture velocityInView:self];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMinX(self.contentView.frame) relativeToWidth:CGRectGetWidth(self.bounds)];
    
    NSTimeInterval animationDuration = [self animationDurationWithVelocity:velocity];
    if(self.activatedDirection == MCSwipeTableViewCellActivatedDirectionLeft && percentage > 0) percentage = 0;
    else if(self.activatedDirection == MCSwipeTableViewCellActivatedDirectionRight && percentage < 0) percentage = 0;
    _direction = [self directionWithPercentage:percentage];
    
    self.readPercentage = percentage;
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        if(self.shouldRegret){
            switch (_direction) {
                case MCSwipeTableViewCellDirectionLeft:
                    if(velocity.x > REGRET_VELOCITY) self.didRegret = YES;
                    else if(velocity.x < -REGRET_VELOCITY) self.didRegret = NO;
                    break;
                case MCSwipeTableViewCellDirectionRight:
                    if(velocity.x < -REGRET_VELOCITY) self.didRegret = YES;
                    else if(velocity.x > REGRET_VELOCITY) self.didRegret = NO;
                default:
                    break;
            }
        }
        CGPoint center = CGPointMake(self.contentView.center.x + translation.x, self.contentView.center.y);
        if(!(self.activatedDirection == MCSwipeTableViewCellActivatedDirectionBoth || self.activatedDirection == MCSwipeTableViewCellActivatedDirectionLeft)){
            CGFloat minAllowed = (self.contentView.frame.size.width/2)-self.bounceAmplitude;
            if(center.x < minAllowed) center.x = minAllowed;
        }
        else if(!(self.activatedDirection == MCSwipeTableViewCellActivatedDirectionBoth || self.activatedDirection == MCSwipeTableViewCellActivatedDirectionRight)){
            CGFloat maxAllowed = (self.contentView.frame.size.width/2)+self.bounceAmplitude;
            if(center.x > maxAllowed) center.x = maxAllowed;
        }
        [self.contentView setCenter:center];
        [self animateWithOffset:CGRectGetMinX(self.contentView.frame)];
        [gesture setTranslation:CGPointZero inView:self];
    }
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        _currentImageName = [self imageNameWithPercentage:percentage];
        _currentPercentage = percentage;
        MCSwipeTableViewCellState cellState= [self stateWithPercentage:percentage];
        // TODO: Build in forced moving
        if (_mode == MCSwipeTableViewCellModeExit && _direction != MCSwipeTableViewCellDirectionCenter && [self validateState:cellState])
            [self moveWithDuration:animationDuration andDirection:_direction];
        else
            [self bounceToOrigin];
    }
}
-(void)switchToState:(MCSwipeTableViewCellState)state{
    self.didRegret = NO;
    CGFloat percentage;
    MCSwipeTableViewCellDirection direction;
    switch (state){
        case MCSwipeTableViewCellState1:
            percentage = kMCStop1+0.01;
            break;
        case MCSwipeTableViewCellState2:
            percentage = kMCStop2+0.01;
            break;
        case MCSwipeTableViewCellState3:
            percentage = -kMCStop1-0.01;
            break;
        case MCSwipeTableViewCellState4:
            percentage = -kMCStop2-0.01;
            break;
        default:
            return;
    }
    _currentPercentage = percentage;
    _currentImageName = [self imageNameWithPercentage:percentage];
    NSString *imageName = [self imageNameWithPercentage:percentage];
    if (imageName != nil) {
        [_slidingImageView setImage:[UIImage imageNamed:imageName]];
        [_slidingImageView setAlpha:[self imageAlphaWithPercentage:percentage]];
    }
    [self slideImageWithPercentage:percentage imageName:imageName isDragging:NO];
    
    // Color
    UIColor *color = [self colorWithPercentage:percentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }
    direction = [self directionWithPercentage:percentage];
    [self moveWithDuration:kMCDurationLowLimit andDirection:direction];
}
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    if([self.delegate respondsToSelector:@selector(swipeTableViewCell:shouldHandleGestureRecognizer:)]){
        if(![self.delegate swipeTableViewCell:self shouldHandleGestureRecognizer:gesture]) return;
    }
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        
        if([self.delegate respondsToSelector:@selector(swipeTableViewCell:didStartPanningWithMode:)])
            [self.delegate swipeTableViewCell:self didStartPanningWithMode:self.mode];
    }
    CGPoint translation = [gesture translationInView:self];
    [self privateHandlePanGestureRecognizer:gesture withTranslation:translation];
    if([self.delegate respondsToSelector:@selector(swipeTableViewCell:didHandleGestureRecognizer:withTranslation:)]){
        [self.delegate swipeTableViewCell:self didHandleGestureRecognizer:gesture withTranslation:translation];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        UIPanGestureRecognizer *g = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [g velocityInView:self];
        //NSLog(@"%f,%f",point.x,point.y);
        if (fabsf(point.x) > fabsf(point.y) ) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Utils

- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width {
    CGFloat offset = percentage * width;

    if (offset < -width) offset = -width;
    else if (offset > width) offset = width;
    return offset;
}

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width {
    CGFloat percentage = offset / width;

    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;

    return percentage;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat width = CGRectGetWidth(self.bounds);
    NSTimeInterval animationDurationDiff = kMCDurationHightLimit - kMCDurationLowLimit;
    CGFloat horizontalVelocity = velocity.x;

    if (horizontalVelocity < -width) horizontalVelocity = -width;
    else if (horizontalVelocity > width) horizontalVelocity = width;

    return (kMCDurationHightLimit + kMCDurationLowLimit) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}

- (MCSwipeTableViewCellDirection)directionWithPercentage:(CGFloat)percentage {
    if (percentage < -kMCStop1)
        return MCSwipeTableViewCellDirectionLeft;
    else if (percentage > kMCStop1)
        return MCSwipeTableViewCellDirectionRight;
    else
        return MCSwipeTableViewCellDirectionCenter;
}

- (NSString *)imageNameWithPercentage:(CGFloat)percentage {
    NSString *imageName;
        // Image
        if (percentage >= 0 && percentage < kMCStop2)
            imageName = _firstIconName;
        else if (percentage >= kMCStop2)
            imageName = _secondIconName;
        else if (percentage < 0 && percentage > -kMCStop2)
            imageName = _thirdIconName;
        else if (percentage <= -kMCStop2)
            imageName = _fourthIconName;
    return imageName;
}

- (CGFloat)imageAlphaWithPercentage:(CGFloat)percentage {
    CGFloat alpha = 0;

    if (percentage >= 0 && percentage < kMCStop1){
        if(self.activatedDirection == MCSwipeTableViewCellActivatedDirectionBoth || self.activatedDirection ==  MCSwipeTableViewCellActivatedDirectionLeft) alpha = percentage / kMCStop1;
    }
        
    else if (percentage < 0 && percentage > -kMCStop1){
        if(self.activatedDirection == MCSwipeTableViewCellActivatedDirectionBoth || self.activatedDirection == MCSwipeTableViewCellActivatedDirectionRight) alpha = fabsf(percentage / kMCStop1);
    }
    else alpha = 1.0;

    return alpha;
}

- (UIColor *)colorWithPercentage:(CGFloat)percentage {
    UIColor *color = self.noneColor; 
    if(!self.didRegret || !self.shouldRegret){
        // Background Color
        if (percentage >= kMCStop1 && percentage < kMCStop2)
            color = _firstColor;
        else if (percentage >= kMCStop2)
            color = _secondColor;
        else if (percentage < -kMCStop1 && percentage > -kMCStop2)
            color = _thirdColor;
        else if (percentage <= -kMCStop2)
            color = _fourthColor;
    }
    self.currentState = [self stateWithPercentage:percentage];
    return color;
}

- (MCSwipeTableViewCellState)stateWithPercentage:(CGFloat)percentage {
    MCSwipeTableViewCellState state;

    state = MCSwipeTableViewCellStateNone;
    if(!self.didRegret || !self.shouldRegret){
        if (percentage >= kMCStop1 && [self validateState:MCSwipeTableViewCellState1])
            state = MCSwipeTableViewCellState1;
        
        if (percentage >= kMCStop2 && [self validateState:MCSwipeTableViewCellState2])
            state = MCSwipeTableViewCellState2;
        
        if (percentage <= -kMCStop1 && [self validateState:MCSwipeTableViewCellState3])
            state = MCSwipeTableViewCellState3;
        
        if (percentage <= -kMCStop2 && [self validateState:MCSwipeTableViewCellState4])
            state = MCSwipeTableViewCellState4;
    }
    return state;
}
-(void)setCurrentState:(MCSwipeTableViewCellState)currentState{
    if(currentState != _currentState){
        _currentState = currentState;
        if([self.delegate respondsToSelector:@selector(swipeTableViewCell:slidedIntoState:)]) [self.delegate swipeTableViewCell:self slidedIntoState:currentState];
    }
}

- (BOOL)validateState:(MCSwipeTableViewCellState)state {
    BOOL isValid = YES;

    switch (state) {
        case MCSwipeTableViewCellStateNone: {
            isValid = NO;
        }
            break;

        case MCSwipeTableViewCellState1: {
            if (!_firstColor && !_firstIconName)
                isValid = NO;
        }
            break;

        case MCSwipeTableViewCellState2: {
            if (!_secondColor && !_secondIconName)
                isValid = NO;
        }
            break;

        case MCSwipeTableViewCellState3: {
            if (!_thirdColor && !_thirdIconName)
                isValid = NO;
        }
            break;

        case MCSwipeTableViewCellState4: {
            if (!_fourthColor && !_fourthIconName)
                isValid = NO;
        }
            break;

        default:
            break;
    }

    return isValid;
}

#pragma mark - Movement

- (void)animateWithOffset:(CGFloat)offset {
    CGFloat percentage = [self percentageWithOffset:offset relativeToWidth:CGRectGetWidth(self.bounds)];

    // Image Name
    NSString *imageName = [self imageNameWithPercentage:percentage];
    if(self.didRegret && self.shouldRegret) [_slidingImageView setImage:[UIImage imageNamed:nil]];
    // Image Position
    if (imageName != nil) {
        if(!self.didRegret || !self.shouldRegret)[_slidingImageView setImage:[UIImage imageNamed:imageName]];
        [_slidingImageView setAlpha:[self imageAlphaWithPercentage:percentage]];
    }
    [self slideImageWithPercentage:percentage imageName:imageName isDragging:YES];

    // Color
    UIColor *color = [self colorWithPercentage:percentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }
}


- (void)slideImageWithPercentage:(CGFloat)percentage imageName:(NSString *)imageName isDragging:(BOOL)isDragging {
    UIImage *slidingImage = [UIImage imageNamed:imageName];
    CGSize slidingImageSize = slidingImage.size;
    CGRect slidingImageRect;
    CGPoint position = CGPointZero;
    position.y = CGRectGetHeight(self.bounds) / 2.0;
    if (isDragging) {
        /*if (percentage >= 0 && percentage < kMCStop1) {
            position.x = [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
            NSLog(@"x:%f",position.x);
        }*/

        if (percentage >= 0) {
            position.x = [self offsetWithPercentage:percentage - (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
       /* else if (percentage < 0 && percentage >= -kMCStop1) {
            position.x = CGRectGetWidth(self.bounds) - [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }*/

        else if (percentage < 0) {
            position.x = CGRectGetWidth(self.bounds) + [self offsetWithPercentage:percentage + (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
    }
    else {
        if (_direction == MCSwipeTableViewCellDirectionRight) {
            position.x = [self offsetWithPercentage:percentage - (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else if (_direction == MCSwipeTableViewCellDirectionLeft) {
            position.x = CGRectGetWidth(self.bounds) + [self offsetWithPercentage:percentage + (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else {
            return;
        }
    }
    slidingImageRect = CGRectMake(position.x - slidingImageSize.width / 2.0,
            position.y - slidingImageSize.height / 2.0,
            slidingImageSize.width,
            slidingImageSize.height);

    slidingImageRect = CGRectIntegral(slidingImageRect);
    [_slidingImageView setFrame:slidingImageRect];
}


- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction {
    CGFloat origin;

    if (direction == MCSwipeTableViewCellDirectionLeft)
        origin = -CGRectGetWidth(self.bounds);
    else
        origin = CGRectGetWidth(self.bounds);

    CGFloat percentage = [self percentageWithOffset:origin relativeToWidth:CGRectGetWidth(self.bounds)];
    CGRect rect = self.contentView.frame;
    rect.origin.x = origin;

    // Color
    UIColor *color = [self colorWithPercentage:_currentPercentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }

    // Image
    if (_currentImageName != nil) {
        [_slidingImageView setImage:[UIImage imageNamed:_currentImageName]];
    }

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [self.contentView setFrame:rect];
                         [_slidingImageView setAlpha:0];
                         [self slideImageWithPercentage:percentage imageName:_currentImageName isDragging:NO];
                     }
                     completion:^(BOOL finished) {
                         [self notifyDelegate];
                     }];
}

- (void)bounceToOrigin {
    CGFloat bounceDistance = self.bounceAmplitude * _currentPercentage;
    if(self.mode != MCSwipeTableViewCellModeSwitch) self.didRegret = YES;
    [UIView animateWithDuration:kMCBounceDuration1
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         CGRect frame = self.contentView.frame;
                         frame.origin.x = -bounceDistance;
                         [self.contentView setFrame:frame];
                         [_slidingImageView setAlpha:0.0];
                         [self slideImageWithPercentage:0 imageName:_currentImageName isDragging:NO];
                     }
                     completion:^(BOOL finished1) {

                         [UIView animateWithDuration:kMCBounceDuration2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              CGRect frame = self.contentView.frame;
                                              frame.origin.x = 0;
                                              [self.contentView setFrame:frame];
                                          }
                                          completion:^(BOOL finished2) {
                                              [self notifyDelegate];
                                              self.didRegret = NO;
                                          }];
                     }];
}

#pragma mark - Delegate Notification

- (void)notifyDelegate {
    MCSwipeTableViewCellState state = [self stateWithPercentage:_currentPercentage];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(swipeTableViewCell:didTriggerState:withMode:)]) {
        [_delegate swipeTableViewCell:self didTriggerState:state withMode:_mode];
    }
}

#pragma mark - Setter

- (void)setFirstStateIconName:(NSString *)firstIconName
                   firstColor:(UIColor *)firstColor
          secondStateIconName:(NSString *)secondIconName
                  secondColor:(UIColor *)secondColor
                thirdIconName:(NSString *)thirdIconName
                   thirdColor:(UIColor *)thirdColor
               fourthIconName:(NSString *)fourthIconName
                  fourthColor:(UIColor *)fourthColor {
    [self setFirstIconName:firstIconName];
    [self setSecondIconName:secondIconName];
    [self setThirdIconName:thirdIconName];
    [self setFourthIconName:fourthIconName];

    [self setFirstColor:firstColor];
    [self setSecondColor:secondColor];
    [self setThirdColor:thirdColor];
    [self setFourthColor:fourthColor];
}

@end