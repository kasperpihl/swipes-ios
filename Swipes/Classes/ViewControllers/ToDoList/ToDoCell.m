//
//  ToDoCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoCell.h"
#import "UtilityClass.h"
#import "KPToDo.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate-Utilities.h"
#import "UIColor+Utilities.h"
#import "StyleHandler.h"
#define TITLE_LABEL_TAG 3
#define TAGS_LABEL_TAG 4
#define DOT_VIEW_TAG 6
#define SELECTION_TAG 7
#define OUTLINE_TAG 8
#define ALARM_LABEL_TAG 9

#define kIconSpacing 5

#define kClockSize 22
#define kTimeLabelMarginRight 5
#define ALARM_HACK 0
#define ICON_SPACING 5
#define ALARM_SPACING 3


#define kMaxNumberOfTitleRows 2


#define kSpaceBetweenLabels 2
#define kOuterSpaceBetweenTasks 12

//#define TITLE_LABEL_HEIGHT sizeWithFont(@"Tjgq",TITLE_LABEL_FONT).height
#define TAGS_LABEL_HEIGHT sizeWithFont(@"Tg",TAGS_LABEL_FONT).height

@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *selectionView;

@property (nonatomic) KPToDo *toDo;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic,weak) IBOutlet UILabel *alarmLabel;
@property (nonatomic) IBOutlet UILabel *alarmSeperator;

@property (nonatomic,strong) UILabel *notesIcon;
@property (nonatomic,strong) UILabel *recurringIcon;
@property (nonatomic,strong) UILabel *locationIcon;

@property (nonatomic, strong) UILabel *actionStepsLabel;

