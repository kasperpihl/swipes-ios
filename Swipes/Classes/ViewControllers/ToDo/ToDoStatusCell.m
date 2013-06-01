//
//  ToDoStatusCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 31/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import "ToDoHandler.h"
#import "ToDoStatusCell.h"
#define STATUS_IMAGE_X 15
#define STATUS_LABEL_X 50

#define STATUS_IMAGE_TAG 1
#define STATUS_LABEL_TAG 2

@interface ToDoStatusCell ()
@property (nonatomic,weak) IBOutlet UIImageView *statusImage;
@property (nonatomic,weak) IBOutlet UILabel *statusLabel;
@end

@implementation ToDoStatusCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mode = MCSwipeTableViewCellModeSwitch;
        self.contentView.backgroundColor = EDIT_TASK_BACKGROUND;
        // Initialization code
        
        CGFloat seperatorSize = 1;//COLOR_SEPERATOR_HEIGHT;
        
        UIImageView *statusImage = [[UIImageView alloc] init];
        statusImage.tag = STATUS_IMAGE_TAG;
        [self.contentView addSubview:statusImage];
        self.statusImage = (UIImageView*)[self.contentView viewWithTag:STATUS_IMAGE_TAG];
        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(STATUS_LABEL_X, 0, 320-STATUS_LABEL_X, STATUS_CELL_HEIGHT)];
        statusLabel.backgroundColor = CLEAR;
        statusLabel.textColor = TEXT_FIELD_COLOR;
        statusLabel.font = TITLE_LABEL_FONT;
        statusLabel.tag = STATUS_LABEL_TAG;

        [self.contentView addSubview:statusLabel];
        self.statusLabel = (UILabel*)[self viewWithTag:STATUS_LABEL_TAG];
        
        UIView *colorBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-seperatorSize, self.frame.size.width, seperatorSize)];
        colorBottomSeperator.backgroundColor = TABLE_CELL_SEPERATOR_COLOR;
        colorBottomSeperator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:colorBottomSeperator];
    }
    return self;
}
-(void)setTitleString:(NSString*)titleString{
    self.statusLabel.text = titleString;
}
-(void)setCellType:(CellType)cellType{
    if(_cellType != cellType){
        _cellType = cellType;
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
        
        UIImage *statusImage = [UIImage imageNamed:[TODOHANDLER coloredIconNameForCellType:cellType]];
        [self updateStatusImage:statusImage];
        
    }
}
-(void)updateStatusImage:(UIImage*)image{
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    self.statusImage.frame = CGRectMake(STATUS_IMAGE_X, (STATUS_CELL_HEIGHT-imageHeight)/2, imageWidth, imageHeight);
    self.statusImage.image = image;
    
}
@end
