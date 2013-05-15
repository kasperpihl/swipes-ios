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
#define CLEARED_SEPERATOR_TAG 1006
#define FILTER_VIEW_MIDDLE_SEPERATOR_TAG 1007
#define FILTER_VIEW_BOTTOM_SEPERATOR_TAG 1008

#define CLEAR_FILTER_BUTTON_SPACE 70


#define CLEAR_FILTER_BUTTON_WIDTH 60
#define CLEAR_FILTER_BUTTON_Y 4
#define CLEAR_FILTER_BUTTON_HEIGHT 30


#import "KPSearchBar.h"
#import "KPTagList.h"
#import "UtilityClass.h"
#import "ToDoHandler.h"
@interface KPSearchBar () <KPTagDelegate>
@property (nonatomic,weak) IBOutlet UITextField *searchField;
@property (nonatomic,weak) IBOutlet UIView *filterView;
@property (nonatomic,weak) IBOutlet UIButton *filterButton;
@property (nonatomic,weak) IBOutlet KPTagList *selectedTagListView;
@property (nonatomic,weak) IBOutlet UIView *clearedColorSeperatorView;
@property (nonatomic,weak) IBOutlet UIView *filterViewMiddleSeperator;
@property (nonatomic,weak) IBOutlet UIView *filterViewBottomSeperator;
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
    [self reloadDataAndUpdate:YES];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    [self.searchBarDelegate searchBar:self deselectedTag:tag];
    [self reloadDataAndUpdate:YES];
}
-(void)reloadDataAndUpdate:(BOOL)update{
    if([self.searchBarDataSource respondsToSelector:@selector(selectedTagsForSearchBar:)]){
        self.selectedTags = [self.searchBarDataSource selectedTagsForSearchBar:self];
    }
    if([self.searchBarDataSource respondsToSelector:@selector(unselectedTagsForSearchBar:)]){
        self.unselectedTags = [self.searchBarDataSource unselectedTagsForSearchBar:self];
    }
    if(update) [self reframeTags];
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UtilityClass imageWithColor:SEGMENT_SELECTED]];
        //[self setTranslucent:YES];
        self.placeholder = @"Search";
        self.backgroundColor = [UIColor clearColor];
           
        CGFloat buttonSize = self.frame.size.height-COLOR_SEPERATOR_HEIGHT;
        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterButton addTarget:self action:@selector(pressedFilter:) forControlEvents:UIControlEventTouchUpInside];
        filterButton.tag = FILTER_BUTTON_TAG;
        filterButton.frame = CGRectMake(self.frame.size.width-buttonSize, 0, buttonSize, buttonSize);
        [filterButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
        //[filterButton setBackgroundImage:[UtilityClass imageWithColor:SWIPES_BLUE] forState:UIControlStateNormal];
        [self addSubview:filterButton];
        self.filterButton = (UIButton*)[self viewWithTag:FILTER_BUTTON_TAG];
        
        
        /* Instantiate filter view */
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
        filterView.tag = FILTER_VIEW_TAG;
        filterView.hidden = YES;
        filterView.backgroundColor = SEGMENT_SELECTED;

        KPTagList *selectedTagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-TAG_HEIGHT-DEFAULT_SPACING, 0)];
        selectedTagList.marginLeft = 0;
        selectedTagList.marginTop = 0;
        selectedTagList.emptyLabelMarginHack = 10;//(TAG_HEIGHT+DEFAULT_SPACING)/2;
        selectedTagList.marginRight = 6;
        selectedTagList.bottomMargin = 0;
        selectedTagList.emptyText = @"Filter";
        selectedTagList.tagDelegate = self;
        selectedTagList.tag = SELECTED_TAG_LIST_TAG;
        [filterView addSubview:selectedTagList];
        
        UIButton *clearFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearFilterButton.frame = CGRectMake(self.frame.size.width-buttonSize,0,buttonSize,buttonSize);
        //[clearFilterButton setBackgroundImage:[UtilityClass imageWithColor:SWIPES_BLUE] forState:UIControlStateNormal];
        [clearFilterButton setImage:[UIImage imageNamed:@"cross_button"] forState:UIControlStateNormal];
        [clearFilterButton addTarget:self action:@selector(pressedClearFilter:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:clearFilterButton];
        self.selectedTagListView = (KPTagList*)[filterView viewWithTag:SELECTED_TAG_LIST_TAG];
        KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        tagList.emptyText = @"No tags assigned";
        tagList.marginLeft = 0;
        tagList.marginTop = 0;
        tagList.marginRight = 0;
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
    if(!(searchField == nil) && !self.searchField) {
        self.searchField = searchField;
        CGRectSetX(searchField.frame, 10);
        CGRectSetSize(searchField.frame, self.frame.size.width-(2*searchField.frame.origin.x)-(self.frame.size.height-COLOR_SEPERATOR_HEIGHT), searchField.frame.size.height);
        searchField.font = TEXT_FIELD_FONT;
        searchField.borderStyle = UITextBorderStyleNone;
        searchField.textColor = [UIColor whiteColor];
        [searchField setBackground:[[UIImage alloc] init]];
        
        [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        searchField.leftView = nil;
        

    }
    
    
}
-(void)pressedClearFilter:(UIButton*)sender{
    if([self.searchBarDelegate respondsToSelector:@selector(clearedAllFiltersForSearchBar:)]) [self.searchBarDelegate clearedAllFiltersForSearchBar:self];
}
-(void)reframe{
    [self.selectedTagListView setTags:self.selectedTags andSelectedTags:self.selectedTags];
    CGFloat tagWidth = self.selectedTagListView.isEmptyList ? (self.frame.size.width-TAG_HEIGHT-DEFAULT_SPACING) : self.frame.size.width;
    CGRectSetSize(self.tagListView.frame, tagWidth, self.tagListView.frame.size.height);
    [self.tagListView setTags:self.unselectedTags andSelectedTags:nil];
    
    CGFloat tempHeight = 0;
    self.selectedTagListView.hidden = self.selectedTagListView.isEmptyList;
    if(!self.selectedTagListView.isEmptyList){
        tempHeight += self.selectedTagListView.frame.size.height + COLOR_SEPERATOR_HEIGHT;
    }
    if(!self.selectedTagListView.isEmptyList) self.tagListView.hidden = self.tagListView.isEmptyList;
    else self.tagListView.hidden = NO;
    CGRectSetY(self.tagListView.frame, tempHeight);
    tempHeight += self.tagListView.frame.size.height;
    CGRectSetSize(self.filterView.frame, self.frame.size.width, tempHeight);
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
                [self reloadDataAndUpdate:NO];
                [self reframeToTags];
                //[self reframeToTags];
                break;
            case KPSearchBarModeNone:
                [self reframeToNone];
                break;
        }
    }
}
-(void)reframeToNone{
    [self.superview bringSubviewToFront:self];
    [UIView animateWithDuration:0.5 animations:^{
        CGRectSetY(self.filterView.frame,0-self.filterView.frame.size.height-TEXT_FIELD_CONTAINER_HEIGHT);
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                TEXT_FIELD_CONTAINER_HEIGHT);
        [self resizeTableHeader];
        [(UITableView *)self.superview setContentOffset:CGPointMake(0, TEXT_FIELD_CONTAINER_HEIGHT)];
    } completion:^(BOOL finished) {
        self.filterButton.hidden = NO;
        self.clearedColorSeperatorView.hidden = NO;
        self.searchField.hidden = NO;
        self.filterView.hidden = YES;
        
        
    }];

}
-(void)resizeTableHeader{
    UITableView *superView = (UITableView *)self.superview;
    UIView *tableHeader = superView.tableHeaderView;
    tableHeader.frame = self.bounds;
    [superView setTableHeaderView:tableHeader];
}
- (void)reframeTags{
    [self reframe];
    NSInteger newHeight = self.filterView.frame.size.height;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            newHeight);
    [self resizeTableHeader];
}
- (void)reframeToTags{
    NSUInteger oldHeight = self.frame.size.height;
    self.filterButton.hidden = YES;
    self.searchField.hidden = YES;
    [self reframe];
    CGRectSetY(self.filterView.frame, 0-self.filterView.frame.size.height+oldHeight);
    self.filterView.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        NSInteger newHeight = self.filterView.frame.size.height;
        CGRectSetY(self.filterView.frame, 0);
        NSInteger originChange = oldHeight - newHeight;
        for (UIView *view in [(UITableView *)self.superview subviews]) {
            if ([view isKindOfClass:[self class]]) {
                continue;
            }
            view.frame = CGRectMake(view.frame.origin.x,
                                    view.frame.origin.y - originChange,
                                    view.frame.size.width,
                                    view.frame.size.height);
        }
    } completion:^(BOOL finished) {
        NSInteger newHeight = self.filterView.frame.size.height;
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                newHeight);
        self.filterView.hidden = NO;
        self.clearedColorSeperatorView.hidden = YES;
        [self resizeTableHeader];
    }];
}

@end
