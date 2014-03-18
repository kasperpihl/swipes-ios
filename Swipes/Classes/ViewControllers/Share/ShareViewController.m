//
//  ShareViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 17/03/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <MessageUI/MFMessageComposeViewController.h>
#import "ContactHandler.h"


#import "ShareViewController.h"


@interface ShareViewController () <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *contacts;
@end

@implementation ShareViewController

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = bodyOfMessage;
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }    
}
-(void)sendMail:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients{
    
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    if (result == MessageComposeResultCancelled)
        NSLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        NSLog(@"Message sent");
    else
        NSLog(@"Message failed");
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID =@"contact_cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    APContact* contact = self.contacts[indexPath.row];
    NSString *name = @"";
    if (contact.firstName)
        name = [name stringByAppendingString:contact.firstName];
    if(contact.lastName){
        if(name.length > 0) name = [name stringByAppendingString:@" "];
        name = [name stringByAppendingString:contact.lastName];
    }
    cell.textLabel.text = name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APContact* contact = self.contacts[indexPath.row];
    [self sendSMS:@"Woohoo" recipientList:contact.emails];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [kContacts loadContactsWithBlock:^(NSArray *contacts, NSError *error) {
        if(contacts){
            self.contacts = contacts;
            [self.tableView reloadData];
        }
        else{
            
        }
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
   /* self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = tcolor(TextColor);
    self.navigationController.navigationBar.backgroundColor = tcolor(BackgroundColor);
    self.navigationController.navigationBar.translucent = NO;*/
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
