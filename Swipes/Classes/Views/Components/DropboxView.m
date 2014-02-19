//
//  DropboxView.m
//  Swipes
//
//  Created by demosten on 2/5/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import "KPBlurry.h"
#import "DropboxView.h"

#define kContentSpacingLeft 0
#define kContentSpacingRight 0
#define kContentSpacingTop 20
#define kSearchBarHeight 44
#define kButtonWidth 44
#define kSearchTimerInterval 1.0

// dropbox creedentials
static NSString *const DROPBOX_APP_KEY = @"qe70emp12gapr4c";
static NSString *const DROPBOX_APP_SECRET = @"aam88evbe0x4zev";

static NSString *const KEY_THUMBNAIL_READY = @"thumbnailReady";
static NSString *const KEY_THUMBNAIL_PATH = @"path";

static const NSInteger g_thumbSize = 80; // this is retina size
static const NSInteger g_maxRetries = 5;

static NSUInteger g_thumbnailCounter = 0;

@interface DropboxView () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, DBRestClientDelegate, DBNetworkRequestDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) UIButton* backButton;
@property (nonatomic, strong) DBRestClient* restClient;

@end

@implementation DropboxView {
    DBMetadata* _metadata;
    NSArray* _sortedMetadata;
    NSArray* _searchResults;
    NSCache* _pathToTempThumbnails;
    NSCache* _tempToPathThumbnails;
    BOOL _isRoot;
    
    NSArray* _listSortDescriptors;
    NSArray* _searchSortDescriptors;
    
    NSTimer* _timer;
    NSInteger _retryCount;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = tcolor(BackgroundColor);
        
        CGFloat top = (OSVER >= 7) ? [Global statusBarHeight] : 0.f;
        
        // initialize controls
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _backButton.frame = CGRectMake(kContentSpacingLeft, top, kButtonWidth, kSearchBarHeight);
        [_backButton setTitle:@" < " forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(kContentSpacingLeft + kButtonWidth, top, 320 -kButtonWidth - kContentSpacingLeft -kContentSpacingRight, kSearchBarHeight)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"Search in Dropbox";
        [self addSubview:_searchBar];

        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(kContentSpacingLeft, kSearchBarHeight + top, 320-kContentSpacingLeft-kContentSpacingRight, self.bounds.size.height - kSearchBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinked:) name:@"dropboxLinked" object:nil];
        
        // folder listing sort Folders first > file names > modification date
        _listSortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"isDirectory" ascending:NO],
                                 [[NSSortDescriptor alloc] initWithKey:@"filename" ascending:YES]];
        //                           [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO]]; // another option
        
        // search result sort order path > last modified date ... can be changed
        _searchSortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"path" ascending:NO],
                                   [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO]];
        
        _useThumbnails = NO; // default
        _pathToTempThumbnails = [[NSCache alloc] init];
        _tempToPathThumbnails = [[NSCache alloc] init];
        
        //Initialize the Dropbox session.
        DBSession* dbSession = [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY appSecret:DROPBOX_APP_SECRET root:kDBRootDropbox];
        [DBSession setSharedSession:dbSession];
        
        [DBRequest setNetworkRequestDelegate:self];
        
        [self performSelectorOnMainThread:@selector(authenticateWithDropbox) withObject:nil waitUntilDone:NO];
    }
    return self;
}

- (DBRestClient *)restClient
{
    if (nil == _restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
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
    [_delegate closeDropboxView:self];
}

#pragma mark - Authentication

- (void)authenticateWithDropbox
{
    // test code, user account unlink
//    if ([[DBSession sharedSession] isLinked]) {
//        [[DBSession sharedSession] unlinkAll];
//    }
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:_caller];
    }
    else {
        [self getFilesForPath:@"/"];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_delegate closeDropboxView:self];
}

- (void)dropboxLinked:(id)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSNumber *linkedNum = [[notification userInfo] objectForKey:@"linked"];
    
    if (![linkedNum boolValue]) {
        // FIXME: is this the best way?
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error."
                                                        message:@"Failed to login to Dropbox."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self getFilesForPath:@"/"];
    }
}

#pragma mark - Dropbox delegate and helpers

- (void)getFilesForPath:(NSString *)path
{
    NSString* hash = (nil != _metadata) ? _metadata.hash : nil;
    [self.restClient loadMetadata:path withHash:hash];
}

