//
//  KPFilter.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kFilter [KPFilter sharedInstance]

typedef enum {
    FilterSettingNone = 0,
    FilterSettingOn,
    FilterSettingOff
} FilterSetting;

@class KPFilter;
@protocol KPFilterDelegate <NSObject>
-(void)didUpdateFilter:(KPFilter*)filter;
@end

@interface KPFilter : NSObject
@property (nonatomic, readonly) BOOL isActive;
@property (nonatomic, strong) NSMutableArray *selectedTags;
@property (nonatomic, strong, readonly) NSString *searchString;
@property (nonatomic, weak) NSObject<KPFilterDelegate> *delegate;
@property (nonatomic) FilterSetting priorityFilter;
@property (nonatomic) FilterSetting recurringFilter;
@property (nonatomic) FilterSetting notesFilter;
@property (nonatomic) FilterSetting locationFilter;
+(KPFilter*)sharedInstance;
-(void)selectTag:(NSString*)tag;
-(void)deselectTag:(NSString*)tag;
-(void)searchForString:(NSString*)string;

-(void)clearAll;
-(NSString*)readableFilterWithResults:(NSInteger)results;
@end
