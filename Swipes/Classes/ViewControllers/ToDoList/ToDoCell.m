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
#define LAYER_VIEW_TAG 1
#define OVERLAY_VIEW_TAG 3020
#define OVERLAY_VIEW2_TAG 3021
#define TITLE_LABEL_TAG 3
#define TAGS_LABEL_TAG 4

#define TITLE_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]
#define TAGS_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue" size:12]

#define TITLE_LABEL_COLOR [UtilityClass colorWithRed:102 green:102 blue:102 alpha:1]
#define TAGS_LABEL_COLOR [UtilityClass colorWithRed:102 green:102 blue:102 alpha:1]

#define SELECTED_LINE_HEIGHT 5

#define LABEL_X 19

#define LABEL_WIDTH (320-(2*LABEL_X))
#define TITLE_DELTA_Y -2
#define LABEL_SPACE 6

#define TITLE_LABEL_HEIGHT [@"Tg" sizeWithFont:TITLE_LABEL_FONT].height
#define TAGS_LABEL_HEIGHT [@"Tg" sizeWithFont:TAGS_LABEL_FONT].height


@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *layerView;
@property (nonatomic,weak) IBOutlet UIView *overlayView;
@property (nonatomic,weak) IBOutlet UIView *overlayView2;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@end
@implementation ToDoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X,TITLE_DELTA_Y + (CELL_HEIGHT-TITLE_LABEL_HEIGHT-TAGS_LABEL_HEIGHT-LABEL_SPACE)/2, LABEL_WIDTH, TITLE_LABEL_HEIGHT)];
        titleLabel.tag = TITLE_LABEL_TAG;
        titleLabel.numberOfLines = 1;
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        titleLabel.font = TITLE_LABEL_FONT;
        titleLabel.textColor = TITLE_LABEL_COLOR;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = (UILabel*)[self.contentView viewWithTag:TITLE_LABEL_TAG];
        
        UILabel *tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, titleLabel.frame.origin.y+titleLabel.frame.size.height+LABEL_SPACE, LABEL_WIDTH, TAGS_LABEL_HEIGHT)];
        tagsLabel.tag = TAGS_LABEL_TAG;
        tagsLabel.numberOfLines = 1;
        tagsLabel.font = TAGS_LABEL_FONT;
        tagsLabel.backgroundColor = [UIColor clearColor];
        tagsLabel.textColor = TAGS_LABEL_COLOR;
        [self.contentView addSubview:tagsLabel];
        self.tagsLabel = (UILabel*)[self.contentView viewWithTag:TAGS_LABEL_TAG];
        
        UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-SELECTED_LINE_HEIGHT, self.bounds.size.width, SELECTED_LINE_HEIGHT)];
        overlayView.backgroundColor = [UtilityClass colorWithRed:204 green:204 blue:204 alpha:0];
        overlayView.tag = OVERLAY_VIEW_TAG;
       
        [self addSubview:overlayView];
        [self bringSubviewToFront:overlayView];
        self.overlayView = [self viewWithTag:OVERLAY_VIEW_TAG];
        
        
        UIView *overlayView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, SELECTED_LINE_HEIGHT)];
        overlayView2.backgroundColor = [UtilityClass colorWithRed:204 green:204 blue:204 alpha:0];
        overlayView2.tag = OVERLAY_VIEW2_TAG;
        [self addSubview:overlayView2];
        [self bringSubviewToFront:overlayView2];
        self.overlayView2 = [self viewWithTag:OVERLAY_VIEW2_TAG];
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
    self.overlayView.hidden = !selected;
    self.overlayView2.hidden = !selected;
    [super setSelected:selected animated:animated];
}
-(void)setCellType:(CellType)cellType{
    if(_cellType != cellType){
        _cellType = cellType;
        CGRectSetY(self.overlayView.frame, self.frame.size.height-SELECTED_LINE_HEIGHT);
        self.overlayView.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
        self.overlayView2.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
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
