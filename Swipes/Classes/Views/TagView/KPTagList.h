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
@protocol KPTagDelegate
-(NSArray*)tagsForTagList:(KPTagList*)tagList;
-(NSArray*)selectedTagsForTagList:(KPTagList*)tagList;
@optional
-(void)tagList:(KPTagList*)tagList selectedTag:(NSString*)tag;
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString*)tag;
@end
@interface KPTagList : UIView
@property (nonatomic,weak) NSObject<KPTagDelegate> *tagDelegate;
@property (nonatomic,weak) NSObject<KPTagListResizeDelegate> *resizeDelegate;
@property (nonatomic,strong) NSMutableArray *tags;
@property (nonatomic,strong) NSMutableArray *selectedTags;
+(KPTagList*)tagListWithWidth:(CGFloat)width andTags:(NSArray*)tags;
-(void)addTag:(NSString*)tag selected:(BOOL)selected;
@end
