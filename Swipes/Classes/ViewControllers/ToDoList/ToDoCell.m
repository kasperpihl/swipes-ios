//
//  ToDoCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoCell.h"
#import "UtilityClass.h"
#import "ToDoHandler.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate-Utilities.h"
#import "UIColor+Utilities.h"
#import "StyleHandler.h"
#import "ClockTimeLabel.h"
#define TITLE_LABEL_TAG 3
#define TAGS_LABEL_TAG 4
#define DOT_VIEW_TAG 6
#define SELECTION_TAG 7
#define OUTLINE_TAG 8
#define ALARM_LABEL_TAG 9

#define kIconSpacing 5

#define kClockSize 22
#define kTimeLabelMarginRight 5



#define TITLE_DELTA_Y 0
#define TITLE_Y (TITLE_DELTA_Y + (CELL_HEIGHT-TITLE_LABEL_HEIGHT-TAGS_LABEL_HEIGHT-LABEL_SPACE)/2)

#define DOT_SIZE GLOBAL_DOT_SIZE
#define DOT_OUTLINE_SIZE 4

#define LABEL_WIDTH (320-(CELL_LABEL_X+(CELL_LABEL_X/3)))

#define LABEL_SPACE 2

#define kUnselectedFrame CGRectMake((CELL_LABEL_X/2),0, LINE_SIZE,CELL_HEIGHT)
#define kSelectedFrame CGRectMake(0,0,(CELL_LABEL_X/2)+LINE_SIZE,CELL_HEIGHT)

#define TITLE_LABEL_HEIGHT sizeWithFont(@"Tjgq",TITLE_LABEL_FONT).height
#define TAGS_LABEL_HEIGHT sizeWithFont(@"Tg",TAGS_LABEL_FONT).height

@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *selectionView;
@property (nonatomic,weak) IBOutlet UIView *dotView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIView *outlineView;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic,weak) IBOutlet ClockTimeLabel *alarmLabel;

