//
//  KPTagList.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import "KPTagList.h"

#define TOP_MARGIN 10
#define LEFTRIGHT_MARGIN 10

#define TAG_HEIGHT 30
#define TAG_SIDE_PADDING 7
#define TAG_TOPBOTTOM_PADDING 3

#define TAG_HORIZONTAL_SPACING 5
#define TAG_VERTICAL_SPACING 10

#define TAG_FONT [UIFont fontWithName:@"HelveticaNeue" size:14]

@interface KPTagList ()
@property (nonatomic,strong) NSArray *tags;
@property (nonatomic,strong) NSMutableArray *selectedTags;
@property (nonatomic,strong) NSMutableArray *removedTags;
@end
@implementation KPTagList
+(KPTagList *)tagListWithWidth:(CGFloat)width{
    KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, width, 10)];
    return tagList;
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
    }
    return self;
}
-(void)setTagDelegate:(NSObject<KPAddTagDelegate> *)tagDelegate{
    _tagDelegate = tagDelegate;
    self.tags = [tagDelegate selectedTagsForTagList:self];
    self.selectedTags = [[tagDelegate selectedTagsForTagList:self] mutableCopy];
    [self reloadData];
}
-(void)reloadData{
    
}
-(void)layoutTags{
    CGFloat currentWidth;
    CGFloat currentHeight;
    for(NSString *tag in self.tags){
        
    }
}
-(UIButton*)buttonWithText:(NSString*)text{
    /*UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:label.frame];
    [button setAccessibilityLabel:label.text];
    [button.layer setCornerRadius:CORNER_RADIUS];
    [button addTarget:self action:@selector(touchDownInside:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [button addTarget:self action:@selector(touchDragInside:) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:button];*/
}
-(UILabel*)labelWithText:(NSString*)text{
    UILabel *label;
    return label;
}
@end
