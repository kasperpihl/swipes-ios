//
//  KPTagList.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import "KPTagList.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>
#define VERTICAL_MARGIN 5
#define HORIZONTAL_MARGIN 5
#define TAG_HEIGHT 44
#define TAG_HORIZONTAL_PADDING 15

#define DEFAULT_SPACING 5

#define SPACE_HACK 1

#define TAG_FONT [UIFont fontWithName:@"HelveticaNeue" size:16]


#define COLOR_DARK [UtilityClass colorWithRed:102 green:102 blue:102 alpha:1]
//#define COLOR_DARK [UtilityClass colorWithRed:51 green:51 blue:51 alpha:1]
#define COLOR_BLUE [UtilityClass colorWithRed:57 green:159 blue:219 alpha:1]
#define COLOR_WHITE [UIColor whiteColor]

@interface KPTagList ()
@property (nonatomic,strong) NSMutableArray *tags;
@property (nonatomic,strong) NSMutableArray *selectedTags;
@end
@implementation KPTagList
+(KPTagList *)tagListWithWidth:(CGFloat)width andTags:(NSArray*)tags{
    KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, width, 100)];
    tagList.tags = [tags mutableCopy];
    [tagList layoutTagsFirst:YES];
    
    return tagList;
}
-(NSMutableArray *)tags{
    if(!_tags) _tags = [NSMutableArray array];
    return _tags;
}
-(NSMutableArray *)selectedTags{
    if(!_selectedTags) _selectedTags = [NSMutableArray array];
    return _selectedTags;
}
-(void)setTags:(NSArray *)tags andSelectedTags:(NSArray *)selectedTags{
    self.tags = [tags mutableCopy];
    self.selectedTags = [selectedTags mutableCopy];
    [self layoutTagsFirst:NO];
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.bottomMargin = VERTICAL_MARGIN;
        self.marginTop = VERTICAL_MARGIN;
        self.marginLeft = HORIZONTAL_MARGIN;
        self.marginRight = HORIZONTAL_MARGIN;
        self.spacing = DEFAULT_SPACING;
        //self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
-(void)setTagDelegate:(NSObject<KPTagDelegate> *)tagDelegate{
    _tagDelegate = tagDelegate;
    [self reloadData];
}
-(void)reloadData{
    if([self.tagDelegate respondsToSelector:@selector(tagsForTagList:)]) self.tags = [[self.tagDelegate tagsForTagList:self] mutableCopy];
    if([self.tagDelegate respondsToSelector:@selector(selectedTagsForTagList:)]) self.selectedTags = [[self.tagDelegate selectedTagsForTagList:self] mutableCopy];
    [self layoutTagsFirst:NO];
}
-(void)addTag:(NSString *)tag selected:(BOOL)selected{
    [self.tags addObject:tag];
    if(selected){
        [self.selectedTags addObject:tag];
        if([self.tagDelegate respondsToSelector:@selector(tagList:selectedTag:)]) [self.tagDelegate tagList:self selectedTag:tag];
    }
    [self layoutTagsFirst:NO];
}
-(void)layoutTagsFirst:(BOOL)first{
    CGFloat oldHeight = self.frame.size.height;
    [self.tags sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *views = [self subviews];
    for(UIView *view in views) [view removeFromSuperview];
    CGFloat currentWidth = self.marginLeft + SPACE_HACK;
    CGFloat currentHeight = self.marginTop;
    CGFloat tagHeight = 0;
    
    if(self.tags.count > 0){
        NSMutableArray *buttonLine = [NSMutableArray array];
        for(NSInteger j = 0 ; j < self.tags.count ; j++){
            NSString *tag = [self.tags objectAtIndex:j];
            UIButton *tagLabel = [self buttonWithTag:tag];
            if([self.selectedTags containsObject:tag]){
                [tagLabel setSelected:YES];
                //[tagLabel.layer setBorderColor:[COLOR_WHITE CGColor]];
            }
            CGFloat difference = (self.frame.size.width - self.marginRight - self.marginLeft) - currentWidth ;
            BOOL nextLine = NO;
            if((currentWidth + tagLabel.frame.size.width + self.marginRight) > self.frame.size.width){
                currentHeight = currentHeight + tagLabel.frame.size.height + self.spacing - SPACE_HACK;
                currentWidth = self.marginLeft + SPACE_HACK;
                tagHeight = 0;
                nextLine = YES;
            }
            
            
            if(tagLabel.frame.size.height > tagHeight) tagHeight = tagLabel.frame.size.height;
            
            tagLabel.frame = CGRectSetPos(tagLabel.frame, currentWidth - SPACE_HACK, currentHeight);
            currentWidth = currentWidth + tagLabel.frame.size.width + self.spacing - SPACE_HACK;
            
            if(nextLine){
                CGFloat extraForEach = difference/buttonLine.count;
                for(NSInteger i = 0 ; i < buttonLine.count ; i++){
                    UIButton *tagButton = [buttonLine objectAtIndex:i];
                    CGRectSetSize(tagButton.frame, tagButton.frame.size.width+extraForEach, tagButton.frame.size.height);
                    CGRectSetX(tagButton.frame, tagButton.frame.origin.x+(i*extraForEach));
                }
                [buttonLine removeAllObjects];
            }
            [buttonLine addObject:tagLabel];
            [self addSubview:tagLabel];
        }
    }
    else{
        UILabel *noTagLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.marginLeft, self.marginTop, self.frame.size.width-self.marginLeft-self.marginRight, 30)];
        noTagLabel.textAlignment = UITextAlignmentCenter;
        noTagLabel.backgroundColor = [UIColor clearColor];
        noTagLabel.textColor = [UIColor whiteColor];
        noTagLabel.text = self.emptyText ? self.emptyText : @"No tags";
        [self addSubview:noTagLabel];
        tagHeight = 30;
    }
    currentHeight += tagHeight + self.bottomMargin;
    CGRectSetSize(self.frame, self.frame.size.width, currentHeight);
    CGFloat differenceHeight = oldHeight-currentHeight;
    if(!first && differenceHeight != 0 && [self.resizeDelegate respondsToSelector:@selector(tagList:changedSize:)]){
        [self.resizeDelegate tagList:self changedSize:self.frame.size];
    }
    //if(resize) CGRectSetY(self.frame, self.frame.origin.y+differenceHeight);
}
-(CGSize)sizeForTagWithText:(NSString*)text{
    CGSize textSize = [text sizeWithFont:TAG_FONT];
    textSize.width += TAG_HORIZONTAL_PADDING*2;
    textSize.height = TAG_HEIGHT;
    //textSize.height += TAG_VERTICAL_PADDING*2;
    return textSize;
}
-(void)clickedButton:(UIButton*)sender{
    NSString *tag = sender.titleLabel.text;
    if([self.selectedTags containsObject:tag]){
        [self.selectedTags removeObject:tag];
        sender.selected = NO;
        if([self.tagDelegate respondsToSelector:@selector(tagList:deselectedTag:)]) [self.tagDelegate tagList:self deselectedTag:tag];
    }
    else {
        [self.selectedTags addObject:tag];
        sender.selected = YES;
        if([self.tagDelegate respondsToSelector:@selector(tagList:selectedTag:)]) [self.tagDelegate tagList:self selectedTag:tag];
    }
}
-(UIButton*)buttonWithTag:(NSString*)tag{
    CGSize sizeForTag = [self sizeForTagWithText:tag];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, sizeForTag.width, sizeForTag.height);
    [button setTitle:tag forState:UIControlStateNormal];
    //button.layer.borderColor = [COLOR_BLUE CGColor];
    //button.layer.borderWidth = 1;
    //button.layer.cornerRadius = 5;
    //button.layer.masksToBounds = YES;
    [button setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    [button setTitleColor:COLOR_WHITE forState:UIControlStateSelected];
    [button setBackgroundImage:[UtilityClass imageWithColor:COLOR_DARK] forState:UIControlStateNormal];
    [button setBackgroundImage:[UtilityClass imageWithColor:COLOR_BLUE] forState:UIControlStateSelected];
    button.titleLabel.font = TAG_FONT;
    [button addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    return button;
}
-(UILabel*)labelWithText:(NSString*)text{
    UILabel *label;
    return label;
}
@end
