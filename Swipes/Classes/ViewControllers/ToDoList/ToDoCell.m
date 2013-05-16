//
//  ToDoCell.m
//  ToDo
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
#define INDICATOR_TAG 3020
#define SEPERATOR_LINE_TAG 3022
#define TITLE_LABEL_TAG 3
#define TAGS_LABEL_TAG 4
#define ORDER_LABEL_TAG 5

#define TITLE_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]
#define TAGS_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue" size:12]
#define ORDER_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:26]


#define INDICATOR_X 40
#define INDICATOR_HEIGHT 23
#define INDICATOR_WIDTH 1

#define LABEL_X 40



#define LABEL_WIDTH (320-(2*LABEL_X))
#define TITLE_DELTA_Y -1
#define LABEL_SPACE 0

#define TITLE_LABEL_HEIGHT [@"Tjgq" sizeWithFont:TITLE_LABEL_FONT].height
#define TAGS_LABEL_HEIGHT [@"Tg" sizeWithFont:TAGS_LABEL_FONT].height


@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *layerView;
@property (nonatomic,weak) IBOutlet UIView *indicatorView;
@property (nonatomic,weak) IBOutlet UILabel *orderLabel;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@end
@implementation ToDoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = TABLE_CELL_BACKGROUND;
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
        tagsLabel.textColor = CELL_TITLE_COLOR;
        [self.contentView addSubview:tagsLabel];
        self.tagsLabel = (UILabel*)[self.contentView viewWithTag:TAGS_LABEL_TAG];
        
        UILabel *orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, INDICATOR_X, CELL_HEIGHT)];
        orderLabel.textAlignment = UITextAlignmentCenter;
        orderLabel.tag = ORDER_LABEL_TAG;
        orderLabel.textColor = SWIPES_BLUE;
        orderLabel.font = ORDER_LABEL_FONT;
        orderLabel.backgroundColor = CLEAR;
        orderLabel.text = @"1";
        [self.contentView addSubview:orderLabel];
        CGFloat seperatorHeight = .5;
        
        
        
        UIView *seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, CELL_HEIGHT-seperatorHeight, self.bounds.size.width, seperatorHeight)];
        [seperatorLine setBackgroundColor:NAVBAR_BACKROUND];
        seperatorLine.tag = SEPERATOR_LINE_TAG;
        [self.contentView addSubview:seperatorLine];
        self.seperatorLine = [self.contentView viewWithTag:SEPERATOR_LINE_TAG];
        
        UIView *overlayView = [[UIView alloc] initWithFrame:self.bounds];
        overlayView.backgroundColor = TABLE_CELL_SELECTED_BACKGROUND;
        self.selectedBackgroundView = overlayView;
        
        UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(INDICATOR_X, (CELL_HEIGHT-INDICATOR_HEIGHT)/2, INDICATOR_WIDTH, INDICATOR_HEIGHT)];
        indicatorView.tag = INDICATOR_TAG;
        indicatorView.hidden = YES;
        [self.contentView addSubview:indicatorView];
        self.indicatorView = [self.contentView viewWithTag:INDICATOR_TAG];
        
    }
    return self;
}
-(void)changeToDo:(KPToDo *)toDo withSelectedTags:(NSArray*)selectedTags{
    self.titleLabel.text = toDo.title;
    if(selectedTags && selectedTags.count > 0 && [self.tagsLabel respondsToSelector:@selector(setAttributedText:)]){
        [self.tagsLabel setAttributedText:[toDo stringForSelectedTags:selectedTags]];
    }else{
        NSString *tagString = [toDo stringifyTags];
        if(!tagString) tagString = @"No Tags";
        self.tagsLabel.font = TAGS_LABEL_FONT;
        self.tagsLabel.text = tagString;
    }
    [self.tagsLabel setNeedsDisplay];
    
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
    self.contentView.backgroundColor = backgroundColor;
}
-(void)setCellType:(CellType)cellType{
    if(_cellType != cellType){
        _cellType = cellType;
        //CGRectSetY(self.overlayView.frame, CELL_HEIGHT-SELECTED_LINE_HEIGHT);
        //CGRectSetY(self.seperatorLine.frame, CELL_HEIGHT-SEPERATOR_WIDTH);
        self.indicatorView.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
        //self.overlayView2.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
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
