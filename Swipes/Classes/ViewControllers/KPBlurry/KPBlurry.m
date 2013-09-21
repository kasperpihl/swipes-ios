
//
//  RNGridMenu.m
//  RNGridMenu
//
//  Created by Ryan Nystrom on 6/11/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "KPBlurry.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

CGFloat const kKPBlurryDefaultDuration = .30f;
CGFloat const kKPBlurryDefaultBlur = 1.0f;
#define KPBlurryDefaultTopBlurry tbackground(PopupBackground)
DisplayPosition const kKPBlurryDefaultDisplayPosition = PositionCenter;

#pragma mark - Categories

@implementation UIView (Screenshot)
- (UIImage *)rn_screenshot {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // helps w/ our colors when blurring
    // feel free to adjust jpeg quality (lower = higher perf)
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

@end
@implementation UIImage (Blur)

-(UIImage *)rn_boxblurImageWithBlur:(CGFloat)blur exclusionPath:(UIBezierPath *)exclusionPath {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    // create unchanged copy of the area inside the exclusionPath
    UIImage *unblurredImage = nil;
    /*if (exclusionPath != nil) {
        CAShapeLayer *maskLayer = [CAShapeLayer new];
        maskLayer.frame = (CGRect){CGPointZero, self.size};
        maskLayer.backgroundColor = [UIColor blackColor].CGColor;
        maskLayer.fillColor = [UIColor whiteColor].CGColor;
        maskLayer.path = exclusionPath.CGPath;
        
        // create grayscale image to mask context
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(nil, maskLayer.bounds.size.width, maskLayer.bounds.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
        CGContextTranslateCTM(context, 0, maskLayer.bounds.size.height);
        CGContextScaleCTM(context, 1.f, -1.f);
        [maskLayer renderInContext:context];
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        UIImage *maskImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        
        UIGraphicsBeginImageContext(self.size);
        context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, maskLayer.bounds.size.height);
        CGContextScaleCTM(context, 1.f, -1.f);
        CGContextClipToMask(context, maskLayer.bounds, maskImage.CGImage);
        CGContextDrawImage(context, maskLayer.bounds, self.CGImage);
        unblurredImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }*/
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    // overlay images?
    if (unblurredImage != nil) {
        UIGraphicsBeginImageContext(returnImage.size);
        [returnImage drawAtPoint:CGPointZero];
        [unblurredImage drawAtPoint:CGPointZero];
        
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end



#pragma mark - KPBlurry

@interface KPBlurry ()

@property (nonatomic, assign) CGPoint menuCenter;
@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, assign) BOOL parentViewCouldScroll;
@property (nonatomic,strong) UIView *menuView;
@end

static KPBlurry *rn_visibleGridMenu;

@implementation KPBlurry
static KPBlurry *sharedObject;
+(KPBlurry *)sharedInstance{
    if (!sharedObject)
        sharedObject = [[KPBlurry allocWithZone:NULL] init];
    return sharedObject;
}
#pragma mark - Lifecycle

+ (instancetype)visibleGridMenu {
    return rn_visibleGridMenu;
}

- (id)init{
    if ((self = [super init])) {
        _blurLevel = kKPBlurryDefaultBlur;
        _animationDuration = kKPBlurryDefaultDuration;
        _blurryTopColor = KPBlurryDefaultTopBlurry;
        _showPosition = kKPBlurryDefaultDisplayPosition;
    }
    
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.blurView.frame = bounds;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if ([self isViewLoaded] && self.view.window != nil) {
        [self createScreenshotAndLayoutWithScreenshotCompletion:nil];
    }
}
-(void)sendSelector:(SEL)selector{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if([self.menuView respondsToSelector:selector]) [self.menuView performSelector:selector];
    if([self.delegate respondsToSelector:selector]) [self.delegate performSelector:selector];
#pragma clang diagnostic pop
}
-(void)closeButton:(id)sender{
    BOOL shouldClose = YES;
    if([self.menuView respondsToSelector:@selector(blurryShouldClose:)]){
        shouldClose = [(UIView<KPBlurryDelegate>*)self.menuView blurryShouldClose:self];
    }
    if([self.delegate respondsToSelector:@selector(blurryShouldClose:)]){
        shouldClose = [self.delegate blurryShouldClose:self];
    }
    if(shouldClose) [self dismissAnimated:YES];
}

- (void)createScreenshotAndLayoutWithScreenshotCompletion:(dispatch_block_t)screenshotCompletion {
    if (self.blurLevel > 0.f) {
        self.blurView.alpha = 0.f;
        self.menuView.alpha = 0.f;
        UIImage *screenshot = [self.parentViewController.view rn_screenshot];
        self.menuView.alpha = 1.f;
        self.blurView.alpha = 1.f;
        self.blurView.layer.contents = (id)screenshot.CGImage;
        
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if(self.blurryTopColor) closeButton.backgroundColor = self.blurryTopColor;
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        closeButton.frame = self.blurView.bounds;
        [closeButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.blurView addSubview:closeButton];
        if (screenshotCompletion != nil) {
            screenshotCompletion();
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
            UIImage *blur = [screenshot rn_boxblurImageWithBlur:self.blurLevel exclusionPath:self.blurExclusionPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *transition = [CATransition animation];
                
                transition.duration = self.animationDuration/2;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                
                [self.blurView.layer addAnimation:transition forKey:nil];
                self.blurView.layer.contents = (id)blur.CGImage;
                
                [self.view setNeedsLayout];
                [self.view layoutIfNeeded];
            });
        });
    }
}

