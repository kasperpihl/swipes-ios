//
//  WalkthroughCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#define DOT_VIEW_TAG 6
#define TIMELINE_TAG 7
#define OUTLINE_TAG 8


#import "WalkthroughCell.h"
#import <QuartzCore/QuartzCore.h>
@interface WalkthroughCell ()
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIView *dotView;
@property (nonatomic,weak) IBOutlet UIView *outlineView;

@property (nonatomic) BOOL activated;
@end
@implementation WalkthroughCell
-(void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.noneColor = tbackground(BackgroundColor);
        CGFloat titleX = roundf(TABLE_WIDTH * LABEL_X);
        CGFloat dotOutlineSize = roundf(TABLE_WIDTH * DOT_OUTLINE_SIZE);
        CGFloat dotSize = roundf(TABLE_WIDTH * DOT_SIZE);
        CGFloat cellHeight = roundf(TABLE_WIDTH * CELL_HEIGHT);
        UIFont *defFont = TITLE_LABEL_FONT;
        CGFloat newSize = roundf(TABLE_WIDTH * (defFont.pointSize/320));
        UIFont *titleFont = [UIFont fontWithName:defFont.fontName size:newSize];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleX,0, 320-titleX-10, cellHeight)];
        titleLabel.numberOfLines = 1;
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        titleLabel.font = titleFont;
        titleLabel.text = @"Pick up laundry tonight";
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
       /*UIView *timelineLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (titleX/2), self.contentView.frame.size.height)];
        timelineLine.tag = TIMELINE_TAG;
        timelineLine.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        
        [self.contentView addSubview:timelineLine];
        self.timelineView = [self.contentView viewWithTag:TIMELINE_TAG];*/
        
        
        CGFloat outlineWidth = dotSize+(2*dotOutlineSize);
        UIView *dotOutlineContainer = [[UIView alloc] initWithFrame:CGRectMake((titleX-outlineWidth)/2, (self.frame.size.height-outlineWidth)/2, outlineWidth, outlineWidth)];
        dotOutlineContainer.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
        dotOutlineContainer.tag = OUTLINE_TAG;
        
        dotOutlineContainer.layer.cornerRadius = outlineWidth/2;
        
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(dotOutlineSize, dotOutlineSize, dotSize,dotSize)];
        dotView.layer.cornerRadius = dotSize/2;
        dotView.tag = DOT_VIEW_TAG;
        
        [dotOutlineContainer addSubview:dotView];
        [self.contentView addSubview:dotOutlineContainer];
        self.dotView = [self.contentView viewWithTag:DOT_VIEW_TAG];
        self.outlineView = [self.contentView viewWithTag:OUTLINE_TAG];
        
        self.helpingImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"walkthrough_swipe_done"]];
        CGRectSetCenterY(self.helpingImage, cellHeight/2);
        self.helpingImage.alpha = 0;
        [self addSubview:self.helpingImage];
        
    }
    return self;
}

-(void)setActivated:(BOOL)activated{
    [self setActivated:activated animated:NO];
}
-(void)setDotColor:(UIColor*)color{
    //BOOL isAnother = ![color isEqual:tcolor(TasksColor)];
    self.dotView.backgroundColor = color;
}
-(void)setActivated:(BOOL)activated animated:(BOOL)animated{
    _activated = activated;
    self.contentView.backgroundColor = activated ? W_CELL_ACTIVATED : W_CELL;
    self.titleLabel.textColor = activated ? W_TITLE_ACTIVATED : W_TIMELINE;
    self.dotView.backgroundColor = activated ? tcolor(TasksColor) : W_CELL;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
