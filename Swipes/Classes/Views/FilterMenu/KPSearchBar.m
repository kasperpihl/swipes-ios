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
#import "UIColor+Utilities.h"
@interface KPSearchBar () <KPTagDelegate,UITextFieldDelegate>

@property (nonatomic,weak) IBOutlet UIView *filterView;
@property (nonatomic,weak) IBOutlet UIButton *filterButton;
@property (nonatomic,weak) IBOutlet UITextField *searchField;
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
        [self setBackgroundImage:[tbackground(SearchDrawerBackground) image]];
        //[self setSearchFieldBackgroundImage:[UtilityClass imageWithColor:TEXTFIELD_BACKGROUND] forState:UIControlStateNormal];
        [self setTranslucent:YES];
        self.placeholder = @"Search";
        self.backgroundColor = [UIColor clearColor];
        CGFloat buttonSize = self.frame.size.height;
        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterButton addTarget:self action:@selector(pressedFilter:) forControlEvents:UIControlEventTouchUpInside];
        filterButton.tag = FILTER_BUTTON_TAG;
        filterButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        filterButton.frame = CGRectMake(self.frame.size.width-buttonSize, 0, buttonSize, buttonSize);
        [filterButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
        //[filterButton setBackgroundImage:[UtilityClass imageWithColor:SWIPES_COLOR] forState:UIControlStateNormal];
        [self addSubview:filterButton];
        self.filterButton = (UIButton*)[self viewWithTag:FILTER_BUTTON_TAG];
        
        
        /* Instantiate filter view */
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
        filterView.tag = FILTER_VIEW_TAG;
        filterView.hidden = YES;
        
        
        KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        tagList.emptyText = @"No tags assigned";
        tagList.marginLeft = tagList.spacing;
        tagList.marginTop = (12+tagList.spacing)/2;
        tagList.emptyLabelMarginHack = 10;
        tagList.firstRowSpacingHack = 44;
        tagList.bottomMargin = (12+tagList.spacing)/2;
        tagList.marginRight = tagList.spacing;
        tagList.tagDelegate = self;
        tagList.tag = TAG_LIST_TAG;
        [filterView addSubview:tagList];
        self.tagListView = (KPTagList*)[filterView viewWithTag:TAG_LIST_TAG];
        
        UIButton *clearFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearFilterButton.frame = CGRectMake(self.frame.size.width-buttonSize,0,buttonSize,buttonSize);
        //[clearFilterButton setBackgroundImage:[UtilityClass imageWithColor:SWIPES_COLOR] forState:UIControlStateNormal];
        [clearFilterButton setImage:[UIImage imageNamed:@"cross_button"] forState:UIControlStateNormal];
        [clearFilterButton addTarget:self action:@selector(pressedClearFilter:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:clearFilterButton];
        
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
        //CGRectSetX(searchField, 10);
        //searchField.userInteractionEnabled = NO;
        CGRectSetSize(searchField, self.frame.size.width-(2*searchField.frame.origin.x)-(self.frame.size.height), searchField.frame.size.height);
        searchField.font = TEXT_FIELD_FONT;
        searchField.autoresizingMask = (UIViewAutoresizingNone);
        searchField.returnKeyType = UIReturnKeyDone;
        searchField.borderStyle = UITextBorderStyleNone;
        searchField.textColor = tcolor(SearchDrawerColor);
        searchField.enablesReturnKeyAutomatically = NO;
        searchField.clearButtonMode = UITextFieldViewModeNever;
        [searchField addTarget:self action:@selector(startedSearch:) forControlEvents:UIControlEventEditingDidBegin];
        [searchField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [searchField setBackground:[[UIImage alloc] init]];
        //[searchField setValue:TEXT_FIELD_COLOR forKeyPath:@"_placeholderLabel.textColor"];
        searchField.leftView = nil;
    }
}
-(void)resignSearchField{
    if(self.currentMode == KPSearchBarModeSearch){
        if(self.searchField.text.length == 0) self.currentMode = KPSearchBarModeNone;
        else [self.searchField resignFirstResponder];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldChanged:(UITextField*)sender{
    if([self.searchBarDelegate respondsToSelector:@selector(searchBar:searchedForString:)]) [self.searchBarDelegate searchBar:self searchedForString:sender.text];
}
-(void)startedSearch:(UITextField*)sender{
    self.currentMode = KPSearchBarModeSearch;
}
-(void)pressedClearFilter:(UIButton*)sender{
    if([self.searchBarDelegate respondsToSelector:@selector(clearedAllFiltersForSearchBar:)]) [self.searchBarDelegate clearedAllFiltersForSearchBar:self];
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
    if(self.currentMode == KPSearchBarModeNone){
        self.currentMode = KPSearchBarModeTags;
    }
    else if(self.currentMode == KPSearchBarModeSearch){
        if([self.searchBarDelegate respondsToSelector:@selector(clearedAllFiltersForSearchBar:)]) [self.searchBarDelegate clearedAllFiltersForSearchBar:self];
        self.currentMode = KPSearchBarModeNone;
    }
}
-(void)setCurrentMode:(KPSearchBarMode)currentMode{
    if(currentMode != _currentMode){
        KPSearchBarMode oldMode = _currentMode;
        _currentMode = currentMode;
        switch (currentMode) {
            case KPSearchBarModeTags:
                [self reloadDataAndUpdate:NO];
                [self reframeToTags];
                //[self reframeToTags];
                break;
            case KPSearchBarModeNone:
                [self reframeToNoneFrom:oldMode];
            case KPSearchBarModeSearch:
                [self reframeToSearch];
                break;
        }
    }
}
-(void)reframeToSearch{
    [self.filterButton setImage:[UIImage imageNamed:@"cross_button"] forState:UIControlStateNormal];
}
-(void)reframeToNoneFrom:(KPSearchBarMode)oldMode{
    UITableView* superView = (UITableView*)self.superview;
    if(oldMode == KPSearchBarModeSearch){
        [self.searchField resignFirstResponder];
        self.searchField.text = @"";
    }
    [UIView animateWithDuration:.5f animations:^{
        self.filterView.alpha = 0;
        //CGRectSetY(self.frame, self.frame.origin.y-self.frame.size.height);
        if(superView) [superView setContentOffset:CGPointMake(0, superView.tableHeaderView.frame.size.height)];
    } completion:^(BOOL finished) {
        CGRectSetHeight(self,SEARCH_BAR_DEFAULT_HEIGHT);
        [self.filterButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
        self.filterView.hidden = YES;
        self.filterButton.hidden = NO;
        self.searchField.hidden = NO;
        [self resizeTableHeader];
        //NSLog(@"super:%f",superView.tableHeaderView.frame.size.height);
        //if(superView && [superView isKindOfClass:[UITableView class]]) [superView setContentOffset:CGPointMake(0, superView.tableHeaderView.frame.size.height)];
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
    self.filterView.hidden = NO;
    self.filterView.alpha = 0;
    [self reframe];
    CGFloat newHeight = self.filterView.frame.size.height;
    NSInteger originChange = oldHeight - newHeight;
    self.frame = CGRectMake(self.frame.origin.x,
                           self.frame.origin.y,
                           self.frame.size.width,
                           newHeight);
    CGRectSetY(self, self.frame.origin.y+originChange);
    [UIView animateWithDuration:.5f animations:^{
        self.filterView.alpha = 1;
        CGRectSetY(self, self.frame.origin.y-originChange);
        
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
        self.filterView.hidden = NO;
        [self resizeTableHeader];
    }];
}

@end
