//
//  SubtasksViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 21/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kDragableHeight 60
@interface SubtasksViewController : UIViewController
@property (nonatomic) UIView *dragableTop;
@property (nonatomic) UILabel *notification;
-(void)startedSliding;
-(void)willStartOpening:(BOOL)opening;
-(void)finishedOpening:(BOOL)opened;
@end
