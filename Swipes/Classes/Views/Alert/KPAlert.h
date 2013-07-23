//
//  KPAlert.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPAlert : UIView
+(void)confirmInView:(UIView*)view title:(NSString*)title message:(NSString*)message block:(SuccessfulBlock)block;
@end
