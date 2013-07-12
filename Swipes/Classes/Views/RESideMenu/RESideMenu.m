//
//  RESideMenu.m
// RESideMenu
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RESideMenu.h"
#import "AccelerationAnimation.h"
#import "Evaluate.h"

const int INTERSTITIAL_STEPS = 99;

@interface RESideMenu ()
{
    BOOL _appIsHidingStatusBar;
    BOOL _isInSubMenu;
}
@property (assign, readwrite, nonatomic) NSInteger initialX;
@property (assign, readwrite, nonatomic) CGSize originalSize;
@property (strong, nonatomic) REBackgroundView *backgroundView;
@property (strong, nonatomic) UIImageView *screenshotView;
@property (strong, nonatomic) UIView *slidebackView;
@property (nonatomic) CGFloat targetScale;


// Array containing menu (which are array of items)

@end

@implementation RESideMenu
- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    self.targetScale = 0.6;
    self.hideStatusBarArea = YES;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    self.panningRecognizer = panGestureRecognizer;

    
    return self;
}

-(void)addPanningToView:(UIView *)view{
    [view addGestureRecognizer:self.panningRecognizer];
}


- (void)show
{
    if (_isShowing)
        return;
    
    _isShowing = YES;
    
    // keep track of whether or not it was already hidden
    _appIsHidingStatusBar=[[UIApplication sharedApplication] isStatusBarHidden];
    
    if(!_appIsHidingStatusBar)
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self performSelector:@selector(showAfterDelay) withObject:nil afterDelay:0];
}

- (void)hide
{
    if (_isShowing)
        [self restoreFromRect:_screenshotView.frame];
}

- (void)setRootViewController:(UIViewController *)viewController
{
    if (_isShowing) [self hide];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = viewController;
    _screenshotView.image = [window re_snapshotWithStatusBar:!self.hideStatusBarArea];
    [window bringSubviewToFront:_backgroundView];
    [window bringSubviewToFront:_screenshotView];
}

- (void)addAnimation:(NSString *)path view:(UIView *)view startValue:(double)startValue endValue:(double)endValue
{
    AccelerationAnimation *animation = [AccelerationAnimation animationWithKeyPath:path
                                                                        startValue:startValue
                                                                          endValue:endValue
                                                                  evaluationObject:[[ExponentialDecayEvaluator alloc] initWithCoefficient:6.0]
                                                                 interstitialSteps:INTERSTITIAL_STEPS];
    animation.removedOnCompletion = NO;
    [view.layer addAnimation:animation forKey:path];
}

//- (void)animate

- (void)showAfterDelay
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    // Take a snapshot
    //
    _screenshotView = [[UIImageView alloc] initWithFrame:CGRectNull];
    _screenshotView.image = [window re_snapshotWithStatusBar:!self.hideStatusBarArea];
    _screenshotView.frame = CGRectMake(0, 0, _screenshotView.image.size.width, _screenshotView.image.size.height);
    _screenshotView.userInteractionEnabled = YES;
    _screenshotView.layer.anchorPoint = CGPointMake(0, 0);
    _originalSize = _screenshotView.frame.size;
    
    // Add views
    //
    _backgroundView = [[REBackgroundView alloc] initWithFrame:window.bounds];
    _backgroundView.backgroundImage = _backgroundImage;
    [window addSubview:_backgroundView];
    
    _slidebackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backbutton"]];
    _slidebackView.autoresizesSubviews = NO;
    _slidebackView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
    _slidebackView.userInteractionEnabled = YES;
    _slidebackView.layer.anchorPoint = CGPointMake(0, 0);
    CGRect slideBackFrame = _slidebackView.frame;
    
    _slidebackView.frame = CGRectMake(0-slideBackFrame.size.width, (window.frame.size.height-slideBackFrame.size.height)/2, slideBackFrame.size.width, slideBackFrame.size.height);
    [window addSubview:_slidebackView];
    
    [window addSubview:_screenshotView];
    
    //[self minimizeFromRect:CGRectMake(0, 0, _originalSize.width, _originalSize.height)];
    
    [_slidebackView addGestureRecognizer:self.panningRecognizer];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [_slidebackView addGestureRecognizer:tapGestureRecognizer];
}

