//
//  FilterMenu.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define CLEAR_VIEW_HEIGHT 50
#define NAV_BAR_MARGIN 25
#define CLEAR_FILTER_BUTTON_TAG 1
#define TAG_LIST_TAG 2
#define SELECTED_TAG_LIST_TAG 3

#import "FilterMenu.h"
#import "UtilityClass.h"
#import "KPTagList.h"
@interface FilterMenu () <KPTagDelegate>
@property (nonatomic,weak) IBOutlet UIView *clearView;
@property (nonatomic,weak) IBOutlet KPTagList *selectedTagListView;
@property (nonatomic,strong) NSArray *selectedTags;
@property (nonatomic,strong) NSArray *unselectedTags;
@property (nonatomic,weak) IBOutlet KPTagList *tagListView;
@end

@implementation FilterMenu
+(FilterMenu *)filterMenuWithUnselectedTags:(NSArray *)unselectedTags selectedTags:(NSArray *)selectedTags{
    FilterMenu *filterMenu = [[FilterMenu alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_MAX_WIDTH, 10)];
    return filterMenu;
}
-(void)setDataSource:(NSObject<FilterMenuDataSource> *)dataSource{
    _dataSource = dataSource;
    [self reloadData];
}
-(void)reloadData{
    if([self.dataSource respondsToSelector:@selector(selectedTagsForFilterMenu:)]){
        self.selectedTags = [self.dataSource selectedTagsForFilterMenu:self];
    }
    if([self.dataSource respondsToSelector:@selector(unselectedTagsForFilterMenu:)]){
        self.unselectedTags = [self.dataSource unselectedTagsForFilterMenu:self];
    }
    [self.tagListView setTags:self.unselectedTags andSelectedTags:nil];
    [self.selectedTagListView setTags:self.selectedTags andSelectedTags:self.selectedTags];
    [self reframe];
}
- (BOOL)isPopped
{
    return self.superview != nil;
}
#pragma mark KPTagDelegate
-(void)tagList:(KPTagList *)tagList selectedTag:(NSString *)tag{
    if(tagList == self.selectedTagListView){
        [self.delegate filterMenu:self deselectedTag:tag];
    }
    else [self.delegate filterMenu:self selectedTag:tag];
    [self reloadData];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    if(tagList == self.selectedTagListView){
        [self.delegate filterMenu:self deselectedTag:tag];
    }
    else [self.delegate filterMenu:self selectedTag:tag];
    [self reloadData];
}
-(void)render{
    self.maxWidth = DEFAULT_MAX_WIDTH;
    self.backgroundColor = [UtilityClass colorWithRed:71 green:71 blue:71 alpha:1];
    KPTagList *selectedTagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, self.maxWidth, 0)];
    selectedTagList.emptyText = @"No tags selected";
    selectedTagList.tagDelegate = self;
    selectedTagList.tag = SELECTED_TAG_LIST_TAG;
    [self addSubview:selectedTagList];
    self.selectedTagListView = (KPTagList*)[self viewWithTag:SELECTED_TAG_LIST_TAG];
    KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, self.maxWidth, 0)];
    tagList.emptyText = @"No tags available for items";
    tagList.tagDelegate = self;
    tagList.tag = TAG_LIST_TAG;
    [self addSubview:tagList];
    self.tagListView = (KPTagList*)[self viewWithTag:TAG_LIST_TAG];
}
-(void)reframe{
    CGFloat tempHeight = 0;
    tempHeight += self.selectedTagListView.frame.size.height;
    self.tagListView.hidden = NO;
    CGRectSetY(self.tagListView.frame, tempHeight);
    tempHeight += self.tagListView.frame.size.height;
    CGRectSetSize(self.frame, self.tagListView.frame.size.width, tempHeight);
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self render];
    }
    return self;
}

- (void)popInWithEvent:(UIEvent*)event
{
    UIView *view = [[event.allTouches anyObject] view];
    if ([view.superview isKindOfClass:[UINavigationBar class]]) {
        UINavigationBar *navBar = (UINavigationBar*)view.superview;
        [navBar.superview insertSubview:self belowSubview:navBar];
        
    }
    [self popInView:view];
}

- (void)popInView:(UIView*)view
{
    //Set frame for menu view
    CGRect frame = view.frame;
    NSInteger menuHeight = self.frame.size.height;
    NSInteger menuWidth = self.frame.size.width;
    NSInteger menuX = frame.origin.x-menuWidth+frame.size.width;

    //if (self.direction == MLPopupMenuUp) {
        /*self.frame = CGRectMake(menuX,
                                menuY,
                                menuWidth,
                                menuHeight);*/
    //}else{
        self.frame = CGRectMake(menuX,
                                64 - menuHeight,
                                menuWidth,
                                menuHeight);
    //}
    if (![self isPopped]){
        
        //Insert menu below superview
        if ([view.superview isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navBar = (UINavigationBar*)view.superview;
            [navBar.superview insertSubview:self belowSubview:navBar];
            
        }else if([view.superview isKindOfClass:[UITabBar class]]){
            UITabBar *navBar = (UITabBar*)view.superview;
            [navBar.superview insertSubview:self belowSubview:navBar];
        }else{
            [view.superview insertSubview:self belowSubview:view];
        }
    }
    
    //Animate popup
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectApplyAffineTransform(self.frame, CGAffineTransformMakeTranslation(0,  menuHeight));
                         
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             
                         }
                     }];
}
- (void)hide
{
    //Get row height
    //CGFloat cellSize = [self rowHeight];
    //Get number of rows
    //NSInteger numberOfRows = [self numberOfRowsInSection:0];
    //Animate popup
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectApplyAffineTransform(self.frame, CGAffineTransformMakeTranslation(0, -self.frame.size.height));
                         
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             [self removeFromSuperview];
                         }
                     }];
}

@end
