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
#import "EvernoteHelperViewController.h"
#import "EvernoteImporterViewController.h"
#import "EvernoteIntegration.h"
#import "IntegrationsViewController.h"

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
    
    
    
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return kEvernoteIntegration + 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = indexPath.row > 0 ? @"SwitchCell" : @"SettingCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil && indexPath.row == 0) {
        SettingsCell *localCell = [[SettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        localCell.settingFont = KP_SEMIBOLD(18);
        localCell.valueFont = KP_SEMIBOLD(16);
        // Configure the cell...
        cell = localCell;
    }
    else if ( cell == nil ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = CLEAR;
        cell.backgroundColor = CLEAR;
        UISwitch *aSwitch = [[UISwitch alloc] init];
        aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        CGRectSetCenter(aSwitch, cell.frame.size.width-aSwitch.frame.size.width, kCellHeight/2);
        [aSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.textLabel.font = KP_REGULAR(16);
        [cell.contentView addSubview:aSwitch];
        
    }
	return cell;
}

-(void)switchChanged:(UISwitch*)sender{
    
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
            if([[EvernoteSession sharedSession] isAuthenticated]){
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
        if(indexPath.row == 1){
            cell.textLabel.text = @"Enable Evernote Sync";
        }
        if(indexPath.row == 2)
            cell.textLabel.text = @"Auto import with \"swipes\"-tag";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
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
                [self evernoteAuthenticateUsingSelector:@selector(reload) withObject:nil];
            }
            break;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self presentViewController:[[EvernoteHelperViewController alloc] init] animated:YES completion:^{
        
    }];
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