- (void)minimizeFromRect:(CGRect)rect
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat m = self.targetScale;
    CGFloat newWidth = _originalSize.width * m;
    CGFloat newHeight = _originalSize.height * m;
    CGFloat targetX = window.frame.size.width;
    CGFloat targetY = (window.frame.size.height - newHeight)/2.0;
    CGFloat sliderWidth = _slidebackView.frame.size.width;
    CGFloat x = rect.origin.x;
    if(x > targetX) x = targetX;
    if(x < 0) x = 0;
    CGFloat percentage = 1-(x/targetX);
    CGFloat duration = 0.7*percentage;
    if(duration<0.2) duration = 0.2;
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    [self addAnimation:@"position.x" view:_screenshotView startValue:rect.origin.x endValue:targetX];
    [self addAnimation:@"position.y" view:_screenshotView startValue:rect.origin.y endValue:targetY];
    [self addAnimation:@"bounds.size.width" view:_screenshotView startValue:rect.size.width endValue:newWidth];
    [self addAnimation:@"bounds.size.height" view:_screenshotView startValue:rect.size.height endValue:newHeight];
    [self addAnimation:@"position.x" view:_slidebackView startValue:rect.origin.x-sliderWidth endValue:targetX-sliderWidth];
    _slidebackView.layer.position = CGPointMake(targetX-sliderWidth, _slidebackView.frame.origin.y);
    _screenshotView.layer.position = CGPointMake(targetX, targetY);
    _screenshotView.layer.bounds = CGRectMake(targetX, targetY, newWidth, newHeight);
    [CATransaction commit];
}
- (void)restoreFromRect:(CGRect)rect
{
    _slidebackView.userInteractionEnabled = NO;
    while (_slidebackView.gestureRecognizers.count) {
        [_slidebackView removeGestureRecognizer:[_slidebackView.gestureRecognizers objectAtIndex:0]];
    }
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat x = rect.origin.x;
    CGFloat targetX = window.frame.size.width;
    if(x > targetX) x = targetX;
    if(x < 0) x = 0;
    CGFloat percentage = (x/targetX);
    CGFloat duration = 0.7*percentage;
    if(duration<0.1) duration = 0.1;
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    [self addAnimation:@"position.x" view:_screenshotView startValue:rect.origin.x endValue:0];
    [self addAnimation:@"position.y" view:_screenshotView startValue:rect.origin.y endValue:0];
    [self addAnimation:@"bounds.size.width" view:_screenshotView startValue:rect.size.width endValue:window.frame.size.width];
    [self addAnimation:@"bounds.size.height" view:_screenshotView startValue:rect.size.height endValue:window.frame.size.height];
    [self addAnimation:@"position.x" view:_slidebackView startValue:rect.origin.x-_slidebackView.frame.size.width endValue:0-_slidebackView.frame.size.width];
    _slidebackView.layer.position = CGPointMake(0-_slidebackView.frame.size.width, _slidebackView.frame.origin.y);
    _screenshotView.layer.position = CGPointMake(0, 0);
    _screenshotView.layer.bounds = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    [CATransaction commit];
    [self performSelector:@selector(restoreView) withObject:nil afterDelay:duration];
    // restore the status bar to its original state.

    _isShowing = NO;
}
-(void)restoreStatusBar{
    
    
}
- (void)restoreView
{
    [[UIApplication sharedApplication] setStatusBarHidden:_appIsHidingStatusBar withAnimation:UIStatusBarAnimationNone];
    [_backgroundView removeFromSuperview];
    [_screenshotView removeFromSuperview];
    [_slidebackView removeFromSuperview];
}

#pragma mark Gestures
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGPoint translation = [sender translationInView:window];
    if (sender.state == UIGestureRecognizerStateBegan) {
        _initialX = _screenshotView.frame.origin.x;
    }
    if(translation.x > 0) [self show];
	if(!self.isShowing) return;
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGFloat x = translation.x + _initialX;
        CGFloat targetX = window.frame.size.width;
        if(x > targetX) x = targetX;
        if(x < 0) x = 0;
        CGFloat targetWidth = _originalSize.width * self.targetScale;
        CGFloat targetHeight = _originalSize.height * self.targetScale;
        
        
        CGFloat percentage = x/targetX;
        
        
        CGFloat width = (1-percentage)*(_originalSize.width-targetWidth)+targetWidth;
        CGFloat height = (1-percentage)*(_originalSize.height-targetHeight)+targetHeight;
        
        CGFloat y = (window.frame.size.height - height) / 2.0;
        
        if (x < 0 || y < 0) {
            _screenshotView.frame = CGRectMake(0, 0, width, height);
            _slidebackView.frame = CGRectMake(0-_slidebackView.frame.size.width, _slidebackView.frame.origin.y, _slidebackView.frame.size.width, _slidebackView.frame.size.height);
        } else {
            _screenshotView.frame = CGRectMake(x, y, width, height);
            _slidebackView.frame = CGRectMake(x-_slidebackView.frame.size.width, _slidebackView.frame.origin.y, _slidebackView.frame.size.width, _slidebackView.frame.size.height);
        }
        /*
        CGFloat screenshotOpaque = 1-percentageForScreenshot;
        _screenshotView.alpha = screenshotOpaque;
        
        CGFloat arrowOpaque = (translatedX >= targetX*percentToAnimateIn) ? ((translatedX-(targetX*percentToAnimateIn))/(targetX*percentToAnimateIn)) : 0;
        _slidebackView.alpha = arrowOpaque;*/
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([sender velocityInView:window].x < 0) {
            [self restoreFromRect:_screenshotView.frame];
        } else {
            [self minimizeFromRect:_screenshotView.frame];
        }
    }
}
- (void)tapGestureRecognized:(UITapGestureRecognizer *)sender
{
    [self restoreFromRect:_screenshotView.frame];
}

#pragma mark - Table view data source

@end