- (CGSize)getBoundedSize:(CGSize)originalSize forWidth:(NSInteger)width height:(NSInteger)height
{
    CGFloat desiredWidth;
    CGFloat desiredHeight;
    
    if(originalSize.width > originalSize.height) {
        desiredWidth = width;
        desiredHeight = 1./(originalSize.width/desiredWidth) * originalSize.height;
        
    }
    else if(originalSize.width < originalSize.height) {
        desiredHeight = height;
        desiredWidth = 1./(originalSize.height/desiredHeight) * originalSize.width;
    }
    else {
        desiredWidth = width;
        desiredHeight = height;
    }
    
    return CGSizeMake(desiredWidth, desiredHeight);
}

- (UIImage *)requestThumbnailItem:(DBMetadata *)item
{
    if (_useThumbnails && item.thumbnailExists) {
        NSDictionary* data = [_pathToTempThumbnails objectForKey:item.path];
        if (nil == data) { // do not repeat requests
            // Create file name. Another option would be to URL encode path and use it as a file name.
            // however this might be risky because we could hit some file system path length limitation
            NSString *pathComponent = [NSString stringWithFormat:@"dbox_thumb%u", g_thumbnailCounter++];
            if (g_thumbnailCounter > 10000) {
                // reset the counter to save space
                g_thumbnailCounter = 0;
            }
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:pathComponent];
            
            [_pathToTempThumbnails setObject:[NSMutableDictionary dictionaryWithDictionary:@{KEY_THUMBNAIL_READY : @(NO), KEY_THUMBNAIL_PATH : path}] forKey:item.path];
            [_tempToPathThumbnails setObject:item.path forKey:path];
            [self.restClient loadThumbnail:item.path ofSize:@"iphone_bestfit" intoPath:path];
        }
        else {
            if ([[data valueForKey:KEY_THUMBNAIL_READY] boolValue]) {
                
                UIImage *thumbnail = [UIImage imageWithContentsOfFile:[data valueForKey:KEY_THUMBNAIL_PATH]];
                if (nil != thumbnail) {
                    CGSize desiredSize = [self getBoundedSize:thumbnail.size forWidth:g_thumbSize height:g_thumbSize];
                    CGSize itemSize = CGSizeMake(g_thumbSize, g_thumbSize);
                    
                    UIGraphicsBeginImageContext(itemSize);
                    CGFloat scale = [UIScreen mainScreen].scale;
                    CGRect imageRect = CGRectMake(ceil(g_thumbSize / scale - desiredSize.width / scale),
                                                  ceil(g_thumbSize / scale - desiredSize.height / scale),
                                                  desiredSize.width,
                                                  desiredSize.height);
                    
                    [thumbnail drawInRect:imageRect];
                    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    return result;
                }
            }
        }
    }
    return nil;
}

// try to provide best image for item
- (UIImage *)imageForItem:(DBMetadata *)item
{
    UIImage* image = [self requestThumbnailItem:item]; // if there is downloaded thumbnail image - gets it, otherwise request thumbnail if available
    if (nil == image) {
        image = [UIImage imageNamed:item.icon];
        if (nil == image) {
            image = [UIImage imageNamed:item.isDirectory ? @"folder" : @"page_white"]; // probably we should rename those
        }
    }
    return image;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    _metadata = metadata;
    _sortedMetadata = [_metadata.contents sortedArrayUsingDescriptors:_listSortDescriptors];
    _isRoot = [_metadata.path isEqualToString:@"/"];
    
    [self.tableView reloadData];
    _retryCount = 0;
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
    DLog(@"metadata is metadataUnchangedAtPath: %@", path);
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    DLog(@"error loading metadata: %@", error);
    if ([[DBSession sharedSession] isLinked] && (g_maxRetries > ++_retryCount)) {
        if (nil == _metadata) {
            [self getFilesForPath:@"/"];
        }
    }
}

