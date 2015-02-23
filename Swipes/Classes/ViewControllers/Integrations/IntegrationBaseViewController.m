//
//  IntegrationBaseViewController.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "IntegrationBaseViewController.h"

static CGFloat const kTopMargin = 50;
static CGFloat const kBottomMargin = 50;

@interface IntegrationBaseViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation IntegrationBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += kTopMargin;
    viewFrame.size.height -= kTopMargin + kBottomMargin;
    self.table = [[UITableView alloc] initWithFrame:viewFrame];
    self.table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.table.backgroundColor = [UIColor clearColor];
    self.table.rowHeight = 60;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - kBottomMargin, kBottomMargin, kBottomMargin)];
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.backButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    self.backButton.titleLabel.font = iconFont(23);
    [self.backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
    
    [self.backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
    // TODO setup icon & font
    [self.view addSubview:self.backButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressedBack:(id)sender {
    [self removeFromParentViewController];
}

@end
