//
//  EvernoteImporterViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 20/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "UtilityClass.h"
#import "KPAttachment.h"
#import "EvernoteImporterViewController.h"
#define kPaginator 100

#define kTitleColor tcolorF(TextColor, ThemeDark)
#define kExistingTitleColor alpha(tcolorF(TextColor,ThemeLight),0.5)
#define kTopHeight 50
@interface EvernoteImporterViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) EDAMNoteList* noteList;
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

-(void)loadEvernoteWithCheckmarks{
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    
    EDAMNoteFilter* filter = [EDAMNoteFilter new];
    filter.words = @"todo:*";
    filter.order = NoteSortOrder_UPDATED;
    filter.ascending = NO;
    
    @try {
        [noteStore findNotesWithFilter:filter offset:0 maxNotes:kPaginator success:^(EDAMNoteList *list) {
            self.noteList = list;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
    @catch (NSException *exception) {
        
    }

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = self.noteList.notes.count;
    return result;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    EDAMNote* note = _noteList.notes[indexPath.row];
    
    NSArray *existingTasks = [KPAttachment findAttachmentsForService:EVERNOTE_SERVICE identifier:note.guid context:nil];
    UIColor *textColor = kTitleColor;
    if(existingTasks.count > 0){
        textColor = kExistingTitleColor;
    }
    cell.detailTextLabel.textColor = textColor;
    cell.textLabel.textColor = textColor;
    
    if (note.titleIsSet) {
        cell.textLabel.text = note.title;
    }
    else if (note.contentIsSet) {
        cell.textLabel.text = note.content;
    }
    else {
        cell.textLabel.text = @"Untitled";
    }
    NSDate *updatedAt = [NSDate dateWithTimeIntervalSince1970:note.updated/1000];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[UtilityClass readableTime:updatedAt showTime:YES]];
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
        
    }
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = tcolorF(BackgroundColor, ThemeDark);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    titleLabel.text = @"Find notes with checkmarks to import";
    titleLabel.numberOfLines = 0;
    titleLabel.font = KP_REGULAR(16);
    titleLabel.backgroundColor = CLEAR;
    titleLabel.textColor = tcolorF(TextColor,ThemeDark);
    [titleLabel sizeToFit];
    [self.view addSubview:titleLabel];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2*kTopHeight ) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.backgroundColor = kEvernoteColor;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UIView *bottomToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-kTopHeight, self.view.bounds.size.width, kTopHeight)];
    bottomToolbar.backgroundColor = tcolorF(BackgroundColor,ThemeDark);
    
    UIButton *importButton = [UIButton buttonWithType:UIButtonTypeCustom];
    importButton.layer.cornerRadius = 5;
    importButton.layer.borderWidth = 1;
    importButton.titleLabel.font = KP_REGULAR(14);
    importButton.layer.borderColor = tcolorF(TextColor, ThemeDark).CGColor;
    [importButton setTitleColor:tcolorF(TextColor, ThemeDark) forState:UIControlStateNormal];
    importButton.backgroundColor = CLEAR;
    CGFloat spacing = 8;
    CGFloat buttonWidth = bottomToolbar.frame.size.width/2 - 2*spacing;
    CGFloat buttonHeight = kTopHeight - 2*spacing;
    importButton.frame = CGRectMake(bottomToolbar.frame.size.width/2 + spacing, spacing, buttonWidth, buttonHeight);
    
    [bottomToolbar addSubview:importButton];
    
    self.importButton = importButton;
    
    [self.view addSubview:bottomToolbar];
    
    // Do any additional setup after loading the view.
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if([cell.textLabel.textColor isEqual:kExistingTitleColor]){
        [UTILITY confirmBoxWithTitle:@"This note is already in sync with a task" andMessage:@"Do you want to import it anyway? (Creates a duplicate)" block:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }];
        return nil;
    }
    return indexPath;
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
        [self.importButton setTitle:[NSString stringWithFormat:@"Import  %li  notes",(long)numberOfSelectedNotes] forState:UIControlStateNormal];
        self.importButton.alpha = 1.0;
    }else{
        [self.importButton setTitle:@"Import notes" forState:UIControlStateNormal];
        self.importButton.alpha = 0.3;

    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadEvernoteWithCheckmarks];
    [self updateButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
