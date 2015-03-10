//
//  GmailHelperViewController.m
//  Swipes
//
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "SlowHighlightIcon.h"
#import "UIColor+Utilities.h"
#import "WalkthroughTitleView.h"
#import "GmailHelperViewController.h"

#define kTopHeight 60
#define kIconHack 0
#define kTextSpacing 10
#define kTitleTopSpacing 45
#define kImageTopSpacing 20

@interface GmailHelperViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property BOOL success;

@end

@implementation GmailHelperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat top = 0;
    UIView *topHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kTopHeight + top)];
    topHeader.backgroundColor = kGmailColor;
    topHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Create the attributed string
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc]initWithString:@"GMAIL INTEGRATION"];
    [titleString addAttribute:NSKernAttributeName value:@(1.5) range:NSMakeRange(0, titleString.length)];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, top, self.view.bounds.size.width, kTopHeight)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    titleLabel.attributedText = titleString;
    titleLabel.numberOfLines = 0;
    titleLabel.font = KP_SEMIBOLD(10);
    titleLabel.backgroundColor = CLEAR;
    titleLabel.textColor = alpha(tcolorF(TextColor, ThemeDark),0.8);
    [topHeader addSubview:titleLabel];

    [self.view addSubview:topHeader];
    
    UIButton *closeButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, top, kTopHeight, kTopHeight)];
    closeButton.titleLabel.font = iconFont(23);
    [closeButton setTitleColor:tcolorF(TextColor, ThemeDark) forState:UIControlStateNormal];
    [closeButton setTitle:iconString(@"roundClose") forState:UIControlStateNormal];
    [closeButton setTitle:iconString(@"roundClose") forState:UIControlStateHighlighted];
    //closeButton.transform = CGAffineTransformMakeRotation(M_PI/2/2);
    closeButton.backgroundColor = CLEAR;
    [closeButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    // Do any additional setup after loading the view.
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topHeader.frame), self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(topHeader.frame))];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    WalkthroughTitleView *firstTitleView = [[WalkthroughTitleView alloc] init];
    CGRectSetWidth(firstTitleView, self.view.bounds.size.width);
    firstTitleView.titleLabel.font = KP_SEMIBOLD(12);
    firstTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    firstTitleView.titleLabel.textColor = tcolorF(TextColor, ThemeLight);
    firstTitleView.subtitleLabel.font = KP_REGULAR(12);
    firstTitleView.spacing = kTextSpacing;
    firstTitleView.maxWidth = 250;
    [firstTitleView setTitle:LOCALIZE_STRING(@"TURN EMAILS INTO TASKS") subtitle:LOCALIZE_STRING(@"To de-clutter your inbox from tasks, use this integration. The integration works with all Gmail based clients.\n\nRecommended workflow with:")];
    CGRectSetY(firstTitleView, kTitleTopSpacing);
    [scrollView addSubview:firstTitleView];
    
    UIImageView *firstImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipes-ui-gmail-integrations-1"]];
    CGRectSetY(firstImage, CGRectGetMaxY( firstTitleView.frame ) + kImageTopSpacing);
    firstImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CGRectSetX(firstImage, scrollView.frame.size.width/2-firstImage.frame.size.width/2);
    [scrollView addSubview:firstImage];
    
    
    WalkthroughTitleView *secondTitleView = [[WalkthroughTitleView alloc] init];
    CGRectSetWidth(secondTitleView, self.view.bounds.size.width);
    secondTitleView.titleLabel.font = KP_SEMIBOLD(12);
    secondTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    secondTitleView.titleLabel.textColor = tcolorF(TextColor, ThemeLight);
    secondTitleView.subtitleLabel.font = KP_REGULAR(12);
    secondTitleView.spacing = kTextSpacing;
    secondTitleView.maxWidth = 250;
    [secondTitleView setTitle:LOCALIZE_STRING(@"HOW TO IMPORT FROM GMAIL") subtitle:LOCALIZE_STRING(@"Move an email to the \"Add to Swipes\" folder in your Gmail client.")];
    CGRectSetY(secondTitleView, CGRectGetMaxY(firstImage.frame)+kTitleTopSpacing);
    [scrollView addSubview:secondTitleView];
    
    UIImageView *secondImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipes-ui-gmail-integrations-2"]];
    secondImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CGRectSetY(secondImage, CGRectGetMaxY( secondTitleView.frame ) + kImageTopSpacing);
    CGRectSetX(secondImage, scrollView.frame.size.width/2-secondImage.frame.size.width/2);
    [scrollView addSubview:secondImage];
    
    
    WalkthroughTitleView *thirdTitleView = [[WalkthroughTitleView alloc] init];
    CGRectSetWidth(thirdTitleView, self.view.bounds.size.width);
    thirdTitleView.titleLabel.font = KP_SEMIBOLD(12);
    thirdTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    thirdTitleView.titleLabel.textColor = tcolorF(TextColor, ThemeLight);
    thirdTitleView.subtitleLabel.font = KP_REGULAR(12);
    thirdTitleView.spacing = kTextSpacing;
    thirdTitleView.maxWidth = 250;
    [thirdTitleView setTitle:LOCALIZE_STRING(@"HOW TO IMPORT FROM GMAIL") subtitle:LOCALIZE_STRING(@"Move an email to the \"Add to Swipes\" folder in your Gmail client.")];
    CGRectSetY(thirdTitleView, CGRectGetMaxY(secondImage.frame)+kTitleTopSpacing);
    [scrollView addSubview:thirdTitleView];
    
    UIImageView *thirdImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipes-ui-gmail-integrations-3"]];
    thirdImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CGRectSetY(thirdImage, CGRectGetMaxY( thirdTitleView.frame ) + kImageTopSpacing);
    CGRectSetX(thirdImage, scrollView.frame.size.width/2-thirdImage.frame.size.width/2);
    [scrollView addSubview:thirdImage];
    
    
    SlowHighlightIcon *getStartedButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [getStartedButton setTitle:[LOCALIZE_STRING(@"Get Started") uppercaseString] forState:UIControlStateNormal];
    getStartedButton.layer.cornerRadius = 5;
    getStartedButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    getStartedButton.titleLabel.font = KP_LIGHT(18);
    getStartedButton.layer.masksToBounds = YES;
    [getStartedButton setBackgroundImage:[alpha(tcolor(LaterColor), 0.5) image] forState:UIControlStateHighlighted];
    [getStartedButton setBackgroundImage:[tcolor(LaterColor) image] forState:UIControlStateNormal];
    [getStartedButton addTarget:self action:@selector(pressedGetStarted:) forControlEvents:UIControlEventTouchUpInside];
    //getStartedButton.backgroundColor = tcolor(LaterColor);
    CGRectSetCenter(getStartedButton, scrollView.frame.size.width/2, CGRectGetMaxY(thirdImage.frame) + kTitleTopSpacing + getStartedButton.frame.size.height/2);
    [scrollView addSubview:getStartedButton];
    
    [self.view addSubview:scrollView];
    scrollView.scrollEnabled = YES;
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(getStartedButton.frame)+kTitleTopSpacing);
}

-(void)pressedGetStarted:(UIButton*)sender{
    self.success = YES;
    [self pressedClose:sender];
}

-(void)pressedClose:(UIButton*)button{
    [self dismissViewControllerAnimated:!self.success completion:^{
        if([self.delegate respondsToSelector:@selector(endedGmailHelperSuccessfully:)])
            [self.delegate endedGmailHelperSuccessfully:self.success];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)dealloc{
    self.scrollView = nil;
}

@end
