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
#define LAYER_VIEW_TAG 1
#define TITLE_LABEL_TAG 3
#define TAGS_LABEL_TAG 4
#define DOT_VIEW_TAG 6
#define TIMELINE_TAG 7
#define OUTLINE_TAG 8
#define ALARM_LABEL_TAG 9

#define INDICATOR_X 40
#define INDICATOR_HEIGHT 23
#define INDICATOR_WIDTH 1

#define kIconSpacing 5
#define kIconSize 8
#define kIndicatorHeight 4
#define kIndicatorX 8
#define kIndicatorHack 5

#define kTimeLabelMarginRight 5

#define kClockSize 26

#define TITLE_DELTA_Y 2
#define TITLE_Y (TITLE_DELTA_Y + (CELL_HEIGHT-TITLE_LABEL_HEIGHT-TAGS_LABEL_HEIGHT-LABEL_SPACE)/2)

#define DOT_SIZE GLOBAL_DOT_SIZE
#define DOT_OUTLINE_SIZE 4

#define LABEL_WIDTH (320-(CELL_LABEL_X+(CELL_LABEL_X/3)))

#define LABEL_SPACE 4

#define TITLE_LABEL_HEIGHT sizeWithFont(@"Tjgq",TITLE_LABEL_FONT).height
#define TAGS_LABEL_HEIGHT sizeWithFont(@"Tg",TAGS_LABEL_FONT).height

#define ALARM_HACK 1
#define ICON_SPACING 5
#define ALARM_SPACING 5

@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *layerView;
@property (nonatomic,weak) IBOutlet UIView *timelineView;
@property (nonatomic,weak) IBOutlet UIView *dotView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIView *outlineView;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic,weak) IBOutlet ClockTimeLabel *alarmLabel;

@property (nonatomic,strong) UIImageView *notesIcon;
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
        tagsLabel.font = TAGS_LABEL_FONT;
        tagsLabel.backgroundColor = [UIColor clearColor];
        //tagsLabel.textColor = tcolor(TaskCellTagColor);
        [self.contentView addSubview:tagsLabel];
        self.tagsLabel = (UILabel*)[self.contentView viewWithTag:TAGS_LABEL_TAG];
        
        UIView *overlayView = [[UIView alloc] initWithFrame:self.bounds];
        overlayView.backgroundColor = tbackground(TaskCellBackground);
        self.selectedBackgroundView = overlayView;
        
        UIView *timelineLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, CELL_HEIGHT)];
        timelineLine.tag = TIMELINE_TAG;
        timelineLine.hidden = YES;
        //timelineLine.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        
        [self.contentView addSubview:timelineLine];
        self.timelineView = [self.contentView viewWithTag:TIMELINE_TAG];
        
        CGFloat outlineWidth = DOT_SIZE+(2*DOT_OUTLINE_SIZE);
        UIView *dotOutlineContainer = [[UIView alloc] initWithFrame:CGRectMake((CELL_LABEL_X-outlineWidth)/2, (CELL_HEIGHT-outlineWidth)/2, outlineWidth, outlineWidth)];
        dotOutlineContainer.tag = OUTLINE_TAG;
        //dotOutlineContainer.layer.borderWidth = LINE_SIZE;
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
        
        self.notesIcon = [[UIImageView alloc] init];
        self.notesIcon.frame = CGRectMake(kIndicatorX, 0, self.timelineView.frame.size.width-kIndicatorX, kIndicatorHeight);
        self.notesIcon.hidden = YES;
        [self.contentView addSubview:self.notesIcon];
        
        ClockTimeLabel *alarmLabel = [[ClockTimeLabel alloc] initWithFrame:CGRectMake(0, 0, kClockSize, kClockSize)];
        alarmLabel.tag = ALARM_LABEL_TAG;
        alarmLabel.font = CELL_ALARM_FONT;
        alarmLabel.circleColor = tcolor(LaterColor);
        
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
    //CGRectSetCenterY(self.alarmLabel, self.tagsLabel.center.y);
    self.tagsLabel.hidden = !showBottomLine;
}
-(void)hideContent:(BOOL)hide animated:(BOOL)animated{
    voidBlock block = ^(void) {
        if(hide){
                self.outlineView.alpha = 0;
                self.dotView.alpha = 0;
                self.timelineView.alpha = 0;
                self.tagsLabel.alpha = 0;
                self.titleLabel.alpha = 0;
        }
        else {
            self.outlineView.alpha = 1;
            self.dotView.alpha = 1;
            self.timelineView.alpha = 1;
            self.tagsLabel.alpha = 1;
            self.titleLabel.alpha = 1;
        }
    };
    if(animated){
        [UIView animateWithDuration:0.25f animations:block];
    }
    else block();
}
-(void)showTimeline:(BOOL)show{
    self.timelineView.hidden = !show;
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
    //CGFloat deltaX = CELL_LABEL_X;
    
    
    self.alarmLabel.hidden = YES;
    if((toDo.schedule) || toDo.completionDate){
        NSDate *showDate = toDo.completionDate ? toDo.completionDate : toDo.schedule;
        self.alarmLabel.time = showDate;
        //[self.alarmLabel sizeToFit];
        //CGRectSetWidth(self.alarmLabel, self.alarmLabel.frame.size.width+2*ALARM_SPACING);
        //CGRectSetHeight(self.alarmLabel, self.alarmLabel.frame.size.height+2*ALARM_SPACING);
        self.alarmLabel.frame = CGRectSetPos(self.alarmLabel.frame, self.frame.size.width-self.alarmLabel.frame.size.width-kTimeLabelMarginRight, (CELL_HEIGHT-self.alarmLabel.frame.size.height)/2);
        self.alarmLabel.hidden = NO;
    }
    //CGRectSetX(self.tagsLabel,deltaX);
    
    [self setTextLabels:showBottomLine];
}
-(void)setIconsForToDo:(KPToDo*)toDo{
    
}
-(void)setDotColor:(CellType)cellType{
    UIColor *color = [StyleHandler colorForCellType:cellType];
    self.timelineView.backgroundColor = color;
    self.outlineView.layer.borderColor = color.CGColor;
    self.dotView.backgroundColor = color;
    self.alarmLabel.layer.borderColor = color.CGColor;
    self.tagsLabel.textColor = color;
    self.alarmLabel.circleColor = color;
    self.timelineView.backgroundColor = color;
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.timelineView.hidden = !selected;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.timelineView.hidden = !selected;
    
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
