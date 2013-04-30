//
//  KPTagList.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import "KPTagList.h"
#import <QuartzCore/QuartzCore.h>
#define VERTICAL_MARGIN 5
#define HORIZONTAL_MARGIN 5
#define TAG_HORIZONTAL_PADDING 10
#define TAG_VERTICAL_PADDING 7

#define TAG_HORIZONTAL_SPACING 5
#define TAG_VERTICAL_SPACING 5

#define TAG_FONT [UIFont fontWithName:@"HelveticaNeue" size:14]

#define TEXT_COLOR [UIColor blackColor]

@interface KPTagList ()
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
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
-(void)setTagDelegate:(NSObject<KPTagDelegate> *)tagDelegate{
    _tagDelegate = tagDelegate;
    [self reloadData];
}
-(void)reloadData{
    self.tags = [[self.tagDelegate tagsForTagList:self] mutableCopy];
    self.selectedTags = [[self.tagDelegate selectedTagsForTagList:self] mutableCopy];
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
    CGFloat currentWidth = HORIZONTAL_MARGIN;
    CGFloat currentHeight = VERTICAL_MARGIN;
    CGFloat tagHeight = 0;
    if(self.tags.count > 0){
        for(NSString *tag in self.tags){
            UIButton *tagLabel = [self buttonWithTag:tag];
            if([self.selectedTags containsObject:tag]) [tagLabel setSelected:YES];
            if((currentWidth + tagLabel.frame.size.width + HORIZONTAL_MARGIN) > self.frame.size.width){
                currentHeight = currentHeight + tagLabel.frame.size.height + TAG_VERTICAL_SPACING;
                currentWidth = HORIZONTAL_MARGIN;
                tagHeight = 0;
            }
            if(tagLabel.frame.size.height > tagHeight) tagHeight = tagLabel.frame.size.height;
            tagLabel.frame = CGRectSetPos(tagLabel.frame, currentWidth, currentHeight);
            currentWidth = currentWidth + tagLabel.frame.size.width + TAG_HORIZONTAL_SPACING;
            [self addSubview:tagLabel];
        }
    }
    else{
        UILabel *noTagLabel = [[UILabel alloc]initWithFrame:CGRectMake(HORIZONTAL_MARGIN, VERTICAL_MARGIN, self.frame.size.width-2*HORIZONTAL_MARGIN, 30)];
        noTagLabel.textAlignment = UITextAlignmentCenter;
        noTagLabel.text = @"No tags yet";
        [self addSubview:noTagLabel];
        tagHeight = 30;
    }
    currentHeight += tagHeight + VERTICAL_MARGIN;
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
    textSize.height += TAG_VERTICAL_PADDING*2;
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
    button.titleLabel.textColor = TEXT_COLOR;
    [button setTitle:tag forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"tag_background"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"tag_selected_background"] forState:UIControlStateSelected];
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
