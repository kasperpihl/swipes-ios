//
//  ToDoCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoCell.h"
#import "KPToDo.h"
#import "UtilityClass.h"
#import "ToDoHandler.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate-Utilities.h"
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

#define LABEL_X 50
#define TITLE_Y (TITLE_DELTA_Y + (CELL_HEIGHT-TITLE_LABEL_HEIGHT-TAGS_LABEL_HEIGHT-LABEL_SPACE)/2)


#define DOT_OUTLINE_SIZE 4
#define TIMELINE_WIDTH 2

#define LABEL_WIDTH (320-(LABEL_X+(LABEL_X/3)))
#define TITLE_DELTA_Y -1
#define LABEL_SPACE 4

#define TITLE_LABEL_HEIGHT [@"Tjgq" sizeWithFont:TITLE_LABEL_FONT].height
#define TAGS_LABEL_HEIGHT [@"Tg" sizeWithFont:TAGS_LABEL_FONT].height

#define ALARM_HACK 1
#define ICON_SPACING 5
#define ALARM_SPACING 3

@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *layerView;

@property (nonatomic,weak) IBOutlet UIView *dotView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIView *outlineView;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic,weak) IBOutlet UILabel *alarmLabel;
@end
@implementation ToDoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.layer.masksToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = TABLE_CELL_BACKGROUND;
        self.backgroundColor = TABLE_CELL_BACKGROUND;
        self.selectedBackgroundView.backgroundColor = TABLE_CELL_BACKGROUND;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X,TITLE_Y, LABEL_WIDTH, TITLE_LABEL_HEIGHT)];
        titleLabel.tag = TITLE_LABEL_TAG;
        titleLabel.numberOfLines = 1;
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        titleLabel.font = TITLE_LABEL_FONT;
        titleLabel.textColor = CELL_TITLE_COLOR;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = (UILabel*)[self.contentView viewWithTag:TITLE_LABEL_TAG];
        
        UILabel *tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, titleLabel.frame.origin.y+titleLabel.frame.size.height+LABEL_SPACE, LABEL_WIDTH, TAGS_LABEL_HEIGHT)];
        tagsLabel.tag = TAGS_LABEL_TAG;
        tagsLabel.numberOfLines = 1;
        tagsLabel.font = TAGS_LABEL_FONT;
        tagsLabel.backgroundColor = [UIColor clearColor];
        tagsLabel.textColor = CELL_TAG_COLOR;
        [self.contentView addSubview:tagsLabel];
        self.tagsLabel = (UILabel*)[self.contentView viewWithTag:TAGS_LABEL_TAG];
        
        UIView *overlayView = [[UIView alloc] initWithFrame:self.bounds];
        overlayView.backgroundColor = TABLE_CELL_BACKGROUND;
        self.selectedBackgroundView = overlayView;
        
        UIView *timelineLine = [[UIView alloc] initWithFrame:CGRectMake((LABEL_X-TIMELINE_WIDTH)/2, 0, TIMELINE_WIDTH, CELL_HEIGHT)];
        timelineLine.tag = TIMELINE_TAG;
        timelineLine.backgroundColor = CELL_TIMELINE_COLOR;
        [self.contentView addSubview:timelineLine];
        self.timelineView = [self.contentView viewWithTag:TIMELINE_TAG];
        
        CGFloat outlineWidth = DOT_SIZE+(2*DOT_OUTLINE_SIZE);
        UIView *dotOutlineContainer = [[UIView alloc] initWithFrame:CGRectMake((LABEL_X-outlineWidth)/2, (CELL_HEIGHT-outlineWidth)/2, outlineWidth, outlineWidth)];
        dotOutlineContainer.tag = OUTLINE_TAG;
        dotOutlineContainer.backgroundColor = TABLE_CELL_BACKGROUND;
        dotOutlineContainer.layer.cornerRadius = outlineWidth/2;
    
        
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(DOT_OUTLINE_SIZE, DOT_OUTLINE_SIZE, DOT_SIZE,DOT_SIZE)];
        dotView.layer.cornerRadius = DOT_SIZE/2;
        dotView.tag = DOT_VIEW_TAG;
        [dotOutlineContainer addSubview:dotView];
        [self.contentView addSubview:dotOutlineContainer];
        self.dotView = [self.contentView viewWithTag:DOT_VIEW_TAG];
        self.outlineView = [self.contentView viewWithTag:OUTLINE_TAG];
        
        UILabel *alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        alarmLabel.tag = ALARM_LABEL_TAG;
        alarmLabel.font = CELL_ALARM_FONT;
        alarmLabel.textColor = CELL_ALARM_TEXT_COLOR;
        alarmLabel.backgroundColor = CELL_ALARM_BACKGROUND;
        alarmLabel.textAlignment = UITextAlignmentCenter;
        self.alarmLabel.numberOfLines = 1;
        alarmLabel.hidden = YES;
        [self.contentView addSubview:alarmLabel];
        self.alarmLabel = (UILabel*)[self.contentView viewWithTag:ALARM_LABEL_TAG];
    }
    return self;
}
-(void)setTextLabels:(BOOL)showBottomLine{
    CGFloat titleY = showBottomLine ? TITLE_Y : ((CELL_HEIGHT - self.titleLabel.frame.size.height)/2);
    CGRectSetY(self.titleLabel,titleY);
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
    CGFloat deltaX = LABEL_X;
    self.alarmLabel.hidden = YES;
    if(toDo.schedule && [toDo.schedule isInFuture]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:usLocale];
        NSString *dateInString = [[dateFormatter stringFromDate:toDo.schedule] lowercaseString];
        self.alarmLabel.text = dateInString;
        [self.alarmLabel sizeToFit];
        CGRectSetWidth(self.alarmLabel, self.alarmLabel.frame.size.width+2*ALARM_SPACING);
        self.alarmLabel.frame = CGRectSetPos(self.alarmLabel.frame, deltaX, self.tagsLabel.center.y-(self.alarmLabel.frame.size.height/2)-ALARM_HACK);
        deltaX += self.alarmLabel.frame.size.width + ICON_SPACING;
        self.alarmLabel.hidden = NO;
        showBottomLine = YES;
    }
    CGRectSetX(self.tagsLabel,deltaX);
    [self setTextLabels:showBottomLine];
}
-(void)setIconsForToDo:(KPToDo*)toDo{
    
}
-(void)setDotColor:(UIColor *)color{
    self.dotView.backgroundColor = color;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIColor *backgroundColor = selected ? TABLE_CELL_SELECTED_BACKGROUND : TABLE_CELL_BACKGROUND;
    UIColor *timelineColor = selected ? TABLE_CELL_BACKGROUND : CELL_TIMELINE_COLOR;
    self.timelineView.backgroundColor = timelineColor;
    self.contentView.backgroundColor = backgroundColor;
}
-(void)setCellType:(CellType)cellType{
    if(_cellType != cellType){
        _cellType = cellType;
        self.selectedBackgroundView.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
        //CGRectSetY(self.overlayView.frame, CELL_HEIGHT-SELECTED_LINE_HEIGHT);
        //CGRectSetY(self.seperatorLine.frame, CELL_HEIGHT-SEPERATOR_WIDTH);
        //self.dotView.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
        CellType firstCell = [TODOHANDLER cellTypeForCell:cellType state:MCSwipeTableViewCellState1];
        CellType secondCell = [TODOHANDLER cellTypeForCell:cellType state:MCSwipeTableViewCellState2];
        CellType thirdCell = [TODOHANDLER cellTypeForCell:cellType state:MCSwipeTableViewCellState3];
        CellType fourthCell = [TODOHANDLER cellTypeForCell:cellType state:MCSwipeTableViewCellState4];
        [self setFirstColor:[TODOHANDLER colorForCellType:firstCell]];
        [self setSecondColor:[TODOHANDLER colorForCellType:secondCell]];
        [self setThirdColor:[TODOHANDLER colorForCellType:thirdCell]];
        [self setFourthColor:[TODOHANDLER colorForCellType:fourthCell]];
        [self setFirstIconName:[TODOHANDLER iconNameForCellType:firstCell]];
        [self setSecondIconName:[TODOHANDLER iconNameForCellType:secondCell]];
        [self setThirdIconName:[TODOHANDLER iconNameForCellType:thirdCell]];
        [self setFourthIconName:[TODOHANDLER iconNameForCellType:fourthCell]];
        self.activatedDirection = [TODOHANDLER directionForCellType:cellType];
    }
}
@end
