//
//  HelpViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/11/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "HelpingViewController.h"
#import "RootViewController.h"
#import "KPAlert.h"
#import "KPBlurry.h"
#import "UtilityClass.h"
#import "Intercom.h"
#define kLocalCellHeight 55
#define kSettingsBlurColor retColor(gray(230, 0.5),gray(50, 0.4))
#define kCellCount 6

@interface HelpingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation HelpingViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return kCellCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"ActionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ( cell == nil ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = CLEAR;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = CLEAR;
        cell.textLabel.font = KP_REGULAR(16);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.transform = CGAffineTransformMakeRotation(M_PI);
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.textLabel.textColor = tcolor(TextColor);
    switch (indexPath.row) {
        case 5:
            cell.textLabel.text = LOCALIZE_STRING(@"Contact Swipes");
            break;
        case 4:
            cell.textLabel.text = LOCALIZE_STRING(@"Walkthrough");
            break;
        case 3:
            cell.textLabel.text = LOCALIZE_STRING(@"Get Started Guides");
            break;
        case 2:
            cell.textLabel.text = LOCALIZE_STRING(@"FAQ");
            break;
        case 1:
            cell.textLabel.text = LOCALIZE_STRING(@"Known Issues");
            break;
        case 0:
            cell.textLabel.text = LOCALIZE_STRING(@"Open Policies");
        default:
            break;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __block NSString *getStartedURL = @"http://support.swipesapp.com/hc/en-us/sections/200685992-Get-Started";
    __block NSString *faqURL = @"http://support.swipesapp.com/hc/en-us/categories/200368652-FAQ";
    __block NSString *knownIssuesURL = @"http://support.swipesapp.com/hc/en-us/sections/200659851-Known-Issues";
    __block NSString *policiesURL = @"http://swipesapp.com/policies.pdf";
    NSString *cancelTitle = [LOCALIZE_STRING(@"cancel") capitalizedString];
    NSString *openTitle = [LOCALIZE_STRING(@"open") capitalizedString];
    switch (indexPath.row) {
        case 5:
            [Intercom presentMessageViewAsConversationList:YES];
            break;
        case 4:
            [ROOT_CONTROLLER walkthrough];
            break;
        case 3:
            [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Get Started") andMessage:LOCALIZE_STRING(@"Learn how to get most out of Swipes.") cancel:cancelTitle confirm:openTitle block:^(BOOL succeeded, NSError *error) {
                
                if(succeeded){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: getStartedURL]];
                }
            }];
            break;
        case 2:
            [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"FAQ") andMessage:LOCALIZE_STRING(@"Learn how to get most out of the different features in Swipes.") cancel:cancelTitle confirm:openTitle block:^(BOOL succeeded, NSError *error) {
                
                if(succeeded){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: faqURL]];
                }
            }];
            break;
        case 1:
            [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Known Issues") andMessage:LOCALIZE_STRING(@"You found a bug? Check out if we're already working on it.") cancel:cancelTitle confirm:openTitle block:^(BOOL succeeded, NSError *error) {
                
                if(succeeded){
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: knownIssuesURL]];
                }
            }];
            break;
        case 0:{
            [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Policies") andMessage:LOCALIZE_STRING(@"Read through our 'Privacy Policy' and 'Terms and Conditions'.") cancel:cancelTitle confirm:openTitle block:^(BOOL succeeded, NSError *error) {
                
                if(succeeded){
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: policiesURL]];
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = CLEAR;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.rowHeight = kLocalCellHeight;
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)dealloc{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}
@end
