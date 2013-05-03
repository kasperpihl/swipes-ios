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
#define OVERLAY_VIEW_TAG 2
#define TITLE_LABEL_TAG 3
#define TAGS_LABEL_TAG 4

#define TITLE_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]
#define TAGS_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue" size:12]

#define TITLE_LABEL_COLOR [UtilityClass colorWithRed:102 green:102 blue:102 alpha:1]
#define TAGS_LABEL_COLOR [UtilityClass colorWithRed:102 green:102 blue:102 alpha:1]

#define LABEL_X 19

#define LABEL_WIDTH (320-(2*LABEL_X))
#define TITLE_DELTA_Y -2
#define LABEL_SPACE 6

#define TITLE_LABEL_HEIGHT [@"Tg" sizeWithFont:TITLE_LABEL_FONT].height
#define TAGS_LABEL_HEIGHT [@"Tg" sizeWithFont:TAGS_LABEL_FONT].height


@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *layerView;
@property (nonatomic,weak) IBOutlet UIView *overlayView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@end
@implementation ToDoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
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
        
        UIView *overlayView = [[UIView alloc] initWithFrame:self.bounds];
        overlayView.backgroundColor = [UtilityClass colorWithRed:204 green:204 blue:204 alpha:1];
        overlayView.tag = OVERLAY_VIEW_TAG;
        self.selectedBackgroundView = overlayView;
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
-(void)setCellType:(CellType)cellType{
    if(_cellType != cellType){
        _cellType = cellType;
        //self.selectedBackgroundView.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
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
-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    //NSLog(@"setting highlighted animation");
}
@end
