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
#import "DejalActivityView.h"
#import "EvernoteImporterViewController.h"
#import "EvernoteIntegration.h"
#import "EvernoteSyncHandler.h"
#import "IntegrationsViewController.h"

#ifdef EVERNOTE_BUSINESS
int const kCellCount = 5;
#else
int const kCellCount = 4;
#endif

#define kLocalCellHeight 55
#define kLearnMoreHeight 70

#define kLearnMoreButtonWidth 160
#define kLearnMoreButtonHeight 44

@interface IntegrationsViewController () <UITableViewDataSource,UITableViewDelegate, EvernoteHelperDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isEvernoteBusinessUser;

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
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.rowHeight = kLocalCellHeight;
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
    [learnMoreButton addTarget:self action:@selector(pressedLearnedMore) forControlEvents:UIControlEventTouchUpInside];
    [learnMoreButton setTitle:@"LEARN MORE" forState:UIControlStateNormal];
    
    _isEvernoteBusinessUser = kEnInt.isBusinessUser;
    
    [tableFooter addSubview:learnMoreButton];
    
    [self.tableView setTableFooterView:tableFooter];
    
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

-(void)pressedLearnedMore{
    [self showEvernoteHelperAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger extraIfConnected = [kEnInt isAuthenticated] ? kCellCount : 0;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = CLEAR;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = CLEAR;
        cell.textLabel.font = KP_REGULAR(14);
        cell.detailTextLabel.font = KP_REGULAR(11);
        if (indexPath.row < kCellCount) {
            
            UISwitch *aSwitch = [[UISwitch alloc] init];
            aSwitch.tag = indexPath.row;
            aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            CGRectSetCenter(aSwitch, cell.frame.size.width-aSwitch.frame.size.width + 5, kLocalCellHeight/2);
            [aSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:aSwitch];
            
            if(indexPath.row == 1) {
                aSwitch.on = kEnInt.enableSync;
            }
            else if(indexPath.row == 2) {
                aSwitch.on = kEnInt.autoFindFromTag;
            }
            else if(indexPath.row == 3) {
                aSwitch.on = kEnInt.findInPersonalLinked;
            }
#ifdef EVERNOTE_BUSINESS
            else if(indexPath.row == 4) {
                if (_isEvernoteBusinessUser) {
                    aSwitch.on = kEnInt.findInBusinessNotebooks;
                }
                else {
                    //aSwitch.on = NO;
                    //aSwitch.enabled = NO;
                    [aSwitch removeFromSuperview];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
#endif
            
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
	return cell;
}

-(void)switchChanged:(UISwitch*)sender{
    NSInteger tag = sender.tag;
    if(tag == 1){
        [kEnInt setEnableSync:sender.on];
    }
    else if(tag == 2){
        [kEnInt setAutoFindFromTag:sender.on];
    }
    else if(tag == 3){
        [kEnInt setFindInPersonalLinked:sender.on];
    }
#ifdef EVERNOTE_BUSINESS
    else if(tag == 4){
        [kEnInt setFindInBusinessNotebooks:sender.on];
    }
#endif
    
    if (sender.on) {
        [[KPCORE evernoteSyncHandler] setUpdatedAt:nil];
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
        cell.textLabel.textColor = tcolor(TextColor);
        cell.detailTextLabel.textColor = tcolor(SubTextColor);
        if(indexPath.row == 1){
            cell.textLabel.text = @"Sync with Evernote on this device";
        }
        else if(indexPath.row == 2){
            cell.textLabel.text = @"Auto import notes with \"swipes\"-tag";
        }
        else if(indexPath.row == 3){
            cell.textLabel.text = @"Sync with personal linked notebooks";
        }
#ifdef EVERNOTE_BUSINESS
        else if(indexPath.row == 4){
            if (_isEvernoteBusinessUser)
                cell.textLabel.text = @"Sync with Evernote Business";
            else {
                cell.textLabel.text = @"Sync with Evernote Business";
                cell.detailTextLabel.text = @"Tap to learn more";
            }
        }
#endif

        else if(indexPath.row == kCellCount){
            cell.textLabel.text = @"Open Evernote Importer";
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)evernoteAuthenticateUsingSelector:(SEL)selector withObject:(id)object
{
    [DejalBezelActivityView activityViewForView:self.parentViewController.view withLabel:@"Opening Evernote.."];
    [kEnInt authenticateEvernoteInViewController:self withBlock:^(NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
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
    [UTILITY alertWithTitle:@"Get started" andMessage:@"Import a few notes right away." buttonTitles:@[@"Not now",@"Choose notes"] block:^(NSInteger number, NSError *error) {
        if(number == 1){
            [self showEvernoteImporterAnimated:YES];
        }
    }];
    [self reload];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Integrations integration = indexPath.row;
    switch (integration) {
        case kEvernoteIntegration:{
            if(kEnInt.isAuthenticated){
                [UTILITY confirmBoxWithTitle:@"Unlink Evernote" andMessage:@"All tasks will be unlinked, are you sure?" block:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [kEnInt logout];
                        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
                        
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
#ifdef EVERNOTE_BUSINESS
    if (indexPath.row == 4) {
        if (!_isEvernoteBusinessUser) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://swipesapp.com/evernote-business/"]];
        }
    }
#endif
    if (indexPath.row == kCellCount) {
        [self showEvernoteImporterAnimated:YES];
    }
}

-(void)endedEvernoteHelperSuccessfully:(BOOL)success{
    if(success && !kEnInt.isAuthenticated){
        [self evernoteAuthenticateUsingSelector:@selector(authenticated) withObject:nil];
    }
}

-(void)openHelperForIntegration:(Integrations)integration{
    switch (integration) {
        case kEvernoteIntegration:
            [self showEvernoteHelperAnimated:NO];
            break;
    }
}

-(void)showEvernoteImporterAnimated:(BOOL)animated{
    [self presentViewController:[[EvernoteImporterViewController alloc] init] animated:animated completion:^{
        
    }];
}
-(void)showEvernoteHelperAnimated:(BOOL)animated{
    EvernoteHelperViewController *helper = [[EvernoteHelperViewController alloc] init];
    helper.delegate = self;
    [self presentViewController:helper animated:animated completion:^{
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

@end
