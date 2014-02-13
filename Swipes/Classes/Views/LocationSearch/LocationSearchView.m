//
//  LocationSearchView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 12/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define SearchHeight 60
#import "LocationSearchView.h"
#import "LocationResultCell.h"
@interface LocationSearchView () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *searchResults;
@property (nonatomic) NSArray *historyResults;
@property (nonatomic) CLGeocoder *geoCoder;
@property (nonatomic) BOOL isSearching;
@end

@implementation LocationSearchView
#pragma mark Getters & Setters
-(CLGeocoder *)geoCoder{
    if(!_geoCoder)
        _geoCoder = [[CLGeocoder alloc] init];
    return _geoCoder;
}
-(NSArray *)searchResults{
    if(!_searchResults)
        _searchResults = [NSArray array];
    return _searchResults;
}
-(NSArray *)historyResults{
    if(!_historyResults)
        _historyResults = [NSArray array];
    return _historyResults;
}


+(NSString *)formattedAddressForPlace:(CLPlacemark *)place{
    NSArray *lines = place.addressDictionary[ @"FormattedAddressLines"];
    NSString *addressString = [lines componentsJoinedByString:@", "];
    return addressString;
}
#pragma mark UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.isSearching ? self.searchResults.count : self.historyResults.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"LocationResult";
    LocationResultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[LocationResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
	return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CLPlacemark *place = [self.searchResults objectAtIndex:indexPath.row];
    [cell.textLabel setText:[LocationSearchView formattedAddressForPlace:place]];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *locationArray = self.isSearching ? self.searchResults : self.historyResults;
    CLPlacemark *selectedPlace;
    if(locationArray.count > indexPath.row)
        selectedPlace = [locationArray objectAtIndex:indexPath.row];
    

    if(selectedPlace && [self.delegate respondsToSelector:@selector(locationSearchView:selectedLocation:)])
        [self.delegate locationSearchView:self selectedLocation:selectedPlace];
}
#pragma mark UITextFieldDelegate
-(void)textFieldDidChange:(UITextField*)textField{
    if(textField.text.length == 0){
        self.isSearching = NO;
        [self.tableView reloadData];
    }
    else{
        [self.geoCoder geocodeAddressString:textField.text inRegion:nil completionHandler:^(NSArray *placemarks, NSError *error) {
            if(self.searchField.text.length > 0){
                self.searchResults = placemarks;
                self.isSearching = (self.searchField.text > 0);
                [self.tableView reloadData];
            }
        }];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.placeholder = @"Type in location";
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    textField.placeholder = @"Type in location";
}
-(void)setIsSearching:(BOOL)isSearching{
    if(_isSearching != isSearching){
        _isSearching = isSearching;
        [self.headerView setTitle:(isSearching ? @"RESULTS " : @"RECENT ")];
    }
}
#pragma mark UIView stuff
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITextField *searchField = [[UITextField alloc] initWithFrame:self.bounds];
        CGFloat padding = 15;
        CGRectSetWidth(searchField,self.bounds.size.width-2*padding);
        CGRectSetX(searchField, padding);
        searchField.delegate = self;
        searchField.textColor = tcolor(TextColor);
        searchField.font = KP_LIGHT(16);
        searchField.placeholder = @"Type in location";
        @try {
            [searchField setValue:tcolor(TextColor) forKeyPath:@"_placeholderLabel.textColor"];
        }
        @catch (NSException *exception) {
            
        }
        
        [searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        CGRectSetHeight(searchField, SearchHeight);
        [self addSubview:searchField];
        self.searchField = searchField;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SearchHeight, self.bounds.size.width, self.bounds.size.height-SearchHeight)];
        tableView.backgroundColor = CLEAR;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.autoresizesSubviews = (UIViewAutoresizingFlexibleHeight);
        tableView.delegate = self;
        tableView.dataSource = self;
        [self addSubview:tableView];
        self.tableView = tableView;
        
        self.headerView = [[SectionHeaderView alloc] initWithColor:tcolor(TextColor) font:SECTION_HEADER_FONT title:@"RECENT "];
        CGRectSetWidth(self.headerView, self.bounds.size.width);
        [self.headerView setNeedsDisplay];
        CGRectSetY(self.headerView, SearchHeight);
        [self addSubview:self.headerView];
        
        // Initialization code
    }
    return self;
}

@end
