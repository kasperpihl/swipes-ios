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

@implementation TagsViewController {
    NSArray* _tagsAsStrings;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tagList.sorted = YES;
    self.tagList.addTagButton = NO;
    self.tagList.emptyText = NSLocalizedString(@"No tags", nil);
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
    _tagsAsStrings = [KPTag allTagsAsStrings];
    [self.tagList setTags:_tagsAsStrings andSelectedTags:_selectedTags ? _selectedTags : @[]];
    //self.scrollView.contentSize = CGSizeMake(self.tagList.frame.size.width, self.tagList.frame.size.height);
    
}

- (void)setSelectedTags:(NSArray *)selectedTags
{
    _selectedTags = [selectedTags copy];
    [self.tagList setTags:_tagsAsStrings andSelectedTags:_selectedTags ? _selectedTags : @[]];
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

@end
