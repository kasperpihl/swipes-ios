//
//  KPTagView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPAddTagPanel;
@protocol KPAddTagDelegate
-(NSArray*)selectedTagsForTagPanel:(KPAddTagPanel*)tagPanel;
-(NSArray*)unselectedTagsForTagPanel:(KPAddTagPanel*)tagPanel;
@optional
-(void)didCreateTag:(NSString*)tag;
-(void)tagPanel:(KPAddTagPanel*)tagPanel closedWithSelectedTags:(NSArray*)selectedTags unselectedTags:(NSArray*)unselectedTags;
@end
@interface KPAddTagPanel : UIView
@property (nonatomic,weak) NSObject<KPAddTagDelegate> *tagDelegate;
-(void)addTags:(NSArray*)tags;
-(void)show:(BOOL)show;
@end