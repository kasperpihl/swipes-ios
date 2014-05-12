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
#import "UIColor+Utilities.h"
#import "UtilityClass.h"

#define kContentSpacingLeft 0
#define kContentSpacingRight 0
#define kSearchBarHeight 52
#define kButtonWidth 44
#define kSearchTimerInterval 0.6
#define POPUP_WIDTH 315
#define kEvernoteColor color(95,179,54,1)
#define kSearchLimit 10     // when _limitSearch is YES this is the limit

@interface EvernoteView () <UITableViewDataSource, UITableViewDelegate, EvernoteViewerViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) UIButton* backButton;

@property (nonatomic, strong) EDAMNoteList* noteList;

@property (nonatomic, strong) EvernoteViewerView* viewer;

@end

@implementation EvernoteView {
    NSTimer* _timer;
    EDAMNote* _selectedNote;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        closeButton.frame = self.bounds;
        closeButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [self addSubview:closeButton];
        self.backgroundColor = CLEAR;
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPUP_WIDTH, POPUP_WIDTH)];
        contentView.autoresizesSubviews = YES;
        contentView.center = self.center;
        contentView.backgroundColor = kEvernoteColor;
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        
        CGFloat top = (OSVER >= 7) ? [Global statusBarHeight] : 0.f;
        /*// initialize controls
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(kContentSpacingLeft, top, kButtonWidth, kSearchBarHeight);
        [_backButton setImage:[UIImage imageNamed:timageStringBW(@"backarrow_icon")] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:_backButton];*/

        _searchBar = [[UISearchBar alloc] init];
        //[_searchBar setSearchFieldBackgroundImage:[kEvernoteColor image] forState:UIControlStateNormal];
        _searchBar.frame = CGRectMake(kContentSpacingLeft, top,
                                      320 - kButtonWidth - kContentSpacingLeft - kContentSpacingRight, kSearchBarHeight);
        _searchBar.delegate = self;
        _searchBar.backgroundColor = CLEAR;
        _searchBar.tintColor = CLEAR;
        _searchBar.barTintColor = [UIColor clearColor];
        NSString *placeholderText = @"Search";
        _searchBar.placeholder = placeholderText;
        _searchBar.translucent = NO;
        _searchBar.backgroundImage = [kEvernoteColor image];
        _searchBar.scopeBarBackgroundImage = [kEvernoteColor image];
        if(OSVER >= 7){
            //[[_searchBar.subviews objectAtIndex:0] removeFromSuperview];
            _searchBar.searchBarStyle = UISearchBarStyleProminent;
            
            //_searchBar.tintColor = tcolorF(TextColor,ThemeDark);
            for (UIView *view in _searchBar.subviews)
            {
                for(UITextField *img in view.subviews){
                    if ([img isKindOfClass:NSClassFromString(@"UITextField")])
                    {
                        img.backgroundColor = CLEAR;
                        [img setTextColor:tcolor(TextColor)];
                        if ([img respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                            UIColor *color = tcolorF(TextColor, ThemeDark);
                            
                            img.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName: color}];
                        } else {
                            NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
                            // TODO: Add fall-back code to set placeholder color.
                        }
                    }
                }
                
            }
        }
        else{
            for (id img in _searchBar.subviews)
            {
                if ([img isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
                {
                    [img removeFromSuperview];
                }
            }
        }
        [contentView addSubview:_searchBar];
        

        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(kContentSpacingLeft, kSearchBarHeight + top, 320-kContentSpacingLeft-kContentSpacingRight, self.bounds.size.height - kSearchBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = CLEAR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [contentView addSubview:_tableView];
        
        // initiate the start lookup
        [self searchBar:_searchBar textDidChange:nil];
        [self addSubview:contentView];
    }
    return self;
}

-(void)blurryWillShow:(KPBlurry *)blurry
{
    //[_searchBar becomeFirstResponder];
}

-(void)blurryWillHide:(KPBlurry *)blurry
{
    if ([_searchBar isFirstResponder])
        [_searchBar resignFirstResponder];
}

- (void)cancel:(id)sender
{
    [_delegate closeEvernoteView:self];
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
        DLog(@"running search");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
        
        EDAMNoteFilter* filter = [EDAMNoteFilter new];

        // Added a better working search term: http://dev.evernote.com/doc/articles/search_grammar.php
        if (_searchBar.text.length > 0){
            NSArray *words = [_searchBar.text componentsSeparatedByString:@" "];
            NSMutableString *searchTerm = [[NSMutableString alloc] init];
            for (NSString *word in words){
                NSString *trimmedString = [word stringByTrimmingCharactersInSet:
                                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (trimmedString.length > 0)
                    [searchTerm appendFormat:@"%@* ",trimmedString];
            }
            if (searchTerm.length > 0)
                filter.words = [searchTerm copy];
        }
        
        // setup additional flags
        if (0 == _searchBar.text.length) { // remove this check if you want order to be always by UPDATED
            filter.order = NoteSortOrder_UPDATED;
            filter.ascending = NO;
        }
        
        [noteStore findNotesWithFilter:filter offset:0 maxNotes:kSearchLimit
            success:^(EDAMNoteList *list) {
                for (EDAMNote* note in list.notes) {
                    DLog(@"Last update: %@",[NSDate dateWithTimeIntervalSince1970:note.updated/1000]);
                    DLog(@"Note title: %@, guid: %@", note.title, note.guid);
                    /*if (!noteViewed) {
                        noteViewed = YES;
                        [[EvernoteNoteStore noteStore] viewNoteInEvernote:note];
                    }*/
                }
                _noteList = list;
                //_limitSearch = (filter.order == NoteSortOrder_UPDATED);
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
    NSInteger result = _noteList.notes.count;
    return result;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = kEvernoteColor;
    cell.contentView.backgroundColor = kEvernoteColor;
    cell.textLabel.textColor = tcolor(TextColor);
    cell.detailTextLabel.textColor = tcolor(TextColor);
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.font = KP_REGULAR(11);
        cell.detailTextLabel.textColor = tcolor(SubTextColor);
        cell.accessoryType = UITableViewCellAccessoryNone;
        //UIButton *accessory = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonWidth)];
        //[accessory addTarget:self action:@selector(pressedAccessory:) forControlEvents:UIControlEventTouchUpInside];
       
        //cell.accessoryView = accessory;
        
    }
    cell.accessoryView.tag = indexPath.row;
    [(UIButton*)cell.accessoryView setImage:[UIImage imageNamed:timageStringBW(@"attach_icon")] forState:UIControlStateNormal];
    
    return cell;
}

-(void)pressedAccessory:(UIButton*)button{
    NSInteger index = button.tag;
    EDAMNote* note = _noteList.notes[index];
    NSLog(@"selected note with title: %@", note.title);
    [_delegate selectedEvernoteInView:self guid:note.guid title:note.title];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger index = indexPath.row;
    _selectedNote = _noteList.notes[index];
    if ([_searchBar isFirstResponder])
        [_searchBar resignFirstResponder];
    _viewer = [[EvernoteViewerView alloc] initWithFrame:self.frame andGuid:_selectedNote.guid];
    _viewer.delegate = self;
    [self addSubview:_viewer];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
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

#pragma mark - Evernote Viewer protocol implementation

- (void)onGetBack
{
    [_viewer removeFromSuperview];
    _viewer = nil;
}

- (void)onAttach
{
    [_viewer removeFromSuperview];
    _viewer = nil;
    [_delegate selectedEvernoteInView:self guid:_selectedNote.guid title:_selectedNote.title];
}

@end
