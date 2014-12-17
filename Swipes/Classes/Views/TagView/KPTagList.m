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
#import "UIColor+Utilities.h"
#import "SlowHighlightIcon.h"
#import "AudioHandler.h"
#define VERTICAL_MARGIN 3
#define HORIZONTAL_MARGIN 10
#define TAG_HORIZONTAL_PADDING 6
#define TAG_BUTTON_TAG 123
#define kAddButtonTag 4114
#define kDefaultSpacing 10

#define SPACE_HACK 0


@interface KPTagList () <UIGestureRecognizerDelegate>
@property (nonatomic,strong) NSMutableArray *tags;
@property (nonatomic,strong) NSMutableArray *selectedTags;
@property (nonatomic,strong) NSString *editingTag;
@end
@implementation KPTagList
+(KPTagList *)tagListWithWidth:(CGFloat)width andTags:(NSArray*)tags{
    KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, width, 100)];
    tagList.tags = [tags mutableCopy];
    [tagList layoutTagsFirst:YES];
    
    return tagList;
}
-(NSArray *)getSelectedTags{
    return (self.selectedTags.count > 0) ? self.selectedTags : nil;
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
        self.tagTitleColor = tcolor(TextColor);
        //self.selectedTagTitleColor = tcolor(TextColor);
        self.tagBackgroundColor = CLEAR;
        //self.selectedTagBackgroundColor = tcolor(DoneColor);
        self.selectedTagBackgroundColor = alpha(tcolor(TextColor),0.9);
        self.selectedTagTitleColor = tcolor(BackgroundColor);
        self.tagBorderColor = tcolor(TextColor);
        self.bottomMargin = VERTICAL_MARGIN;
        self.marginTop = VERTICAL_MARGIN;
        self.marginLeft = HORIZONTAL_MARGIN;
        self.marginRight = HORIZONTAL_MARGIN;
        self.spacing = kDefaultSpacing;
    }
    return self;
}
-(void)setTagDataSource:(id<KPTagListDataSource>)tagDataSource{
    _tagDataSource = tagDataSource;
    [self reloadData];
}
-(void)reloadData{
    if([self.tagDataSource respondsToSelector:@selector(tagsForTagList:)]) self.tags = [[self.tagDataSource tagsForTagList:self] mutableCopy];
    if([self.tagDataSource respondsToSelector:@selector(selectedTagsForTagList:)]) self.selectedTags = [[self.tagDataSource selectedTagsForTagList:self] mutableCopy];
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
    if(self.sorted) [self.tags sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *views = [self subviews];
    for(UIView *view in views) [view removeFromSuperview];
    CGFloat currentWidth = self.marginLeft + SPACE_HACK;
    CGFloat currentHeight = self.marginTop;
    CGFloat tagHeight = 0;
    NSInteger numberOfTags = self.tags.count;
    self.numberOfRows = 1;
    self.numberOfTags = numberOfTags;
    if(numberOfTags > 0){
        self.isEmptyList = NO;
        NSMutableArray *buttonLine = [NSMutableArray array];
        for(NSInteger j = 0 ; j <= numberOfTags ; j++){
            UIButton *tagButton;
            BOOL isLastTag = (j == (numberOfTags-1));
            BOOL isAddButton = (j == numberOfTags);
            
            
            CGFloat targetWidth = self.frame.size.width;
            if(self.numberOfRows == 1 && self.firstRowSpacingHack)
                targetWidth = self.frame.size.width - self.firstRowSpacingHack;
            if((isLastTag && !self.addTagButton) || isAddButton)
                targetWidth = self.frame.size.width - self.lastRowSpacingHack;
            
            
            if(isAddButton){
                if(!self.addTagButton)
                    continue;
                tagButton = [self addButton];
            }
            else{
                NSString *tag = [self.tags objectAtIndex:j];
                tagButton = [self buttonWithTag:tag];
                tagButton.tag = TAG_BUTTON_TAG + j;
                if([self.selectedTags containsObject:tag]){
                    [tagButton setSelected:YES];
                    if(self.selectedTagBorderColor) tagButton.layer.borderColor = self.selectedTagBorderColor.CGColor;
                    //[tagLabel.layer setBorderColor:[COLOR_WHITE CGColor]];
                }
            }
            

            CGFloat difference = (targetWidth - self.marginRight) - currentWidth ;
            BOOL nextLine = NO;
            
            CGFloat addButtonSpaceIfLastItem = (isLastTag && self.addTagButton) ? [self sizeForTagWithText:@"add"].height+self.spacing : 0;
            
            if((currentWidth + tagButton.frame.size.width + self.marginRight + addButtonSpaceIfLastItem ) > targetWidth){
                currentHeight = currentHeight + tagButton.frame.size.height + self.spacing - SPACE_HACK;
                currentWidth = self.marginLeft + SPACE_HACK;
                tagHeight = 0;
                nextLine = YES;
                self.numberOfRows++;
            }
            /*if(j == numberOfTags-1){
                nextLine = YES;
                [buttonLine addObject:tagLabel];
            }*/
            
            
            if(tagButton.frame.size.height > tagHeight)
                tagHeight = tagButton.frame.size.height;
            
            tagButton.frame = CGRectSetPos(tagButton.frame, currentWidth - SPACE_HACK, currentHeight);
            currentWidth = currentWidth + tagButton.frame.size.width + self.spacing - SPACE_HACK;
            
            if(nextLine){
                NSInteger numberOfButtonsInRow = buttonLine.count;
                CGFloat extraForEach = (difference+self.spacing)/numberOfButtonsInRow;
                for(NSInteger i = 0 ; i < numberOfButtonsInRow ; i++){
                    UIButton *tagButton = [buttonLine objectAtIndex:i];
                    CGRectSetWidth(tagButton, tagButton.frame.size.width+extraForEach);
                    CGRectSetX(tagButton, tagButton.frame.origin.x+(i*extraForEach));
                }
                [buttonLine removeAllObjects];
            }
            [buttonLine addObject:tagButton];
            [self addSubview:tagButton];
            if(isLastTag || isAddButton){
                self.remainingSpaceOnLastLine = targetWidth - currentWidth;
            }
        }
        
    }
    else{
        tagHeight = TAG_HEIGHT;
        self.isEmptyList = YES;
        UIButton *noTagButton = [[UIButton alloc]initWithFrame:CGRectMake(self.marginLeft+self.emptyLabelMarginHack, self.marginTop, self.frame.size.width-self.marginLeft-self.marginRight, TAG_HEIGHT)];
        noTagButton.titleLabel.font = NO_TAG_FONT;
        noTagButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        noTagButton.backgroundColor = [UIColor clearColor];
        [noTagButton setTitleColor:self.tagTitleColor forState:UIControlStateNormal];
        [noTagButton setTitle:self.emptyText ? self.emptyText : @"No tags, tap to add." forState:UIControlStateNormal];
        [noTagButton addTarget:self action:@selector(pressedNoTagButton) forControlEvents:UIControlEventTouchUpInside];
        //[noTagLabel sizeToFit];
        //noTagLabel.frame = CGRectSetPos(noTagLabel.frame, ((self.frame.size.width-noTagLabel.frame.size.width)/2)+self.emptyLabelMarginHack, (totalHeight-noTagLabel.frame.size.height)/2);
        [self addSubview:noTagButton];
        
    }
    currentHeight += tagHeight + self.bottomMargin;
    CGRectSetHeight(self, currentHeight);
    CGFloat differenceHeight = oldHeight-currentHeight;
    if(!first && differenceHeight != 0 && [self.resizeDelegate respondsToSelector:@selector(tagList:changedSize:)]){
        [self.resizeDelegate tagList:self changedSize:self.frame.size];
    }
    //if(resize) CGRectSetY(self.frame, self.frame.origin.y+differenceHeight);
}
- (void)pressedNoTagButton{
    if([self.addDelegate respondsToSelector:@selector(pressedAddButtonForTagList:)])
        [self.addDelegate pressedAddButtonForTagList:self];
}
- (void) animationKeyFramed: (CALayer *) layer
                   delegate: (id) object
                     forKey: (NSString *) key {
    int random = arc4random() % 10 + 1;
    CGFloat beginTime = 0.2f / random;
    CAKeyframeAnimation *animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.2;
    animation.beginTime = CACurrentMediaTime()+ beginTime;
    animation.cumulative = YES;
    animation.repeatCount = 1000;
    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat: 0.0],
                        [NSNumber numberWithFloat: radians(-2.0)],
                        [NSNumber numberWithFloat: 0.0],
                        [NSNumber numberWithFloat: radians(2.0)],
                        [NSNumber numberWithFloat: 0.0], nil];
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = NO;
    animation.delegate = object;
    
    [layer addAnimation:animation forKey:key];
}
-(void)setWobling:(BOOL)wobling forView:(UIButton*)button{
    _wobling = wobling;
    BOOL isAddButton = (button.tag == kAddButtonTag);
    if(isAddButton){
        button.hidden = wobling;
        return;
    }
    if(wobling){
        UIColor *woblingColor = tcolor(LaterColor);
        [self animationKeyFramed:button.layer delegate:self forKey:@"wobbling"];
        [button setBackgroundImage:[woblingColor image] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[woblingColor image] forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    else{
        [button.layer removeAnimationForKey:@"wobbling"];
        [button setBackgroundImage:[self.selectedTagBackgroundColor image] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[self.tagTitleColor image] forState:UIControlStateSelected | UIControlStateHighlighted];
    }
}
-(void)setWobling:(BOOL)wobling{
    _wobling = wobling;
    for(UIButton *button in self.subviews){
        if(![button isKindOfClass:[UIButton class]]) continue;
        [self setWobling:wobling forView:button];
    }
}
-(CGSize)sizeForTagWithText:(NSString*)text{
    
    CGSize textSize = sizeWithFont(text, TAG_FONT);
    textSize.width += TAG_HORIZONTAL_PADDING*2;
    textSize.height = TAG_HEIGHT;
    //textSize.height += TAG_VERTICAL_PADDING*2;
    return textSize;
}
-(void)deleteTag:(NSString*)tag{
    if([self.tags containsObject:tag]) [self.tags removeObject:tag];
    if([self.selectedTags containsObject:tag]) [self.selectedTags removeObject:tag];
    if([self.tagDelegate respondsToSelector:@selector(tagList:deletedTag:)])[self.tagDelegate tagList:self deletedTag:tag];
    [self layoutTagsFirst:NO];
    if(self.tags.count == 0) self.wobling = NO;
}
-(void)clickedButton:(UIButton*)sender{
    NSString *tag = sender.titleLabel.text;
    if(self.wobling){
        if([self.deleteDelegate respondsToSelector:@selector(tagList:triedToDeleteTag:)])
            [self.deleteDelegate tagList:self triedToDeleteTag:tag];
        return;
    }
    if([self.selectedTags containsObject:tag]){
        [kAudio playSoundWithName:@"New state - scheduled.m4a"];
        [self.selectedTags removeObject:tag];
        sender.selected = NO;
        if([self.tagDelegate respondsToSelector:@selector(tagList:deselectedTag:)]) [self.tagDelegate tagList:self deselectedTag:tag];
    }
    else {
        [kAudio playSoundWithName:@"Succesful action.m4a"];
        [self.selectedTags addObject:tag];
        sender.selected = YES;
        if([self.tagDelegate respondsToSelector:@selector(tagList:selectedTag:)]) [self.tagDelegate tagList:self selectedTag:tag];
    }
}
-(UIButton*)addButton{
    UIButton *addButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
    CGSize sizeForButton = [self sizeForTagWithText:@"add"];
    addButton.tag = kAddButtonTag;
    addButton.frame = CGRectMake(0, 0, sizeForButton.height, sizeForButton.height);
    addButton.layer.cornerRadius = sizeForButton.height/2;
    addButton.layer.borderColor = self.tagTitleColor.CGColor;
    addButton.layer.masksToBounds = YES;
    addButton.layer.borderWidth = LINE_SIZE;
    addButton.titleLabel.font = iconFont(14);
    //addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [addButton setTitle:@"plusThick" forState:UIControlStateNormal];
    [addButton setTitleColor:self.tagTitleColor forState:UIControlStateNormal];
    [addButton setTitleColor:self.selectedTagTitleColor forState:UIControlStateHighlighted];
    [addButton setBackgroundImage:[self.tagBackgroundColor image] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[self.selectedTagBackgroundColor image] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(pressedAdd:) forControlEvents:UIControlEventTouchUpInside];
    return addButton;
}
-(UIButton*)buttonWithTag:(NSString*)tag{
    CGSize sizeForTag = [self sizeForTagWithText:tag];
    SlowHighlightIcon *button = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, sizeForTag.width, sizeForTag.height);
    [button setTitle:tag forState:UIControlStateNormal];
    [button setTitleColor:self.tagTitleColor forState:UIControlStateNormal];
    [button setTitleColor:self.selectedTagTitleColor forState:UIControlStateHighlighted];
    [button setTitleColor:self.selectedTagTitleColor forState:UIControlStateSelected];
    [button setTitleColor:self.tagTitleColor forState:UIControlStateHighlighted | UIControlStateSelected];
    [button setBackgroundImage:[self.tagBackgroundColor image] forState:UIControlStateNormal];
    [button setBackgroundImage:[self.tagBackgroundColor image] forState:UIControlStateHighlighted | UIControlStateSelected];
    [button setBackgroundImage:[self.selectedTagBackgroundColor image] forState:UIControlStateSelected];
    [button setBackgroundImage:[self.selectedTagBackgroundColor image] forState:UIControlStateHighlighted];
    button.titleLabel.font = KP_REGULAR(14);
    [button addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    button.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    button.layer.cornerRadius = button.frame.size.height/2;
    button.layer.borderColor = self.tagBorderColor.CGColor;
    button.layer.borderWidth = LINE_SIZE;
    button.layer.masksToBounds = YES;
    if(self.wobling) [self setWobling:YES forView:button];
    return button;
}

-(void)pressedAdd:(UIButton*)sender{
    if([self.addDelegate respondsToSelector:@selector(pressedAddButtonForTagList:)])
        [self.addDelegate pressedAddButtonForTagList:self];
    
}

-(UILabel*)labelWithText:(NSString*)text{
    UILabel *label;
    return label;
}
@end
