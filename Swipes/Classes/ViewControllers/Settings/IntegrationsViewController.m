//
//  IntegrationsViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "SettingsCell.h"
#import "KPAttachment.h"
#import "KPToDo.h"
#import "UtilityClass.h"
#import "CoreSyncHandler.h"
#import "UIColor+Utilities.h"
#import "EvernoteHelperViewController.h"
#import "EvernoteImporterViewController.h"
#import "EvernoteIntegration.h"
#import "IntegrationsViewController.h"


#define kSwitchTag 13
#define kLocalCellHeight 55
#define kLearnMoreHeight 70

#define kLearnMoreButtonWidth 160
#define kLearnMoreButtonHeight 44

@interface IntegrationsViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) UITableView *tableView;

@end

@implementation IntegrationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = CLEAR;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[self.tableView setSeparatorColor:tcolor(TextColor)];
    
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kLearnMoreHeight)];
    tableFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tableFooter.backgroundColor = CLEAR;
    
    
    UIButton *learnMoreButton = [[UIButton alloc] initWithFrame:CGRectMake((320-kLearnMoreButtonWidth)/2, kLearnMoreHeight-kLearnMoreButtonHeight, kLearnMoreButtonWidth, kLearnMoreButtonHeight)];
    //learnMoreButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [learnMoreButton setTitleColor:tcolorF(TextColor, ThemeDark) forState:UIControlStateNormal];
    [learnMoreButton setBackgroundImage:[kEvernoteColor image] forState:UIControlStateNormal];
    [learnMoreButton setBackgroundImage:[alpha(kEvernoteColor, 0.5) image] forState:UIControlStateHighlighted];
    learnMoreButton.layer.cornerRadius = 5;
    learnMoreButton.layer.masksToBounds = YES;
    [learnMoreButton addTarget:self action:@selector(showEvernoteHelper) forControlEvents:UIControlEventTouchUpInside];
    [learnMoreButton setTitle:@"LEARN MORE" forState:UIControlStateNormal];
    
    
    
    [tableFooter addSubview:learnMoreButton];
    
    [self.tableView setTableFooterView:tableFooter];
    
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger extraIfConnected = [kEnInt isAuthenticated] ? 3 : 0;
    return kEvernoteIntegration + 1 + extraIfConnected;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = indexPath.row > 0 ? @"SwitchCell" : @"SettingCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil && indexPath.row == 0) {
        SettingsCell *localCell = [[SettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        localCell.settingFont = KP_SEMIBOLD(16);
        localCell.leftPadding = 14;
        localCell.valueFont = KP_SEMIBOLD(16);
        // Configure the cell...
        cell = localCell;
    }
    else if ( cell == nil ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = CLEAR;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = CLEAR;
        cell.textLabel.font = KP_REGULAR(14);
        if(indexPath.row < 3){
            
            UISwitch *aSwitch = [[UISwitch alloc] init];
            aSwitch.tag = kSwitchTag;
            aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            CGRectSetCenter(aSwitch, cell.frame.size.width-aSwitch.frame.size.width + 5, kLocalCellHeight/2);
            [aSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:aSwitch];
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
	return cell;
}

-(void)switchChanged:(UISwitch*)sender{
    UITableViewCell *cell = (UITableViewCell*)sender.superview.superview.superview;
    NSIndexPath *switchHandled = [self.tableView indexPathForCell:cell];
    if(switchHandled.row == 1){
        [kEnInt setEnableSync:sender.on];
    }
    if(switchHandled.row == 2){
        [kEnInt setAutoFindFromTag:sender.on];
    }
}

-(NSString*)nameForIntegration:(Integrations)integration{
    NSString *name;
    switch (integration) {
        case kEvernoteIntegration:
            name = @"Evernote";
            break;
            
        default:
            break;
    }
    return name;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(SettingsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Integrations integration = indexPath.row;
    NSString *name = [self nameForIntegration:integration];
    NSString *valueString;
    switch (integration) {
        case kEvernoteIntegration:
            if([kEnInt isAuthenticated]){
                name = [name stringByAppendingString:@" (Connected)"];
                valueString = @"Unlink";
            }
            else
                valueString = @"Link account";
            break;
        default:break;
    }
    if(indexPath.row == 0)
        [cell setSetting:name value:valueString];
    if(indexPath.row > 0){
        UISwitch *aSwitch = (UISwitch*)[cell viewWithTag:kSwitchTag];
        if(indexPath.row == 1){
            cell.textLabel.text = @"Sync with Evernote on this device";
            aSwitch.on = kEnInt.enableSync;
        }
        if(indexPath.row == 2){
            aSwitch.on = kEnInt.autoFindFromTag;
            cell.textLabel.text = @"Auto import notes with \"swipes\"-tag";
        }
        if(indexPath.row == 3){
            cell.textLabel.text = @"Open Evernote Importer";
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLocalCellHeight;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)evernoteAuthenticateUsingSelector:(SEL)selector withObject:(id)object
{
    [kEnInt authenticateEvernoteInViewController:self withBlock:^(NSError *error) {
        if (error || !kEnInt.isAuthenticated) {
            // TODO show message to the user
            //NSLog(@"Session authentication failed: %@", [error localizedDescription]);
        }
        else {
            [self performSelectorOnMainThread:selector withObject:object waitUntilDone:NO];
        }
    }];
}

-(void)reload{
    [self.tableView reloadData];
}

-(void)authenticated{
    [self showEvernoteImporter];
    [self reload];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Integrations integration = indexPath.row;
    switch (integration) {
        case kEvernoteIntegration:{
            if(kEnInt.isAuthenticated){
                [UTILITY confirmBoxWithTitle:@"Unlink Evernote" andMessage:@"All tasks will be unlinked, are you sure?" block:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        [[EvernoteSession sharedSession] logout];
                        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                        
                        [KPToDo removeAllAttachmentsForAllToDosWithService:EVERNOTE_SERVICE inContext:context save:YES];
                        [self reload];
                    }
                }];
                
            }
            else{
                [self evernoteAuthenticateUsingSelector:@selector(authenticated) withObject:nil];
            }
            break;
        }
    }
    if(indexPath.row == 3){
        [self showEvernoteImporter];
    }
}
-(void)showEvernoteImporter{
    [self presentViewController:[[EvernoteImporterViewController alloc] init] animated:YES completion:^{
        
    }];
}
-(void)showEvernoteHelper{
    [self presentViewController:[[EvernoteHelperViewController alloc] init] animated:YES completion:^{
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
