//
//  KPLocationAlert.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPLocationAlert : UIView
+(KPLocationAlert*)alertWithFrame:(CGRect)frame message:(NSString *)message block:(SuccessfulBlock)block;
+(void)alertInView:(UIView *)view message:(NSString *)message block:(SuccessfulBlock)block;
@end
