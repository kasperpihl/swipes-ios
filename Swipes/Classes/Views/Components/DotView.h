//
//  DotView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 20/10/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DotView : UIView
@property (nonatomic) UIColor *dotColor;
@property (nonatomic) BOOL priority;
@property (nonatomic) CGFloat scale;
-(CGFloat)maxHeight;
@end
