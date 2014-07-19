//
//  EvernoteView.m
//  Swipes
//
//  Created by demosten on 1/20/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPBlurry.h"
#import "EvernoteViewerView.h"
#import "EvernoteIntegration.h"
#import "EvernoteView.h"
#import "UIColor+Utilities.h"
#import "SectionHeaderView.h"
#import "UtilityClass.h"
#import "CheckmarkButton.h"

#define kContentSpacingLeft 10
#define kContentSpacingRight 10
#define kContentTopBottomSpacing 70
#define kSearchBarHeight 46

#define kButtonWidth 44
#define kBottomBarHeight 60
#define kCheckmarkSize 44
#define kSearchTimerInterval 0.6
#define POPUP_WIDTH 300
#define MAX_HEIGHT 500
#define kEvernoteColor color(95,179,54,1)
#define kSearchLimit 10     // when _limitSearch is YES this is the limit

@interface EvernoteView () <UITableViewDataSource, UITableViewDelegate, EvernoteViewerViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic) UIView *contentView;
@property (nonatomic, strong) UITextField* searchBar;
@property (nonatomic, strong) UIButton* backButton;

@property (nonatomic, strong) EDAMNoteList* noteList;

@property (nonatomic, strong) EvernoteViewerView* viewer;
@property (nonatomic) CheckmarkButton *checkmark;

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
        
        CGFloat top = (OSVER >= 7) ? 20 : 0;
        
        
        CGFloat height = MIN(self.frame.size.height - top - 2*kContentTopBottomSpacing, MAX_HEIGHT);
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPUP_WIDTH, height)];
        contentView.autoresizesSubviews = YES;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        contentView.center = self.center;
        contentView.backgroundColor = kEvernoteColor;
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        
        
        CGFloat startX = 10;
        
        UIButton *loopButton = [[UIButton alloc] initWithFrame:CGRectMake(startX, 0, kSearchBarHeight, kSearchBarHeight)];
        loopButton.titleLabel.font = iconFont(23);
        [loopButton setTitle:iconString(@"actionSearch") forState:UIControlStateNormal];
        loopButton.backgroundColor = CLEAR;
        [loopButton setTitleColor:tcolorF(TextColor, ThemeDark) forState:UIControlStateNormal];
        [contentView addSubview:loopButton];
        
        UILabel *evernoteLabel = iconLabel(@"integrationEvernote", 25);
        evernoteLabel.textColor = tcolorF(TextColor, ThemeDark);
        CGFloat evernoteWidth = 50;
        CGFloat evernoteTopHack = 6;
        CGRectSetCenter(evernoteLabel, contentView.frame.size.width-evernoteWidth/2, kSearchBarHeight/2 + evernoteTopHack);
        
        [contentView addSubview:evernoteLabel];
        
        CGFloat searchX = CGRectGetMaxX(loopButton.frame);
        CGFloat searchWidth = CGRectGetMinX(evernoteLabel.frame) -searchX;
        
        self.searchBar = [[UITextField alloc] initWithFrame:CGRectMake(searchX, 0, searchWidth, kSearchBarHeight)];
        self.searchBar.font = KP_LIGHT(16);
        self.searchBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.searchBar.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSFontAttributeName: KP_LIGHT(16) , NSForegroundColorAttributeName: tcolorF(TextColor, ThemeDark)}];
        [contentView addSubview:self.searchBar];
        self.searchBar.delegate = self;
        self.searchBar.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.searchBar.returnKeyType = UIReturnKeyDone;
        [self.searchBar addTarget:self action:@selector(searchBar:textDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.searchBar.textColor = tcolorF(TextColor, ThemeDark);
        [self.searchBar addTarget:self
                            action:@selector(searchBarDidReturn:)
                  forControlEvents:UIControlEventEditingDidEndOnExit];

        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(kContentSpacingLeft, kSearchBarHeight, 320-kContentSpacingLeft-kContentSpacingRight, self.bounds.size.height - 2 * kSearchBarHeight ) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        self.tableView.backgroundColor = CLEAR;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [contentView addSubview:self.tableView];
        
        [self searchBar:_searchBar textDidChange:nil];
        
        SectionHeaderView *sectionHeader = [[SectionHeaderView alloc] initWithColor:alpha(tcolorF(TextColor, ThemeDark),0.6) font:KP_LIGHT(12) title:@"         " width:contentView.frame.size.width];
        CGRectSetY(sectionHeader, kSearchBarHeight);
        sectionHeader.fillColor = kEvernoteColor;
        sectionHeader.lineThickness = 2;
        [contentView addSubview:sectionHeader];
        
        
        CheckmarkButton *checkmarkButton = [[CheckmarkButton alloc] initWithFrame:CGRectMake(startX, 0, kSearchBarHeight, kSearchBarHeight)];
        checkmarkButton.backgroundColor = kEvernoteColor;
        checkmarkButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        checkmarkButton.selected = YES;
        CGRectSetY(checkmarkButton, CGRectGetHeight(contentView.frame) - kSearchBarHeight);
        
        [contentView addSubview:checkmarkButton];
        self.checkmark = checkmarkButton;
        
        UILabel *syncTasksLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(checkmarkButton.frame), CGRectGetMinY(checkmarkButton.frame), CGRectGetWidth(contentView.frame) - CGRectGetMaxX(checkmarkButton.frame)-kContentSpacingRight, kSearchBarHeight)];
        syncTasksLabel.backgroundColor = kEvernoteColor;
        syncTasksLabel.text = @"Sync tasks from Evernote";
        syncTasksLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        syncTasksLabel.textColor = tcolorF(TextColor, ThemeDark);
        syncTasksLabel.font = KP_REGULAR(14);
        [contentView addSubview:syncTasksLabel];
        
        // initiate the start lookup
        [self addSubview:contentView];
        self.contentView = contentView;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
        
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

