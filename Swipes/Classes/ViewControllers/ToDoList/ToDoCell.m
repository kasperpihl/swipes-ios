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
@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *layerView;
@property (nonatomic,weak) IBOutlet UIView *overlayView;
@end
@implementation ToDoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor whiteColor];
        
        UIView *overlayView = [[UIView alloc] initWithFrame:self.bounds];
        overlayView.backgroundColor = [UtilityClass colorWithRed:155 green:155 blue:155 alpha:0.6];
        overlayView.tag = OVERLAY_VIEW_TAG;
        self.selectedBackgroundView = overlayView;
    }
    return self;
}
-(void)changeToDo:(KPToDo *)toDo{
    
}
-(void)setCellType:(CellType)cellType{
    if(_cellType != cellType){
        _cellType = cellType;
        self.selectedBackgroundView.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
        /*self.contentView.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
        self.textLabel.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];*/
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
