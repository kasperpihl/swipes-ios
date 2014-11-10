//
//  AwesomeMenuItem.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AwesomeMenuItemDelegate;

@interface AwesomeMenuItem : UILabel
{
    CGFloat _buttonSize;
    CGPoint _startPoint;
    CGPoint _endPoint;
    CGPoint _nearPoint; // near
    CGPoint _farPoint; // far
    

}
@property (nonatomic) NSString *highlightString;
@property (nonatomic) NSString *imageString;
@property (nonatomic) CGFloat buttonSize;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint nearPoint;
@property (nonatomic) CGPoint farPoint;

@property (nonatomic, weak) id<AwesomeMenuItemDelegate> delegate;

- (id)initWithImageString:(NSString*)imgStr
   highlightedImageString:(NSString*)hImgStr;

@end

@protocol AwesomeMenuItemDelegate <NSObject>
- (void)AwesomeMenuItemTouchesBegan:(AwesomeMenuItem *)item;
- (void)AwesomeMenuItemTouchesEnd:(AwesomeMenuItem *)item;
@end