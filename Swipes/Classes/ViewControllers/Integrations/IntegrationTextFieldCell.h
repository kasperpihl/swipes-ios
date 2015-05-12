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


@interface IntegrationTextFieldCell : UITableViewCell

- (id)initWithCustomStyle:(IntegrationTextFieldStyle)style reuseIdentifier:(NSString *)reuseIdentifier mandatory:(BOOL)mandatory;

@property (nonatomic, strong) UITextField* textField;
@property (nonatomic, assign) IntegrationTextFieldStyle customStyle;
@property (nonatomic, strong) NSString* title;

@end
