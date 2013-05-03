//
//  FilterHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPSearchBar.h"
#define FILTER [FilterHandler sharedInstance]
@interface FilterHandler : NSObject  <KPSearchBarDataSource>
@property (nonatomic,strong) NSArray *items;
@property (nonatomic,strong) NSArray *allTags;
@property (nonatomic,strong) NSArray *remainingTags;
@property (nonatomic,strong) NSMutableArray *selectedTags;
@property (nonatomic,strong) NSArray *sortedItems;

+(FilterHandler *)filterForItems:(NSArray*)items;
-(void)selectTag:(NSString*)tag;
-(void)deselectTag:(NSString*)tag;
-(void)clearAll;
@end