@property (nonatomic,strong) UIImageView *notesIcon;
@property (nonatomic,strong) UIImageView *recurringIcon;
@end
@implementation ToDoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.shouldRegret = YES;
        //self.contentView.layer.masksToBounds = YES;
        self.backgroundColor = tbackground(BackgroundColor);
        self.contentView.backgroundColor = tbackground(BackgroundColor);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LABEL_X,TITLE_Y, LABEL_WIDTH, TITLE_LABEL_HEIGHT)];
        titleLabel.tag = TITLE_LABEL_TAG;
        titleLabel.numberOfLines = 1;
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        titleLabel.font = TITLE_LABEL_FONT;
        titleLabel.textColor = tcolor(TaskCellTitle);
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = (UILabel*)[self.contentView viewWithTag:TITLE_LABEL_TAG];
        
        UILabel *tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LABEL_X, titleLabel.frame.origin.y+titleLabel.frame.size.height+LABEL_SPACE, LABEL_WIDTH, TAGS_LABEL_HEIGHT)];
        tagsLabel.tag = TAGS_LABEL_TAG;
        tagsLabel.numberOfLines = 1;
        tagsLabel.textColor = gray(170, 1);
        tagsLabel.font = TAGS_LABEL_FONT;
        tagsLabel.backgroundColor = [UIColor clearColor];
        //tagsLabel.textColor = tcolor(TaskCellTagColor);
        [self.contentView addSubview:tagsLabel];
        self.tagsLabel = (UILabel*)[self.contentView viewWithTag:TAGS_LABEL_TAG];
        
        
        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, CELL_HEIGHT)];//CGRectMake((CELL_LABEL_X/2),0, LINE_SIZE,CELL_HEIGHT)]; //];
        selectionView.tag = SELECTION_TAG;
        selectionView.hidden = YES;
        //timelineLine.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        
        [self.contentView addSubview:selectionView];
        self.selectionView = [self.contentView viewWithTag:SELECTION_TAG];
        
        CGFloat outlineWidth = DOT_SIZE+(2*DOT_OUTLINE_SIZE);
        UIView *dotOutlineContainer = [[UIView alloc] initWithFrame:CGRectMake((CELL_LABEL_X-outlineWidth)/2, (CELL_HEIGHT-outlineWidth)/2, outlineWidth, outlineWidth)];
        dotOutlineContainer.tag = OUTLINE_TAG;
        dotOutlineContainer.layer.borderWidth = LINE_SIZE;
        dotOutlineContainer.layer.borderColor = tcolor(TasksColor).CGColor;
        dotOutlineContainer.backgroundColor = tbackground(BackgroundColor);
        dotOutlineContainer.layer.cornerRadius = outlineWidth/2;
        
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(DOT_OUTLINE_SIZE, DOT_OUTLINE_SIZE, DOT_SIZE,DOT_SIZE)];
        dotView.layer.cornerRadius = DOT_SIZE/2;
        dotView.tag = DOT_VIEW_TAG;
        [dotOutlineContainer addSubview:dotView];
        [self.contentView addSubview:dotOutlineContainer];
        self.dotView = [self.contentView viewWithTag:DOT_VIEW_TAG];
        self.outlineView = [self.contentView viewWithTag:OUTLINE_TAG];
        self.outlineView.hidden = YES;
        
        self.notesIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_notes_tasks"]];
        self.notesIcon.hidden = YES;
        [self.contentView addSubview:self.notesIcon];
        
        self.recurringIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_recurring_tasks"]];
        self.recurringIcon.hidden = YES;
        [self.contentView addSubview:self.recurringIcon];
        
        ClockTimeLabel *alarmLabel = [[ClockTimeLabel alloc] initWithFrame:CGRectMake(0, 0, kClockSize, kClockSize)];
        alarmLabel.tag = ALARM_LABEL_TAG;
        //alarmLabel.layer.cornerRadius = kClockSize /2;
        alarmLabel.font = CELL_ALARM_FONT;
        //alarmLabel.backgroundColor = tbackground(BackgroundColor);
        alarmLabel.circleColor = gray(170, 1);
        
        //self.alarmLabel.numberOfLines = 1;
        alarmLabel.hidden = YES;
        [self.contentView addSubview:alarmLabel];
        self.alarmLabel = (ClockTimeLabel*)[self.contentView viewWithTag:ALARM_LABEL_TAG];
    }
    return self;
}
-(void)setTextLabels:(BOOL)showBottomLine{
    CGFloat titleY = showBottomLine ? TITLE_Y : ((CELL_HEIGHT - self.titleLabel.frame.size.height)/2);
    CGRectSetY(self.titleLabel,titleY);
    CGRectSetY(self.tagsLabel, TITLE_Y+self.titleLabel.frame.size.height+LABEL_SPACE);
    CGRectSetCenterY(self.recurringIcon, self.tagsLabel.center.y);
    CGRectSetCenterY(self.notesIcon, self.tagsLabel.center.y);
    //CGRectSetCenterY(self.alarmLabel, self.tagsLabel.center.y);
    self.tagsLabel.hidden = !showBottomLine;
}
-(void)changeToDo:(KPToDo *)toDo withSelectedTags:(NSArray*)selectedTags{
    BOOL showBottomLine = YES;
    self.titleLabel.text = toDo.title;
    
    NSString *tagString = [toDo stringifyTags];
    if(selectedTags && selectedTags.count > 0 && [self.tagsLabel respondsToSelector:@selector(setAttributedText:)] && tagString && tagString.length > 0){
        [self.tagsLabel setAttributedText:[toDo stringForSelectedTags:selectedTags]];
    }else{
        if (!tagString || tagString.length == 0){
            showBottomLine = NO;
            tagString = @"";
        }
        self.tagsLabel.font = TAGS_LABEL_FONT;
        self.tagsLabel.text = tagString;
    }
    CGFloat deltaX = CELL_LABEL_X;
    self.notesIcon.hidden = YES;
    self.recurringIcon.hidden = YES;
    
    self.alarmLabel.hidden = YES;
    self.outlineView.hidden = YES;
    if((toDo.schedule) || toDo.completionDate){
        NSDate *showDate = toDo.completionDate ? toDo.completionDate : toDo.schedule;
        self.alarmLabel.time = showDate;
        if(toDo.schedule && [toDo.schedule isInPast]){
            self.alarmLabel.time = [[NSDate date] dateAtHours:8 minutes:0];
            self.alarmLabel.text = @"";
        }
        self.alarmLabel.center = CGPointMake(CELL_LABEL_X/2, CELL_HEIGHT/2);
        //self.alarmLabel.frame = CGRectSetPos(self.alarmLabel.frame, self.frame.size.width-self.alarmLabel.frame.size.width-kTimeLabelMarginRight, (CELL_HEIGHT-self.alarmLabel.frame.size.height)/2);
        if(self.cellType != CellTypeToday) self.alarmLabel.hidden = NO;
        else self.outlineView.hidden = NO;
    }
    else self.outlineView.hidden = NO;
    
    
    if(toDo.notes && toDo.notes.length > 0){
        self.notesIcon.hidden = NO;
        showBottomLine = YES;
        CGRectSetX(self.notesIcon, deltaX);
        deltaX += self.notesIcon.frame.size.width + kIconSpacing;
    }
    if(toDo.repeatOptionValue > RepeatNever){
        self.recurringIcon.hidden = NO;
        showBottomLine = YES;
        CGRectSetX(self.recurringIcon, deltaX);
        deltaX += self.recurringIcon.frame.size.width + kIconSpacing;
    }
    CGRectSetX(self.tagsLabel,deltaX);
    //CGFloat deltaX = CELL_LABEL_X;
    
    
    
    
    [self setTextLabels:showBottomLine];
}
-(void)setDotColor:(CellType)cellType{
    UIColor *color = [StyleHandler colorForCellType:cellType];
    self.selectionView.backgroundColor = color;
    self.outlineView.layer.borderColor = color.CGColor;
    self.dotView.backgroundColor = color;
    self.alarmLabel.circleColor = color;
}
-(void)setSelected:(BOOL)selected{
    [self setSelected:selected animated:NO];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionView.hidden = !selected;
    //self.selectionView.frame = selected ? kSelectedFrame : kUnselectedFrame;
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
