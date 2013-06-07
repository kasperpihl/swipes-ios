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
#define RIGHT_ICON_CONTAINER_TAG 9


#define INDICATOR_X 40
#define INDICATOR_HEIGHT 23
#define INDICATOR_WIDTH 1

#define LABEL_X 50


#define DOT_OUTLINE_SIZE 4
#define TIMELINE_WIDTH 2

#define LABEL_WIDTH (320-(2*LABEL_X))
#define TITLE_DELTA_Y -1
#define LABEL_SPACE 4

#define TITLE_LABEL_HEIGHT [@"Tjgq" sizeWithFont:TITLE_LABEL_FONT].height
#define TAGS_LABEL_HEIGHT [@"Tg" sizeWithFont:TAGS_LABEL_FONT].height

#define RIGHT_ICON_WIDTH 25
#define RIGHT_ICON_RIGHT_MARGIN 10

#define RIGHT_ICON_CORNER_RADIUS 5

@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *layerView;

@property (nonatomic,weak) IBOutlet UIView *dotView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIView *outlineView;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic,weak) IBOutlet UIView *rightIconContainer;
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
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X,TITLE_DELTA_Y + (CELL_HEIGHT-TITLE_LABEL_HEIGHT-TAGS_LABEL_HEIGHT-LABEL_SPACE)/2, LABEL_WIDTH, TITLE_LABEL_HEIGHT)];
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
        
        UIView *rightIconContainer = [[UIView alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width-RIGHT_ICON_WIDTH-RIGHT_ICON_RIGHT_MARGIN, (self.contentView.frame.size.height-RIGHT_ICON_WIDTH)/2, RIGHT_ICON_WIDTH, RIGHT_ICON_WIDTH)];
        
        rightIconContainer.tag = RIGHT_ICON_CONTAINER_TAG;
        rightIconContainer.backgroundColor = TABLE_CELL_ICON_BACKGROUND;
        rightIconContainer.layer.cornerRadius = RIGHT_ICON_CORNER_RADIUS;
        UIImageView *rightIcon = [[UIImageView alloc] initWithImage:[UtilityClass imageNamed:@"edit_alarm_icon" withColor:EDIT_TASK_GRAYED_OUT_TEXT]];
        rightIcon.frame = CGRectSetPos(rightIcon.frame, (rightIconContainer.frame.size.width-rightIcon.frame.size.width)/2, (rightIconContainer.frame.size.height-rightIcon.frame.size.height)/2);
        [rightIconContainer addSubview:rightIcon];
        rightIconContainer.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
        [self.contentView addSubview:rightIconContainer];
        self.rightIconContainer = [self.contentView viewWithTag:RIGHT_ICON_CONTAINER_TAG];
    }
    return self;
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
    /*UIColor *currentColor = self.isSelected ? TABLE_CELL_BACKGROUND : CELL_TIMELINE_COLOR;
    self.outlineView.backgroundColor = show ? currentColor : CLEAR;*/
}
-(void)changeToDo:(KPToDo *)toDo withSelectedTags:(NSArray*)selectedTags{
    self.titleLabel.text = toDo.title;
    NSString *tagString = [toDo stringifyTags];
    if(selectedTags && selectedTags.count > 0 && [self.tagsLabel respondsToSelector:@selector(setAttributedText:)] && tagString && tagString.length > 0){
        [self.tagsLabel setAttributedText:[toDo stringForSelectedTags:selectedTags]];
    }else{
        
        if(!tagString || tagString.length == 0) tagString = @"No Tags";
        self.tagsLabel.font = TAGS_LABEL_FONT;
        self.tagsLabel.text = tagString;
    }
    [self setIconsForToDo:toDo];
    [self.tagsLabel setNeedsDisplay];
    
}
-(void)setIconsForToDo:(KPToDo*)toDo{
    BOOL shouldShowIcon = NO;
    if(toDo.alarm && [toDo.alarm isInFuture]){
        shouldShowIcon = YES;
    }
    self.rightIconContainer.hidden = !shouldShowIcon;
}
-(void)setDotColor:(UIColor *)color{
    self.dotView.backgroundColor = color;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    /*self.overlayView.hidden = !selected;
    self.overlayView2.hidden = !selected;
    if(selected){
        CGRectSetX(self.titleLabel.frame, 32);
        CGRectSetX(self.tagsLabel.frame, 32);
    }
    else{
        CGRectSetX(self.titleLabel.frame, LABEL_X);
        CGRectSetX(self.tagsLabel.frame, LABEL_X);
    }
    //self.seperatorLine.hidden = selected;*/
    //self.seperatorLine.hidden = selected;
    [super setSelected:selected animated:animated];
    UIColor *backgroundColor = selected ? TABLE_CELL_SELECTED_BACKGROUND : TABLE_CELL_BACKGROUND;
    UIColor *timelineColor = selected ? TABLE_CELL_BACKGROUND : CELL_TIMELINE_COLOR;
    //self.outlineView.backgroundColor = timelineColor;
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
