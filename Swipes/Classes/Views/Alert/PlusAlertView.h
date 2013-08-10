//
//  PlusAlertView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlusAlertView : UIView
+(void)alertInView:(UIView*)view message:(NSString*)message block:(SuccessfulBlock)block;
+(PlusAlertView*)alertWithFrame:(CGRect)frame message:(NSString *)message block:(SuccessfulBlock)block;
@end
