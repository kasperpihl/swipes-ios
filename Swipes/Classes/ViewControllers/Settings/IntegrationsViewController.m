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
    
    
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 300)];
    tableFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tableFooter.backgroundColor = CLEAR;
    CGFloat padding = 10;
    UITextView *tutorialView = [[UITextView alloc] initWithFrame:CGRectMake(padding, 0, tableFooter.frame.size.width- 2*padding, tableFooter.frame.size.height)];
    tutorialView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tutorialView.backgroundColor = CLEAR;
    tutorialView.editable = NO;
    tutorialView.scrollEnabled = NO;
    tutorialView.font = KP_REGULAR(18);
    tutorialView.textColor = tcolor(TextColor);
    
    //tutorialView.text = @"Swipes Evernote integration enables you to attach a note in Swipes, and sync all checkmarks from Evernote directly into Swipes as Action Steps and back.\r\n\r\n1. Add a task in Swipes\r\n2. Open it and press the Elephant\r\n3. Select the note you want to sync\r\n4. Now all checkmarks will be synced back and forth";
    NSString *evernoteIconString = @"editEvernote";
    NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] init];
    NSArray *lines = @[
                       @"This integration lets you sync notes and checkmarks from Evernote into Swipes.",
                       @"",
                       @"Get started:",
                       @"",
                       @"1. Create a task in Swipes\r\n",
                       [NSString stringWithFormat:@"2. Double tap to open it > press the %@",evernoteIconString],
                       @"",
                       @"3. Select the note you want to sync",
                       @"",
                       @"Checkmarks now sync as action steps in Swipes. Complete them and they’ll sync back."
                       ];
    NSInteger counter = 0;
    for( NSString *line in lines){
        counter++;
        NSInteger length = line.length;
        NSMutableAttributedString *attributedLine = [[NSMutableAttributedString alloc] initWithString:line];
        [attributedLine appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n"]];
        NSDictionary *attributes;
        if(counter >= 5 && counter <= 9){
            NSInteger fontSize = 16;
            attributes = @{ NSFontAttributeName: KP_SEMIBOLD(fontSize), NSForegroundColorAttributeName: tcolor(TextColor)};
            if(counter == 6){
                length -= evernoteIconString.length;
                [attributedLine addAttributes:@{ NSFontAttributeName: iconFont(18), NSForegroundColorAttributeName: tcolor(TextColor) } range:NSMakeRange(length, evernoteIconString.length)];
                
            }
            
        }
        else
            attributes = @{ NSFontAttributeName: KP_REGULAR(18), NSForegroundColorAttributeName: tcolor(TextColor)};
        [attributedLine addAttributes:attributes range:NSMakeRange(0, length)];
        [mutableAttributed appendAttributedString:attributedLine];
    }
    tutorialView.attributedText = mutableAttributed;
    [tutorialView sizeToFit];
    CGRectSetCenterX(tutorialView, tableFooter.frame.size.width/2);
    [tableFooter addSubview:tutorialView];
    
    UIImageView *integrationImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipesandevernote"]];
    CGRectSetY(integrationImage, CGRectGetMaxY(tutorialView.frame));
    CGRectSetCenterX(integrationImage, tableFooter.frame.size.width/2);
    [tableFooter addSubview:integrationImage];
    CGRectSetHeight(tableFooter, CGRectGetMaxY(integrationImage.frame));
    
    [self.tableView setTableFooterView:tableFooter];
    
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return kEvernoteIntegration + 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"SettingCell";
    SettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.settingFont = KP_SEMIBOLD(18);
        cell.valueFont = KP_SEMIBOLD(16);
    }
	return cell;
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
    [cell setSetting:name value:valueString];
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
    [self presentViewController:[[EvernoteImporterViewController alloc] init] animated:YES completion:^{
        
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
