//
//  EvernoteView.m
//  Swipes
//
//  Created by demosten on 1/20/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPBlurry.h"
#import "EvernoteViewerView.h"
#import "EvernoteView.h"

#define kContentSpacingLeft 0
#define kContentSpacingRight 0
#define kSearchBarHeight 44
#define kSearchTimerInterval 2.0

@interface EvernoteView () <UITableViewDataSource, UITableViewDelegate, EvernoteViewerViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) EDAMNoteList* noteList;

@property (nonatomic, strong) EvernoteViewerView* viewer;

@end

@implementation EvernoteView {
    NSTimer* _timer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = tbackground(BackgroundColor);
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(kContentSpacingLeft, 0, 320-kContentSpacingLeft-kContentSpacingRight, kSearchBarHeight)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"Search in Evernote notes";
        [self addSubview:_searchBar];

        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(kContentSpacingLeft, kSearchBarHeight, 320-kContentSpacingLeft-kContentSpacingRight, self.bounds.size.height - kSearchBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        // initiate the start lookup
        [self searchBar:_searchBar textDidChange:nil];
    }
    return self;
}

-(void)blurryWillShow:(KPBlurry *)blurry
{
    [_searchBar becomeFirstResponder];
}

-(void)blurryWillHide:(KPBlurry *)blurry
{
    if ([_searchBar isFirstResponder])
        [_searchBar resignFirstResponder];
}

- (void)evernoteAuthenticateUsingSelector:(SEL)selector withObject:(id)object
{
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:_caller completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            // TODO show message to the user
            NSLog(@"Session authentication failed: %@", [error localizedDescription]);
        }
        else {
            [self performSelectorOnMainThread:selector withObject:object waitUntilDone:NO];
        }
    }];
}

- (IBAction)searchNoteStore:(id)sender
{
    EvernoteSession *session = [EvernoteSession sharedSession];
    if (session.isAuthenticated) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
/*        [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
                            // success... so do something with the returned objects
                            NSLog(@"notebooks: %@", notebooks);
                        }
                        failure:^(NSError *error) {
                            // failure... show error notification, etc
                            if([EvernoteSession isTokenExpiredWithError:error]) {
                                // trigger auth again
                                // auth code is shown in the Authenticate section
                            }
                            NSLog(@"error %@", error);
                        }];*/
        
        EDAMNoteFilter* filter = [EDAMNoteFilter new];
        //filter.words = @"photo";
        filter.words = _searchBar.text;
        __block BOOL noteViewed = NO;
        [noteStore findNotesWithFilter:filter offset:0 maxNotes:10 success:^(EDAMNoteList *list) {
                for (EDAMNote* note in list.notes) {
                    DLog(@"Note title: %@, guid: %@", note.title, note.guid);
                    if (!noteViewed) {
                        noteViewed = YES;
                        [[EvernoteNoteStore noteStore] viewNoteInEvernote:note];
                    }
                }
                _noteList = list;
                [_tableView reloadData];
                
                //DLog(@"notebooks: %@", list);
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
            failure:^(NSError *error) {
                NSLog(@"error %@", error);
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                // failure... show error notification, etc
                if ([EvernoteSession isTokenExpiredWithError:error]) {
                    // trigger auth again
                    [self evernoteAuthenticateUsingSelector:@selector(searchNoteStore:) withObject:nil];
                }
            }
         ];
    }
    else {
        NSLog(@"Session not authenticated");
        [self evernoteAuthenticateUsingSelector:@selector(searchNoteStore:) withObject:nil];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText1
{
    if (nil != _timer) {
        [_timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:kSearchTimerInterval target:self selector:@selector(searchNoteStore:) userInfo:nil repeats:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _noteList.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID =@"evernote_cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    EDAMNote* note = _noteList.notes[indexPath.row];
    if (note.titleIsSet) {
        cell.textLabel.text = note.title;
    }
    else if (note.contentIsSet) {
        cell.textLabel.text = note.content;
    }
    else {
        cell.textLabel.text = @"Untitled";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EDAMNote* note = _noteList.notes[indexPath.row];
    NSLog(@"selected note with title: %@", note.title);
    [_delegate selectedEvernoteInView:self guid:note.guid title:note.title];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    EDAMNote* note = _noteList.notes[indexPath.row];
    if ([[EvernoteSession sharedSession] isEvernoteInstalled]) {
        [[EvernoteNoteStore noteStore] viewNoteInEvernote:note];
    }
    else {
        if ([_searchBar isFirstResponder])
            [_searchBar resignFirstResponder];
        _viewer = [[EvernoteViewerView alloc] initWithFrame:self.frame andGuid:note.guid];
        _viewer.delegate = self;
        [self addSubview:_viewer];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_searchBar isFirstResponder])
        [_searchBar resignFirstResponder];
}

-(void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _searchBar.delegate = nil;
    [_tableView removeFromSuperview];
    [_searchBar removeFromSuperview];
    _tableView = nil;
    _searchBar = nil;
}

- (void)onGetBack
{
    [_viewer removeFromSuperview];
    _viewer = nil;
}

@end
