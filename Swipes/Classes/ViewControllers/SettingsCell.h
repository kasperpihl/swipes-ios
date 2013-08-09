//
//  SettingsCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCellHeight 65
@interface SettingsCell : UITableViewCell
@property (nonatomic) UIColor *labelColor;
@property (nonatomic) UIFont *settingFont;
@property (nonatomic) UIFont *valueFont;
-(void)setSetting:(NSString*)setting value:(NSString*)value;
@end
