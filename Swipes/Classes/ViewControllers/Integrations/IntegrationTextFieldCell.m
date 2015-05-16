//
//  IntegrationTextFieldCell.m
//  Swipes
//
//  Created by demosten on 5/12/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "IntegrationTextFieldCell.h"

static CGFloat const kTopMargin = 10;
static CGFloat const kLabelMargin = 9;
static CGFloat const kHorizontalMargin = 26;
static CGFloat const kTextFieldHeight = 16;
static CGFloat const kLabelHeight = 16;
static CGFloat const kUnderlineMargin = 2;

#define kDefTitleFont KP_BOLD(10)
#define kDefTextFieldFont KP_REGULAR(16)

@interface IntegrationTextFieldCell () <UITextFieldDelegate>

@property (nonatomic, assign) IntegrationTextFieldStyle style;
@property (nonatomic, assign) BOOL mandatory;
@property (nonatomic, strong) UIView* lineView;
@property (nonatomic, strong) UILabel* titleLabel;

@end

@implementation IntegrationTextFieldCell

- (instancetype)initWithCustomStyle:(IntegrationTextFieldStyle)style reuseIdentifier:(NSString *)reuseIdentifier mandatory:(BOOL)mandatory
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalMargin, kTopMargin, self.contentView.frame.size.width - 2 * kHorizontalMargin, kLabelHeight)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = tcolor(TextColor);
        _titleLabel.font = kDefTitleFont;
        [self.contentView addSubview:_titleLabel];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(kHorizontalMargin, kTopMargin + kLabelHeight + kLabelMargin, self.contentView.frame.size.width - 2 * kHorizontalMargin, kTextFieldHeight)];
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = tcolor(TextColor);
        _textField.font = kDefTextFieldFont;
        _textField.returnKeyType = UIReturnKeyNext;
        _textField.delegate = self;
        [self.contentView addSubview:_textField];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(kHorizontalMargin, kTopMargin + kLabelHeight + kLabelMargin + kTextFieldHeight + kUnderlineMargin, self.contentView.frame.size.width - 2 * kHorizontalMargin, 0.5)];
        _lineView.backgroundColor = gray(158, 1);
        _lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_lineView];
        
        self.customStyle = style;
        self.mandatory = mandatory;
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setupTitle];
}

- (void)setupTitle
{
    NSString* title = _mandatory ? [NSString stringWithFormat:@"%@ %@", [_title uppercaseString], @"actionIndicatorOn"] : [_title uppercaseString];
    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:title];
    [myString addAttribute:NSKernAttributeName value:@(1.5) range:NSMakeRange(0, _title.length)];
    if (_mandatory) {
        NSRange range = NSMakeRange(_title.length + 1, 17);
        [myString addAttribute:NSFontAttributeName value:iconFont(6) range:range];
        [myString addAttribute:NSBaselineOffsetAttributeName value:@(7) range:range];
        [myString addAttribute:NSForegroundColorAttributeName value:tcolor(LaterColor) range:range];
    }
    self.titleLabel.attributedText = [[NSAttributedString alloc]initWithAttributedString: myString];
}

- (void)setCustomStyle:(IntegrationTextFieldStyle)customStyle
{
    _customStyle = customStyle;
    switch (customStyle) {
        case IntegrationTextFieldStyleEmail:
            self.textField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case IntegrationTextFieldStylePhone:
            self.textField.keyboardType = UIKeyboardTypePhonePad;
            break;
        default:
            self.textField.keyboardType = UIKeyboardTypeDefault;
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(textFieldCellShouldReturn:)]) {
        return [_delegate textFieldCellShouldReturn:self];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(textFieldCellDidBeginEditing:)]) {
        [_delegate textFieldCellDidBeginEditing:self];
    }
}

@end
