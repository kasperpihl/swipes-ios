//
//  KPTagList.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPTagList;
@protocol KPTagListResizeDelegate <NSObject>
-(void)tagList:(KPTagList*)tagList changedSize:(CGSize)size;
@end
@protocol KPTagListDeleteDelegate <NSObject>
-(void)tagList:(KPTagList*)tagList triedToDeleteTag:(NSString*)tag;
@end
@protocol KPTagDelegate
@optional
-(void)tagList:(KPTagList*)tagList deletedTag:(NSString*)tag;
-(NSArray*)tagsForTagList:(KPTagList*)tagList;
-(NSArray*)selectedTagsForTagList:(KPTagList*)tagList;
-(NSArray*)deselectedTagsForTagList:(KPTagList*)tagList;
-(void)tagList:(KPTagList*)tagList selectedTag:(NSString*)tag;
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString*)tag;
@end
@interface KPTagList : UIView
@property (nonatomic) NSString *emptyText;
@property (nonatomic) NSInteger marginTop;
@property (nonatomic) NSInteger bottomMargin;
@property (nonatomic) NSInteger marginLeft;
@property (nonatomic) NSInteger marginRight;
@property (nonatomic) NSInteger firstRowSpacingHack;
@property (nonatomic) NSInteger spacing;
@property (nonatomic) NSInteger emptyLabelMarginHack;

@property (nonatomic) UIColor *tagBackgroundColor;
@property (nonatomic) UIColor *tagTitleColor;
@property (nonatomic) UIColor *tagBorderColor;

@property (nonatomic) UIColor *selectedTagBackgroundColor;
@property (nonatomic) UIColor *selectedTagTitleColor;
@property (nonatomic) UIColor *selectedTagBorderColor;
@property (nonatomic) BOOL sorted;
@property (nonatomic) BOOL isEmptyList;
@property (nonatomic) BOOL enableEdit;
@property (nonatomic) BOOL wobling;
@property (nonatomic) NSInteger numberOfRows;
@property (nonatomic) NSInteger numberOfTags;
@property (nonatomic,weak) NSObject<KPTagDelegate> *tagDelegate;
@property (nonatomic,weak) NSObject<KPTagListResizeDelegate> *resizeDelegate;
@property (nonatomic,weak) NSObject<KPTagListDeleteDelegate> *deleteDelegate;
-(void)setTags:(NSArray*)tags andSelectedTags:(NSArray*)selectedTags;
+(KPTagList*)tagListWithWidth:(CGFloat)width andTags:(NSArray*)tags;
-(void)addTag:(NSString*)tag selected:(BOOL)selected;
-(void)setWobling:(BOOL)wobling;
-(void)deleteTag:(NSString*)tag;
-(NSArray*)getSelectedTags;
@end
