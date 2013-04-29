//
//  KPTagView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPTagList.h"
@class KPAddTagPanel;
@protocol KPAddTagDelegate <NSObject>
-(void)tagPanel:(KPAddTagPanel*)tagPanel createdTag:(NSString*)tag;
-(void)tagPanel:(KPAddTagPanel*)tagPanel closedWithSelectedTags:(NSArray*)selectedTags;
@end

@interface KPAddTagPanel : UIView
@property (nonatomic,weak) IBOutlet KPTagList *tagView;
@property (nonatomic,weak) NSObject <KPAddTagDelegate> *delegate;
-(void)show:(BOOL)show;
@end