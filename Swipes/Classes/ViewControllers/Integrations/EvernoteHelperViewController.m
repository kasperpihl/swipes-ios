//
//  EvernoteHelperViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 21/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "SlowHighlightIcon.h"
#import "WalkthroughTitleView.h"
#import "EvernoteHelperViewController.h"
#define kTopHeight 50
#define kIconHack 0
#define kTextSpacing 10
#define kTitleTopSpacing 45
#define kImageTopSpacing 20
@interface EvernoteHelperViewController ()
@property (nonatomic) UIScrollView *scrollView;
@end

@implementation EvernoteHelperViewController

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
    
    self.view.backgroundColor = gray(225,1);
    
    CGFloat top = OSVER >= 7 ? 20 : 0;
    UIView *topHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kTopHeight + top)];
    topHeader.backgroundColor = kEvernoteColor;
    topHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    
    UILabel *iconLabel = iconLabel(@"integrationEvernoteFull", kTopHeight/2);
    CGRectSetCenter(iconLabel, self.view.bounds.size.width/2-kIconHack, top + kTopHeight/2);
    iconLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    iconLabel.textColor = alpha(tcolorF(TextColor, ThemeLight),0.8);
    [topHeader addSubview:iconLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, top, self.view.bounds.size.width, kTopHeight)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    titleLabel.text = @"      EVERNOTE            INTEGRATION";
    titleLabel.numberOfLines = 0;
    titleLabel.font = KP_SEMIBOLD(15);
    titleLabel.backgroundColor = CLEAR;
    titleLabel.textColor = alpha(tcolorF(TextColor, ThemeLight),0.8);
    [topHeader addSubview:titleLabel];

    [self.view addSubview:topHeader];
    
    UIButton *closeButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, top, kTopHeight, kTopHeight)];
    closeButton.titleLabel.font = iconFont(23);
    [closeButton setTitleColor:tcolorF(TextColor, ThemeLight) forState:UIControlStateNormal];
    [closeButton setTitle:iconString(@"roundClose") forState:UIControlStateNormal];
    [closeButton setTitle:iconString(@"roundCloseFull") forState:UIControlStateHighlighted];
    //closeButton.transform = CGAffineTransformMakeRotation(M_PI/4);
    closeButton.backgroundColor = CLEAR;
    [closeButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    // Do any additional setup after loading the view.
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topHeader.frame), self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(topHeader.frame))];
    
    WalkthroughTitleView *firstTitleView = [[WalkthroughTitleView alloc] init];
    CGRectSetWidth(firstTitleView, 320);
    firstTitleView.titleLabel.font = KP_LIGHT(20);
    firstTitleView.titleLabel.textColor = tcolorF(TextColor, ThemeLight);
    firstTitleView.subtitleLabel.font = KP_LIGHT(14);
    firstTitleView.spacing = kTextSpacing;
    firstTitleView.maxWidth = 250;
    [firstTitleView setTitle:@"HOW SYNC WORKS" subtitle:@"All your Evernote Checkmarks are synced across your Swipes Action Steps."];
    CGRectSetY(firstTitleView, kTitleTopSpacing);
    [scrollView addSubview:firstTitleView];
    
    UIImageView *firstImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipesandevernote"]];
    CGRectSetY(firstImage, CGRectGetMaxY( firstTitleView.frame ) + kImageTopSpacing);
    CGRectSetX(firstImage, scrollView.frame.size.width/2-firstImage.frame.size.width/2);
    [scrollView addSubview:firstImage];
    
    
    WalkthroughTitleView *secondTitleView = [[WalkthroughTitleView alloc] init];
    CGRectSetWidth(secondTitleView, 320);
    secondTitleView.titleLabel.font = KP_LIGHT(20);
    secondTitleView.titleLabel.textColor = tcolorF(TextColor, ThemeLight);
    secondTitleView.subtitleLabel.font = KP_LIGHT(14);
    secondTitleView.spacing = kTextSpacing;
    secondTitleView.maxWidth = 250;
    [secondTitleView setTitle:@"IMPORT NOTES" subtitle:@"Automatically from your Evernote. Simply attach the \"swipes\" tag."];
    CGRectSetY(secondTitleView, CGRectGetMaxY(firstImage.frame)+kTitleTopSpacing);
    [scrollView addSubview:secondTitleView];
    
    UIImageView *secondImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipesevernotetag"]];
    CGRectSetY(secondImage, CGRectGetMaxY( secondTitleView.frame ) + kImageTopSpacing);
    CGRectSetX(secondImage, scrollView.frame.size.width/2-secondImage.frame.size.width/2);
    [scrollView addSubview:secondImage];
    
    
    SlowHighlightIcon *getStartedButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    
    
    [self.view addSubview:scrollView];
    scrollView.scrollEnabled = YES;
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(secondImage.frame)+kTitleTopSpacing);
}

-(void)pressedClose:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:^{
        
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