-(void)searchBarDidReturn:(UITextField*)searchBar{
    [searchBar resignFirstResponder];
}


-(void)keyboardWillHide:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    NSInteger startPoint = (OSVER >= 7) ? 20 : 0;
    CGFloat height = MIN(self.frame.size.height - startPoint - 2*kContentTopBottomSpacing, MAX_HEIGHT);
    CGRectSetHeight(self.contentView, height);
    CGRectSetCenterY(self.contentView, self.bounds.size.height/2);
    [UIView commitAnimations];
}
-(void)keyboardWillShow:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    NSInteger spacing = 3;
    NSInteger startPoint = (OSVER >= 7) ? (20 + spacing) : spacing;
    CGFloat height = MIN(self.frame.size.height - keyboardHeight - startPoint- spacing, MAX_HEIGHT);
    CGRectSetHeight(self.contentView, height);
    CGFloat visibleSpace = self.frame.size.height - keyboardHeight - startPoint;
    CGRectSetCenterY(self.contentView,startPoint + visibleSpace / 2);
    
    [UIView commitAnimations];
}



- (void)cancel:(id)sender
{
    [_delegate closeEvernoteView:self];
}

- (void)evernoteAuthenticateUsingSelector:(SEL)selector withObject:(id)object
{
    [kEnInt authenticateEvernoteInViewController:_caller withBlock:^(NSError *error) {
        if (error || !kEnInt.isAuthenticated) {
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
    if (kEnInt.isAuthenticated) {
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
        filter.order = NoteSortOrder_UPDATED;
        filter.ascending = NO;
        // setup additional flags
        if (0 == _searchBar.text.length) { // remove this check if you want order to be always by UPDATED
            filter.words = @"todo:*";
        }
        @try {
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
                                       [UtilityClass sendError:error type:@"Evernote Filter Error"];
                                       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                       // failure... show error notification, etc
                                       if ([EvernoteSession isTokenExpiredWithError:error]) {
                                           // trigger auth again
                                           [self evernoteAuthenticateUsingSelector:@selector(searchNoteStore:) withObject:nil];
                                       }
                                   }
             ];
        }
        @catch (NSException *exception) {
            [UtilityClass sendException:exception type:@"Evernote Filter Exception"];
        }

        
    }
    else {
        NSLog(@"Session not authenticated");
        [self evernoteAuthenticateUsingSelector:@selector(searchNoteStore:) withObject:nil];
    }
}

- (void)searchBar:(UITextField *)searchBar textDidChange:(NSString *)searchText1
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
    cell.textLabel.textColor = tcolorF(TextColor,ThemeDark);
    cell.detailTextLabel.textColor = tcolorF(TextColor,ThemeDark);
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
        cell.detailTextLabel.font = KP_REGULAR(10);
        cell.detailTextLabel.textColor = tcolor(SubTextColor);
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    cell.accessoryView.tag = indexPath.row;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger index = indexPath.row;
    _selectedNote = _noteList.notes[index];
    if ([_searchBar isFirstResponder])
        [_searchBar resignFirstResponder];
    
    [_delegate selectedEvernoteInView:self guid:_selectedNote.guid title:_selectedNote.title sync:self.checkmark.selected];
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
    clearNotify();
    _tableView = nil;
    _searchBar = nil;
}

- (void)orientationChanged:(NSNotification *)notification{
    if(kIsIpad)
        [self cancel:self];
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
    [_delegate selectedEvernoteInView:self guid:_selectedNote.guid title:_selectedNote.title sync:self.checkmark.selected];
}

@end
