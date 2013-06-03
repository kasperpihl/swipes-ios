//
//  AlertPopup.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPPopup.h"
typedef void (^AlarmPopupBlock)(NSDate *chosenDate);
@interface AlarmPopup : KPPopup
+(AlarmPopup *)showInView:(UIView *)view withBlock:(AlarmPopupBlock)block andDate:(NSDate*)alarmDate;
@end
