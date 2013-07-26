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
-(void)closeTagPanel:(KPAddTagPanel*)tagPanel;
@end

@interface KPAddTagPanel : UIView
- (id)initWithFrame:(CGRect)frame andTags:(NSArray*)tags;
@property (nonatomic,weak) IBOutlet KPTagList *tagView;
@property (nonatomic,weak) NSObject <KPAddTagDelegate> *delegate;
@end