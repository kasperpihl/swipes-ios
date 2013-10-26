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
#import "SlowHighlightIcon.h"
#import "UIColor+Utilities.h"
@interface KPSearchBar () <KPTagDelegate,UITextFieldDelegate>

@property (nonatomic,weak) IBOutlet UIView *filterView;
@property (nonatomic,weak) IBOutlet UIButton *filterButton;
@property (nonatomic) UIButton *clearButton;
@property (nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic,weak) IBOutlet UIView *filterViewMiddleSeperator;
@property (nonatomic,weak) IBOutlet UIView *filterViewBottomSeperator;
@property (nonatomic,strong) NSArray *selectedTags;
@property (nonatomic,strong) NSArray *unselectedTags;
@property (nonatomic) NSInteger height;

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
        self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_LEFT, 0, self.frame.size.width-TEXT_FIELD_MARGIN_LEFT-self.frame.size.height, self.frame.size.height)];
        self.searchField.font = TEXT_FIELD_FONT;
        self.searchField.textColor = tcolor(TextColor);
        self.searchField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.searchField.returnKeyType = UIReturnKeyDone;
        self.searchField.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        self.searchField.placeholder = @"Search";
        self.searchField.borderStyle = UITextBorderStyleNone;
        self.searchField.delegate = self;
        self.searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        @try {
            self.backgroundColor = tbackground(BackgroundColor);
            [self.searchField setValue:tcolor(TextColor) forKeyPath:@"_placeholderLabel.textColor"];
        }
        @catch (NSException *exception) {
            
        }
        self.searchField.userInteractionEnabled = YES;
        //CGRectSetSize(searchField, self.frame.size.width-(2*searchField.frame.origin.x)-(self.frame.size.height), searchField.frame.size.height);
        //searchField.enablesReturnKeyAutomatically = NO;
        //searchField.clearButtonMode = UITextFieldViewModeNever;
        [self.searchField addTarget:self action:@selector(startedSearch:) forControlEvents:UIControlEventEditingDidBegin];
        [self.searchField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.searchField];
        
        
        
        /* Instantiate filter view */
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
        filterView.tag = FILTER_VIEW_TAG;
        filterView.hidden = YES;
        
        
        KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        tagList.emptyText = @"No tags assigned";
        //UIColor *tagColor = gray(0,1);
        //tagList.tagBackgroundColor = CLEAR;
        //tagList.selectedTagBackgroundColor = tagColor;
        //tagList.tagBorderColor = tagColor;
        //tagList.tagTitleColor = tagColor;
        //tagList.selectedTagTitleColor = tcolor(TextColor);
        tagList.spacing = 8;
        tagList.marginLeft = tagList.spacing;
        tagList.marginTop = (14+tagList.spacing)/2;
        tagList.emptyLabelMarginHack = 10;
        tagList.firstRowSpacingHack = 44;
        tagList.bottomMargin = (16+tagList.spacing)/2;
        tagList.marginRight = tagList.spacing;
        tagList.tagDelegate = self;
        tagList.tag = TAG_LIST_TAG;
        [filterView addSubview:tagList];
        self.tagListView = (KPTagList*)[filterView viewWithTag:TAG_LIST_TAG];
        
        [self addSubview:filterView];
        self.filterView = [self viewWithTag:FILTER_VIEW_TAG];
        //self.hidden = YES;
        
        CGFloat buttonSize = self.frame.size.height;
        SlowHighlightIcon *filterButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        [filterButton addTarget:self action:@selector(pressedFilter:) forControlEvents:UIControlEventTouchUpInside];
        [filterButton setImage:[UIImage imageNamed:@"tag_icon_white"] forState:UIControlStateNormal];
        [filterButton setImage:[UIImage imageNamed:@"tag_icon_white-high"] forState:UIControlStateHighlighted];
        filterButton.tag = FILTER_BUTTON_TAG;
        filterButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        filterButton.frame = CGRectMake(self.frame.size.width-buttonSize, 0, buttonSize, buttonSize);
        //[filterButton setBackgroundImage:[UtilityClass imageWithColor:SWIPES_COLOR] forState:UIControlStateNormal];
        [self addSubview:filterButton];
        self.filterButton = (UIButton*)[self viewWithTag:FILTER_BUTTON_TAG];
        
        UIButton *clearFilterButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        clearFilterButton.frame = CGRectMake(self.frame.size.width-buttonSize,0,buttonSize,buttonSize);
        //[clearFilterButton setBackgroundImage:[UtilityClass imageWithColor:SWIPES_COLOR] forState:UIControlStateNormal];
        [clearFilterButton setImage:[UIImage imageNamed:@"round_cross_small"] forState:UIControlStateNormal];
        [clearFilterButton setImage:[UIImage imageNamed:@"round_cross_small-high"] forState:UIControlStateHighlighted];
        [clearFilterButton addTarget:self action:@selector(pressedClearFilter:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearFilterButton];
        clearFilterButton.hidden = YES;
        self.clearButton = clearFilterButton;

        CGRectSetHeight(self, 0);
    }
    return self;
}
-(void)resignSearchField{
    if(self.currentMode == KPSearchBarModeSearch){
        if(self.searchField.text.length == 0) [self pressedClearFilter:self.filterButton];
        else [self.searchField resignFirstResponder];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.currentMode = KPSearchBarModeReady;
    return YES;
}
-(void)textFieldChanged:(UITextField*)sender{
    if([self.searchBarDelegate respondsToSelector:@selector(searchBar:searchedForString:)]) [self.searchBarDelegate searchBar:self searchedForString:sender.text];
}
-(void)startedSearch:(UITextField*)sender{
    if([self.searchBarDelegate respondsToSelector:@selector(startedSearchBar:)]) [self.searchBarDelegate startedSearchBar:self];
    self.currentMode = KPSearchBarModeSearch;
}
-(void)pressedClearFilter:(UIButton*)sender{
    if([self.searchBarDelegate respondsToSelector:@selector(clearedAllFiltersForSearchBar:)]) [self.searchBarDelegate clearedAllFiltersForSearchBar:self];
    self.currentMode = KPSearchBarModeReady;
}
-(void)reframe{
    NSArray *totalTags = [self.selectedTags arrayByAddingObjectsFromArray:self.unselectedTags];
    [self.tagListView setTags:totalTags andSelectedTags:self.selectedTags];
    CGFloat tempHeight = 0;
    CGRectSetY(self.tagListView, tempHeight);
    tempHeight += self.tagListView.frame.size.height;
    CGRectSetSize(self.filterView, self.frame.size.width, tempHeight);
}
-(void)pressedFilter:(UIButton*)sender{
    if(self.currentMode == KPSearchBarModeNone || self.currentMode == KPSearchBarModeReady){
        if([self.searchBarDelegate respondsToSelector:@selector(startedSearchBar:)]) [self.searchBarDelegate startedSearchBar:self];
        self.currentMode = KPSearchBarModeTags;
    }
}
-(void)setCurrentMode:(KPSearchBarMode)currentMode{
    if(currentMode != _currentMode){
        KPSearchBarMode oldMode = _currentMode;
        _currentMode = currentMode;
        switch (currentMode) {
            case KPSearchBarModeReady:
                [self readyToSearchFrom:oldMode];
                break;
            case KPSearchBarModeTags:
                [self reloadDataAndUpdate:NO];
                [self reframeTags];
                //[self reframeToTags];
                break;
            case KPSearchBarModeNone:
                [self reframeToNoneFrom:oldMode];
                break;
            case KPSearchBarModeSearch:
                [self reframeToSearch];
                break;
        }
    }
}
-(void)readyToSearchFrom:(KPSearchBarMode)oldMode{
    
    if(oldMode == KPSearchBarModeSearch){
        [self.searchField resignFirstResponder];
        self.searchField.text = @"";
    }
    CGRectSetHeight(self,SEARCH_BAR_DEFAULT_HEIGHT);
    
    self.filterView.hidden = YES;
    self.filterButton.hidden = NO;
    self.searchField.hidden = NO;
    self.clearButton.hidden = YES;
    //if(superView) [superView setContentOffset:CGPointMake(0, 0)];
    [self resizeTableHeader];
}
-(void)reframeToSearch{
    self.clearButton.hidden = NO;
    self.filterButton.hidden = YES;
}
-(void)reframeToNoneFrom:(KPSearchBarMode)oldMode{
    CGFloat oldHeight = self.frame.size.height;
    UITableView* superView = (UITableView*)self.superview;
    [UIView animateWithDuration:.2f animations:^{
        if(superView) [superView setContentOffset:CGPointMake(0, -oldHeight)];
    } completion:^(BOOL finished) {
        CGRectSetHeight(self,0);
        [self resizeTableHeader];
        //if(superView) [superView setContentOffset:CGPointMake(0, superView.contentOffset.y-oldHeight)];
        
    }];
}
-(void)resizeTableHeader{
    UITableView *superView = (UITableView *)self.superview;
    UIView *tableHeader = superView.tableHeaderView;
    tableHeader.frame = self.bounds;
    CGRectSetHeight(tableHeader,tableHeader.frame.size.height);
    [superView setTableHeaderView:tableHeader];
}
- (void)reframeTags{
    if(self.currentMode != KPSearchBarModeTags){
        return;
    }
    self.filterButton.hidden = YES;
    self.clearButton.hidden = NO;
    self.searchField.hidden = YES;
    self.filterView.hidden = NO;
    [self reframe];
    NSInteger newHeight = self.filterView.frame.size.height;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            newHeight);
    [self resizeTableHeader];
}
@end
