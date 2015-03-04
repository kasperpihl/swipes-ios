//
//  IntegrationBaseViewController.h
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const kKeyTitle;
extern NSString* const kKeySubtitle;
extern NSString* const kKeyIcon;
extern NSString* const kKeyIsOn;
extern NSString* const kKeyCellType;
extern NSString* const kKeyTouchSelector;
extern UIColor* kIntegrationGreenColor;

typedef NS_ENUM(NSUInteger, IntegrationCellTypes) {
    kIntegrationCellTypeNoAccessory,
    kIntegrationCellTypeCheck,
    kIntegrationCellTypeStatus,
    kIntegrationCellTypeViewMore,
    kIntegrationCellTypeSeparator,
    kIntegrationCellTypeSection,
};

@interface IntegrationBaseViewController : UIViewController

@property (nonatomic, strong) UITableView* table;
@property (nonatomic, strong) UIButton* backButton;
@property (nonatomic, strong) UIColor* lightColor;
@property (nonatomic, strong) NSArray* cellInfo;

- (void)recreateCellInfo;
- (void)reloadData;
- (void)goBack;
-(void)addModalTransition;

@end
