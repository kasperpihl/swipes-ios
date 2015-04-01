//
//  TagsViewController.m
//  Swipes
//
//  Created by demosten on 3/31/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "KPTag.h"
#import "TagsViewController.h"

static const NSUInteger kTagMargin = 6;
static const NSUInteger kTagSpacing = 6;

@interface TagsViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

@end

@implementation TagsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tagList.sorted = YES;
    self.tagList.addTagButton = NO;
    self.tagList.emptyText = LOCALIZE_STRING(@"No tags");
    self.tagList.tagBackgroundColor = tcolorF(BackgroundColor, ThemeLight);
    self.tagList.tagTitleColor = tcolorF(TextColor, ThemeLight);
    self.tagList.tagBorderColor = tcolorF(TextColor, ThemeLight);
    self.tagList.selectedTagBackgroundColor = tcolorF(BackgroundColor, ThemeDark);
    self.tagList.selectedTagTitleColor = tcolorF(TextColor, ThemeDark);
    self.tagList.selectedTagBorderColor = tcolorF(TextColor, ThemeLight);
    self.tagList.marginTop = kTagMargin;
    self.tagList.bottomMargin = kTagMargin;
    self.tagList.marginLeft = kTagMargin;
    self.tagList.marginRight = kTagMargin;
    self.tagList.spacing = kTagSpacing;
    [self.tagList setTags:[KPTag allTagsAsStrings] andSelectedTags:@[]];
    //self.scrollView.contentSize = CGSizeMake(self.tagList.frame.size.width, self.tagList.frame.size.height);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    [_tagList sizeToFit];
    self.scrollView.contentSize = CGSizeMake(self.tagList.frame.size.width, self.tagList.frame.size.height);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
