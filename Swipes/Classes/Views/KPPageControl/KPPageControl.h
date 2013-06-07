//
//  KPPageControl.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPPageControl : UIPageControl

@property (nonatomic, readwrite, retain) UIImage* imageNormal;
@property (nonatomic, readwrite, retain) UIImage* imageCurrent;

@end