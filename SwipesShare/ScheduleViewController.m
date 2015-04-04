//
//  ScheduleViewController.m
//  Swipes
//
//  Created by demosten on 4/1/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "SchedulePopup.h"
#import "ScheduleViewController.h"

@interface ScheduleViewController ()

@property (nonatomic, strong) SchedulePopup* scheduleView;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _scheduleView = [SchedulePopup popupWithFrame:self.view.bounds block:^(KPScheduleButtons button, NSDate *chosenDate, CLPlacemark *chosenLocation, GeoFenceType type) {
//        NSInteger beforeCounter = self.itemHandler.itemCounter;
//        if(button == KPScheduleButtonCancel){
//            [self returnSelectedRowsAndBounce:YES];
//        }
//        else if(button == KPScheduleButtonLocation) {
//            NSArray *movedItems = [KPToDo notifyToDos:toDosArray onLocation:chosenLocation type:type save:YES];
//            [self moveItems:movedItems toCellType:targetCellType];
//        }
//        else {
//            if([chosenDate isEarlierThanDate:[NSDate date]]) targetCellType = CellTypeToday;
//            NSArray *movedItems = [KPToDo scheduleToDos:toDosArray forDate:chosenDate save:YES];
//            [self moveItems:movedItems toCellType:targetCellType];
//        }
//        if(button != KPScheduleButtonCancel){
//            [kHints triggerHint:HintScheduled];
//            if(!([self.state isEqualToString:@"today"] && beforeCounter == toDosArray.count))
//                [kAudio playSoundWithName:@"New state - scheduled.m4a"];
//        }
//        self.isHandlingTrigger = NO;
//        int i = 5;
    }];
    _scheduleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [[NSNotificationCenter defaultCenter] removeObserver:_scheduleView];
    _scheduleView.contentView.backgroundColor = [UIColor clearColor];
    _scheduleView.contentView.layer.cornerRadius = 0;
    _scheduleView.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    _scheduleView.contentView.layer.shadowColor = nil;
    _scheduleView.contentView.layer.shadowOpacity = 0;
        
    [self.view addSubview:_scheduleView];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
