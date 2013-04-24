//
//  ToDoCell.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoCell.h"
#import "UtilityClass.h"
#define LAYER_VIEW_TAG 1
#define SELECTED_VIEW_TAG 2
@interface ToDoCell ()
@property (nonatomic,weak) IBOutlet UIView *layerView;
@end
@implementation ToDoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor whiteColor];
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [UtilityClass colorWithRed:155 green:155 blue:155 alpha:0.8];
        [self setSelectedBackgroundView:selectedView];
        /*UIView *layerView = [[UIView alloc] init];
        layerView.tag = LAYER_VIEW_TAG;
        layerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:layerView];
        self.layerView = [self viewWithTag:LAYER_VIEW_TAG];
        
        UIView *selectedView = [[UIView alloc] init];
        selectedView.tag = SELECTED_VIEW_TAG;
        selectedView.backgroundColor = [UtilityClass colorWithRed:155 green:155 blue:155 alpha:0.8];
        selectedView.hidden = YES;
        [self addSubview:selectedView];*/
    }
    return self;
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.layerView.frame = CGRectSetPos(frame,0,0);
    //self.selectedView.frame = CGRectSetPos(frame, 0, 0);
    //[self bringSubviewToFront:self.layerView];
    
}
-(void)select:(BOOL)select{
    [self setSelected:YES animated:NO];
    //self.selectedView.hidden = !select;
}
@end