@end
@implementation ToDoCell
+(CGFloat)heightWithText:(NSString *)text hasSubtask:(BOOL)hasSubtask{
    UIApplication *application = [UIApplication sharedApplication];
    BOOL landscape = UIInterfaceOrientationIsLandscape(application.statusBarOrientation);
    CGSize size = [UIScreen mainScreen].bounds.size;
    //CGFloat height = landscape ? presentationPlace.frame.size.width : presentationPlace.frame.size.height;
    CGFloat width = landscape ? size.height : size.width;
    width = width - 2*CELL_LABEL_X;
    if( !hasSubtask )
        width = width + CELL_LABEL_X/1.5;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 100)];
    titleLabel.numberOfLines = kMaxNumberOfTitleRows;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.font = TITLE_LABEL_FONT;
    [titleLabel setText:text];
    [titleLabel sizeToFit];
    return titleLabel.frame.size.height + kSpaceBetweenLabels + 2*kOuterSpaceBetweenTasks + TAGS_LABEL_HEIGHT;
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.shouldRegret = YES;
        //self.contentView.layer.masksToBounds = YES;
        self.backgroundColor = tcolor(BackgroundColor);
        self.contentView.backgroundColor = tcolor(BackgroundColor);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LABEL_X, 0, 0, 100)];
        titleLabel.tag = TITLE_LABEL_TAG;
        titleLabel.numberOfLines = kMaxNumberOfTitleRows;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.font = TITLE_LABEL_FONT;
        titleLabel.textColor = tcolor(TextColor);
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = (UILabel*)[self.contentView viewWithTag:TITLE_LABEL_TAG];
        
        UILabel *tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LABEL_X, 0, 0, TAGS_LABEL_HEIGHT)];
        tagsLabel.tag = TAGS_LABEL_TAG;
        tagsLabel.numberOfLines = 1;
        tagsLabel.textColor = tcolor(SubTextColor);
        tagsLabel.font = TAGS_LABEL_FONT;
        tagsLabel.backgroundColor = [UIColor clearColor];
        //tagsLabel.textColor = tcolor(TaskCellTagColor);
        [self.contentView addSubview:tagsLabel];
        self.tagsLabel = (UILabel*)[self.contentView viewWithTag:TAGS_LABEL_TAG];
        
        // 4
        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, self.frame.size.height)];//CGRectMake((CELL_LABEL_X/2),0, LINE_SIZE,CELL_HEIGHT)]; //];
        selectionView.tag = SELECTION_TAG;
        selectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        selectionView.hidden = YES;
        //timelineLine.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        
        [self.contentView addSubview:selectionView];
        self.selectionView = [self.contentView viewWithTag:SELECTION_TAG];
        
        DotView *dotView = [[DotView alloc] init];
        dotView.tag = DOT_VIEW_TAG;
        [self.contentView addSubview:dotView];
        self.dotView = (DotView*)[self.contentView viewWithTag:DOT_VIEW_TAG];
        self.dotView.center = CGPointMake(CELL_LABEL_X/2, self.frame.size.height/2);
        self.dotView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        NSInteger iconHeight = 9;
        
        self.locationIcon = iconLabel(@"editLocation", iconHeight);
        [self.locationIcon setTextColor:tcolor(SubTextColor)];
        self.locationIcon.hidden = YES;
        [self.contentView addSubview:self.locationIcon];
        
        self.notesIcon = iconLabel(@"editNotes", iconHeight);
        [self.notesIcon setTextColor:tcolor(SubTextColor)];
        self.notesIcon.hidden = YES;
        [self.contentView addSubview:self.notesIcon];
        
        self.recurringIcon = iconLabel(@"editRepeat", iconHeight);
        [self.recurringIcon setTextColor:tcolor(SubTextColor)];
        self.recurringIcon.hidden = YES;
        [self.contentView addSubview:self.recurringIcon];
        
        UILabel *alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        alarmLabel.tag = ALARM_LABEL_TAG;
        alarmLabel.font = TAGS_LABEL_FONT;
        alarmLabel.backgroundColor = CLEAR;
        alarmLabel.textColor = tcolor(SubTextColor);
        alarmLabel.hidden = YES;
        
        self.alarmSeperator = [[UILabel alloc] init];
        self.alarmSeperator.font = TAGS_LABEL_FONT;
        self.alarmSeperator.text = @"//";
        self.alarmSeperator.backgroundColor = CLEAR;
        self.alarmSeperator.hidden = YES;
        [self.alarmSeperator sizeToFit];
        CGRectSetHeight(self.alarmSeperator,TAGS_LABEL_HEIGHT);
        self.alarmSeperator.textColor = tcolor(SubTextColor);
        [self.contentView addSubview:self.alarmSeperator];
        [self.contentView addSubview:alarmLabel];
        self.alarmLabel = (UILabel*)[self.contentView viewWithTag:ALARM_LABEL_TAG];
        
        UIButton *priorityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CELL_LABEL_X, self.frame.size.height)];
        priorityButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [priorityButton addTarget:self action:@selector(pressedPriority) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:priorityButton];
        
        self.actionStepsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-CELL_LABEL_X, 0, CELL_LABEL_X, self.frame.size.height)];
        //self.actionStepsButton.backgroundColor = tcolor(TextColor);
        //self.actionStepsButton.titleLabel.backgroundColor = tcolor(DoneColor);
        self.actionStepsLabel = [[UILabel alloc] init];
        self.actionStepsLabel.font = KP_REGULAR(11);
        self.actionStepsLabel.textColor = tcolor(TextColor);
        self.actionStepsLabel.layer.borderColor = tcolor(TextColor).CGColor;
        self.actionStepsLabel.layer.cornerRadius = 3;
        self.actionStepsLabel.layer.borderWidth = 1;
        self.actionStepsLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.actionStepsButton addSubview:self.actionStepsLabel];
        self.actionStepsLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.actionStepsButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [self.actionStepsButton addTarget:self action:@selector(pressedActionSteps) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.actionStepsButton];
        
    }
    return self;
}
-(void)pressedActionSteps{
    if ( [self.actionDelegate respondsToSelector:@selector(pressedActionStepsButtonCell:)])
        [self.actionDelegate pressedActionStepsButtonCell:self];
        
}

