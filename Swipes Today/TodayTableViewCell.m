//
//  TodaySwipeableTableViewCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 18/09/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define color(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a]

#import "TodayTableViewCell.h"
@interface TodayTableViewCell () <UIGestureRecognizerDelegate>
@property (nonatomic) IBOutlet UIButton *completeButton;
@property (nonatomic) IBOutlet UILabel *taskTitle;

@end
@implementation TodayTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializer];
    }
    return self;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (void)initializer {
    self.taskTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-self.frame.size.height, self.frame.size.height)];
    self.taskTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.taskTitle];
    
    
    UIButton *completeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-self.frame.size.height, 0, self.frame.size.height, self.frame.size.height)];
    [completeButton setTitle:@"done" forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(pressedComplete:) forControlEvents:UIControlEventTouchUpInside];
    [completeButton setTitle:@"doneFull" forState:UIControlStateHighlighted];
    [completeButton setTitleColor:color(134,211,110,1) forState:UIControlStateNormal];
    completeButton.titleLabel.font = [UIFont fontWithName:@"swipes" size:15];
    completeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:completeButton];
}

-(void)resetAndSetTaskTitle:(NSString *)title{
    self.taskTitle.text = title;
}

-(void)pressedComplete:(UIButton*)sender{
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
