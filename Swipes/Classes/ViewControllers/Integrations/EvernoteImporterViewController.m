//
//  EvernoteImporterViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 20/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <ENSDK/Advanced/ENSDKAdvanced.h>
#import "UtilityClass.h"
#import "KPAttachment.h"
#import "AnalyticsHandler.h"
#import "SlowHighlightIcon.h"
#import "EvernoteSyncHandler.h"
#import "SectionHeaderView.h"
#import "EvernoteIntegration.h"
#import "DejalActivityView.h"
#import "EvernoteImporterViewController.h"

#define kPaginator 100
#define kTopDarkColor alpha(tcolorF(TextColor, ThemeLight),0.8)
#define kTitleColor tcolorF(TextColor, ThemeDark)
#define kExistingTitleColor alpha(tcolorF(TextColor,ThemeLight),0.5)
#define kTopHeight 50

@interface EvernoteImporterViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* noteList;
@property (nonatomic) UIButton *selectAllButton;
@property (nonatomic) UIButton *importButton;

@end

@implementation EvernoteImporterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = self.noteList.count;
    return result;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 46;
//}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    ENSessionFindNotesResult* note = _noteList[indexPath.row];
    
    NSArray *existingTasks = [KPAttachment findAttachmentsForService:EVERNOTE_SERVICE identifier:[EvernoteIntegration ENNoteRefToNSString:note.noteRef] context:nil];
    UIColor *textColor = kTitleColor;
    if(existingTasks.count > 0){
        textColor = kExistingTitleColor;
    }
    cell.detailTextLabel.textColor = textColor;
    cell.textLabel.textColor = textColor;
    
    if (note.title && note.title.length > 0) {
        cell.textLabel.text = note.title;
    }
    else {
        cell.textLabel.text = @"Untitled note";
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[UtilityClass readableTime:note.updated showTime:YES]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID =@"evernote_cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
        cell.textLabel.font = KP_REGULAR(15);
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.detailTextLabel.font = KP_REGULAR(10);
        cell.detailTextLabel.textColor = tcolor(SubTextColor);
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = kEvernoteColor;
        cell.contentView.backgroundColor = kEvernoteColor;
        cell.textLabel.textColor = tcolorF(TextColor,ThemeDark);
        cell.detailTextLabel.textColor = tcolorF(TextColor,ThemeDark);
        
        UIView *selectedView = [[UIView alloc] initWithFrame:cell.bounds];
        selectedView.backgroundColor = alpha(tcolorF(BackgroundColor, ThemeDark),0.2);
        cell.selectedBackgroundView = selectedView;
        
    }
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kEvernoteColor;
    CGFloat top = 20;
    
    UILabel *iconLabel = iconLabel(@"integrationEvernoteFull", kTopHeight/1.8);
    CGRectSetCenter(iconLabel, self.view.bounds.size.width/2, top + kTopHeight/2);
    iconLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    iconLabel.textColor = kTopDarkColor;
    [self.view addSubview:iconLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, top, self.view.bounds.size.width, kTopHeight)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    titleLabel.text = @"EVERNOTE            IMPORTER";
    titleLabel.numberOfLines = 0;
    titleLabel.font = KP_SEMIBOLD(15);
    titleLabel.backgroundColor = CLEAR;
    titleLabel.textColor = kTopDarkColor;
    //[titleLabel sizeToFit];
    //CGRectSetWidth(titleLabel, self.view.bounds.size.width);
    [self.view addSubview:titleLabel];
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopHeight+top, self.view.bounds.size.width, self.view.bounds.size.height - 2*kTopHeight - top ) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    //self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.backgroundColor = CLEAR;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 46;
    [self.view addSubview:self.tableView];
    
    /*UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    tableHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tableHeader.backgroundColor = CLEAR;
    
    UILabel *getStartedLabel = [[UILabel alloc] initWithFrame:tableHeader.bounds];
    getStartedLabel.textAlignment = NSTextAlignmentCenter;
    getStartedLabel.backgroundColor = CLEAR;
    getStartedLabel.textColor = tcolorF(TextColor, ThemeLight);
    getStartedLabel.font = KP_REGULAR(14);
    getStartedLabel.numberOfLines = 0;
    
    getStartedLabel.text = @"Quickly get started - import your notes";
    
    [tableHeader addSubview:getStartedLabel];
    [self.tableView setTableHeaderView:tableHeader];*/
    
    
    UIView *bottomToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-kTopHeight, self.view.bounds.size.width, kTopHeight)];
    bottomToolbar.backgroundColor = tcolorF(BackgroundColor,ThemeDark);
    bottomToolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin);
    bottomToolbar.layer.masksToBounds = YES;
    
    UIButton *closeButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, top, kTopHeight, kTopHeight)];
    closeButton.titleLabel.font = iconFont(23);
    [closeButton setTitleColor:tcolorF(TextColor, ThemeLight) forState:UIControlStateNormal];
    [closeButton setTitle:iconString(@"plusThick") forState:UIControlStateNormal];
    [closeButton setTitle:iconString(@"plusThick") forState:UIControlStateHighlighted];
    closeButton.transform = CGAffineTransformMakeRotation(M_PI/2/2);
    //closeButton.transform = CGAffineTransformMakeRotation(M_PI/4);
    closeButton.backgroundColor = CLEAR;
    [closeButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UIButton *importButton = [UIButton buttonWithType:UIButtonTypeCustom];
    importButton.layer.cornerRadius = 5;
    importButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    importButton.layer.borderWidth = 1;
    importButton.titleLabel.font = KP_REGULAR(14);
    importButton.layer.borderColor = tcolorF(TextColor, ThemeDark).CGColor;
    [importButton setTitleColor:tcolorF(TextColor, ThemeDark) forState:UIControlStateNormal];
    [importButton addTarget:self action:@selector(pressedImport:) forControlEvents:UIControlEventTouchUpInside];
    importButton.backgroundColor = CLEAR;
    CGFloat spacing = 8;
    CGFloat buttonWidth = 320/2 - 2*spacing;
    CGFloat buttonHeight = kTopHeight - 2*spacing;
    //bottomToolbar.frame.size.width - spacing - buttonWidth
    importButton.frame = CGRectMake(spacing, spacing, buttonWidth, buttonHeight);
    
    [bottomToolbar addSubview:importButton];
    
    self.importButton = importButton;
    
    [self.view addSubview:bottomToolbar];
    
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

-(void)pressedClose:(UIButton*)button{
    [ANALYTICS popView];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)pressedImport:(UIButton*)button{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    if(selectedIndexPaths.count == 0)
        return;
    NSMutableArray *notesToImport = [NSMutableArray array];
    for( NSIndexPath *indexPath in selectedIndexPaths ){
        ENSessionFindNotesResult *note = _noteList[indexPath.row];
        [notesToImport addObject:note];
    }
    [DejalBezelActivityView activityViewForView:self.view withLabel:LOCALIZE_STRING(@"Importing...")];
    [EvernoteSyncHandler addAndSyncNewTasksFromNotes:notesToImport withArray:nil];
    [DejalBezelActivityView removeViewAnimated:YES];
    [UTILITY alertWithTitle:LOCALIZE_STRING(@"Successfully imported.") andMessage:LOCALIZE_STRING(@"Next time, assign the \"swipes\"-tag in Evernote and we'll import the notes automatically.") buttonTitles:@[LOCALIZE_STRING(@"Great! I got it.")] block:nil];
    [self pressedClose:nil];
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if([cell.textLabel.textColor isEqual:kExistingTitleColor]){
        __block EvernoteImporterViewController *strongSelf = self;
        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"This note has already been imported.") andMessage:LOCALIZE_STRING(@"Do you want to duplicate it?") block:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                [strongSelf.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [strongSelf updateButtons];
            }
        }];
        return nil;
    }
    return indexPath;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *title = [LOCALIZE_STRING(@"notes with checkmarks") uppercaseString];
    UIFont *font = SECTION_HEADER_FONT;
    SectionHeaderView *sectionHeader = [[SectionHeaderView alloc] initWithColor:kTopDarkColor
                                                                           font:font title:title width:tableView.frame.size.width];
    sectionHeader.fillColor = kEvernoteColor;
    sectionHeader.textColor = kTopDarkColor;
    return sectionHeader;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateButtons];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self updateButtons];
}

-(void)updateButtons{
    NSInteger numberOfSelectedNotes = [self.tableView indexPathsForSelectedRows].count;
    if(numberOfSelectedNotes > 0){
        [self.importButton setTitle:[NSString stringWithFormat:LOCALIZE_STRING(@"Import  %li  notes"),(long)numberOfSelectedNotes] forState:UIControlStateNormal];
        self.importButton.alpha = 1.0;
    }else{
        [self.importButton setTitle:LOCALIZE_STRING(@"Import notes") forState:UIControlStateNormal];
        self.importButton.alpha = 0.3;

    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [GlobalApp activityIndicatorVisible:YES];
    [kEnInt findNotesWithSearch:@"todo:*" block:^(NSArray *findNotesResults, NSError *error) {
        if (findNotesResults) {
            if (findNotesResults.count == 0) {
                [UTILITY alertWithTitle:LOCALIZE_STRING(@"Couldn't find any notes with Checkmarks") andMessage:LOCALIZE_STRING(@"You can add notes manually under each tasks from Swipes as well")];
            }
            self.noteList = findNotesResults;
            [self.tableView reloadData];
            [GlobalApp activityIndicatorVisible:NO];
        }
    }];
    
    [self updateButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