#pragma mark - Animations

- (void)showView:(UIView*)view inViewController:(UIViewController *)parentViewController{
    NSParameterAssert(parentViewController != nil);
    
    if (rn_visibleGridMenu != nil) {
        [rn_visibleGridMenu dismissAnimated:NO];
    }
    _menuView = view;
    [self rn_addToParentViewController:parentViewController callingAppearanceMethods:YES];
    // [self.view convertPoint:center toView:self.view];
    self.view.frame = parentViewController.view.bounds;
    switch (self.showPosition) {
        case PositionTop:
            self.menuView.center = CGPointMake(self.view.center.x, self.menuView.frame.size.height/2);
            break;
        case PositionCenter:
            self.menuView.center = self.view.center;
            break;
        case PositionBottom:
            self.menuView.center = CGPointMake(self.view.center.x, self.view.frame.size.height-(self.menuView.frame.size.height/2));
            break;
    }
    [self showAnimated:YES];
}

- (void)showAnimated:(BOOL)animated {
    rn_visibleGridMenu = self;
    
    self.blurView = [[UIView alloc] initWithFrame:self.parentViewController.view.bounds];
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blurView];
    [self.view addSubview:self.menuView];
    if([self.menuView respondsToSelector:@selector(blurryWillShow:)]) [(UIView<KPBlurryDelegate>*)self.menuView blurryWillShow:self];
    if([self.delegate respondsToSelector:@selector(blurryWillShow:)]) [self.delegate blurryWillShow:self];
    [self createScreenshotAndLayoutWithScreenshotCompletion:^{
        if (animated) {
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.fromValue = @0.;
            opacityAnimation.toValue = @1.;
            opacityAnimation.duration = self.animationDuration;
            [self.menuView.layer addAnimation:opacityAnimation forKey:nil];
            [self performSelector:@selector(didShow) withObject:nil afterDelay:self.animationDuration];
        }
    }];
}
-(void)didShow{
    if([self.menuView respondsToSelector:@selector(blurryDidShow:)]) [(UIView<KPBlurryDelegate>*)self.menuView blurryDidShow:self];
    if([self.delegate respondsToSelector:@selector(blurryDidShow:)]) [self.delegate blurryDidShow:self];
}
- (void)dismissAnimated:(BOOL)animated {
    if (self.dismissAction != nil) {
        self.dismissAction();
    }
    
    if (animated) {
        if([self.menuView respondsToSelector:@selector(blurryWillHide:)]) [(UIView<KPBlurryDelegate>*)self.menuView blurryWillHide:self];
        if([self.delegate respondsToSelector:@selector(blurryWillHide:)]) [self.delegate blurryWillHide:self];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @1.;
        opacityAnimation.toValue = @0.;
        opacityAnimation.duration = self.animationDuration;
        [self.blurView.layer addAnimation:opacityAnimation forKey:nil];
        
        CATransform3D transform = CATransform3DScale(self.menuView.layer.transform, 0, 0, 0);
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[opacityAnimation];
        animationGroup.duration = self.animationDuration;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.menuView.layer addAnimation:animationGroup forKey:nil];
        
        self.blurView.layer.opacity = 0;
        self.menuView.layer.transform = transform;
        [self performSelector:@selector(cleanup) withObject:nil afterDelay:self.animationDuration];
    } else {
        [self cleanup];
    }
    
    rn_visibleGridMenu = nil;
}

- (void)cleanup {
    self.dismissAction = nil;
    self.animationDuration = kKPBlurryDefaultDuration;
    self.blurLevel = kKPBlurryDefaultBlur;
    self.blurryTopColor = KPBlurryDefaultTopBlurry;
    self.showPosition = kKPBlurryDefaultDisplayPosition;
    if([self.menuView respondsToSelector:@selector(blurryDidHide:)]) [(UIView<KPBlurryDelegate>*)self.menuView blurryDidHide:self];
    if([self.delegate respondsToSelector:@selector(blurryDidHide:)]) [self.delegate blurryDidHide:self];
    [self.menuView removeFromSuperview];
    [self rn_removeFromParentViewControllerCallingAppearanceMethods:YES];
}

#pragma mark - Private

- (void)rn_addToParentViewController:(UIViewController *)parentViewController callingAppearanceMethods:(BOOL)callAppearanceMethods {
    if (self.parentViewController != nil) {
        [self rn_removeFromParentViewControllerCallingAppearanceMethods:callAppearanceMethods];
    }
    
    if (callAppearanceMethods) [self beginAppearanceTransition:YES animated:NO];
    [parentViewController addChildViewController:self];
    [parentViewController.view addSubview:self.view];
    [self didMoveToParentViewController:self];
    if (callAppearanceMethods) [self endAppearanceTransition];
    
    if ([parentViewController.view respondsToSelector:@selector(setScrollEnabled:)] && [(UIScrollView *)parentViewController.view isScrollEnabled]) {
        self.parentViewCouldScroll = YES;
        [(UIScrollView *)parentViewController.view setScrollEnabled:NO];
    }
}

- (void)rn_removeFromParentViewControllerCallingAppearanceMethods:(BOOL)callAppearanceMethods {
    if (self.parentViewCouldScroll) {
        [(UIScrollView *)self.parentViewController.view setScrollEnabled:YES];
        self.parentViewCouldScroll = NO;
    }
    
    if (callAppearanceMethods) [self beginAppearanceTransition:NO animated:NO];
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if (callAppearanceMethods) [self endAppearanceTransition];
}


@end
