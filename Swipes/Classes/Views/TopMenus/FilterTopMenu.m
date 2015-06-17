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
#import "AudioHandler.h"
#import "UserHandler.h"
#define kBackgroundColorButtons CLEAR

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
        self.backgroundColor = CLEAR;
        CGFloat gradientHeight = 4;
        UIView *gradientBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, gradientHeight)];
        gradientBackground.backgroundColor = CLEAR;
        CAGradientLayer *agradient = [CAGradientLayer layer];
        agradient.frame = gradientBackground.bounds;
        gradientBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        agradient.colors = @[(id)alpha(tcolor(TextColor),0.0f).CGColor,(id)alpha(tcolor(TextColor),0.2f).CGColor,(id)alpha(tcolor(TextColor),0.4f).CGColor];
        agradient.locations = @[@0.0,@0.5,@1.0];
        [gradientBackground.layer insertSublayer:agradient atIndex:0];
        [self addSubview:gradientBackground];
        
        CGFloat topY = 44;
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, gradientHeight, self.frame.size.width, self.frame.size.height-gradientHeight)];
        background.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        background.backgroundColor = tcolor(BackgroundColor);
        [self addSubview:background];
        /*
        UIView *seperator2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 2)];
        seperator2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        seperator2.backgroundColor = alpha(tcolor(TextColor),0.3);
        [self addSubview:seperator2];
        */
        
        
        
        
        UIButton *setWorkSpaceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, gradientHeight, self.frame.size.width, topY)];
        
        setWorkSpaceButton.backgroundColor = CLEAR;
        [setWorkSpaceButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        setWorkSpaceButton.titleLabel.font = KP_REGULAR(16);
        [setWorkSpaceButton setTitle:[NSLocalizedString(@"Set Workspace", nil) uppercaseString] forState:UIControlStateNormal];
        [setWorkSpaceButton addTarget:self action:@selector(onHelp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:setWorkSpaceButton];
        
        KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, topY+gradientHeight, self.frame.size.width, 0)];
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
        //tagList.lastRowSpacingHack = 90;
        tagList.marginTop = 4;
        tagList.bottomMargin = (16+tagList.spacing)/2;
        if(kUserHandler.isPlus)
            tagList.bottomMargin = 0;
        tagList.marginRight = tagList.spacing;
        tagList.resizeDelegate = self;
        tagList.tagDelegate = self;
        [self addSubview:tagList];
        self.tagListView = tagList;

        
        UIButton *clearButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        clearButton.frame = CGRectMake(0, gradientHeight, kSideButtonsWidth, topY);
        clearButton.titleLabel.font = iconFont(20);
        clearButton.transform = CGAffineTransformMakeRotation(M_PI/2/2);
        [clearButton setTitle:@"plusThick" forState:UIControlStateNormal];
        [clearButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(onClear:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearButton];
        self.clearButton = clearButton;
        
        UIButton *closeButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(frame.size.width-kSideButtonsWidth, gradientHeight, kSideButtonsWidth, topY);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        closeButton.titleLabel.font = iconFont(20);
        [closeButton setTitle:@"arrowThick" forState:UIControlStateNormal];
        
        [closeButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
        
        if(kUserHandler.isPlus){
        
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
    [filterButton setBackgroundImage:[kBackgroundColorButtons image] forState:UIControlStateNormal];
    [filterButton setBackgroundImage:[kBackgroundColorButtons image] forState:UIControlStateSelected|UIControlStateHighlighted];
    [filterButton setBackgroundImage:[tcolor(TextColor) image] forState:UIControlStateHighlighted];
    [filterButton setBackgroundImage:[tcolor(TextColor) image] forState:UIControlStateSelected];
    filterButton.layer.borderColor = tcolor(TextColor).CGColor;
    filterButton.layer.borderWidth = LINE_SIZE;
    filterButton.layer.cornerRadius = buttonHeight/2;
    filterButton.layer.masksToBounds = YES;
    return filterButton;
}

-(void)tagList:(KPTagList *)tagList changedSize:(CGSize)size{
    if(kUserHandler.isPlus)
        CGRectSetHeight(self, CGRectGetMaxY(tagList.frame)  + kSideButtonsWidth  );
    else
        CGRectSetHeight(self, CGRectGetMaxY(tagList.frame));// + kSideButtonsWidth  );
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
    if(newStatus)
        [kAudio playSoundWithName:@"Succesful action.m4a"];
    else
        [kAudio playSoundWithName:@"New state - scheduled.m4a"];
    [priorityButton setSelected:newStatus];
    [self updateButtons];
}
-(void)onNotes:(UIButton*)notesButton{
    BOOL newStatus = !notesButton.selected;
    [self.filterDelegate filterMenu:self updatedNotes:newStatus];
    if(newStatus)
        [kAudio playSoundWithName:@"Succesful action.m4a"];
    else
        [kAudio playSoundWithName:@"New state - scheduled.m4a"];
    [notesButton setSelected:newStatus];
    [self updateButtons];
}
-(void)onRecurring:(UIButton*)recurringButton{
    BOOL newStatus = !recurringButton.selected;
    [self.filterDelegate filterMenu:self updatedRecurring:newStatus];
    if(newStatus)
        [kAudio playSoundWithName:@"Succesful action.m4a"];
    else
        [kAudio playSoundWithName:@"New state - scheduled.m4a"];
    [recurringButton setSelected:newStatus];
    [self updateButtons];
}


-(void)onClear:(UIButton*)clearButton{
    [self.filterDelegate didClearFilterTopMenu:self];
}
-(void)onClose:(UIButton*)closeButton{
    [self.filterDelegate didPressFilterTopMenu:self];
}
-(void)onHelp:(UIButton*)helpButton{
    [self.filterDelegate didPressHelpInFilterTopMenu:self];
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
