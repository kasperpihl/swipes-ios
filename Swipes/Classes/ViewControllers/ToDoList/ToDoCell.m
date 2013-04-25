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
-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    NSLog(@"setting highlighted animation");
}
@end
