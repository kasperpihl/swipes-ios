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
#define LAYER_VIEW_TAG 1
#define TITLE_LABEL_TAG 3
#define TAGS_LABEL_TAG 4
#define DOT_VIEW_TAG 6
#define TIMELINE_TAG 7
#define OUTLINE_TAG 8


#define INDICATOR_X 40
#define INDICATOR_HEIGHT 23
#define INDICATOR_WIDTH 1

#define LABEL_X 40

#define DOT_SIZE 12
#define DOT_OUTLINE_SIZE 4
#define TIMELINE_WIDTH 2

#define LABEL_WIDTH (320-(2*LABEL_X))
#define TITLE_DELTA_Y -1
#define LABEL_SPACE 0

#define TITLE_LABEL_HEIGHT [@"Tjgq" sizeWithFont:TITLE_LABEL_FONT].height
#define TAGS_LABEL_HEIGHT [@"Tg" sizeWithFont:TAGS_LABEL_FONT].height


@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *layerView;

@property (nonatomic,weak) IBOutlet UIView *dotView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIView *outlineView;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
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
    if(selectedTags && selectedTags.count > 0 && [self.tagsLabel respondsToSelector:@selector(setAttributedText:)]){
        [self.tagsLabel setAttributedText:[toDo stringForSelectedTags:selectedTags]];
    }else{
        NSString *tagString = [toDo stringifyTags];
        if(!tagString || tagString.length == 0) tagString = @"No Tags";
        self.tagsLabel.font = TAGS_LABEL_FONT;
        self.tagsLabel.text = tagString;
    }
    [self.tagsLabel setNeedsDisplay];
    
}
-(void)setDotColor:(UIColor *)color{
    self.dotView.backgroundColor = color;
}
-(void)setOrderNumber:(NSInteger)orderNumber{
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
