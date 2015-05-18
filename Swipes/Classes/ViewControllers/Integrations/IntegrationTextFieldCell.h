//
//  IntegrationTextFieldCell.h
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, IntegrationTextFieldStyle) {
    IntegrationTextFieldStyleDefault    = 0,
    IntegrationTextFieldStyleEmail,
    IntegrationTextFieldStylePhone,
};

@class IntegrationTextFieldCell;

@protocol IntegrationTextFieldCellDelegate <NSObject>

@optional

- (BOOL)textFieldCellShouldReturn:(IntegrationTextFieldCell *)cell;
- (void)textFieldCellDidBeginEditing:(IntegrationTextFieldCell *)cell;

@end


@interface IntegrationTextFieldCell : UITableViewCell

@property (nonatomic, strong) UITextField* textField;
@property (nonatomic, assign) IntegrationTextFieldStyle customStyle;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, weak) id<IntegrationTextFieldCellDelegate> delegate;
@property (nonatomic, assign) BOOL mandatory;

@end
