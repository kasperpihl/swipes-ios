//
//  FilterTopMenu.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "SlowHighlightIcon.h"
#import "KPTagList.h"
#import "UIColor+Utilities.h"
#import "FilterTopMenu.h"

@interface FilterTopMenu () <KPTagListResizeDelegate, KPTagDelegate>
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UIButton *clearButton;
@property (nonatomic, strong) IBOutlet UIButton *priorityFilterButton;
@property (nonatomic, strong) IBOutlet UIButton *notesFilterButton;
@property (nonatomic, strong) IBOutlet UIButton *recurringFilterButton;
@end

@implementation FilterTopMenu
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = tcolor(BackgroundColor);
        
        
        
        KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, kTopY, self.frame.size.width, 0)];
        tagList.emptyText = @"No tags assigned";
        tagList.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //tagList.addTagButton = YES;
        
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
        //tagList.lastRowSpacingHack = 90;
        tagList.bottomMargin = 0;//(16+tagList.spacing)/2;
        tagList.marginRight = tagList.spacing;
        tagList.resizeDelegate = self;
        tagList.tagDelegate = self;
        [self addSubview:tagList];
        self.tagListView = tagList;

        
        UIButton *clearButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        clearButton.frame = CGRectMake(0, self.frame.size.height - kSideButtonsWidth, kSideButtonsWidth, kSideButtonsWidth);
        clearButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        clearButton.titleLabel.font = KP_REGULAR(15);
        [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        [clearButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(onClear:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearButton];
        self.clearButton = clearButton;
        
        UIButton *closeButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(frame.size.width-kSideButtonsWidth, self.frame.size.height - kSideButtonsWidth, kSideButtonsWidth, kSideButtonsWidth);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        closeButton.titleLabel.font = KP_REGULAR(15);
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
        
        
        
        UIButton *priorityFilterButton = [self iconButton];
        CGRectSetCenterX(priorityFilterButton, self.frame.size.width/2 - 45);
        [priorityFilterButton setTitle:iconString(@"filterPriority") forState:UIControlStateNormal];
        [priorityFilterButton addTarget:self action:@selector(onPriority:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:priorityFilterButton];
        self.priorityFilterButton = priorityFilterButton;
        
        UIButton *notesFilterButton = [self iconButton];
        CGRectSetCenterX(notesFilterButton, self.frame.size.width/2);
        [notesFilterButton setTitle:iconString(@"editNotes") forState:UIControlStateNormal];
        [notesFilterButton addTarget:self action:@selector(onNotes:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:notesFilterButton];
        self.notesFilterButton = notesFilterButton;
        
        UIButton *recurringFilterButton = [self iconButton];
        CGRectSetCenterX(recurringFilterButton, self.frame.size.width/2 + 45);
        [recurringFilterButton setTitle:iconString(@"editRepeat") forState:UIControlStateNormal];
        [recurringFilterButton addTarget:self action:@selector(onRecurring:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:recurringFilterButton];
        self.recurringFilterButton = recurringFilterButton;
        
    }
    return self;
}

-(UIButton*)iconButton{
    CGFloat buttonHeight = 34;
    UIButton *filterButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, self.frame.size.height-(kSideButtonsWidth-buttonHeight)/2-buttonHeight, buttonHeight, buttonHeight)];
    filterButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    filterButton.titleLabel.font = iconFont(16);
    [filterButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    [filterButton setTitleColor:tcolor(TextColor) forState:UIControlStateSelected|UIControlStateHighlighted];
    [filterButton setTitleColor:tcolor(BackgroundColor) forState:UIControlStateHighlighted];
    [filterButton setTitleColor:tcolor(BackgroundColor) forState:UIControlStateSelected];
    [filterButton setBackgroundImage:[tcolor(BackgroundColor) image] forState:UIControlStateNormal];
    [filterButton setBackgroundImage:[tcolor(BackgroundColor) image] forState:UIControlStateSelected|UIControlStateHighlighted];
    [filterButton setBackgroundImage:[tcolor(TextColor) image] forState:UIControlStateHighlighted];
    [filterButton setBackgroundImage:[tcolor(TextColor) image] forState:UIControlStateSelected];
    filterButton.layer.borderColor = tcolor(TextColor).CGColor;
    filterButton.layer.borderWidth = LINE_SIZE;
    filterButton.layer.cornerRadius = buttonHeight/2;
    filterButton.layer.masksToBounds = YES;
    return filterButton;
}

-(void)tagList:(KPTagList *)tagList changedSize:(CGSize)size{
    CGRectSetHeight(self, kTopY + tagList.frame.size.height + kSideButtonsWidth  );
    [self.topMenuDelegate topMenu:self changedSize:self.frame.size];
    [self updateButtons];
}

-(void)setPriority:(BOOL)priority notes:(BOOL)notes recurring:(BOOL)recurring{
    self.priorityFilterButton.selected = priority;
    self.notesFilterButton.selected = notes;
    self.recurringFilterButton.selected = recurring;
    [self updateButtons];
}


#pragma mark KPTagDelegate
-(void)tagList:(KPTagList *)tagList selectedTag:(NSString *)tag{
    [self.filterDelegate filterMenu:self selectedTag:tag];
    [self updateButtons];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    [self.filterDelegate filterMenu:self deselectedTag:tag];
    [self updateButtons];
}


#pragma mark Actions
-(void)onPriority:(UIButton*)priorityButton{
    BOOL newStatus = !priorityButton.selected;
    [self.filterDelegate filterMenu:self updatedPriority:newStatus];
    [priorityButton setSelected:newStatus];
    [self updateButtons];
}
-(void)onNotes:(UIButton*)notesButton{
    BOOL newStatus = !notesButton.selected;
    [self.filterDelegate filterMenu:self updatedNotes:newStatus];
    [notesButton setSelected:newStatus];
    [self updateButtons];
}
-(void)onRecurring:(UIButton*)recurringButton{
    BOOL newStatus = !recurringButton.selected;
    [self.filterDelegate filterMenu:self updatedRecurring:newStatus];
    [recurringButton setSelected:newStatus];
    [self updateButtons];
}


-(void)onClear:(UIButton*)clearButton{
    [self.filterDelegate didClearFilterTopMenu:self];
}
-(void)onClose:(UIButton*)closeButton{
    [self.filterDelegate didPressFilterTopMenu:self];
}




-(void)updateButtons{
    BOOL hasFilterOn = NO;
    if(self.priorityFilterButton.selected || self.notesFilterButton.selected || self.recurringFilterButton.selected)
        hasFilterOn = YES;
    if([self.tagListView getSelectedTags].count > 0)
        hasFilterOn = YES;
    
    //NSString *closeTitle = hasFilterOn ? @"Clear" : @"Close";
    //[self.closeButton setTitle:closeTitle forState:UIControlStateNormal];
    
    self.clearButton.enabled = hasFilterOn;
    self.clearButton.alpha = hasFilterOn ? 1 : 0.5;
}

-(void)updateSize{
    
}

-(void)dealloc{
    self.tagListView = nil;
    self.closeButton = nil;
    self.clearButton = nil;
}
@end
