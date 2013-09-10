//
//  DateStampView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 05/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kStampSize 120
@interface DateStampView : UIView
-(id)initWithDate:(NSDate*)date;
@property (nonatomic) NSDate *date;
@end
