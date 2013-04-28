//
//  KPTagList.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPTagList;
@protocol KPAddTagDelegate
-(NSArray*)tagsForTagList:(KPTagList*)tagList;
-(NSArray*)selectedTagsForTagList:(KPTagList*)tagList;
@optional
-(void)didCreateTag:(NSString*)tag;
-(void)tagPanel:(KPTagList*)tagPanel closedWithSelectedTags:(NSArray*)selectedTags removedTags:(NSArray*)removedTags;
@end
@interface KPTagList : UIView
@property (nonatomic,weak) NSObject<KPAddTagDelegate> *tagDelegate;
+(KPTagList*)tagListWithWidth:(CGFloat)width;
@end
