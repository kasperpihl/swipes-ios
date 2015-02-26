//
//  SettingsCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCellHeight 55
@interface SettingsCell : UITableViewCell
@property (nonatomic) UIColor *labelColor;
@property (nonatomic) UIFont *settingFont;
@property (nonatomic) UIFont *valueFont;
@property (nonatomic) UILabel *settingLabel;
@property (nonatomic) UILabel *valueLabel;
@property (nonatomic) NSInteger leftPadding;
-(void)setSetting:(NSString*)setting value:(NSString*)value;
@end