-(void)pressedPriority{
    [self.toDo switchPriority];
    [self setPriority:(self.toDo.priorityValue == 1)];
}

- (void)setPriority:(BOOL)priority {
    self.dotView.priority = priority;
}

-(void)updateActionSteps{
    NSSet *filteredSubtasks = [self.toDo.subtasks filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"completionDate = nil"]];
    if( filteredSubtasks && filteredSubtasks.count > 0){
        self.actionStepsButton.hidden = NO;
        self.actionStepsLabel.text = [NSString stringWithFormat:@"%i",filteredSubtasks.count];
        [self.actionStepsLabel sizeToFit];
        CGRectSetSize(self.actionStepsLabel, CGRectGetWidth(self.actionStepsLabel.frame)+12, CGRectGetHeight(self.actionStepsLabel.frame)+5);
        CGRectSetCenter(self.actionStepsLabel, CGRectGetWidth(self.actionStepsButton.frame)/2, CGRectGetHeight(self.actionStepsButton.frame)/2);
    }
    else self.actionStepsButton.hidden = YES;
}

- (void)setTextLabels:(BOOL)showBottomLine {
    
    
    CGFloat targetWidth = self.frame.size.width - 2*CELL_LABEL_X;
    if( self.toDo.subtasks.count == 0 )
        targetWidth += CELL_LABEL_X/1.5;
    CGRectSetWidth(self.titleLabel, targetWidth);
    [self.titleLabel sizeToFit];
    CGRectSetWidth(self.titleLabel, targetWidth);
    
    CGFloat titleY = showBottomLine ? kOuterSpaceBetweenTasks : ((self.frame.size.height - self.titleLabel.frame.size.height)/2);
    CGRectSetY(self.titleLabel,titleY);
    
    
    CGRectSetY(self.tagsLabel, CGRectGetMaxY(self.titleLabel.frame) + kSpaceBetweenLabels);
    CGFloat iconHack = 0.5;
    CGRectSetCenterY(self.locationIcon, self.tagsLabel.center.y - iconHack);
    CGRectSetCenterY(self.recurringIcon, self.tagsLabel.center.y - iconHack);
    CGRectSetCenterY(self.notesIcon, self.tagsLabel.center.y - iconHack);
    CGRectSetCenterY(self.alarmLabel, self.tagsLabel.center.y);
    CGRectSetCenterY(self.alarmSeperator, self.tagsLabel.center.y);
    self.tagsLabel.hidden = !showBottomLine;
}

