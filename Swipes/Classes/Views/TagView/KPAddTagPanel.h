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

@interface KPAddTagPanel : UIView
@property (nonatomic,weak) IBOutlet KPTagList *tagView;
-(void)show:(BOOL)show;
@end