- (void)restClient:(DBRestClient *)client loadedThumbnail:(NSString *)destPath
{
    //DLog(@"loaded thumbnail for path: %@", destPath);
    
    NSString* dbPath = [_tempToPathThumbnails objectForKey:destPath];
    if (nil != dbPath) {
        NSMutableDictionary* data = [_pathToTempThumbnails objectForKey:dbPath];
        if (nil != data) {
            data[KEY_THUMBNAIL_READY] = @(YES);
            // reload the cell
            if (nil != _searchResults) {
                for (NSUInteger i = 0; i < _searchResults.count; i++) {
                    DBMetadata* item = _searchResults[i];
                    if ([item.path isEqualToString:dbPath]) {
                        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    }
                }
            }
            else {
                for (NSUInteger i = 0; i < _sortedMetadata.count; i++) {
                    DBMetadata* item = _sortedMetadata[i];
                    if ([item.path isEqualToString:dbPath]) {
                        NSInteger correction = _isRoot ? 0 : 1;
                        NSArray* indexPaths = @[[NSIndexPath indexPathForRow:i + correction inSection:0]];
                        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    }
                }
            }
        }
    }
}

- (void)restClient:(DBRestClient *)client loadThumbnailFailedWithError:(NSError *)error
{
}


#pragma mark - DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
	outstandingRequests++;
	if (outstandingRequests == 1) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
	outstandingRequests--;
	if (outstandingRequests == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

#pragma mark - Search related stuff

- (void)restClient:(DBRestClient*)restClient loadedSearchResults:(NSArray*)results
           forPath:(NSString*)path keyword:(NSString*)keyword
// results is a list of DBMetadata * objects
{
    //DLog(@"searching: %@ for path: %@", keyword, path);
    _searchResults = [results sortedArrayUsingDescriptors:_searchSortDescriptors];
    [_tableView reloadData];
}

- (void)restClient:(DBRestClient*)restClient searchFailedWithError:(NSError*)error
{
    DLog(@"error searching: %@", error);
    _searchResults = nil;
    [_tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText1
{
    if (nil != _timer) {
        [_timer invalidate];
    }
    if (0 == _searchBar.text.length) {
        _searchResults = nil;
        [_tableView reloadData];
    }
    else {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kSearchTimerInterval target:self selector:@selector(searchDropbox:) userInfo:nil repeats:NO];
    }
}

- (void)searchDropbox:(id)sender
{
    if (0 < _searchBar.text.length) {
        [self.restClient searchPath:_metadata.path forKeyword:_searchBar.text];
    }
    else {
        _searchResults = nil;
        [_tableView reloadData];
    }
}

#pragma mark - table view fills

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil != _searchResults) {
        return _searchResults.count;
    }
    
    if (nil == _metadata)
        return 0;
    
    NSInteger result = _sortedMetadata.count;
    if (!_isRoot)
        result++;
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID =@"dropbox_cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
    }
    
    if (nil != _searchResults) {
        DBMetadata* item = _searchResults[indexPath.row];
        cell.textLabel.text = item.filename;
        cell.detailTextLabel.text = item.path;
        cell.imageView.image = [self imageForItem:item];
    }
    else {
        cell.detailTextLabel.text = nil;
        if (!_isRoot && (0 == indexPath.row)) {
            cell.textLabel.text = @".. (go back)";
            cell.imageView.image = [UIImage imageNamed:@"folder"]; // TODO make it "back" icon
        }
        else {
            NSInteger correction = _isRoot ? 0 : -1;
            DBMetadata* item = _sortedMetadata[indexPath.row + correction];
            cell.textLabel.text = item.filename;
            cell.imageView.image = [self imageForItem:item];
        }
    }
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isRoot && (0 == indexPath.row)) {
        // going back
        NSMutableArray* pathComponents = [NSMutableArray arrayWithArray:[_metadata.path pathComponents]];
        [pathComponents removeLastObject];
        [self getFilesForPath:[NSString pathWithComponents:pathComponents]];
    }
    else {
        NSInteger correction = _isRoot ? 0 : -1;
        DBMetadata* item = _sortedMetadata[indexPath.row + correction];
        if (item.isDirectory) {
            [self getFilesForPath:item.path];
        }
        else {
            [_delegate selectedFileInView:self path:item.path];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_searchBar isFirstResponder]) {
         [_searchBar resignFirstResponder];
    }
}

-(void)dealloc
{
    [_pathToTempThumbnails removeAllObjects];
    [_tempToPathThumbnails removeAllObjects];
    self.restClient.delegate = nil;
    _metadata = nil;
    _searchResults = nil;
    [self.restClient cancelAllRequests];
    self.restClient = nil;
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _searchBar.delegate = nil;
    [_tableView removeFromSuperview];
    [_searchBar removeFromSuperview];
    _tableView = nil;
    _searchBar = nil;
}

@end