- (void)changeToDo:(KPToDo *)toDo withSelectedTags:(NSArray*)selectedTags {
    
    self.toDo = toDo;
    self.dotView.priority = (toDo.priorityValue == 1);
    
    self.titleLabel.text = toDo.title;
    
    [self updateActionSteps];
    
    __block BOOL showBottomLine = NO;
    __block CGFloat deltaX = CELL_LABEL_X;
    __block BOOL alarmLabel = NO;
    
    
    self.alarmLabel.hidden = YES;
    if((toDo.schedule && [toDo.schedule isInFuture]) || toDo.completionDate){
        NSDate *showDate = toDo.completionDate ? toDo.completionDate : toDo.schedule;
        NSString *dateInString = [UtilityClass timeStringForDate:showDate];
        self.alarmLabel.text = dateInString;
        //if(deltaX > CELL_LABEL_X) self.alarmLabel.text = [@"//  " stringByAppendingString:self.alarmLabel.text];
        [self.alarmLabel sizeToFit];
        self.alarmLabel.textColor = [StyleHandler colorForCellType:self.cellType];
        CGRectSetX(self.alarmLabel,deltaX);
        deltaX += self.alarmLabel.frame.size.width + kIconSpacing;
        self.alarmLabel.hidden = NO;
        showBottomLine = YES;
        alarmLabel = YES;
    }
    self.alarmSeperator.hidden = YES;

    
    self.locationIcon.hidden = YES;
    self.notesIcon.hidden = YES;
    self.recurringIcon.hidden = YES;
    
    viewBlock blockForIcon = ^(UIView *view) {
        if(alarmLabel){
            self.alarmSeperator.hidden = NO;
            CGRectSetX(self.alarmSeperator, deltaX);
            deltaX += self.alarmSeperator.frame.size.width + kIconSpacing;
            alarmLabel = NO;
        }
        view.hidden = NO;
        showBottomLine = YES;
        CGRectSetX(view, deltaX);
        deltaX += view.frame.size.width + kIconSpacing;
    };
    
    if(toDo.location && toDo.location.length > 0){
        blockForIcon(self.locationIcon);
    }
    
    if(toDo.notes && toDo.notes.length > 0){
        blockForIcon(self.notesIcon);
    }
    
    if(toDo.repeatOptionValue > RepeatNever){
        blockForIcon(self.recurringIcon);
    }
    //if(showBottomLine) deltaX += kIconSpacing;
    
    
    
    CGRectSetWidth(self.tagsLabel, self.frame.size.width - deltaX - CELL_LABEL_X/2);
    CGRectSetX(self.tagsLabel,deltaX);
    
    NSString *tagString = toDo.tagString;
    if (tagString && tagString.length > 0){
        showBottomLine = YES;
    }
    if(selectedTags && selectedTags.count > 0 && [self.tagsLabel respondsToSelector:@selector(setAttributedText:)] && tagString && tagString.length > 0){
        NSMutableAttributedString *mutableAttributedString = [[toDo stringForSelectedTags:selectedTags] mutableCopy];
        if(deltaX > CELL_LABEL_X) [mutableAttributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"//  " attributes:Nil] atIndex:0];
        [self.tagsLabel setAttributedText:mutableAttributedString];
        
    }else{
        self.tagsLabel.font = TAGS_LABEL_FONT;
        self.tagsLabel.text = tagString;
        if(deltaX > CELL_LABEL_X && self.tagsLabel.text.length > 0) self.tagsLabel.text = [@"//  " stringByAppendingString:self.tagsLabel.text];
    }
    
    [self setTextLabels:showBottomLine];

}

-(void)setDotColor:(CellType)cellType{
    UIColor *color = [StyleHandler colorForCellType:cellType];
    self.selectionView.backgroundColor = color;
    self.dotView.dotColor = color;
    self.actionStepsLabel.layer.borderColor = color.CGColor;
}

-(void)setSelected:(BOOL)selected{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionView.hidden = !selected;
}

-(void)setCellType:(CellType)cellType{
    if(_cellType != cellType){
        _cellType = cellType;
        self.selectedBackgroundView.backgroundColor = [StyleHandler colorForCellType:self.cellType];
        CellType firstCell = [StyleHandler cellTypeForCell:cellType state:MCSwipeTableViewCellState1];
        CellType secondCell = [StyleHandler cellTypeForCell:cellType state:MCSwipeTableViewCellState2];
        CellType thirdCell = [StyleHandler cellTypeForCell:cellType state:MCSwipeTableViewCellState3];
        CellType fourthCell = [StyleHandler cellTypeForCell:cellType state:MCSwipeTableViewCellState4];
        [self setFirstColor:[StyleHandler colorForCellType:firstCell]];
        [self setSecondColor:[StyleHandler colorForCellType:secondCell]];
        [self setThirdColor:[StyleHandler colorForCellType:thirdCell]];
        [self setFourthColor:[StyleHandler colorForCellType:fourthCell]];
        [self setFirstIconName:[StyleHandler iconNameForCellType:firstCell]];
        [self setSecondIconName:[StyleHandler iconNameForCellType:secondCell]];
        [self setThirdIconName:[StyleHandler iconNameForCellType:thirdCell]];
        [self setFourthIconName:[StyleHandler iconNameForCellType:fourthCell]];
        self.activatedDirection = [StyleHandler directionForCellType:cellType];
    }
}

@end
