//
//  MCSwipeTableViewCell.h
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//

@class MCSwipeTableViewCell;

#define MAX_DRAGGING 10
typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellDirection){
    MCSwipeTableViewCellDirectionLeft = 0,
    MCSwipeTableViewCellDirectionCenter,
    MCSwipeTableViewCellDirectionRight
};

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellMode){
    MCSwipeTableViewCellModeExit = 0,
    MCSwipeTableViewCellModeSwitch
};

@protocol MCSwipeTableViewCellDelegate <NSObject>

@optional
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didStartPanningWithMode:(MCSwipeTableViewCellMode)mode;
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode;
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didHandleGestureRecognizer:(UIPanGestureRecognizer *)gesture withTranslation:(CGPoint)translation;
-(BOOL)swipeTableViewCell:(MCSwipeTableViewCell *)cell shouldHandleGestureRecognizer:(UIPanGestureRecognizer *)gesture;
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell slidedIntoState:(MCSwipeTableViewCellState)state;

@end
@interface MCSwipeTableViewCell : UITableViewCell
@property(nonatomic, assign) id <MCSwipeTableViewCellDelegate> delegate;

@property(nonatomic, copy) NSString *firstIconName;
@property(nonatomic, copy) NSString *secondIconName;
@property(nonatomic, copy) NSString *thirdIconName;
@property(nonatomic, copy) NSString *fourthIconName;

@property(nonatomic, strong) UIColor *firstColor;
@property(nonatomic, strong) UIColor *secondColor;
@property(nonatomic, strong) UIColor *thirdColor;
@property(nonatomic, strong) UIColor *fourthColor;
@property(nonatomic, assign) MCSwipeTableViewCellActivatedDirection activatedDirection;
@property(nonatomic, assign) MCSwipeTableViewCellMode mode;
-(void)switchToState:(MCSwipeTableViewCellState)state;
- (void)publicHandlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture withTranslation:(CGPoint)translation;
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
 firstStateIconName:(NSString *)firstIconName
         firstColor:(UIColor *)firstColor
secondStateIconName:(NSString *)secondIconName
        secondColor:(UIColor *)secondColor
      thirdIconName:(NSString *)thirdIconName
         thirdColor:(UIColor *)thirdColor
     fourthIconName:(NSString *)fourthIconName
        fourthColor:(UIColor *)fourthColor;
- (void)bounceToOrigin;
- (void)setFirstStateIconName:(NSString *)firstIconName
                   firstColor:(UIColor *)firstColor
          secondStateIconName:(NSString *)secondIconName
                  secondColor:(UIColor *)secondColor
                thirdIconName:(NSString *)thirdIconName
                   thirdColor:(UIColor *)thirdColor
               fourthIconName:(NSString *)fourthIconName
                  fourthColor:(UIColor *)fourthColor;

@end
