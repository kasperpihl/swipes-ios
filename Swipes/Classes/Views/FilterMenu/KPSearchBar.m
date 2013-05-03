//
//  KPSearchBar.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 02/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define CLEAR_FILTER_BUTTON_TAG 1000
#define TAG_LIST_TAG 1001
#define SELECTED_TAG_LIST_TAG 1002
#define FILTER_VIEW_TAG 1003
#define FILTER_BUTTON_TAG 1005
#define CLEAR_FILTER_BUTTON_SPACE 70

#define CLEAR_FILTER_BUTTON_WIDTH 60
#define CLEAR_FILTER_BUTTON_Y 4
#define CLEAR_FILTER_BUTTON_HEIGHT 30
#define SEARCH_BAR_ORIGINAL_HEIGHT 44

#import "KPSearchBar.h"
#import "KPTagList.h"
#import "UtilityClass.h"
@interface KPSearchBar () <KPTagDelegate>
@property (nonatomic,weak) IBOutlet UITextField *searchField;
@property (nonatomic,weak) IBOutlet UIView *filterView;
@property (nonatomic,weak) IBOutlet UIButton *filterButton;
@property (nonatomic,weak) IBOutlet KPTagList *selectedTagListView;
@property (nonatomic,strong) NSArray *selectedTags;
@property (nonatomic,strong) NSArray *unselectedTags;
@property (nonatomic,weak) IBOutlet KPTagList *tagListView;
@end
@implementation KPSearchBar
@synthesize searchField = __searchField;
-(void)setSearchBarDataSource:(NSObject<KPSearchBarDataSource> *)searchBarDataSource{
    _searchBarDataSource = searchBarDataSource;
    //[self reloadData];
}
-(void)tagList:(KPTagList *)tagList selectedTag:(NSString *)tag{
    [self.searchBarDelegate searchBar:self selectedTag:tag];
    [self reloadData];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    [self.searchBarDelegate searchBar:self deselectedTag:tag];
    [self reloadData];
}
-(void)reloadData{
    if([self.searchBarDataSource respondsToSelector:@selector(selectedTagsForSearchBar:)]){
        self.selectedTags = [self.searchBarDataSource selectedTagsForSearchBar:self];
    }
    if([self.searchBarDataSource respondsToSelector:@selector(unselectedTagsForSearchBar:)]){
        self.unselectedTags = [self.searchBarDataSource unselectedTagsForSearchBar:self];
    }
    [self reframeToTags];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage new]];
        [self setTranslucent:YES];
        self.placeholder = @"Search";
        self.backgroundColor = [UIColor clearColor];
        
        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterButton addTarget:self action:@selector(pressedFilter:) forControlEvents:UIControlEventTouchUpInside];
        filterButton.tag = FILTER_BUTTON_TAG;
        filterButton.frame = CGRectMake(320-57, 0, 44, 44);
        [filterButton setImage:[UIImage imageNamed:@"filterButton"] forState:UIControlStateNormal];
        [self addSubview:filterButton];
        self.filterButton = (UIButton*)[self viewWithTag:FILTER_BUTTON_TAG];
        
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
        filterView.tag = FILTER_VIEW_TAG;
        filterView.hidden = YES;
        
        
        
        KPTagList *selectedTagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-CLEAR_FILTER_BUTTON_SPACE, 0)];
        selectedTagList.emptyText = @"No tags selected";
        selectedTagList.tagDelegate = self;
        selectedTagList.tag = SELECTED_TAG_LIST_TAG;
        [filterView addSubview:selectedTagList];
        
        UIButton *clearFilterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        clearFilterButton.frame = CGRectMake(self.frame.size.width-CLEAR_FILTER_BUTTON_SPACE+((CLEAR_FILTER_BUTTON_SPACE-CLEAR_FILTER_BUTTON_WIDTH)/2), CLEAR_FILTER_BUTTON_Y, CLEAR_FILTER_BUTTON_WIDTH, CLEAR_FILTER_BUTTON_HEIGHT);
        [clearFilterButton setTitle:@"Clear" forState:UIControlStateNormal];
        [clearFilterButton addTarget:self action:@selector(pressedClearFilter:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:clearFilterButton];
        self.selectedTagListView = (KPTagList*)[filterView viewWithTag:SELECTED_TAG_LIST_TAG];
        KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        tagList.emptyText = @"No tags available for items";
        tagList.tagDelegate = self;
        tagList.tag = TAG_LIST_TAG;
        [filterView addSubview:tagList];
        self.tagListView = (KPTagList*)[filterView viewWithTag:TAG_LIST_TAG];
        [self addSubview:filterView];
        self.filterView = [self viewWithTag:FILTER_VIEW_TAG];
    }
    return self;
}
- (void)layoutSubviews {
    UITextField *searchField;
    NSUInteger numViews = [self.subviews count];
    for(int i = 0; i < numViews; i++) {
        if([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
            searchField = [self.subviews objectAtIndex:i];
        }
    }
    [super layoutSubviews];
    if(!(searchField == nil)) {
        self.searchField = searchField;
        CGRectSetSize(searchField.frame, 250, searchField.frame.size.height);
        //searchField.textColor = [UIColor whiteColor];
        //[searchField setBackground: [UIImage imageNamed:@"buscador.png"] ];
        //[searchField setBorderStyle:UITextBorderStyleNone];
    }
    
    
}
-(void)pressedClearFilter:(UIButton*)sender{
    if([self.searchBarDelegate respondsToSelector:@selector(clearedAllFiltersForSearchBar:)]) [self.searchBarDelegate clearedAllFiltersForSearchBar:self];
}
-(void)reframe{
    CGFloat tempHeight = 0;
    tempHeight += self.selectedTagListView.frame.size.height;
    self.tagListView.hidden = NO;
    CGRectSetY(self.tagListView.frame, tempHeight);
    tempHeight += self.tagListView.frame.size.height;
    CGRectSetSize(self.filterView.frame, self.frame.size.width, tempHeight);
    //[(UITableView *)self.superview setTableHeaderView:self];
    //[self adjustTableHeaderHeight:tempHeight];
}
-(void)pressedFilter:(UIButton*)sender{
    if([self.searchBarDelegate respondsToSelector:@selector(searchBar:pressedFilterButton:)])
        [self.searchBarDelegate searchBar:self pressedFilterButton:sender];
}
-(void)setCurrentMode:(KPSearchBarMode)currentMode{
    if(currentMode != _currentMode){
        _currentMode = currentMode;
        switch (currentMode) {
            case KPSearchBarModeTags:
                [self reloadData];
                break;
            case KPSearchBarModeNone:
                [self reframeToNone];
                break;
        }
    }
}
-(void)reframeToNone{
    NSUInteger oldHeight = self.frame.size.height;
    self.filterView.hidden = YES;
    self.filterButton.hidden = NO;
    self.searchField.hidden = NO;
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    NSInteger newHeight = SEARCH_BAR_ORIGINAL_HEIGHT;
    NSInteger originChange = oldHeight - newHeight;
    NSLog(@"new:%i orig: %i",newHeight,originChange);
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            newHeight);
    
    for (UIView *view in [(UITableView *)self.superview subviews]) {
        if ([view isKindOfClass:[self class]]) {
            continue;
        }
        view.frame = CGRectMake(view.frame.origin.x,
                                view.frame.origin.y - originChange,
                                view.frame.size.width,
                                view.frame.size.height);
    }
    [UIView commitAnimations];
}
- (void)reframeToTags{
    NSUInteger oldHeight = self.frame.size.height;
    self.filterButton.hidden = YES;
    self.searchField.hidden = YES;
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    self.filterView.hidden = NO;
    [self.tagListView setTags:self.unselectedTags andSelectedTags:nil];
    [self.selectedTagListView setTags:self.selectedTags andSelectedTags:self.selectedTags];
    [self reframe];
    NSInteger newHeight = self.filterView.frame.size.height;
    NSInteger originChange = oldHeight - newHeight;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            newHeight);
    
    for (UIView *view in [(UITableView *)self.superview subviews]) {
        if ([view isKindOfClass:[self class]]) {
            continue;
        }
        view.frame = CGRectMake(view.frame.origin.x,
                                view.frame.origin.y - originChange,
                                view.frame.size.width,
                                view.frame.size.height);
    }
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    [(UITableView *)self.superview setTableHeaderView:self];
}
@end
